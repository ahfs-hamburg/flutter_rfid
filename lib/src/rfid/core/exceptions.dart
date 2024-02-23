/// A custom exception for general RFID operation errors.
///
/// Represents errors that occur during RFID interactions, encapsulating the error message for easy identification.
class RFIDException implements Exception {
  final String message;
  RFIDException(this.message);

  @override
  String toString() => 'RFIDException: $message';
}

/// Indicates an attempt to access an invalid block number on an RFID tag.
///
/// This exception is thrown when operations are requested on block numbers that are outside the valid range of the RFID tag's memory.
class InvalidBlockException extends RFIDException {
  InvalidBlockException(String detail) : super('Invalid block: $detail');
}

/// Signifies invalid data provided for RFID tag operations.
///
/// Thrown when the data intended for writing to an RFID tag does not meet the required specifications, such as incorrect length or byte values outside the valid range.
class InvalidDataException extends RFIDException {
  InvalidDataException(String detail) : super('Invalid data: $detail');
}

/// Represents failures in RFID tag authentication processes.
///
/// This exception is raised during unsuccessful authentication attempts with an RFID tag, such as when using an incorrect key or encountering communication issues.
class AuthenticationException extends RFIDException {
  AuthenticationException(String detail)
      : super('Authentication failed: $detail');
}
