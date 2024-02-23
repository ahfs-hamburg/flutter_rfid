import 'package:flutter_rfid/src/rfid/protocols/adpu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApduHeader', () {
    test('Correctly initializes and converts to list', () {
      // Example values for testing
      const testClassNumber = 0xA0;
      const testInstruction = 0xB1;
      const testP1 = 0xC2;
      const testP2 = 0xD3;

      // Create an instance of ApduHeader with the test values
      final header = ApduHeader(
        classNumber: testClassNumber,
        instruction: testInstruction,
        p1: testP1,
        p2: testP2,
      );

      // Verify that the properties match the inputs
      expect(header.classNumber, equals(testClassNumber));
      expect(header.instruction, equals(testInstruction));
      expect(header.p1, equals(testP1));
      expect(header.p2, equals(testP2));

      // Verify the toList method output
      expect(header.toList(),
          equals([testClassNumber, testInstruction, testP1, testP2]));
    });

    test('Handles edge values correctly', () {
      const edgeValue = 0xFF;
      final header = ApduHeader(
        classNumber: edgeValue,
        instruction: edgeValue,
        p1: edgeValue,
        p2: edgeValue,
      );

      expect(header.toList(),
          equals([edgeValue, edgeValue, edgeValue, edgeValue]));
    });

    test('Handles zero values correctly', () {
      const zeroValue = 0x00;
      final header = ApduHeader(
        classNumber: zeroValue,
        instruction: zeroValue,
        p1: zeroValue,
        p2: zeroValue,
      );

      expect(header.toList(),
          equals([zeroValue, zeroValue, zeroValue, zeroValue]));
    });
  });

  group('ApduResponse', () {
    test('Correctly initializes data, sw1, and sw2', () {
      // Example data for testing
      final testData = [0x01, 0x02, 0x03];
      const testSw1 = 0x90;
      const testSw2 = 0x00;

      // Create an instance of ApduResponse with the test data
      final response = ApduResponse(
        data: testData,
        sw1: testSw1,
        sw2: testSw2,
      );

      // Verify that the properties match the inputs
      expect(response.data, equals(testData));
      expect(response.sw1, equals(testSw1));
      expect(response.sw2, equals(testSw2));
    });
  });
}
