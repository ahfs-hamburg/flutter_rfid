import 'package:flutter/services.dart';
import 'package:flutter_rfid/flutter_rfid_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCallbacks extends Mock {
  void onReaderConnected();
  void onReaderDisconnected();
  void onCardPresent();
  void onCardAbsent();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelFlutterRfid', () {
    late MethodChannelFlutterRfid platform;
    const MethodChannel channel = MethodChannel('flutter_rfid');
    late MockCallbacks mockCallbacks;

    setUp(() {
      platform = MethodChannelFlutterRfid();
      mockCallbacks = MockCallbacks();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'scanForReader':
            case 'scanForCard':
              return null;
            case 'transmit':
            case 'getAtr':
              return Uint8List.fromList([0x90, 0x00]);
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('scanForReader', () {
      test('scans for reader', () async {
        await platform.scanForReader();
      });
    });

    group('scanForCard', () {
      test('scans for card', () async {
        await platform.scanForCard();
      });
    });

    group('transmit', () {
      test('transmit', () async {
        expect(
          await platform.transmit(Uint8List(8)),
          Uint8List.fromList([0x90, 0x00]),
        );
      });
    });

    group('getAtr', () {
      test('getAtr', () async {
        expect(
          await platform.getAtr(),
          Uint8List.fromList([0x90, 0x00]),
        );
      });
    });

    group('onReaderConnected', () {
      test('callback is called', () async {
        platform.setOnReaderConnectedCallback(mockCallbacks.onReaderConnected);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onReaderConnected', null),
          ),
          (ByteData? data) {},
        );

        verify(() => mockCallbacks.onReaderConnected()).called(1);
      });
    });

    group('onReaderDisconnected', () {
      test('callback is called', () async {
        platform.setOnReaderDisconnectedCallback(
            mockCallbacks.onReaderDisconnected);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onReaderDisconnected', null),
          ),
          (ByteData? data) {},
        );

        verify(() => mockCallbacks.onReaderDisconnected()).called(1);
      });
    });

    group('onCardPresent', () {
      test('callback is called', () async {
        platform.setOnCardPresentCallback(mockCallbacks.onCardPresent);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onCardPresent', null),
          ),
          (ByteData? data) {},
        );

        verify(() => mockCallbacks.onCardPresent()).called(1);
      });
    });

    group('onCardAbsent', () {
      test('callback is called', () async {
        platform.setOnCardAbsentCallback(mockCallbacks.onCardAbsent);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(
            const MethodCall('onCardAbsent', null),
          ),
          (ByteData? data) {},
        );

        verify(() => mockCallbacks.onCardAbsent()).called(1);
      });
    });
  });
}
