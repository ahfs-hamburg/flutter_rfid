/// Represents the header of an APDU (Application Protocol Data Unit) command.
///
/// This class encapsulates the basic elements of an APDU header, including the
/// class number, instruction code, and parameters P1 and P2. It is used to
/// construct APDU commands for communication with smart cards or RFID tags.
///
/// ## Parameters
///   - `classNumber`: The class byte of the APDU command, indicating the type of command.
///   - `instruction`: The instruction byte of the APDU command, indicating the specific command.
///   - `p1`: The first parameter for the instruction.
///   - `p2`: The second parameter for the instruction.
///
/// ## Example
/// ```dart
/// var header = ApduHeader(classNumber: 0x00, instruction: 0xA4, p1: 0x04, p2: 0x00);
/// ```
class ApduHeader {
  final int classNumber;
  final int instruction;
  final int p1;
  final int p2;

  ApduHeader({
    required this.classNumber,
    required this.instruction,
    required this.p1,
    required this.p2,
  });

  /// Converts the APDU header into a list of integers.
  ///
  /// ## Returns
  ///   A list of integers representing the APDU header.
  List<int> toList() {
    return [
      classNumber,
      instruction,
      p1,
      p2,
    ];
  }
}

/// Represents the response from an APDU command.
///
/// This class encapsulates the response data from an APDU command, including
/// the data payload and the status words SW1 and SW2, which indicate the result
/// of the command execution.
///
/// ## Parameters
///   - `data`: The data returned by the command, if any.
///   - `sw1`: The first status word of the APDU response.
///   - `sw2`: The second status word of the APDU response.
///
/// ## Example
/// ```dart
/// var response = ApduResponse(data: [0x90, 0x00], sw1: 0x90, sw2: 0x00);
/// ```
class ApduResponse {
  final List<int> data;
  final int sw1;
  final int sw2;

  ApduResponse({
    required this.data,
    required this.sw1,
    required this.sw2,
  });
}
