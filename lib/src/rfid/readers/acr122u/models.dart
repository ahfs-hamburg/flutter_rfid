/// Defines the types of authentication keys used in access control systems.
///
/// This enumeration represents the two standard types of authentication keys,
/// `A` and `B`, commonly used in various security and access control systems.
/// These key types are typically used to specify the type of key required for
/// performing authentication operations, such as reading from or writing to a
/// secure element or RFID tag.
///
/// ## Values
///   - `A`: Represents key type A, used for certain security operations.
///   - `B`: Represents key type B, used for a different set of security operations.
///
/// ## Example
/// ```dart
/// var keyType = AuthenticationKeyType.A;
/// if (keyType == AuthenticationKeyType.A) {
///   print('Using key type A for authentication.');
/// } else {
///   print('Using key type B for authentication.');
/// }
/// ```
///
/// ## Note
/// The choice between key type A and B depends on the specific security requirements
/// and configuration of the system being interacted with.
enum AuthenticationKeyType {
  A,
  B,
}

/// Represents the state of a two-color LED with red and green components.
///
/// This class models the on/off state of a two-color LED, allowing for the representation
/// of the LED's current color state. Each color component of the LED (red and green) can be
/// independently set to on (`true`) or off (`false`). This class is useful for applications
/// that require control over LED states, such as indicating status or alerts in a user interface.
///
/// ## Properties
///   - `red`: A boolean indicating whether the red component of the LED is on (`true`) or off (`false`).
///   - `green`: A boolean indicating whether the green component of the LED is on (`true`) or off (`false`).
///
/// ## Example
/// ```dart
/// // Creating a LedState instance with the red LED on and the green LED off.
/// var ledState = LedState(red: true, green: false);
///
/// // Accessing the state of the LED components.
/// print('Red LED is ${ledState.red ? "on" : "off"}');
/// print('Green LED is ${ledState.green ? "on" : "off"}');
/// ```
///
/// ## Note
///   - This class can be extended or modified to include additional LED colors or behaviors
///     as required by specific applications.
class LedState {
  final bool red;
  final bool green;

  LedState({
    required this.red,
    required this.green,
  });
}

/// Defines the polling intervals for periodic operations or checks.
///
/// This enumeration represents the set of predefined intervals at which a system
/// or application might poll or check for updates, changes, or conditions. The intervals
/// are specified in milliseconds, allowing for fine-grained control over the frequency
/// of these operations.
///
/// ## Values
///   - `ms250`: A polling interval of 250 milliseconds, suitable for relatively frequent checks.
///   - `ms500`: A polling interval of 500 milliseconds, for less frequent checks.
///
/// ## Example
/// ```dart
/// var pollInterval = PollInterval.ms250;
/// switch (pollInterval) {
///   case PollInterval.ms250:
///     print('Polling every 250 ms.');
///     break;
///   case PollInterval.ms500:
///     print('Polling every 500 ms.');
///     break;
/// }
/// ```
///
/// Note:
/// Choosing the appropriate polling interval depends on the specific requirements
/// of the application, including desired responsiveness and resource efficiency.
enum PollInterval {
  ms250,
  ms500,
}
