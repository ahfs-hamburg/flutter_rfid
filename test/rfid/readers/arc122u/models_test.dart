import 'package:flutter_rfid/src/rfid/readers/acr122u/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LedState', () {
    test('LedState should correctly initialize with red and green values', () {
      // Test for both red and green LEDs on
      var ledStateOn = LedState(red: true, green: true);
      expect(ledStateOn.red, isTrue);
      expect(ledStateOn.green, isTrue);

      // Test for both red and green LEDs off
      var ledStateOff = LedState(red: false, green: false);
      expect(ledStateOff.red, isFalse);
      expect(ledStateOff.green, isFalse);

      // Test for red on and green off
      var redOnGreenOff = LedState(red: true, green: false);
      expect(redOnGreenOff.red, isTrue);
      expect(redOnGreenOff.green, isFalse);

      // Test for red off and green on
      var redOffGreenOn = LedState(red: false, green: true);
      expect(redOffGreenOn.red, isFalse);
      expect(redOffGreenOn.green, isTrue);
    });
  });
}
