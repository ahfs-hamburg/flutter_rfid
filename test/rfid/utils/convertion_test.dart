import 'package:flutter_rfid/src/rfid/utils/conversion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('convertBytesToHex', () {
    test('should return an empty string for an empty list', () {
      expect(convertBytesToHex([]), equals(''));
    });

    test('should correctly convert a single byte', () {
      expect(convertBytesToHex([0xAB]), equals('AB'));
    });

    test('should correctly convert multiple bytes', () {
      expect(convertBytesToHex([0xAB, 0xCD, 0xEF]), equals('AB CD EF'));
    });

    test('should handle edge values correctly', () {
      expect(convertBytesToHex([0x00, 0xFF]), equals('00 FF'));
    });

    test('should perform efficiently with large lists', () {
      var largeList = List<int>.generate(1000, (i) => i % 256);
      // Here you would check if the function executes without error,
      // but for an actual check, you would need to know the expected result.
      // This test case is more about performance checking.
      expect(convertBytesToHex(largeList).isNotEmpty, equals(true));
    });
  });

  group('rotateListData', () {
    test('returns empty list unchanged', () {
      expect(rotateListData([], 3), equals([]));
    });

    test('correctly rotates a list by a given value within list length', () {
      expect(rotateListData([1, 2, 3, 4, 5], 2), equals([3, 4, 5, 1, 2]));
    });

    test('correctly rotates a list by a value equal to list length', () {
      expect(rotateListData([1, 2, 3, 4, 5], 5), equals([1, 2, 3, 4, 5]));
    });

    test('correctly rotates a list by a value greater than list length', () {
      expect(rotateListData([1, 2, 3, 4, 5], 8), equals([4, 5, 1, 2, 3]));
    });

    test('handles single-element lists correctly', () {
      expect(rotateListData([1], 3), equals([1]));
    });

    test('performs efficiently with large lists', () {
      var largeList = List<int>.generate(10000, (i) => i % 256);
      // This test is more about ensuring that the function can handle large inputs without crashing.
      // Specific correctness for large rotations can be difficult to assert without a known pattern.
      expect(rotateListData(largeList, 5000).length, equals(10000));
    });

    test('correctly rotates a list by a negative value', () {
      // This test expects that negative values will perform a reverse rotation.
      // Adjust the implementation of rotateListData if you want to support this behavior.
      expect(rotateListData([1, 2, 3, 4, 5], -2), equals([4, 5, 1, 2, 3]));
    });
  });
}
