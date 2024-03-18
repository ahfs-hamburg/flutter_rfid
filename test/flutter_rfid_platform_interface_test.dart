import 'dart:typed_data';

import 'package:flutter_rfid/flutter_rfid_method_channel.dart';
import 'package:flutter_rfid/flutter_rfid_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterRfidPlatform extends FlutterRfidPlatform with Mock {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterRfidPlatform', () {
    test('default instance is of type MethodChannelFlutterRfid', () {
      expect(FlutterRfidPlatform.instance, isA<MethodChannelFlutterRfid>());
    });

    test('can be overridden with mock', () {
      final mock = MockFlutterRfidPlatform();
      FlutterRfidPlatform.instance = mock;

      expect(FlutterRfidPlatform.instance, isA<MockFlutterRfidPlatform>());
    });

    test('unimplemented methods throw UnimplementedError', () {
      final mock = MockFlutterRfidPlatform();
      FlutterRfidPlatform.instance = mock;

      expect(() => mock.scanForReader(), throwsUnimplementedError);
      expect(() => mock.scanForCard(), throwsUnimplementedError);
      expect(() => mock.transmit(Uint8List(0)), throwsUnimplementedError);
      expect(() => mock.getAtr(), throwsUnimplementedError);
      expect(() => mock.setOnReaderConnectedCallback(() {}),
          throwsUnimplementedError);
      expect(() => mock.setOnReaderDisconnectedCallback(() {}),
          throwsUnimplementedError);
      expect(
          () => mock.setOnCardPresentCallback(() {}), throwsUnimplementedError);
      expect(
          () => mock.setOnCardAbsentCallback(() {}), throwsUnimplementedError);
    });
  });
}
