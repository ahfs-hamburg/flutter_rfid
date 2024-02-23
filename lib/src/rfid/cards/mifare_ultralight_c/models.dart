/// Defines the lock status for authentication operations on an RFID tag.
///
/// This enum represents the possible states of authentication lock on an RFID tag,
/// specifically for Mifare Ultralight C tags. It determines what operations (read/write)
/// are permitted post-authentication.
///
/// ## Values
/// - `write`: Indicates that only write operations are locked.
/// - `readWrite`: Indicates that both read and write operations are locked.
///
/// ## Attributes
/// - `value`: The integer value associated with the lock status, used for serialization and interaction with RFID tag configurations.
///
/// ## Factory Constructor
/// - `fromInt`: Creates an `AuthLock` instance from an integer value. This facilitates conversion from raw tag data to an `AuthLock` status.
///
/// ## Throws
/// - `Exception` if an invalid integer value is provided, indicating that the value does not correspond to a valid lock status.
///
/// ## Example
/// ```dart
/// try {
///   AuthLock lockStatus = AuthLock.fromInt(0x00);
///   print('Lock status: ${lockStatus}');
/// } catch (e) {
///   print('Error: $e');
/// }
/// ```
///
/// Note: The `AuthLock` enum is crucial for managing the security and access control of RFID tags. By correctly interpreting and setting these values, one can ensure that tag data remains protected according to the desired access restrictions.
enum AuthLock {
  write(0x01),
  readWrite(0x00);

  const AuthLock(this.value);

  final int value;

  factory AuthLock.fromInt(int value) {
    for (final lock in AuthLock.values) {
      if (lock.value == value) {
        return lock;
      }
    }

    throw Exception('Invalid auth lock value: $value');
  }
}

/// Represents the authentication configuration of a Mifare Ultralight C RFID tag.
///
/// Encapsulates the settings related to authentication, including the starting block for
/// authentication checks and the lock status determining the level of access restriction.
///
/// ## Attributes
/// - `startingBlock`: The block number on the RFID tag where authentication operations begin.
/// - `lock`: An instance of `AuthLock` indicating the authentication lock status (e.g., read/write permissions).
///
/// ## Usage
/// This class is used to configure and retrieve authentication settings on an RFID tag, helping
/// manage how authentication and subsequent operations are handled.
///
/// ## Example
/// ```dart
/// AuthConfig config = AuthConfig(startingBlock: 4, lock: AuthLock.readWrite);
/// print('Auth starts at block: ${config.startingBlock}, with lock status: ${config.lock}');
/// ```
///
/// Note: The `AuthConfig` class plays a crucial role in securing RFID tags by specifying where
/// authentication begins and defining the level of access control. Proper configuration ensures
/// that only authorized access is allowed, protecting sensitive data on the tag.
class AuthConfig {
  final int startingBlock;
  final AuthLock lock;

  AuthConfig({
    required this.startingBlock,
    required this.lock,
  });
}
