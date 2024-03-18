import 'package:flutter_rfid/cards/mifare_ultralight_c.dart';
import 'package:flutter_rfid/src/rfid/cards/mifare_ultralight_c/mifare_ultralight_c.dart';
import 'package:flutter_rfid/src/rfid/cards/mifare_ultralight_c/models.dart';
import 'package:flutter_rfid/src/rfid/core/card_manufacturer.dart';
import 'package:flutter_rfid/src/rfid/core/exceptions.dart';
import 'package:flutter_rfid/src/rfid/core/reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockedReader extends Mock implements RFIDReader {}

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
      setUp(() {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((invocation) {
          final blockNumber = invocation.namedArguments[#blockNumber] as int;
          final length = invocation.namedArguments[#length] as int;

          return Future.value(List<int>.generate(
              length, (index) => index + (blockNumber - 0x04) * 4));
        });
      });

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

      test('should throw an exception if card read fails', () {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenThrow(Exception());

        expect(
          () async => await card.readData(blockNumber: 0x04, length: 4),
          throwsA(isA<RFIDException>()),
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
      setUp(() {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((invocation) {
          final blockNumber = invocation.namedArguments[#blockNumber] as int;
          final length = invocation.namedArguments[#length] as int;

          return Future.value(List<int>.generate(
              length, (index) => index + (blockNumber - 0x04) * 4));
        });
      });

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

      test('should throw an exception if card read fails', () {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenThrow(Exception());

        expect(
          card.readLongData(blockNumber: 0x04, length: 16),
          throwsA(isA<RFIDException>()),
        );
      });

      test(
          'should read normally for valid block numbers and lengths within bounds',
          () {
        expect(
          () async => await card.readLongData(blockNumber: 0x04, length: 16),
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

      test('should throw an exception if card write fails', () {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenThrow(Exception());

        expect(
          card.writeData(
            blockNumber: DATA_ADDRESS_START,
            data: [0x00, 0x00, 0x00, 0x00],
          ),
          throwsA(isA<RFIDException>()),
        );
      });

      test('should successfully write data to the correct block', () async {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenAnswer((_) => Future.value());

        await card.writeData(
          blockNumber: DATA_ADDRESS_START,
          data: [0x01, 0x02, 0x03, 0x04],
        );

        verify(() => reader.writeBlock(
              blockNumber: DATA_ADDRESS_START,
              data: [0x01, 0x02, 0x03, 0x04],
            )).called(1);

        await card.writeData(
          blockNumber: DATA_ADDRESS_END,
          data: [0x05, 0x06, 0x07, 0x08],
        );

        verify(() => reader.writeBlock(
              blockNumber: DATA_ADDRESS_END,
              data: [0x05, 0x06, 0x07, 0x08],
            )).called(1);
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

      test('should throw an exception if data contains invalid bytes', () {
        expect(
          card.writeLongData(
            blockNumber: DATA_ADDRESS_START,
            data: [-1, 0x00, 0x100, 0x00],
          ), // Invalid bytes
          throwsA(isA<InvalidDataException>()),
        );
      });

      test('should throw an exception if card write fails', () {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenThrow(Exception());

        expect(
          card.writeLongData(
            blockNumber: DATA_ADDRESS_START,
            data: [0x00, 0x00, 0x00, 0x00],
          ),
          throwsA(isA<RFIDException>()),
        );
      });

      test('should successfully write long data spanning multiple blocks',
          () async {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenAnswer((_) => Future.value());

        List<int> longData = List<int>.generate(
            BLOCK_SIZE * 3, (i) => i % 256); // Example long data
        await card.writeLongData(
            blockNumber: DATA_ADDRESS_START, data: longData);

        verify(() => reader.writeBlock(
              blockNumber: DATA_ADDRESS_START,
              data: longData.sublist(0, BLOCK_SIZE),
            )).called(1);

        verify(() => reader.writeBlock(
              blockNumber: DATA_ADDRESS_START + 1,
              data: longData.sublist(BLOCK_SIZE, BLOCK_SIZE * 2),
            )).called(1);

        verify(() => reader.writeBlock(
              blockNumber: DATA_ADDRESS_START + 2,
              data: longData.sublist(BLOCK_SIZE * 2, BLOCK_SIZE * 3),
            )).called(1);
      });
    });

    group('read and write complete data', () {
      test('should read and write complete data correctly', () async {
        List<int> edgeCaseData = List<int>.generate(
            (DATA_ADDRESS_END - DATA_ADDRESS_START + 1) * BLOCK_SIZE,
            (i) => i % 50);

        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((invocation) {
          final blockNumber = invocation.namedArguments[#blockNumber] as int;
          final length = invocation.namedArguments[#length] as int;

          return Future.value(edgeCaseData.sublist(
              (blockNumber - DATA_ADDRESS_START) * BLOCK_SIZE,
              (blockNumber - DATA_ADDRESS_START) * BLOCK_SIZE + length));
        });

        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenAnswer((invocation) {
          final blockNumber = invocation.namedArguments[#blockNumber] as int;
          final data = invocation.namedArguments[#data] as List<int>;

          for (int i = 0; i < data.length; i++) {
            edgeCaseData[(blockNumber - DATA_ADDRESS_START) * BLOCK_SIZE + i] =
                data[i];
          }

          return Future.value();
        });

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

      test('should throw an exception if card authentication fails', () {
        when(() => reader.authenticate3DES(key: any(named: 'key')))
            .thenThrow(Exception());

        expect(
          card.authenticate(key: List<int>.generate(16, (i) => i)),
          throwsA(isA<RFIDException>()),
        );
      });

      test('should successfully authenticate with the correct key', () async {
        when(() => reader.authenticate3DES(key: any(named: 'key')))
            .thenAnswer((_) => Future.value());

        final key = List<int>.generate(16, (i) => i);
        await card.authenticate(key: key);

        verify(() => reader.authenticate3DES(key: key)).called(1);
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

      test('should throw an exception if card read fails', () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenThrow(Exception());

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e, isA<RFIDException>());
        }
      });

      test('should throw an exception if manufacturer ID is invalid', () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value(generateSerial(
              uid: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07],
              validBcc0: true,
              validBcc1: true,
            )));

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e.toString(), 'RFIDException: Invalid manufacturer ID');
          expect(e, isA<RFIDException>());
        }
      });

      test('should throw an exception if checksum (BCC0) is invalid', () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value(generateSerial(
              uid: uid,
              validBcc0: false,
              validBcc1: true,
            )));

        try {
          await card.getUID();

          fail('Expected an exception');
        } catch (e) {
          expect(e.toString(), 'RFIDException: Invalid checksum');
          expect(e, isA<RFIDException>());
        }
      });

      test('should throw an exception if checksum (BCC1) is invalid', () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value(generateSerial(
              uid: uid,
              validBcc0: true,
              validBcc1: false,
            )));

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
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value(generateSerial(
              uid: uid,
              validBcc0: true,
              validBcc1: true,
            )));

        expect(await card.getUID(), equals(uid));
      });
    });

    group('getAuthConfig', () {
      test('should throw an exception if card read fails', () {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenThrow(Exception());

        expect(
          card.getAuthConfig(),
          throwsA(isA<RFIDException>()),
        );
      });

      test('should call reader.readBlock with the correct parameters',
          () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value([0x04, 0x00, 0x00, 0x00, 0x00]));

        await card.getAuthConfig();

        verify(() => reader.readBlock(
              blockNumber: MifareUltralightC.AUTH_CONFIG_ADDRESS_START,
              length: BLOCK_SIZE * 2,
            )).called(1);
      });

      test('should return the correct AuthConfig if card read succeeds',
          () async {
        when(() => reader.readBlock(
              blockNumber: any(named: 'blockNumber'),
              length: any(named: 'length'),
            )).thenAnswer((_) => Future.value([0x04, 0x00, 0x00, 0x00, 0x00]));

        expect(
          await card.getAuthConfig(),
          isA<AuthConfig>()
              .having((config) => config.startingBlock, 'startingBlock', 0x04)
              .having((config) => config.lock, 'lock', AuthLock.readWrite),
        );
      });
    });

    group('setAuthConfig', () {
      test('should throw an exception if starting block is out of range', () {
        expect(
          card.setAuthConfig(
            startingBlock: 0x01,
            lock: AuthLock.readWrite,
          ),
          throwsA(isA<InvalidBlockException>()),
        );

        expect(
          card.setAuthConfig(
            startingBlock: MifareUltralightC.MEMORY_ADDRESS_END + 1,
            lock: AuthLock.readWrite,
          ),
          throwsA(isA<InvalidBlockException>()),
        );
      });

      test('should throw an exception if card write fails', () {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenThrow(Exception());

        expect(
          card.setAuthConfig(
            startingBlock: DATA_ADDRESS_START,
            lock: AuthLock.readWrite,
          ),
          throwsA(isA<RFIDException>()),
        );
      });

      test('should successfully set the authentication configuration',
          () async {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenAnswer((_) => Future.value());

        await card.setAuthConfig(
          startingBlock: DATA_ADDRESS_START,
          lock: AuthLock.readWrite,
        );

        verify(() => reader.writeBlock(
              blockNumber: MifareUltralightC.AUTH_CONFIG_ADDRESS_START,
              data: [DATA_ADDRESS_START, 0x00, 0x00, 0x00],
            )).called(1);

        verify(() => reader.writeBlock(
              blockNumber: MifareUltralightC.AUTH_CONFIG_ADDRESS_START + 1,
              data: [AuthLock.readWrite.value, 0x00, 0x00, 0x00],
            )).called(1);
      });
    });

    group('changeAuthKey', () {
      test('should throw an exception if key length is not 16', () {
        expect(
          () async => await card.changeAuthKey(key: [0x01, 0x02, 0x03]),
          throwsException,
        );

        expect(
          () async =>
              await card.changeAuthKey(key: List<int>.generate(17, (i) => i)),
          throwsException,
        );
      });

      test('should throw an exception if key contains invalid bytes', () {
        expect(
          () async {
            final invalidKey = List<int>.generate(16, (i) => i);
            invalidKey[0] = -1;

            await card.changeAuthKey(key: invalidKey);
          },
          throwsException,
        );

        expect(
          () async {
            final invalidKey = List<int>.generate(16, (i) => i);
            invalidKey[0] = 0x100;

            await card.changeAuthKey(key: invalidKey);
          },
          throwsException,
        );
      });

      test('should throw an exception if card write fails', () {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenThrow(Exception());

        expect(
          () async => await card.changeAuthKey(
            key: List<int>.generate(16, (i) => i),
          ),
          throwsException,
        );
      });

      test('should successfully change the authentication key', () async {
        when(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).thenAnswer((_) => Future.value());

        final key = List<int>.generate(16, (i) => i);
        await card.changeAuthKey(key: key);

        verify(() => reader.writeBlock(
              blockNumber: any(named: 'blockNumber'),
              data: any(named: 'data'),
            )).called(4);
      });
    });
  });
}
