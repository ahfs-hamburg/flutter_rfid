import 'package:flutter_rfid/src/rfid/core/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RFIDException', () {
    test('should have the correct error message', () {
      final exception = RFIDException('Test message');
      expect(exception.toString(), 'RFIDException: Test message');
    });
  });

  group('InvalidBlockException', () {
    test('should have the correct error message', () {
      final exception = InvalidBlockException('Test detail');
      expect(exception.toString(), 'RFIDException: Invalid block: Test detail');
    });
  });

  group('InvalidDataException', () {
    test('should have the correct error message', () {
      final exception = InvalidDataException('Test detail');
      expect(exception.toString(), 'RFIDException: Invalid data: Test detail');
    });
  });

  group('AuthenticationException', () {
    test('should have the correct error message', () {
      final exception = AuthenticationException('Test detail');
      expect(exception.toString(),
          'RFIDException: Authentication failed: Test detail');
    });
  });
}
