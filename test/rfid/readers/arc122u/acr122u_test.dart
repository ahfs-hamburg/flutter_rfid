import 'dart:typed_data';
import 'dart:ui';

import 'package:dart_des/dart_des.dart';
import 'package:flutter_rfid/flutter_rfid_platform_interface.dart';
import 'package:flutter_rfid/readers/acr122u.dart';
import 'package:flutter_rfid/src/rfid/utils/conversion.dart';
import 'package:flutter_rfid/src/rfid/utils/generation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockedFlutterRfidPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterRfidPlatform {
  VoidCallback? onCardPresentCallback;

  @override
  void setOnCardPresentCallback(VoidCallback callback) {
    onCardPresentCallback = callback;
  }

  void callCardPresent() {
    onCardPresentCallback?.call();
  }
}

void main() {
  group('ACR122U', () {
    late MockedFlutterRfidPlatform platform;
    late ACR122U reader;

    setUpAll(() {
      registerFallbackValue(Uint8List(0));
    });

    setUp(() {
      platform = MockedFlutterRfidPlatform();
      FlutterRfidPlatform.instance = platform;
      reader = ACR122U();

      when(() => platform.transmit(any(
            that: isA<Uint8List>(),
          ))).thenAnswer(
        (invocation) => Future.value(Uint8List.fromList([0x90, 0x00])),
      );
      when(() => platform.getAtr()).thenAnswer((_) => Future.value(null));
    });

    group('constructor', () {
      test('initializes without error', () {
        expect(() => ACR122U(), returnsNormally);
      });

      test('disables green LED if specified', () async {
        ACR122U(disableGreenLed: true);
        platform.callCardPresent();

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x40, // p1
                int.parse(
                  '00001101',
                  radix: 2,
                ), // p2
                0x04, // data length
                0x00, // data[0]
                0x00, // data[1]
                0x00, // data[2]
                int.parse(
                  '00',
                  radix: 2,
                ), // data[3]
              ]),
            )).called(1);
      });

      test('disables buzzer if specified', () async {
        ACR122U(disableBuzzer: true);
        platform.callCardPresent();

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x52, // p1
                0x00, // p2
                0x00, // data length
              ]),
            )).called(1);
      });
    });

    group('authenticate', () {
      test('throws Exception for invalid blockNumber', () {
        expect(
          () => reader.authenticate(
            blockNumber: 0x04,
            key: List.generate(15, (index) => index),
          ),
          throwsException,
        );
      });

      test('completes authentication process successfully', () async {
        final key = List.generate(6, (index) => index);

        when(() => platform.transmit(
                  Uint8List.fromList([
                    0xFF, // classNumber
                    0x82, // instruction
                    0x00, // p1
                    0x00, // p2
                    key.length, // data length
                    ...key, // data
                  ]),
                ))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        when(() => platform.transmit(
                  Uint8List.fromList([
                    0xFF, // classNumber
                    0x86, // instruction
                    0x00, // p1
                    0x00, // p2
                    5, // data length
                    0x01, // data
                    0x00,
                    0x04, // data blocknumber
                    0x60,
                    0x00,
                  ]),
                ))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        await reader.authenticate(
          blockNumber: 0x04,
          key: key,
        );
      });
    });

    group('authenticate3DES', () {
      Future<Uint8List> cardResponse({
        required Uint8List data,
        required List<int> key,
        required List<int> b,
        int authenticationState = 0,
        bool invalidResponse = false,
      }) {
        final ekB = DES3(
          key: key,
          mode: DESMode.CBC,
          iv: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        ).encrypt(b).sublist(0, 8);

        if (!(data[0] == 0xFF && // classNumber
            data[1] == 0x00 && // instruction
            data[2] == 0x00 && // p1
            data[3] == 0x00)) {
          return Future.value(Uint8List.fromList([0x63, 0x00]));
        }

        if (invalidResponse) {
          return Future.value(
              Uint8List.fromList([0xAF, 0x00, 0x00, 0x00, 0x00, 0x90, 0x00]));
        }

        switch (authenticationState) {
          case 0:
            if (data[4] == 4 && // data length
                    data[5] == 0xD4 && // data[0]
                    data[6] == 0x42 && // data[1]
                    data[7] == 0x1A && // data[2]
                    data[8] == 0x00 // data[3]
                ) {
              authenticationState = 1;

              return Future.value(Uint8List.fromList(
                  [0xAF, 0x00, 0x00, 0x00, ...ekB, 0x90, 0x00]));
            }

            break;

          case 1:
            if (data[4] == 19 // data length
                ) {
              final ekABDash = data.sublist(8);

              final aBDash = DES3(
                key: key,
                mode: DESMode.CBC,
                iv: ekB,
              ).decrypt(ekABDash);

              final a = aBDash.sublist(0, 8);

              final aDash = rotateListData(a, 1);

              final ekADash = DES3(
                key: key,
                mode: DESMode.CBC,
                iv: ekABDash.sublist(8),
              ).encrypt(aDash).sublist(0, 8);

              authenticationState = 2;

              return Future.value(Uint8List.fromList(
                  [0x00, 0x00, 0x00, 0x00, ...ekADash, 0x90, 0x00]));
            }

            break;
        }

        return Future.value(Uint8List.fromList([0x63, 0x00]));
      }

      late int authenticationState;
      late List<int> b;

      setUp(() {
        authenticationState = 0;
        b = getRandomBytes(length: 8);
      });

      test('completes authentication process successfully', () async {
        final key = List<int>.generate(24, (index) => index);

        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) {
            final Uint8List data =
                invocation.positionalArguments.first as Uint8List;

            final response = cardResponse(
              data: data,
              key: key,
              b: b,
              authenticationState: authenticationState,
            );

            authenticationState++;

            return response;
          },
        );

        try {
          await reader.authenticate3DES(key: key);
        } catch (e) {
          fail('Authentication failed with exception: $e');
        }
      });

      test('throws Exception for invalid first response', () async {
        final key = List<int>.generate(24, (index) => index);

        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) {
            final Uint8List data =
                invocation.positionalArguments.first as Uint8List;

            final response = cardResponse(
              data: data,
              key: key,
              b: b,
              authenticationState: authenticationState,
              invalidResponse: true,
            );

            authenticationState++;

            return response;
          },
        );

        expect(
          reader.authenticate3DES(
            key: key,
          ),
          throwsException,
        );
      });

      test('throws Exception for invalid second response', () async {
        final key = List<int>.generate(24, (index) => index);

        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) {
            final Uint8List data =
                invocation.positionalArguments.first as Uint8List;

            final response = cardResponse(
              data: data,
              key: key,
              b: b,
              authenticationState: authenticationState,
              invalidResponse: authenticationState == 1,
            );

            authenticationState++;

            return response;
          },
        );

        expect(
          reader.authenticate3DES(
            key: key,
          ),
          throwsException,
        );
      });

      test('throws Exception for invalid key', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) {
            final Uint8List data =
                invocation.positionalArguments.first as Uint8List;

            final response = cardResponse(
              data: data,
              key: List<int>.generate(24, (index) => index + 1),
              b: b,
              authenticationState: authenticationState,
            );

            authenticationState++;

            return response;
          },
        );

        expect(
          reader.authenticate3DES(
            key: List<int>.generate(24, (index) => index),
          ),
          throwsException,
        );
      });
    });

    group('readBlock', () {
      test('reads block successfully', () async {
        when(() => platform.transmit(
                  Uint8List.fromList([
                    0xFF, // classNumber
                    0xB0, // instruction
                    0x00, // p1
                    0x04, // p2
                    0x04, // output length
                  ]),
                ))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        expect(
            await reader.readBlock(
              blockNumber: 0x04,
              length: 0x04,
            ),
            isA<List<int>>());

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0xB0, // instruction
                0x00, // p1
                0x04, // p2
                0x04, // output length
              ]),
            )).called(1);
      });
    });

    group('writeBlock', () {
      test('writes block successfully', () async {
        when(() => platform.transmit(
                  Uint8List.fromList([
                    0xFF, // classNumber
                    0xD6, // instruction
                    0x00, // p1
                    0x04, // p2
                    0x04, // data length
                    0x00, // data[0]
                    0x01, // data[1]
                    0x02, // data[2]
                    0x03, // data[3]
                  ]),
                ))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        await reader.writeBlock(
          blockNumber: 0x04,
          data: Uint8List.fromList([0x00, 0x01, 0x02, 0x03]),
        );

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0xD6, // instruction
                0x00, // p1
                0x04, // p2
                0x04, // data length
                0x00, // data[0]
                0x01, // data[1]
                0x02, // data[2]
                0x03, // data[3]
              ]),
            )).called(1);
      });
    });

    group('getFirmwareVersion', () {
      test('sends the correct APDU', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) => Future.value(Uint8List.fromList([0x90, 0x00])),
        );

        await reader.getFirmwareVersion();

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x48, // p1
                0x00, // p2
                0x00, // data length
              ]),
            )).called(1);
      });

      test('returns the correct firmware version', () async {
        when(() => platform.transmit(any(
                  that: isA<Uint8List>(),
                )))
            .thenAnswer((_) => Future.value(Uint8List.fromList(
                [0x41, 0x43, 0x52, 0x31, 0x32, 0x32, 0x55, 0x32, 0x30, 0x31])));

        expect(await reader.getFirmwareVersion(), equals('ACR122U201'));
      });
    });

    group('controlLedBuzzer', () {
      test('throws Exception for invalid t1Duration', () {
        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: -1, // Invalid value
            t2Duration: 100,
            repetitions: 1,
          ),
          throwsException,
        );

        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 50, // Invalid value
            t2Duration: 100,
            repetitions: 1,
          ),
          throwsException,
        );

        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 0x100, // Invalid value
            t2Duration: 100,
            repetitions: 1,
          ),
          throwsException,
        );
      });

      test('throws Exception for invalid t2Duration', () {
        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 100,
            t2Duration: -1, // Invalid value
            repetitions: 1,
          ),
          throwsException,
        );

        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 100,
            t2Duration: 50, // Invalid value
            repetitions: 1,
          ),
          throwsException,
        );

        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 100,
            t2Duration: 0x100, // Invalid value
            repetitions: 1,
          ),
          throwsException,
        );
      });

      test('throws Exception for invalid repetitions', () {
        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 100,
            t2Duration: 100,
            repetitions: -1, // Invalid value
          ),
          throwsException,
        );

        expect(
          reader.controlLedBuzzer(
            redInitialState: true,
            greenInitialState: false,
            t1Duration: 100,
            t2Duration: 100,
            repetitions: 0x100, // Invalid value
          ),
          throwsException,
        );
      });

      test('sends the correct APDU', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) => Future.value(Uint8List.fromList([0x90, 0x00])),
        );

        await reader.controlLedBuzzer(
          redInitialState: true,
          greenInitialState: false,
          redFinalState: true,
          greenFinalState: false,
          t1Duration: 100,
          t2Duration: 200,
          repetitions: 5,
          redBlinking: true,
          greenBlinking: true,
          buzzerT1: false,
          buzzerT2: false,
        );

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x40, // p1
                int.parse(
                  '11011101',
                  radix: 2,
                ), // p2
                0x04, // data length
                0x01, // data[0]
                0x02, // data[1]
                0x05, // data[2]
                int.parse(
                  '00',
                  radix: 2,
                ), // data[3]
              ]),
            )).called(1);
      });

      test('returns the correct LED state', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) => Future.value(Uint8List.fromList([0x90, 0x01])),
        );

        final result = await reader.controlLedBuzzer(
          redInitialState: true,
          greenInitialState: false,
          redFinalState: true,
          greenFinalState: false,
          t1Duration: 100,
          t2Duration: 200,
          repetitions: 5,
          redBlinking: true,
          greenBlinking: true,
          buzzerT1: false,
          buzzerT2: false,
        );

        expect(result.red, isTrue);
        expect(result.green, isFalse);
      });
    });

    group('setBuzzerOnDetection', () {
      test('sends the correct APDU', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) => Future.value(Uint8List.fromList([0x90, 0x00])),
        );

        await reader.setBuzzerOnDetection(enabled: true);

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x52, // p1
                0xFF, // p2
                0x00, // data length
              ]),
            )).called(1);
      });
    });

    group('transmitDirect', () {
      test('sends the correct APDU', () async {
        when(() => platform.transmit(any(
              that: isA<Uint8List>(),
            ))).thenAnswer(
          (invocation) => Future.value(Uint8List.fromList([0x90, 0x00])),
        );

        await reader.transmitDirect(
          data: Uint8List.fromList([0x12]),
        );

        verify(() => platform.transmit(
              Uint8List.fromList([
                0xFF, // classNumber
                0x00, // instruction
                0x00, // p1
                0x00, // p2
                0x01, // data length
                0x12, // data
              ]),
            )).called(1);
      });
    });
  });
}
