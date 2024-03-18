import 'package:flutter_rfid/src/rfid/utils/generation.dart';
import 'package:flutter_rfid/src/rfid/utils/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getRandomBytes', () {
    test('should return an empty list for a length of 0', () {
      expect(getRandomBytes(length: 0), equals([]));
    });

    test('should return a list of the correct length', () {
      expect(getRandomBytes(length: 5).length, equals(5));
    });

    test('should return a list of random bytes', () {
      var bytes = getRandomBytes(length: 5);
      expect(bytes.every((byte) => byte >= 0 && byte <= 255), equals(true));
      expect(() => validateByteList(bytes), returnsNormally);
    });

    test('should perform efficiently with large lengths', () {
      expect(getRandomBytes(length: 10000).length, equals(10000));
    });
  });
}
