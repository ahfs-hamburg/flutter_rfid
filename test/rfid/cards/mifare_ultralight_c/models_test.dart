import 'package:flutter_rfid/src/rfid/cards/mifare_ultralight_c/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthLock', () {
    test('fromInt returns correct AuthLock for valid values', () {
      expect(AuthLock.fromInt(0x01), AuthLock.write);
      expect(AuthLock.fromInt(0x00), AuthLock.readWrite);
    });

    test('fromInt throws for invalid values', () {
      expect(() => AuthLock.fromInt(0xFF), throwsException);
    });
  });

  group('AuthConfig', () {
    test('can be instantiated with valid parameters', () {
      final config = AuthConfig(startingBlock: 4, lock: AuthLock.write);
      expect(config.startingBlock, 4);
      expect(config.lock, AuthLock.write);
    });
  });
}
