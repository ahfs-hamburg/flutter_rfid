import 'package:flutter_rfid/src/rfid/utils/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateByte', () {
    test('should not throw for a valid byte', () {
      expect(() => validateByte(0x7F), returnsNormally);
    });

    test('should throw for a byte below 0x00', () {
      expect(() => validateByte(-1), throwsException);
    });

    test('should throw for a byte above 0xFF', () {
      expect(() => validateByte(0x100), throwsException);
    });

    test('should not throw for the lower boundary (0x00)', () {
      expect(() => validateByte(0x00), returnsNormally);
    });

    test('should not throw for the upper boundary (0xFF)', () {
      expect(() => validateByte(0xFF), returnsNormally);
    });
  });

  group('validateByteList', () {
    test('should not throw for a valid byte list', () {
      expect(() => validateByteList([0x00, 0x7F, 0xFF]), returnsNormally);
    });

    test('should throw for a list with a byte below 0x00', () {
      expect(() => validateByteList([0x00, -1, 0xFF]), throwsException);
    });

    test('should throw for a list with a byte above 0xFF', () {
      expect(() => validateByteList([0x00, 0x100, 0xFF]), throwsException);
    });

    test('should not throw for an empty list', () {
      expect(() => validateByteList([]), returnsNormally);
    });

    test('should perform efficiently with a large list of valid bytes', () {
      var largeList = List<int>.generate(1000, (i) => i % 256);
      expect(() => validateByteList(largeList), returnsNormally);
    });
  });
}
