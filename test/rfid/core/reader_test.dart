import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_rfid/flutter_rfid_platform_interface.dart';
import 'package:flutter_rfid/src/rfid/core/reader.dart';
import 'package:flutter_rfid/src/rfid/protocols/adpu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockedFlutterRfidPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterRfidPlatform {
  VoidCallback? onReaderConnectedCallback;
  VoidCallback? onReaderDisconnectedCallback;
  VoidCallback? onCardPresentCallback;
  VoidCallback? onCardAbsentCallback;

  @override
  void setOnReaderConnectedCallback(VoidCallback callback) {
    onReaderConnectedCallback = callback;
  }

  @override
  void setOnReaderDisconnectedCallback(VoidCallback callback) {
    onReaderDisconnectedCallback = callback;
  }

  @override
  void setOnCardPresentCallback(VoidCallback callback) {
    onCardPresentCallback = callback;
  }

  @override
  void setOnCardAbsentCallback(VoidCallback callback) {
    onCardAbsentCallback = callback;
  }

  void callReaderConnected() {
    onReaderConnectedCallback?.call();
  }

  void callReaderDisconnected() {
    onReaderDisconnectedCallback?.call();
  }

  void callCardPresent() {
    onCardPresentCallback?.call();
  }

  void callCardAbsent() {
    onCardAbsentCallback?.call();
  }
}

class MockedReader extends RFIDReader with Mock {}

class MockCallbacks extends Mock {
  void onReaderConnected();
  void onReaderDisconnected();
  void onCardPresent();
  void onCardAbsent();
}

void main() {
  group('RFIDReader', () {
    late MockedFlutterRfidPlatform platform;
    late RFIDReader reader;
    late MockCallbacks mockCallbacks;

    setUpAll(() {
      registerFallbackValue(Uint8List(0));
    });

    setUp(() {
      platform = MockedFlutterRfidPlatform();
      FlutterRfidPlatform.instance = platform;
      reader = MockedReader();
      mockCallbacks = MockCallbacks();

      when(() => platform.getAtr()).thenAnswer((_) => Future.value(null));
    });

    group('transmitApdu', () {
      test('sends the correct APDU', () async {
        when(() => platform.transmit(any(
                  that: isA<Uint8List>(),
                )))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        await reader.transmitApdu(
          ApduHeader(
            classNumber: 0x00,
            instruction: 0x00,
            p1: 0x00,
            p2: 0x00,
          ),
          data: Uint8List.fromList([0x00]),
        );

        verify(() => platform.transmit(
              Uint8List.fromList([
                0x00, // classNumber
                0x00, // instruction
                0x00, // p1
                0x00, // p2
                0x01, // data length
                0x00, // data
              ]),
            ));
      });

      test('should return the response from the platform', () async {
        when(() => platform.transmit(any(
                  that: isA<Uint8List>(),
                )))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x90, 0x00])));

        final response = await reader.transmitApdu(
          ApduHeader(
            classNumber: 0x00,
            instruction: 0x00,
            p1: 0x00,
            p2: 0x00,
          ),
          data: Uint8List.fromList([0x00]),
        );

        expect(response.sw1, equals(0x90));
        expect(response.sw2, equals(0x00));
        expect(response.data, equals([]));
      });

      test('should throw an exception if the transmit fails', () async {
        when(() => platform.transmit(any(
                  that: isA<Uint8List>(),
                )))
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x63, 0x00])));

        try {
          await reader.transmitApdu(
            ApduHeader(
              classNumber: 0x00,
              instruction: 0xFF,
              p1: 0x00,
              p2: 0x00,
            ),
            data: Uint8List(0),
          );

          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), equals('Exception: Error: 99 0'));
        }
      });
    });

    group('getAtr', () {
      test('should return the ATR from the platform', () async {
        when(() => platform.getAtr())
            .thenAnswer((_) => Future.value(Uint8List.fromList([0x3B, 0x8F])));

        final atr = await reader.getAtr();

        expect(atr, equals(Uint8List.fromList([0x3B, 0x8F])));

        verify(() => platform.getAtr()).called(1);
      });

      test('should return null if the ATR is not available', () async {
        when(() => platform.getAtr()).thenAnswer((_) => Future.value(null));

        final atr = await reader.getAtr();

        expect(atr, isNull);

        verify(() => platform.getAtr()).called(1);
      });
    });

    group('onReaderConnectedCallback', () {
      test('should call the callback when the reader is connected', () {
        reader.addOnReaderConnectedCallback(mockCallbacks.onReaderConnected);

        verifyNever(() => mockCallbacks.onReaderConnected());

        platform.callReaderConnected();

        verify(() => mockCallbacks.onReaderConnected()).called(1);
      });

      test('should remove the callback when the reader is disconnected', () {
        reader.addOnReaderConnectedCallback(mockCallbacks.onReaderConnected);

        verifyNever(() => mockCallbacks.onReaderConnected());

        reader.removeOnReaderConnectedCallback(mockCallbacks.onReaderConnected);
        platform.callReaderConnected();

        verifyNever(() => mockCallbacks.onReaderConnected());
      });
    });

    group('onReaderDisconnectedCallback', () {
      test('should call the callback when the reader is disconnected', () {
        reader.addOnReaderDisconnectedCallback(
            mockCallbacks.onReaderDisconnected);

        verifyNever(() => mockCallbacks.onReaderDisconnected());

        platform.callReaderDisconnected();

        verify(() => mockCallbacks.onReaderDisconnected()).called(1);
      });

      test('should remove the callback when the reader is disconnected', () {
        reader.addOnReaderDisconnectedCallback(
            mockCallbacks.onReaderDisconnected);

        verifyNever(() => mockCallbacks.onReaderDisconnected());

        reader.removeOnReaderDisconnectedCallback(
            mockCallbacks.onReaderDisconnected);
        platform.callReaderDisconnected();

        verifyNever(() => mockCallbacks.onReaderDisconnected());
      });
    });

    group('onCardPresentCallback', () {
      test('should call the callback when a card is present', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardPresentCallback(callback);

        expect(callbackCalled, isFalse);

        platform.callCardPresent();

        expect(callbackCalled, isTrue);
      });

      test('should remove the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardPresentCallback(callback);

        expect(callbackCalled, isFalse);

        reader.removeOnCardPresentCallback(callback);
        platform.callCardPresent();

        expect(callbackCalled, isFalse);
      });
    });

    group('onCardAbsentCallback', () {
      test('should call the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardAbsentCallback(callback);

        expect(callbackCalled, isFalse);

        platform.callCardAbsent();

        expect(callbackCalled, isTrue);
      });

      test('should remove the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardAbsentCallback(callback);

        expect(callbackCalled, isFalse);

        reader.removeOnCardAbsentCallback(callback);
        platform.callCardAbsent();

        expect(callbackCalled, isFalse);
      });
    });

    group('isConnected', () {
      test('should return true if the reader is connected', () {
        platform.callReaderConnected();

        expect(reader.isConnected, isTrue);
      });

      test('should return false if the reader is not connected', () {
        expect(reader.isConnected, isFalse);
      });
    });

    group('isCardPresent', () {
      test('should return true if a card is present', () {
        platform.callCardPresent();

        expect(reader.isCardPresent, isTrue);
      });

      test('should return false if a card is not present', () {
        expect(reader.isCardPresent, isFalse);
      });
    });
  });
}
