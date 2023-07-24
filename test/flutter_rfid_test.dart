import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rfid/flutter_rfid.dart';
import 'package:flutter_rfid/flutter_rfid_platform_interface.dart';
import 'package:flutter_rfid/flutter_rfid_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterRfidPlatform
    with MockPlatformInterfaceMixin
    implements FlutterRfidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterRfidPlatform initialPlatform = FlutterRfidPlatform.instance;

  test('$MethodChannelFlutterRfid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterRfid>());
  });

  test('getPlatformVersion', () async {
    FlutterRfid flutterRfidPlugin = FlutterRfid();
    MockFlutterRfidPlatform fakePlatform = MockFlutterRfidPlatform();
    FlutterRfidPlatform.instance = fakePlatform;

    expect(await flutterRfidPlugin.getPlatformVersion(), '42');
  });
}
