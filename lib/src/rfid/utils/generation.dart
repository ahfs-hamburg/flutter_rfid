import 'dart:math';

/// Generates a list of random bytes.
///
/// This method creates a list of random integers (bytes) using a cryptographically secure random generator.
/// Each byte in the list is within the range of 0 to 255.
///
/// ## Parameters
///   - `length`: The number of random bytes to generate.
///
/// ## Returns
///   A list of integers, each representing a random byte.
///
/// ## Example
/// ```dart
/// var randomBytes = _getRandomBytes(length: 16); // Generates 16 random bytes.
/// ```
///
/// Note: This method is typically used for generating random keys or initialization vectors (IVs)
/// for cryptographic operations in a secure manner.
List<int> getRandomBytes({required int length}) {
  final random = Random.secure();
  return List<int>.generate(length, (i) => random.nextInt(256));
}
