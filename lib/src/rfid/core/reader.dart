import 'package:flutter/foundation.dart';

import '../../../flutter_rfid_platform_interface.dart';
import '../protocols/adpu.dart';

/// Defines an interface for RFID reader operations.
///
/// This abstract class outlines methods for authenticating, reading from,
/// and writing to RFID tags, as well as transmitting APDU commands. It is designed
/// to be extended by concrete classes that implement these operations for specific
/// RFID hardware.
///
/// Implementers will provide the logic for interacting with RFID tags,
/// including secure authentication and data manipulation. This class integrates
/// with [ChangeNotifier] to allow implementations to notify listeners about significant
/// events or state changes.
///
/// ## Extending RFIDReader
///
/// Extend this class to create a custom RFID reader interface tailored to your
/// hardware's requirements. When creating a subclass, it is essential to call `super()`
/// in your subclass's constructor to ensure proper initialization of the [ChangeNotifier]
/// functionality. Failure to do so may result in runtime errors or unexpected behavior.
///
/// ### Example
///
/// ```dart
/// class MyRFIDReader extends RFIDReader {
///   MyRFIDReader() : super() {
///     // Custom initialization for MyRFIDReader
///   }
///
///   @override
///   Future<void> authenticate(...) {
///     // Implementation of authenticate method
///   }
///
///   // Implement other abstract methods...
/// }
/// ```
///
/// Note: Always ensure to call `super()` in constructors of subclasses to maintain
/// the integrity of the [ChangeNotifier] behavior.
abstract class RFIDReader with ChangeNotifier {
  bool _isConnected = false;
  bool _isCardPresent = false;
  final List<void Function()> _onReaderConnectedCallbacks = [];
  final List<void Function()> _onReaderDisconnectedCallbacks = [];
  final List<void Function()> _onCardPresentCallbacks = [];
  final List<void Function()> _onCardAbsentCallbacks = [];

  RFIDReader() {
    _initializeCallbacks();
  }

  /// Initializes platform-specific callbacks for state changes.
  ///
  /// This method configures callbacks to handle changes in the RFID reader and card states,
  /// such as the presence or absence of a card and the connection status of the reader. It ensures
  /// that the internal state of the RFID reader is accurately updated in response to these events,
  /// facilitating the synchronization of the reader's state with its actual operational context.
  ///
  /// Invoked during the initialization phase of the RFID reader, this method is crucial for
  /// setting up the necessary mechanisms for state monitoring and event-driven behavior. It
  /// allows the reader to effectively communicate state changes to the rest of the application,
  /// enabling responsive and adaptive interactions based on the current status of the reader and card.
  ///
  /// Note: This is an internal configuration method and is not exposed as part of the public API.
  void _initializeCallbacks() {
    FlutterRfidPlatform.instance.setOnCardPresentCallback(() {
      _isCardPresent = true;

      _onCardPresent();
      notifyListeners();
    });

    FlutterRfidPlatform.instance.setOnCardAbsentCallback(() {
      _isCardPresent = false;

      _onCardAbsent();
      notifyListeners();
    });

    FlutterRfidPlatform.instance.setOnReaderConnectedCallback(() {
      _isConnected = true;

      _onReaderConnected();
      notifyListeners();
    });

    FlutterRfidPlatform.instance.setOnReaderDisconnectedCallback(() {
      _isConnected = false;
      _isCardPresent = false;

      _onReaderDisconnected();
      _onCardAbsent();
      notifyListeners();
    });
  }

  /// Authenticates a specified block with a provided key using standard security.
  ///
  /// This method performs authentication on a specified block using a key of a predefined length.
  /// It is designed to work with RFID tags that support standard authentication mechanisms.
  ///
  /// ## Parameters
  ///   - `blockNumber`: The block number to authenticate against.
  ///   - `key`: A list of integers representing the key used for authentication. Must be exactly 6 bytes long.
  ///
  /// ## Throws
  ///   - `Exception` if the key length is not 6 bytes, indicating an invalid key length.
  ///   - Other exceptions may be thrown based on lower-level API errors or authentication failures.
  ///
  /// ## Example
  /// ```dart
  /// await reader.authenticate(blockNumber: 4, key: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
  /// ```
  ///
  /// Note: The authentication mechanism and key management should adhere to the security requirements
  /// of the specific RFID system being interacted with.
  Future<void> authenticate({
    required int blockNumber,
    required List<int> key,
  });

  /// Performs 3DES authentication with a provided key.
  ///
  /// This advanced authentication method uses Triple DES encryption to securely authenticate
  /// with an RFID tag. It requires a properly formatted key and involves multiple steps of
  /// encryption and decryption to achieve authentication.
  ///
  /// ## Parameters
  ///   - `key`: A list of integers representing the 3DES key used for authentication. The key
  ///            length and format must comply with 3DES standards.
  ///
  /// ## Throws
  ///   - `Exception` for invalid responses during the authentication process, indicating potential
  ///     issues with the key, communication, or tag's response.
  ///
  /// ## Example
  /// ```dart
  /// await reader.authenticate3DES(key: [/* 24-byte 3DES key */]);
  /// ```
  ///
  /// Note: This method is intended for use with RFID systems that support 3DES authentication.
  /// Ensure that the key and system configurations are secure and conform to best practices.
  Future<void> authenticate3DES({
    required List<int> key,
  });

  /// Reads data from a specific block of an RFID tag.
  ///
  /// This method sends an APDU command to the RFID reader to read a specified amount of data
  /// from a given block number on the RFID tag. It is useful for retrieving stored information
  /// on the tag, such as identifiers or other data.
  ///
  /// ## Parameters
  ///   - `blockNumber`: The block number from which to read data.
  ///   - `length`: The number of bytes to read from the specified block.
  ///
  /// ## Returns
  ///   A list of integers representing the data read from the specified block.
  ///
  /// ## Throws
  ///   - Exceptions related to APDU transmission failures or if the RFID tag responds with an error.
  ///
  /// ## Example
  /// ```dart
  /// var data = await readBlock(blockNumber: 4, length: 16);
  /// print('Data read from block: $data');
  /// ```
  ///
  /// Note: Ensure the block number and length are within the limits supported by the RFID tag.
  Future<List<int>> readBlock({
    required int blockNumber,
    required int length,
  });

  /// Writes data to a specified block on an RFID tag.
  ///
  /// Sends an APDU command to the RFID reader to write provided data into a specified block number
  /// on the RFID tag. This method is essential for storing data on RFID tags.
  ///
  /// ## Parameters
  ///   - `blockNumber`: The block number where the data will be written.
  ///   - `data`: A list of integers (bytes) to write to the specified block.
  ///
  /// ## Throws
  ///   - Exceptions if the APDU command fails to transmit, if the data length exceeds the block size,
  ///     or if the RFID tag responds with an error.
  ///
  /// ## Example
  /// ```dart
  /// await writeBlock(blockNumber: 4, data: [0x01, 0x02, 0x03, 0x04]);
  /// ```
  ///
  /// Note: The size of the `data` list must not exceed the maximum block size of the RFID tag.
  Future<void> writeBlock({
    required int blockNumber,
    required List<int> data,
  });

  /// Transmits an APDU command to the RFID tag or smart card and receives a response.
  ///
  /// This method constructs an APDU command using the provided header and optional data,
  /// transmits it, and processes the response.
  ///
  /// ## Parameters
  ///   - `header`: The APDUHeader object representing the command header.
  ///   - `data`: Optional data for the APDU command.
  ///   - `le`: Optional expected length of the response data.
  ///
  /// ## Returns
  ///   An `ApduResponse` object containing the response data and status words.
  ///
  /// ## Throws
  ///   - `Exception` with error status words if the command execution fails.
  Future<ApduResponse> transmitApdu(
    ApduHeader header, {
    List<int>? data,
    int? le,
  }) async {
    List<int> apdu = header.toList();

    if (data != null) {
      apdu.add(data.length);
      apdu.addAll(data);
    }

    if (le != null) {
      apdu.add(le);
    }

    final result = await transmitRaw(Uint8List.fromList(apdu));

    final sw1 = result[result.length - 2];
    final sw2 = result[result.length - 1];

    final body = result.sublist(0, result.length - 2);

    if (sw1 == 0x90) {
      return ApduResponse(
        data: body,
        sw1: sw1,
        sw2: sw2,
      );
    } else {
      throw Exception('Error: $sw1 $sw2');
    }
  }

  /// Transmits raw data to the RFID reader and receives a response.
  ///
  /// This protected method is used internally to transmit raw data to the RFID reader
  /// and receive a response. It should not be called directly by external code.
  ///
  /// ## Parameters
  ///   - `data`: The raw data to transmit as a Uint8List.
  ///
  /// ## Returns
  ///   A `Uint8List` representing the raw response from the RFID reader.
  @protected
  @visibleForTesting
  Future<Uint8List> transmitRaw(Uint8List data) async {
    getAtr();
    return await FlutterRfidPlatform.instance.transmit(data);
  }

  /// Retrieves the Answer to Reset (ATR) from the RFID tag or smart card.
  ///
  /// ## Returns
  ///   A list of integers representing the ATR, or `null` if the ATR could not be retrieved.
  Future<List<int>?> getAtr() async {
    final atr = await FlutterRfidPlatform.instance.getAtr();

    if (atr == null) {
      return null;
    }

    return atr.toList();
  }

  /// Indicates whether the RFID reader is currently connected.
  ///
  /// Returns a boolean value representing the connection status of the RFID reader.
  /// True indicates that the reader is connected, while false indicates it is not.
  ///
  /// ## Example
  /// ```dart
  /// if (reader.isConnected) {
  ///   print('The reader is connected.');
  /// } else {
  ///   print('The reader is not connected.');
  /// }
  /// ```
  ///
  /// Note: This property can be polled or checked before attempting operations that require
  /// an active connection to the RFID reader.
  bool get isConnected {
    return _isConnected;
  }

  /// Indicates whether an RFID card is currently present within the reader's detection field.
  ///
  /// Returns a boolean value that is true if an RFID card is detected by the reader, and false otherwise.
  ///
  /// ## Example
  /// ```dart
  /// if (reader.isCardPresent) {
  ///   print('An RFID card is present.');
  /// } else {
  ///   print('No RFID card detected.');
  /// }
  /// ```
  ///
  /// Note: This property is useful for triggering card-specific operations, such as reading or writing data,
  /// only when a card is physically present.
  bool get isCardPresent {
    return _isCardPresent;
  }

  /// Triggers all registered callbacks associated with the reader's connection event.
  ///
  /// This method iterates through the list of callbacks registered for when the RFID reader becomes connected,
  /// invoking each callback in the order they were added. This is typically used to notify the application
  /// or the relevant components within the application that the RFID reader has successfully connected.
  ///
  /// ## Usage
  /// You do not call this method directly; it is called internally within the RFID reader implementation
  /// when a reader connection event occurs.
  void _onReaderConnected() {
    for (final callback in _onReaderConnectedCallbacks) {
      callback();
    }
  }

  /// Triggers all registered callbacks associated with the reader's disconnection event.
  ///
  /// Similar to [_onReaderConnected], this method iterates through the list of callbacks registered for
  /// when the RFID reader becomes disconnected, invoking each callback in sequence. This method is used
  /// to inform the application or its components that the RFID reader has been disconnected, allowing
  /// for appropriate response actions (e.g., updating UI, cleaning up resources, etc.).
  ///
  /// ## Usage
  /// This method is not meant to be called directly; it is invoked internally within the RFID reader
  /// implementation when a reader disconnection event is detected.
  void _onReaderDisconnected() {
    for (final callback in _onReaderDisconnectedCallbacks) {
      callback();
    }
  }

  /// Triggers all registered callbacks for the card present event.
  ///
  /// When an RFID card is detected by the reader, this method is called to notify all registered listeners
  /// about the presence of the card. Each callback in the list of card present callbacks is invoked in
  /// the order they were added.
  ///
  /// ## Usage
  /// This method is internally called within the RFID reader implementation when a card is detected.
  void _onCardPresent() {
    for (final callback in _onCardPresentCallbacks) {
      callback();
    }
  }

  /// Triggers all registered callbacks for the card absent event.
  ///
  /// This method is called when an RFID card is no longer detected by the reader, to notify all registered
  /// listeners about the absence of the card. Each callback in the list of card absent callbacks is invoked
  /// in the order they were added.
  ///
  /// ## Usage
  /// This method is internally called within the RFID reader implementation when a card is no longer present.
  void _onCardAbsent() {
    for (final callback in _onCardAbsentCallbacks) {
      callback();
    }
  }

  /// Adds a callback to be invoked when the RFID reader connects.
  ///
  /// Use this to register actions that should occur upon the successful connection
  /// of the RFID reader. It's particularly useful for UI updates or initiating
  /// operations that depend on the reader being connected.
  ///
  /// ## Example:
  /// ```dart
  /// reader.addOnReaderConnectedCallback(() {
  ///   print('Reader connected!');
  /// });
  /// ```
  void addOnReaderConnectedCallback(void Function() callback) {
    _onReaderConnectedCallbacks.add(callback);
  }

  /// Removes a previously registered callback for the RFID reader's connection event.
  ///
  /// Call this when you no longer need to be notified about the reader's connection status,
  /// or to prevent a callback from being called after it's no longer relevant, such as when
  /// a UI element is no longer visible or has been disposed.
  ///
  /// ## Example:
  /// ```dart
  /// reader.removeOnReaderConnectedCallback(myCallbackFunction);
  /// ```
  void removeOnReaderConnectedCallback(void Function() callback) {
    _onReaderConnectedCallbacks.remove(callback);
  }

  /// Adds a callback to be invoked when the RFID reader disconnects.
  ///
  /// This method allows for registering actions to take place once the RFID reader
  /// disconnects, which can be useful for cleanup tasks or UI updates to indicate
  /// the disconnection to the user.
  ///
  /// ## Example:
  /// ```dart
  /// reader.addOnReaderDisconnectedCallback(() {
  ///   print('Reader disconnected!');
  /// });
  /// ```
  void addOnReaderDisconnectedCallback(void Function() callback) {
    _onReaderDisconnectedCallbacks.add(callback);
  }

  /// Removes a previously registered callback for the RFID reader's disconnection event.
  ///
  /// Use this method to unregister callbacks that are no longer needed, preventing unnecessary
  /// actions from being performed when the reader disconnects.
  ///
  /// ## Example:
  /// ```dart
  /// reader.removeOnReaderDisconnectedCallback(myCallbackFunction);
  /// ```
  void removeOnReaderDisconnectedCallback(void Function() callback) {
    _onReaderDisconnectedCallbacks.remove(callback);
  }

  /// Adds a callback to be invoked when an RFID card is detected by the reader.
  ///
  /// Register a callback to be notified when an RFID card comes into the reader's
  /// field of detection. This is useful for triggering read or write operations
  /// automatically upon card presence.
  ///
  /// ## Example:
  /// ```dart
  /// reader.addOnCardPresentCallback(() {
  ///   print('Card detected!');
  /// });
  /// ```
  void addOnCardPresentCallback(void Function() callback) {
    _onCardPresentCallbacks.add(callback);
  }

  /// Removes a callback that was previously added to notify when an RFID card is present.
  ///
  /// If you need to stop certain actions from being triggered upon card detection,
  /// use this method to unregister the corresponding callback.
  ///
  /// ## Example:
  /// ```dart
  /// reader.removeOnCardPresentCallback(myCallbackFunction);
  /// ```
  void removeOnCardPresentCallback(void Function() callback) {
    _onCardPresentCallbacks.remove(callback);
  }

  /// Adds a callback to be invoked when the RFID reader no longer detects an RFID card.
  ///
  /// This is useful for triggering actions when an RFID card leaves the reader's
  /// detection field, such as updating UI elements to reflect the absence of the card.
  ///
  /// ## Example:
  /// ```dart
  /// reader.addOnCardAbsentCallback(() {
  ///   print('Card removed!');
  /// });
  /// ```
  void addOnCardAbsentCallback(void Function() callback) {
    _onCardAbsentCallbacks.add(callback);
  }

  /// Removes a previously registered callback for when an RFID card is no longer present.
  ///
  /// Use this method to clean up callbacks that should no longer be invoked when
  /// a card is removed from the reader's field.
  ///
  /// ## Example:
  /// ```dart
  /// reader.removeOnCardAbsentCallback(myCallbackFunction);
  /// ```
  void removeOnCardAbsentCallback(void Function() callback) {
    _onCardAbsentCallbacks.remove(callback);
  }
}
