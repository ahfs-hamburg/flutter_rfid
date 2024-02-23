import 'package:flutter_rfid/src/rfid/core/card_manufacturer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardManufacturer Enum Tests', () {
    test('CardManufacturer values should have correct properties', () {
      // Test for Motorola
      expect(CardManufacturer.Motorola.id, 0x01);
      expect(CardManufacturer.Motorola.company, 'Motorola');
      expect(CardManufacturer.Motorola.country, 'UK');

      // Test for STMicroelectronics
      expect(CardManufacturer.STMicroelectronics.id, 0x02);
      expect(
          CardManufacturer.STMicroelectronics.company, 'STMicroelectronics SA');
      expect(CardManufacturer.STMicroelectronics.country, 'France');

      // Test for HitachiLtd
      expect(CardManufacturer.HitachiLtd.id, 0x03);
      expect(CardManufacturer.HitachiLtd.company, 'Hitachi, Ltd');
      expect(CardManufacturer.HitachiLtd.country, 'Japan');
    });

    test('CardManufacturer should have the correct number of entries', () {
      expect(CardManufacturer.values.length, greaterThan(100));
    });

    test('returns correct CardManufacturer for valid IDs', () {
      expect(CardManufacturer.fromInt(0x01), CardManufacturer.Motorola);
      expect(
          CardManufacturer.fromInt(0x02), CardManufacturer.STMicroelectronics);
      expect(CardManufacturer.fromInt(0x03), CardManufacturer.HitachiLtd);
    });

    test('throws Exception for invalid ID', () {
      expect(() => CardManufacturer.fromInt(0xFF), throwsA(isA<Exception>()));
    });

    // Add more tests if your enum has more functionality
  });
}
