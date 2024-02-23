import 'models.dart';

/// Represents the operating parameters for PICC (Proximity Integrated Circuit Card) devices.
///
/// This class encapsulates various settings related to the operation of PICC devices,
/// including polling behavior, ATS (Answer to Select) generation, polling intervals,
/// and the types of cards to detect. It provides a structured way to specify these
/// parameters, which can be critical for applications involving RFID and NFC card reading.
///
/// ## Properties
///   - `autoPiccPolling`: Determines whether automatic polling of PICC devices is enabled.
///   - `autoAtsGeneration`: Determines whether automatic ATS generation is enabled.
///   - `pollInterval`: Specifies the polling interval, chosen from predefined `PollInterval` values.
///   - `detectFeliCa424K`: Enables detection of FeliCa cards operating at 424 Kbps.
///   - `detectFeliCa212K`: Enables detection of FeliCa cards operating at 212 Kbps.
///   - `detectTopaz`: Enables detection of Topaz cards.
///   - `detectIso14443TypeB`: Enables detection of ISO/IEC 14443 Type B cards.
///   - `detectIso14443TypeA`: Enables detection of ISO/IEC 14443 Type A cards.
///
/// The class also provides a factory constructor `fromByte` to create an instance from a byte value,
/// allowing for easy serialization and deserialization of operating parameters.
///
/// ## Example
/// ```dart
/// var params = PiccOperatingParameter.fromByte(0xFF);
/// print(params.autoPiccPolling); // true
/// print(params.pollInterval); // PollInterval.ms250
/// ```
///
/// The `fromByte` factory constructor interprets the byte according to bit flags,
/// with each bit representing a different parameter setting.
class PiccOperatingParameter {
  final bool autoPiccPolling;
  final bool autoAtsGeneration;
  final PollInterval pollInterval;
  final bool detectFeliCa424K;
  final bool detectFeliCa212K;
  final bool detectTopaz;
  final bool detectIso14443TypeB;
  final bool detectIso14443TypeA;

  PiccOperatingParameter({
    required this.autoPiccPolling,
    required this.autoAtsGeneration,
    required this.pollInterval,
    required this.detectFeliCa424K,
    required this.detectFeliCa212K,
    required this.detectTopaz,
    required this.detectIso14443TypeB,
    required this.detectIso14443TypeA,
  });

  /// Factory constructor to create a `PiccOperatingParameter` instance from a byte value.
  ///
  /// The byte value's bits are used to set the parameters, with specific bits mapped to
  /// specific settings as follows:
  /// - 7th bit (0x80): `autoPiccPolling`
  /// - 6th bit (0x40): `autoAtsGeneration`
  /// - 5th bit (0x20): `pollInterval`
  /// - 4th bit (0x10): `detectFeliCa424K`
  /// - 3rd bit (0x08): `detectFeliCa212K`
  /// - 2nd bit (0x04): `detectTopaz`
  /// - 1st bit (0x02): `detectIso14443TypeB`
  /// - 0th bit (0x01): `detectIso14443TypeA`
  ///
  /// ## Parameters
  ///   - `byte`: The byte value representing the operating parameters.
  ///
  /// ## Returns
  ///   An instance of `PiccOperatingParameter` configured according to the byte value.
  factory PiccOperatingParameter.fromByte(int byte) {
    return PiccOperatingParameter(
      autoPiccPolling: byte & 0x80 == 0x80,
      autoAtsGeneration: byte & 0x40 == 0x40,
      pollInterval:
          byte & 0x20 == 0x20 ? PollInterval.ms250 : PollInterval.ms500,
      detectFeliCa424K: byte & 0x10 == 0x10,
      detectFeliCa212K: byte & 0x08 == 0x08,
      detectTopaz: byte & 0x04 == 0x04,
      detectIso14443TypeB: byte & 0x02 == 0x02,
      detectIso14443TypeA: byte & 0x01 == 0x01,
    );
  }
}
