import '../../core/card_manufacturer.dart';
import '../../core/exceptions.dart';
import '../../core/reader.dart';
import '../../utils/validation.dart';
import 'models.dart';

/// Provides an interface for interacting with Mifare Ultralight C RFID tags via an RFID reader.
///
/// This class facilitates operations such as reading and writing data to Mifare Ultralight C RFID tags,
/// authenticating access to the tags, and configuring tag settings. It abstracts the complexities
/// of direct communication with RFID hardware through the use of an RFID reader interface.
///
/// ## Usage
/// An instance of `RFIDReader` must be provided to handle communication with the RFID hardware.
/// Once instantiated, `MifareUltralightC` offers methods for data manipulation, authentication,
/// and tag configuration management.
///
/// ## Example
/// ```dart
/// MifareUltralightC card = MifareUltralightC(reader: yourRFIDReader);
/// // Reading data from the tag
/// List<int> data = await card.readData(blockNumber: 4);
/// // Writing data to the tag
/// await card.writeData(blockNumber: 4, data: [0x01, 0x02, 0x03, 0x04]);
/// ```
///
/// ## Features
/// - Read and write operations with support for both single and multiple blocks.
/// - Secure tag authentication using standard and advanced encryption methods.
/// - Access to tag's unique identification and configuration for advanced management.
///
/// Note: This class is specifically designed for Mifare Ultralight C tags and relies on the capabilities
/// of the provided `RFIDReader` implementation. Ensure compatibility of your RFID reader with the class.
class MifareUltralightC {
  /// The size of a single block in bytes. Mifare Ultralight C tags use a block size of 4 bytes.
  static const int BLOCK_SIZE = 4;

  /// The starting address of the RFID tag's memory.
  static const int MEMORY_ADDRESS_START = 0x00;

  /// The ending address of the RFID tag's memory.
  static const int MEMORY_ADDRESS_END = 0x2F;

  /// The maximum number of bytes that can be read in a single read operation.
  static const int MAX_READ_LENGTH = BLOCK_SIZE * 4;

  /// The starting address of the serial number in the RFID tag's memory.
  static const int SERIAL_NUMBER_ADDRESS_START = 0x00;

  /// The ending address of the serial number in the RFID tag's memory.
  static const int SERIAL_NUMBER_ADDRESS_END = 0x02;

  /// The address of the One-Time Programmable (OTP) area in the RFID tag's memory.
  static const int OTP_ADDRESS = 0x03;

  /// The starting address of the general data area in the RFID tag's memory.
  static const int DATA_ADDRESS_START = 0x04;

  /// The ending address of the general data area in the RFID tag's memory.
  static const int DATA_ADDRESS_END = 0x27;

  /// The starting address of the authentication key in the RFID tag's memory.
  static const int AUTH_KEY_ADDRESS_START = 0x2C;

  /// The ending address of the authentication key in the RFID tag's memory.
  static const int AUTH_KEY_ADDRESS_END = 0x2F;

  /// The starting address of the authentication configuration in the RFID tag's memory.
  static const int AUTH_CONFIG_ADDRESS_START = 0x2A;

  /// The ending address of the authentication configuration in the RFID tag's memory.
  static const int AUTH_CONFIG_ADDRESS_END = 0x2B;

  /// The RFID reader used for communicating with the RFID tag.
  final RFIDReader reader;

  MifareUltralightC({required this.reader});

  /// Reads data from a specified block on a Mifare Ultralight C RFID tag.
  ///
  /// This method communicates with the RFID tag through the RFID reader to retrieve data
  /// from a specified block. It supports reading a custom length of data, not exceeding
  /// the maximum allowed read length.
  ///
  /// ## Parameters
  /// - `blockNumber`: The block number from which to start reading. Must be within the
  ///   tag's memory address range.
  /// - `length`: (Optional) The number of bytes to read, defaulting to the block size.
  ///   This value cannot exceed the tag's maximum read length.
  ///
  /// ## Returns
  /// A `Future<List<int>>` that resolves to the data read from the specified block as a list of integers.
  ///
  /// ## Throws
  /// - `Exception` if the specified length is invalid (less than 0 or greater than the maximum read length).
  /// - `RFIDException` if there is an error reading data from the block, including issues like communication errors
  ///   with the RFID reader or the block number being out of the allowed range.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   List<int> data = await card.readData(blockNumber: 4, length: 4);
  ///   print('Data read from block 4: $data');
  /// } catch (e) {
  ///   print('Failed to read data: $e');
  /// }
  /// ```
  ///
  /// Note: Ensure the `blockNumber` and `length` are within the bounds of the RFID tag's memory layout to avoid errors.
  Future<List<int>> readData({
    required int blockNumber,
    int length = BLOCK_SIZE,
  }) async {
    if (length < 0 || length > MAX_READ_LENGTH) {
      throw Exception('Invalid length');
    }

    _validateBlockNumber(
      blockNumber: blockNumber,
      length: length,
      start: MEMORY_ADDRESS_START,
      end: MEMORY_ADDRESS_END,
    );

    try {
      return await reader.readBlock(
        blockNumber: blockNumber,
        length: length,
      );
    } catch (e) {
      throw RFIDException('Error reading data: ${e.toString()}');
    }
  }

  /// Writes data to a specified block on a Mifare Ultralight C RFID tag.
  ///
  /// This method allows writing a predefined list of byte data to a specific block within
  /// the RFID tag's memory. It ensures that the data length matches the block size and validates
  /// the data bytes against the tag's specifications.
  ///
  /// ## Parameters
  /// - `blockNumber`: The block number where the data should be written. It must fall within
  ///   the valid data address range of the tag.
  /// - `data`: A list of integers representing the data to be written. The length of this list
  ///   must exactly match the tag's block size.
  ///
  /// ## Throws
  /// - `InvalidDataException` if the data length does not match the required block size or if
  ///   any byte in the data list is outside the valid byte range (0x00 to 0xFF).
  /// - `RFIDException` if there is an error during the write operation, such as communication
  ///   issues with the RFID reader or validation failures.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await card.writeData(blockNumber: 4, data: [0x01, 0x02, 0x03, 0x04]);
  ///   print('Data successfully written to block 4');
  /// } catch (e) {
  ///   print('Failed to write data: $e');
  /// }
  /// ```
  ///
  /// Note: This method enforces strict validation of the data length and byte values to ensure
  /// compatibility with the Mifare Ultralight C tag's specifications. Ensure that the `blockNumber`
  /// and `data` are correctly specified to avoid errors.
  Future<void> writeData({
    required int blockNumber,
    required List<int> data,
  }) async {
    _validateBlockNumber(
      blockNumber: blockNumber,
      start: DATA_ADDRESS_START,
      end: DATA_ADDRESS_END,
    );

    if (data.length != BLOCK_SIZE) {
      throw InvalidDataException(
          'Invalid data length. Must be equal to $BLOCK_SIZE');
    }

    try {
      validateByteList(data);
    } catch (e) {
      throw InvalidDataException(
          'Invalid data. Each byte must be within 0x00 and 0xFF');
    }

    try {
      await reader.writeBlock(blockNumber: blockNumber, data: data);
    } catch (e) {
      throw RFIDException(
        'Error writing data to block $blockNumber: ${e.toString()}',
      );
    }
  }

  /// Reads a sequence of data spanning multiple blocks from a Mifare Ultralight C RFID tag.
  ///
  /// This method facilitates reading data over the tag's block size limit by segmenting the read operation
  /// into multiple blocks. It is particularly useful for retrieving larger data sets stored across
  /// consecutive memory blocks on the tag.
  ///
  /// ## Parameters
  /// - `blockNumber`: The starting block number from which the data reading begins. It should be within
  ///   the RFID tag's valid data address range.
  /// - `length`: The total number of bytes to read. While the length may exceed the size of a single block,
  ///   it must be a positive value and within the constraints of the tag's memory.
  ///
  /// ## Returns
  /// A `Future<List<int>>` that resolves to a concatenated list of integers representing the data read
  /// from the specified blocks.
  ///
  /// ## Throws
  /// - `Exception` if the specified `length` is less than 0, indicating an invalid length.
  /// - `RFIDException` if there is an error in reading data from the blocks, which could be due to issues
  ///   like communication errors with the RFID reader or attempting to read beyond the tag's memory limits.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   List<int> longData = await card.readLongData(blockNumber: 4, length: 16);
  ///   print('Long data read from starting at block 4: $longData');
  /// } catch (e) {
  ///   print('Failed to read long data: $e');
  /// }
  /// ```
  ///
  /// Note: This method efficiently manages reading operations that span multiple blocks by automatically
  /// calculating the necessary reads based on the `length` and `blockNumber` parameters. Ensure that the
  /// starting block and the length parameters are chosen such that the read operation does not attempt to
  /// access beyond the tag's memory capacity.
  Future<List<int>> readLongData({
    required int blockNumber,
    int length = BLOCK_SIZE,
  }) async {
    if (length < 0) {
      throw Exception('Invalid length');
    }

    _validateBlockNumber(
      blockNumber: blockNumber,
      length: length,
      start: DATA_ADDRESS_START,
      end: DATA_ADDRESS_END,
    );

    try {
      List<int> data = [];

      for (var i = 0; i < length; i += MAX_READ_LENGTH) {
        final currentBlock = blockNumber + (i / BLOCK_SIZE).floor();
        final remainingLength = length - data.length;

        data += await readData(
          blockNumber: currentBlock,
          length: remainingLength > MAX_READ_LENGTH
              ? MAX_READ_LENGTH
              : remainingLength,
        );
      }

      return data;
    } catch (e) {
      throw RFIDException('Error reading data: ${e.toString()}');
    }
  }

  /// Writes a sequence of data spanning multiple blocks to a Mifare Ultralight C RFID tag.
  ///
  /// This method allows for writing data that exceeds the size of a single block by breaking
  /// the data into segments that fit within the tag's block size. It ensures that the total
  /// data length is a multiple of the block size and validates the byte values before writing.
  ///
  /// ## Parameters
  /// - `blockNumber`: The starting block number where the data writing begins. Must be within
  ///   the valid range for the RFID tag's memory.
  /// - `data`: A list of integers representing the data to be written across multiple blocks.
  ///   The length of this list must be a multiple of the block size.
  ///
  /// ## Throws
  /// - `InvalidDataException` if the data length is not a multiple of the block size or if
  ///   any byte in the data list is outside the valid range (0x00 to 0xFF).
  /// - `RFIDException` if there's an error during the write operation, such as communication
  ///   problems with the RFID reader or if attempting to write beyond the tag's memory limits.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await card.writeLongData(blockNumber: 4, data: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]);
  ///   print('Data successfully written starting from block 4');
  /// } catch (e) {
  ///   print('Failed to write long data: $e');
  /// }
  /// ```
  ///
  /// Note: Ensure that the starting block number and data length are appropriately chosen to avoid
  /// writing beyond the RFID tag's memory capacity. The data must be carefully prepared to ensure
  /// integrity and compatibility with the tag's specifications.
  Future<void> writeLongData({
    required int blockNumber,
    required List<int> data,
  }) async {
    if (data.length % BLOCK_SIZE != 0) {
      throw InvalidDataException(
          'Invalid data length. Must be a multiple of $BLOCK_SIZE');
    }

    _validateBlockNumber(
      blockNumber: blockNumber,
      length: data.length,
      start: DATA_ADDRESS_START,
      end: DATA_ADDRESS_END,
    );

    try {
      validateByteList(data);
    } catch (e) {
      throw InvalidDataException(
          'Invalid data. Each byte must be within 0x00 and 0xFF');
    }

    try {
      for (var i = 0; i < data.length; i += BLOCK_SIZE) {
        await writeData(
          blockNumber: blockNumber + (i / BLOCK_SIZE).floor(),
          data: data.sublist(i, i + BLOCK_SIZE),
        );
      }
    } catch (e) {
      throw RFIDException('Error writing data: ${e.toString()}');
    }
  }

  /// Authenticates with a Mifare Ultralight C RFID tag using a 3DES key.
  ///
  /// This method performs a secure authentication operation on the RFID tag using Triple DES (3DES) encryption.
  /// It requires a 16-byte key for the encryption process, ensuring that the authentication process is secure
  /// and that only authorized entities can access the tag's protected features and data.
  ///
  /// ## Parameters
  /// - `key`: A list of integers representing the 16-byte 3DES key used for authentication.
  ///   Each byte must be within the valid range (0x00 to 0xFF).
  ///
  /// ## Throws
  /// - `Exception` if the provided key does not meet the required length of 16 bytes, or if
  ///   any byte in the key is outside the valid range.
  /// - `RFIDException` if there's an error during the authentication process, which could be
  ///   due to issues with the key, communication problems with the RFID reader, or the tag's
  ///   response to the authentication attempt.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await card.authenticate(key: [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF]);
  ///   print('Authentication successful');
  /// } catch (e) {
  ///   print('Authentication failed: $e');
  /// }
  /// ```
  ///
  /// Note: The key must be carefully managed and securely stored to prevent unauthorized access. The use of 3DES
  /// for authentication provides a higher level of security compared to simpler encryption methods, making it
  /// suitable for applications that require secure access control and data protection.
  Future<void> authenticate({required List<int> key}) async {
    if (key.length != 16) {
      throw Exception('Invalid key length');
    }

    try {
      validateByteList(key);
    } catch (e) {
      throw Exception('Invalid key. Each byte must be within 0x00 and 0xFF');
    }

    try {
      await reader.authenticate3DES(
        key: key,
      );
    } catch (e) {
      throw RFIDException('Error authenticating: ${e.toString()}');
    }
  }

  /// Retrieves the Unique Identifier (UID) of a Mifare Ultralight C RFID tag.
  ///
  /// This method reads the UID from the specified blocks of the RFID tag, verifying the manufacturer ID
  /// and checksums to ensure the UID's authenticity. The UID is a crucial component for identifying
  /// the tag and ensuring secure operations.
  ///
  /// ## Returns
  /// A `Future<List<int>>` that resolves to the UID of the tag as a list of integers.
  ///
  /// ## Throws
  /// - `RFIDException` if there is an error reading the UID from the tag, including issues such as
  ///   communication errors with the RFID reader or if the UID data fails validation checks (e.g., incorrect
  ///   manufacturer ID or checksum validation failure).
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   List<int> uid = await card.getUID();
  ///   print('Tag UID: $uid');
  /// } catch (e) {
  ///   print('Failed to get UID: $e');
  /// }
  /// ```
  ///
  /// Note: The UID is derived from specific blocks that include the manufacturer ID and checksum bytes
  /// for validation. This method ensures the integrity and authenticity of the UID by checking these
  /// values against expected standards.
  Future<List<int>> getUID() async {
    final data = await reader
        .readBlock(blockNumber: SERIAL_NUMBER_ADDRESS_START, length: 9)
        .catchError((dynamic e) {
      throw RFIDException('Error getting UID: ${e.toString()}');
    });

    final manufacturerId = data[0];
    final bcc0 = data[3];
    final bcc1 = data[8];
    final uid = data.sublist(0, 3) + data.sublist(4, 8);

    if (manufacturerId != CardManufacturer.NXPSemiconductors.id) {
      throw RFIDException('Invalid manufacturer ID');
    }

    if (bcc0 != 0x88 ^ uid[0] ^ uid[1] ^ uid[2]) {
      throw RFIDException('Invalid checksum');
    }

    if (bcc1 != uid[3] ^ uid[4] ^ uid[5] ^ uid[6]) {
      throw RFIDException('Invalid checksum');
    }

    return uid;
  }

  /// Retrieves the authentication configuration from a Mifare Ultralight C RFID tag.
  ///
  /// This method reads the authentication configuration data from the RFID tag, including the starting
  /// block for authentication and the lock status. It encapsulates this information in an `AuthConfig`
  /// object for easy access and manipulation.
  ///
  /// ## Returns
  /// A `Future<AuthConfig>` that resolves to an `AuthConfig` object containing the authentication
  /// configuration details of the tag.
  ///
  /// ## Throws
  /// - `RFIDException` if there's an error during the read operation. This could be due to communication
  ///   issues with the RFID reader or problems interpreting the data from the tag.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   AuthConfig config = await card.getAuthConfig();
  ///   print('Starting block for authentication: ${config.startingBlock}');
  ///   print('Lock status: ${config.lock}');
  /// } catch (e) {
  ///   print('Failed to get authentication configuration: $e');
  /// }
  /// ```
  ///
  /// Note: The authentication configuration is crucial for understanding and managing how authentication
  /// operations are performed with the RFID tag. This method provides a straightforward way to access
  /// these settings, aiding in secure and effective tag management.
  Future<AuthConfig> getAuthConfig() async {
    try {
      final data = await reader.readBlock(
        blockNumber: AUTH_CONFIG_ADDRESS_START,
        length: BLOCK_SIZE * 2,
      );

      return AuthConfig(
        startingBlock: data[0],
        lock: AuthLock.fromInt(data[4]),
      );
    } catch (e) {
      throw RFIDException('Error getting authentication configuration');
    }
  }

  /// Sets the authentication configuration on a Mifare Ultralight C RFID tag.
  ///
  /// This method updates the RFID tag's authentication configuration, including the starting block for
  /// authentication operations and the lock status, based on the provided parameters. It writes this
  /// configuration to the tag, ensuring that future authentication actions adhere to these settings.
  ///
  /// ## Parameters
  /// - `startingBlock`: The block number at which authentication operations should start.
  /// - `lock`: The `AuthLock` status indicating whether the tag is locked for writing, reading,
  ///   or both. This is determined by the `AuthLock` enum value provided.
  ///
  /// ## Throws
  /// - `RFIDException` if there's an error during the write operation. This could result from issues
  ///   like communication problems with the RFID reader or invalid block numbers that fall outside the
  ///   tag's memory range.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await card.setAuthConfig(startingBlock: 4, lock: AuthLock.readWrite);
  ///   print('Authentication configuration set successfully');
  /// } catch (e) {
  ///   print('Failed to set authentication configuration: $e');
  /// }
  /// ```
  ///
  /// Note: Properly configuring the authentication settings is crucial for the security and integrity
  /// of the RFID tag's data. This method allows for precise control over these parameters, aiding in
  /// the secure management of the tag.
  Future<void> setAuthConfig({
    required int startingBlock,
    required AuthLock lock,
  }) async {
    _validateBlockNumber(
      blockNumber: startingBlock,
      start: OTP_ADDRESS,
      end: MEMORY_ADDRESS_END,
    );

    try {
      await reader.writeBlock(blockNumber: AUTH_CONFIG_ADDRESS_START, data: [
        startingBlock,
        0x00,
        0x00,
        0x00,
      ]);

      await reader
          .writeBlock(blockNumber: AUTH_CONFIG_ADDRESS_START + 1, data: [
        lock.value,
        0x00,
        0x00,
        0x00,
      ]);
    } catch (e) {
      throw RFIDException('Error setting authentication configuration');
    }
  }

  /// Updates the authentication key on a Mifare Ultralight C RFID tag.
  ///
  /// Changes the RFID tag's authentication key to a new 16-byte key. This key is split
  /// and written to specific memory blocks in a reversed order to enhance security.
  ///
  /// ## Parameters
  /// - `key`: A 16-byte list representing the new authentication key. Each byte must be
  ///   within the range 0x00 to 0xFF.
  ///
  /// ## Throws
  /// - `Exception` for invalid key length if the key is not exactly 16 bytes.
  /// - `Exception` if any byte in the key is outside the valid range.
  /// - `Exception` labeled 'Error changing authentication key' upon failure to write the new
  ///   key to the tag's memory.
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await card.changeAuthKey(key: [0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
  ///                                   0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]);
  ///   print('Authentication key updated successfully.');
  /// } catch (e) {
  ///   print('Failed to update authentication key: $e');
  /// }
  /// ```
  ///
  /// Note: It's crucial to handle the new authentication key securely and ensure its confidentiality
  /// to maintain the tag's security.
  Future<void> changeAuthKey({required List<int> key}) async {
    if (key.length != 16) {
      throw Exception('Invalid key length');
    }

    try {
      validateByteList(key);
    } catch (e) {
      throw Exception('Invalid key. Each byte must be within 0x00 and 0xFF');
    }

    final key1 = key.sublist(0, 8);
    final key2 = key.sublist(8, 16);

    try {
      await reader.writeBlock(
        blockNumber: AUTH_KEY_ADDRESS_START,
        data: key1.reversed.toList().sublist(0, 4),
      );

      await reader.writeBlock(
        blockNumber: AUTH_KEY_ADDRESS_START + 1,
        data: key1.reversed.toList().sublist(4, 8),
      );

      await reader.writeBlock(
        blockNumber: AUTH_KEY_ADDRESS_START + 2,
        data: key2.reversed.toList().sublist(0, 4),
      );

      await reader.writeBlock(
        blockNumber: AUTH_KEY_ADDRESS_START + 3,
        data: key2.reversed.toList().sublist(4, 8),
      );
    } catch (e) {
      throw Exception('Error changing authentication key');
    }
  }

  /// Validates the specified block number and length for operations on an RFID tag.
  ///
  /// Ensures the block number and operation length fall within a predefined valid range.
  /// This safeguard prevents operations from targeting invalid memory blocks on the tag.
  ///
  /// ## Parameters
  /// - `blockNumber`: Starting block number for the operation.
  /// - `length`: Length of the operation, defaulting to the block size.
  /// - `start`: Start of the valid block number range.
  /// - `end`: End of the valid block number range.
  ///
  /// ## Throws
  /// - `InvalidBlockException` if the operation exceeds tag memory limits, detailed with the
  ///   problematic block number and length.
  ///
  /// ## Usage
  /// Utilized internally to validate block numbers prior to read/write operations. Not for
  /// external use.
  ///
  /// Note: This method is crucial for maintaining data integrity and operational safety
  /// by ensuring that all operations occur within the tag's physical memory boundaries.
  void _validateBlockNumber({
    required int blockNumber,
    int length = BLOCK_SIZE,
    required int start,
    required int end,
  }) {
    if (blockNumber < start ||
        blockNumber + ((length / BLOCK_SIZE).ceil() - 1) > end) {
      throw InvalidBlockException(
        '$blockNumber with length $length. All blocks must be within $start and $end',
      );
    }
  }
}
