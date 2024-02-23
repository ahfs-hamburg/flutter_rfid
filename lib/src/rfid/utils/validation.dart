/// Validates a single byte to ensure it is within the valid range of 0x00 to 0xFF.
///
/// This function checks if the provided byte falls within the hexadecimal
/// range 0x00 to 0xFF. If the byte is outside this range, an exception is thrown.
///
/// ## Throws
///   - `Exception` if the byte is not within the 0x00 to 0xFF range.
///
/// ## Parameters
///   - `byte`: An integer representing the byte to be validated.
///
/// ## Examples
/// ```dart
/// validateByte(0x00); // Passes validation.
/// validateByte(-1); // Throws Exception.
/// validateByte(0x1FF); // Throws Exception.
/// ```
void validateByte(int byte) {
  if (byte < 0x00 || byte > 0xFF) {
    throw Exception('Invalid byte. Must be within 0x00 and 0xFF');
  }
}

/// Validates a list of bytes to ensure each byte is within the valid range.
///
/// This function iterates through each byte in the provided list, validating
/// that each byte is within the hexadecimal range 0x00 to 0xFF (0 to 255 in decimal).
/// Throws an exception if any byte falls outside of this range.
///
/// ## Throws
///   - `Exception` if any byte in the list is not within the 0x00 to 0xFF range.
///
/// ## Parameters
///   - `data`: A list of integers representing the bytes to be validated.
///
/// ## Examples
/// ```dart
/// validateByteList([0x01, 0xFF]); // Passes validation.
/// validateByteList([0x01, 0x1FF]); // Throws Exception.
/// ```
void validateByteList(List<int> data) {
  for (final byte in data) {
    try {
      validateByte(byte);
    } catch (e) {
      throw Exception('Invalid data. Each byte must be within 0x00 and 0xFF');
    }
  }
}
