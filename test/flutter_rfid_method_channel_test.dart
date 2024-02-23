import 'package:flutter/services.dart';
import 'package:flutter_rfid/flutter_rfid_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterRfid platform = MethodChannelFlutterRfid();
  const MethodChannel channel = MethodChannel('flutter_rfid');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return Uint8List.fromList([0x90, 0x00]);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('transmit', () async {
    expect(
      await platform.transmit(Uint8List(8)),
      Uint8List.fromList([0x90, 0x00]),
    );
  });

  test('getAtr', () async {
    expect(
      await platform.getAtr(),
      Uint8List.fromList([0x90, 0x00]),
    );
  });
}
