import 'package:flutter_rfid/src/rfid/readers/acr122u/models.dart';
import 'package:flutter_rfid/src/rfid/readers/acr122u/picc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PiccOperatingParameter', () {
    group('fromByte', () {
      test('should correctly interpret the byte value', () {
        var params = PiccOperatingParameter.fromByte(0xFF);

        expect(params.autoPiccPolling, isTrue);
        expect(params.autoAtsGeneration, isTrue);
        expect(params.pollInterval, equals(PollInterval.ms250));
        expect(params.detectFeliCa424K, isTrue);
        expect(params.detectFeliCa212K, isTrue);
        expect(params.detectTopaz, isTrue);
        expect(params.detectIso14443TypeB, isTrue);
        expect(params.detectIso14443TypeA, isTrue);
      });
    });
  });
}
