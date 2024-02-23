import 'package:flutter_rfid/cards/mifare_ultralight_c.dart';
import 'package:flutter_rfid/src/rfid/cards/mifare_ultralight_c/mifare_ultralight_c.dart';
import 'package:flutter_rfid/src/rfid/core/card_manufacturer.dart';
import 'package:flutter_rfid/src/rfid/core/exceptions.dart';
import 'package:flutter_rfid/src/rfid/core/reader.dart';
import 'package:flutter_test/flutter_test.dart';

class MockedReader extends RFIDReader {
  var data = List<int>.generate(
      ((MifareUltralightC.DATA_ADDRESS_END + 1) -
              MifareUltralightC.DATA_ADDRESS_START) *
          MifareUltralightC.BLOCK_SIZE,
      (index) => index);
  var serial = generateSerial(uid: [
    CardManufacturer.NXPSemiconductors.id,
    0x01,
    0x02,
    0x03,
    0x04,
    0x05,
    0x06
  ]);

  @override
  Future<List<int>> readBlock({
    required int blockNumber,
    required int length,
  }) {
    if (blockNumber == MifareUltralightC.SERIAL_NUMBER_ADDRESS_START) {
      return Future.value(serial);
    }

    final startIndex = (blockNumber - MifareUltralightC.DATA_ADDRESS_START) *
        MifareUltralightC.BLOCK_SIZE;

    return Future.value(
      data.sublist(startIndex, startIndex + length),
    );
  }

  @override
  Future<bool> writeBlock({
    required int blockNumber,
    required List<int> data,
  }) {
    final startIndex = (blockNumber - MifareUltralightC.DATA_ADDRESS_START) *
        MifareUltralightC.BLOCK_SIZE;

    // Update the specified block with the new data
    for (int i = 0; i < data.length; i++) {
      if (startIndex + i < this.data.length) {
        this.data[startIndex + i] = data[i];
      }
    }

    return Future.value(true);
  }

  @override
  Future<bool> authenticate({
    required int blockNumber,
    required List<int> key,
  }) {
    return Future.value(true);
  }

  @override
  Future<bool> authenticate3DES({
    required List<int> key,
  }) {
    return Future.value(true);
  }
}

List<int> generateSerial({
  required List<int> uid,
  bool validBcc0 = true,
  bool validBcc1 = true,
}) {
  List<int> serial = List<int>.filled(9, 0x00);

  final bcc0 = (validBcc0 ? 0x88 : 0x00) ^ uid[0] ^ uid[1] ^ uid[2];
  // final bcc1 = uid[3] ^ uid[4] ^ uid[5] ^ uid[6];
  final bcc1 = (validBcc1 ? 0x00 : 0x04) ^ uid[3] ^ uid[4] ^ uid[5] ^ uid[6];

  serial[0] = uid[0];
  serial[1] = uid[1];
  serial[2] = uid[2];
  serial[3] = bcc0;
  serial[4] = uid[3];
  serial[5] = uid[4];
  serial[6] = uid[5];
  serial[7] = uid[6];
  serial[8] = bcc1;

  return serial;
}

void main() {
  const BLOCK_SIZE = MifareUltralightC.BLOCK_SIZE;
  const DATA_ADDRESS_START = MifareUltralightC.DATA_ADDRESS_START;
  const DATA_ADDRESS_END = MifareUltralightC.DATA_ADDRESS_END;

  group('MifareUltralightC', () {
    late MockedReader reader;
    late MifareUltralightC card;

    setUp(() {
      reader = MockedReader();
      card = MifareUltralightC(reader: reader);
    });

    group('readData', () {
      test('should throw an exception if length is less than 0', () {
        expect(
          () async => await card.readData(blockNumber: 0x04, length: -1),
          throwsException,
        );
      });

      test('should throw an exception if length is greater than 16', () {
        expect(
          () async => await card.readData(blockNumber: 0x04, length: 17),
          throwsException,
        );
      });

      test('should throw an exception if block number is less than 0x04', () {
        expect(
          () async => await card.readData(blockNumber: 0x03, length: 4),
          throwsException,
        );

        expect(
          () async => await card.readData(blockNumber: 0x03, length: 8),
          throwsException,
        );
      });

      test('should throw an exception if block number is greater than 0x27',
          () {
        expect(
          () async => await card.readData(blockNumber: 0x28, length: 4),
          throwsException,
        );
      });

      test(
          'should throw an exception if block number + length is greater than 0x27',
          () {
        expect(
          () async => await card.readData(blockNumber: 0x27, length: 5),
          throwsException,
        );

        expect(
          () async => await card.readData(blockNumber: 0x26, length: 9),
          throwsException,
        );
      });

      test(
          'should read normally if block number + length is equal to 0x27 or less',
          () {
        expect(
          () async => await card.readData(blockNumber: 0x04, length: 4),
          returnsNormally,
        );

        expect(
          () async => await card.readData(blockNumber: 0x04, length: 8),
          returnsNormally,
        );

        expect(
          () async => await card.readData(blockNumber: 0x26, length: 8),
          returnsNormally,
        );
      });

      test('should return a list of input length', () async {
        expect(
          (await card.readData(blockNumber: 0x04, length: 4)),
          [0, 1, 2, 3],
        );

        expect(
          (await card.readData(blockNumber: 0x04, length: 5)),
          [0, 1, 2, 3, 4],
        );

        expect(
          (await card.readData(blockNumber: 0x04, length: 16)),
          List<int>.generate(16, (index) => index),
        );

        expect(
          (await card.readData(blockNumber: 0x26, length: 8)),
          List<int>.generate(8, (index) => index + (0x26 - 0x04) * 4),
        );
      });
    });

    group('readLongData', () {
      test('should throw an exception if length is less than 0', () {
        expect(
          () async => await card.readLongData(blockNumber: 0x04, length: -1),
          throwsException,
        );
      });

      // Assuming there's a maximum length that readLongData can handle, e.g., based on memory limits
      test('should throw an exception if length exceeds maximum allowed length',
          () {
        expect(
          () async => await card.readLongData(
              blockNumber: 0x04, length: 1025), // Example maximum length
          throwsException,
        );
      });

      test(
          'should throw an exception if block number is less than allowed start',
          () {
        expect(
          () async => await card.readLongData(blockNumber: 0x03, length: 16),
          throwsException,
        );
      });

      test('should throw an exception if request exceeds memory bounds', () {
        expect(
          () async => await card.readLongData(blockNumber: 0x26, length: 32),
          throwsException,
        );
      });

      test(
          'should read normally for valid block numbers and lengths within bounds',
          () {
        expect(
          () async => await card.readLongData(blockNumber: 0x04, length: 24),
          returnsNormally,
        );
      });

      test('should handle reads that span across multiple blocks correctly',
          () async {
        expect(
          (await card.readLongData(blockNumber: 0x04, length: 16)),
          List<int>.generate(16, (index) => index),
        );

        expect(
          (await card.readLongData(blockNumber: 0x04, length: 32)),
          List<int>.generate(32, (index) => index),
        );

        expect(
          (await card.readLongData(blockNumber: 0x20, length: 32)),
          List<int>.generate(32, (index) => index + (0x20 - 0x04) * 4),
        );
      });

      test('should handle reads with lengths that do not align with block size',
          () async {
        expect(
          (await card.readLongData(blockNumber: 0x04, length: 18)),
          List<int>.generate(18, (index) => index),
        );
      });
    });

    group('writeData', () {
      test('should throw an exception if block number is out of range', () {
        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_START - 1,
            data: [0x00, 0x00, 0x00, 0x00],
          ),
          throwsA(isA<InvalidBlockException>()),
        );

        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_END + 1,
            data: [0x00, 0x00, 0x00, 0x00],
          ),
          throwsA(isA<InvalidBlockException>()),
        );
      });

      test(
          'should throw an exception if data length is not equal to BLOCK_SIZE',
          () {
        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_START,
            data: [0x00, 0x00, 0x00],
          ), // Less than BLOCK_SIZE
          throwsA(isA<InvalidDataException>()),
        );

        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_START,
            data: [0x00, 0x00, 0x00, 0x00, 0x00],
          ), // More than BLOCK_SIZE
          throwsA(isA<InvalidDataException>()),
        );
      });

      test('should throw an exception if data contains invalid bytes', () {
        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_START,
            data: [-1, 0x00, 0x100, 0x00],
          ), // Invalid bytes
          throwsA(isA<InvalidDataException>()),
        );
      });

      test('should successfully write data to the correct block', () async {
        await card.writeData(
          blockNumber: DATA_ADDRESS_START,
          data: [0x01, 0x02, 0x03, 0x04],
        );
        expect(
          await reader.readBlock(
            blockNumber: DATA_ADDRESS_START,
            length: BLOCK_SIZE,
          ),
          equals([0x01, 0x02, 0x03, 0x04]),
        );

        await card.writeData(
          blockNumber: DATA_ADDRESS_END,
          data: [0x05, 0x06, 0x07, 0x08],
        );

        expect(
          await reader.readBlock(
            blockNumber: DATA_ADDRESS_END,
            length: BLOCK_SIZE,
          ),
          equals([0x05, 0x06, 0x07, 0x08]),
        );
      });
    });

    group('writeLongData', () {
      test('should throw an exception if block number is out of range', () {
        expect(
          card.writeLongData(
              blockNumber: DATA_ADDRESS_START - 1,
              data: List.filled(BLOCK_SIZE * 2, 0x00)),
          throwsA(isA<InvalidBlockException>()),
        );

        expect(
          card.writeLongData(
              blockNumber: DATA_ADDRESS_END,
              data: List.filled(BLOCK_SIZE * 2,
                  0x00)), // This might succeed if it fits in the last block, adjust based on your implementation
          throwsA(isA<InvalidBlockException>()),
        );
      });

      test(
          'should throw an exception if data length is not a multiple of BLOCK_SIZE',
          () {
        expect(
          card.writeLongData(
              blockNumber: DATA_ADDRESS_START,
              data: [0x00, 0x00, 0x00]), // Not a multiple of BLOCK_SIZE
          throwsA(isA<InvalidDataException>()),
        );
      });

      test('should successfully write long data spanning multiple blocks',
          () async {
        List<int> longData = List<int>.generate(
            BLOCK_SIZE * 3, (i) => i % 256); // Example long data
        await card.writeLongData(
            blockNumber: DATA_ADDRESS_START, data: longData);

        // Verify data written correctly across blocks
        for (int i = 0; i < 3; i++) {
          List<int> expectedData =
              longData.sublist(i * BLOCK_SIZE, (i + 1) * BLOCK_SIZE);

          List<int> actualData = await reader.readBlock(
              blockNumber: DATA_ADDRESS_START + i, length: BLOCK_SIZE);

          expect(actualData, equals(expectedData));
        }
      });
    });

    group('read and write complete data', () {
      test('should read and write complete data correctly', () async {
        List<int> edgeCaseData = List<int>.generate(
            (DATA_ADDRESS_END - DATA_ADDRESS_START + 1) * BLOCK_SIZE,
            (i) => i % 50);
        await card.writeLongData(
            blockNumber: DATA_ADDRESS_START, data: edgeCaseData);

        expect(
          await card.readLongData(
              blockNumber: DATA_ADDRESS_START, length: edgeCaseData.length),
          equals(edgeCaseData),
        );
      });
    });

    group('authenticate', () {
      test('should throw an exception if key length is not 16', () {
        expect(
          () async => await card.authenticate(key: [0x01, 0x02, 0x03]),
          throwsException,
        );

        expect(
          () async =>
              await card.authenticate(key: List<int>.generate(17, (i) => i)),
          throwsException,
        );
      });

      test('should throw an exception if key contains invalid bytes', () {
        expect(
          () async {
            final invalidKey = List<int>.generate(16, (i) => i);
            invalidKey[0] = -1;

            await card.authenticate(key: invalidKey);
          },
          throwsException,
        );

        expect(
          () async {
            final invalidKey = List<int>.generate(16, (i) => i);
            invalidKey[0] = 0x100;

            await card.authenticate(key: invalidKey);
          },
          throwsException,
        );
      });
    });

    group('getUID', () {
      final uid = [
        CardManufacturer.NXPSemiconductors.id,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06
      ];

      test('should throw an exception if manufacturer ID is invalid', () async {
        reader.serial = generateSerial(
          uid: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07],
          validBcc0: true,
          validBcc1: true,
        );

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e.toString(), 'RFIDException: Invalid manufacturer ID');
          expect(e, isA<RFIDException>());
        }
      });

      test('should throw an exception if checksum (BCC0) is invalid', () async {
        reader.serial = generateSerial(
          uid: uid,
          validBcc0: false,
          validBcc1: true,
        );

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e.toString(), 'RFIDException: Invalid checksum');
          expect(e, isA<RFIDException>());
        }
      });

      test('should throw an exception if checksum (BCC1) is invalid', () async {
        reader.serial = generateSerial(
          uid: uid,
          validBcc0: true,
          validBcc1: false,
        );

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e.toString(), 'RFIDException: Invalid checksum');
          expect(e, isA<RFIDException>());
        }
      });

      test('should return the correct UID if all checks pass', () async {
        final uid = [
          CardManufacturer.NXPSemiconductors.id,
          0x01,
          0x02,
          0x03,
          0x04,
          0x05,
          0x06
        ];

        reader.serial = generateSerial(
          uid: uid,
          validBcc0: true,
          validBcc1: true,
        );

        expect(await card.getUID(), equals(uid));
      });
    });
  });
}
