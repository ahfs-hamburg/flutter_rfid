import 'package:dart_des/dart_des.dart';
import 'package:flutter/foundation.dart';

import '../../core/reader.dart';
import '../../protocols/adpu.dart';
import '../../utils/conversion.dart';
import '../../utils/generation.dart';
import 'models.dart';

/// A class representing the ACR122U NFC reader, extending [RFIDReader] capabilities.
///
/// The ACR122U class provides an interface to interact with the ACR122U NFC reader hardware,
/// facilitating operations such as card reading, authentication, and direct command transmission.
/// It manages the reader's connectivity state, detects card presence, and supports configuring
/// the reader's LED and buzzer behaviors. Callbacks can be registered for significant events
/// such as reader connection/disconnection and card presence/absence, allowing for custom
/// application logic to be executed in response.
///
/// Usage involves instantiating the class and optionally setting callback functions to handle
/// specific events. The class also implements methods to authenticate with cards using standard
/// or 3DES encryption, read and write data to cards, and directly transmit APDU commands.
///
/// ## Example
/// ```dart
/// var reader = ACR122U()
///   ..onReaderConnectedCallback = () => print('Reader connected')
///   ..onCardPresentCallback = () => print('Card detected');
///
/// await reader.authenticate(blockNumber: 4, key: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
/// ```
///
/// This class simplifies the integration of ACR122U reader functionalities into Dart and Flutter
/// applications, abstracting the complexities of direct hardware interaction.
class ACR122U extends RFIDReader {
  ACR122U({bool disableGreenLed = false, bool disableBuzzer = false})
      : super() {
    addOnCardPresentCallback(() {
      if (disableGreenLed) {
        controlLedBuzzer(
          redFinalState: true,
          greenFinalState: false,
          redInitialState: false,
          greenInitialState: false,
          redBlinking: false,
          greenBlinking: false,
          t1Duration: 0,
          t2Duration: 0,
          repetitions: 0,
          buzzerT1: false,
          buzzerT2: false,
        );
      }

      if (disableBuzzer) {
        setBuzzerOnDetection(enabled: false);
      }
    });
  }

  @override
  Future<void> authenticate({
    required int blockNumber,
    required List<int> key,
  }) async {
    if (key.length != 6) {
      throw Exception('Invalid key length');
    }

    const keyLocation = 0x00;

    await _loadKey(
      key: key,
      keyLocation: keyLocation,
    );

    await _authenticate(
      blockNumber: blockNumber,
      keyType: AuthenticationKeyType.A,
      keyLocation: keyLocation,
    );
  }

  @override
  Future<void> authenticate3DES({required List<int> key}) async {
    final a = getRandomBytes(length: 8);

    final ekBResponse = await transmitDirect(
      data: [0xD4, 0x42, 0x1A, 0x00],
    );

    if (ekBResponse.length != 12) {
      throw Exception('Invalid response');
    }

    final ekB = ekBResponse.sublist(4);

    final b = DES3(
      key: key,
      mode: DESMode.CBC,
      iv: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
    ).decrypt(ekB);

    final bDash = rotateListData(b, 1);

    final ekABDash = DES3(
      key: key,
      mode: DESMode.CBC,
      iv: ekB,
    ).encrypt(a + bDash).sublist(0, 16);

    final ekADashResponse = await transmitDirect(
      data: [0xD4, 0x42, 0xAF] + ekABDash,
    );

    if (ekADashResponse.length != 12) {
      throw Exception('Invalid response');
    }

    final ekADash = ekADashResponse.sublist(4, 12);

    final aDash = DES3(
      key: key,
      mode: DESMode.CBC,
      iv: ekABDash.sublist(8, 16),
    ).decrypt(ekADash);

    if (a.length != aDash.length) {
      throw Exception('Invalid response');
    }

    final aDashComp = rotateListData(a, 1);
    for (var i = 0; i < 8; i++) {
      if (aDashComp[i] != aDash[i]) {
        throw Exception('Invalid response');
      }
    }
  }

  /// Loads a cryptographic key into the specified location of the RFID reader.
  ///
  /// This method transmits an APDU command to the RFID reader to load a cryptographic key
  /// into a designated key storage location. It is used as part of the authentication process
  /// with RFID tags that require cryptographic keys.
  ///
  /// ## Parameters
  ///   - `key`: The cryptographic key to be loaded into the reader.
  ///   - `keyLocation`: The location (index) in the reader's key storage where the key should be loaded.
  ///
  /// ## Throws
  ///   - Exceptions related to APDU transmission failures or if the RFID reader responds with an error.
  ///
  /// ## Example
  /// ```dart
  /// await _loadKey(key: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF], keyLocation: 0x00);
  /// ```
  ///
  /// Note: This method is internal and should be used as part of a larger authentication or
  /// initialization process within the class.
  Future<void> _loadKey({
    required List<int> key,
    required int keyLocation,
  }) async {
    await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0x82,
        p1: 0x00,
        p2: keyLocation,
      ),
      data: key,
    );
  }

  /// Performs authentication with an RFID tag using a previously loaded cryptographic key.
  ///
  /// This method sends an APDU command to the RFID reader to authenticate a specific block
  /// of an RFID tag using one of the reader's stored cryptographic keys. The authentication
  /// can be performed using either Key Type A or Key Type B, depending on the requirements
  /// of the RFID system.
  ///
  /// ## Parameters
  ///   - `blockNumber`: The block number on the RFID tag to authenticate.
  ///   - `keyType`: The type of key to use for authentication (Key Type A or B).
  ///   - `keyLocation`: The location (index) in the reader's key storage of the key to use.
  ///
  /// ## Throws
  ///   - Exceptions related to APDU transmission failures or if the RFID reader or tag responds with an error.
  ///
  /// ## Example
  /// ```dart
  /// await _authenticate(blockNumber: 4, keyType: AuthenticationKeyType.A, keyLocation: 0x00);
  /// ```
  ///
  /// Note: This method is critical for ensuring secure communication with RFID tags that
  /// support cryptographic authentication. It should be used with a correct understanding
  /// of the RFID system's security requirements.
  Future<void> _authenticate({
    required int blockNumber,
    required AuthenticationKeyType keyType,
    required int keyLocation,
  }) async {
    await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0x86,
        p1: 0x00,
        p2: 0x00,
      ),
      data: [
        0x01, // Version
        0x00,
        blockNumber,
        keyType == AuthenticationKeyType.A ? 0x60 : 0x61,
        keyLocation,
      ],
    );
  }

  @override
  Future<List<int>> readBlock({
    required int blockNumber,
    required int length,
  }) async {
    return (await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0xB0,
        p1: 0x00,
        p2: blockNumber,
      ),
      le: length,
    ))
        .data;
  }

  @override
  Future<void> writeBlock({
    required int blockNumber,
    required List<int> data,
  }) async {
    await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0xD6,
        p1: 0x00,
        p2: blockNumber,
      ),
      data: data,
    );
  }

  /// Retrieves the firmware version of the RFID reader.
  ///
  /// This method sends a raw command to the RFID reader to request its firmware version,
  /// parsing the response into a human-readable string format.
  ///
  /// ## Returns
  ///   A `String` representing the firmware version of the RFID reader.
  ///
  /// ## Throws
  ///   - Exceptions if the command fails to transmit or if the response format is unexpected.
  ///
  /// ## Example
  /// ```dart
  /// var firmwareVersion = await getFirmwareVersion();
  /// print('RFID reader firmware version: $firmwareVersion');
  /// ```
  ///
  /// Note: This method can be used to verify the reader's software version or for diagnostic purposes.
  Future<String> getFirmwareVersion() async {
    final result = await transmitRaw(
      Uint8List.fromList([
        ...ApduHeader(
          classNumber: 0xFF,
          instruction: 0x00,
          p1: 0x48,
          p2: 0x00,
        ).toList(),
        0x00,
      ]),
    );

    return String.fromCharCodes(result);
  }

  /// Controls the LED and buzzer behavior on the RFID reader.
  ///
  /// This method enables detailed customization of the RFID reader's LED and buzzer behaviors,
  /// allowing for adjustments to the initial and final states of LEDs, controlling LED blinking,
  /// defining the duration for blinking cycles, and managing buzzer sounds during specific intervals.
  ///
  /// ## Parameters
  ///   - `redFinalState`: Optional final state of the red LED (on/off). If null, the state remains unchanged.
  ///   - `greenFinalState`: Optional final state of the green LED (on/off). If null, the state remains unchanged.
  ///   - `redInitialState`: The initial state of the red LED (on/off) before any blinking occurs.
  ///   - `greenInitialState`: The initial state of the green LED (on/off) before any blinking occurs.
  ///   - `redBlinking`: Determines whether the red LED should blink.
  ///   - `greenBlinking`: Determines whether the green LED should blink.
  ///   - `t1Duration`: The duration of the first part of the blinking cycle in milliseconds. Must be a multiple of 100ms.
  ///   - `t2Duration`: The duration of the second part of the blinking cycle in milliseconds. Must be a multiple of 100ms.
  ///   - `repetitions`: The number of blinking cycles to repeat.
  ///   - `buzzerT1`: Indicates whether the buzzer should be activated during the first part of the blinking cycle.
  ///   - `buzzerT2`: Indicates whether the buzzer should be activated during the second part of the blinking cycle.
  ///
  /// ## Returns
  ///   An `LedState` object reflecting the final states of the red and green LEDs.
  ///
  /// ## Throws
  ///   - `Exception` if the `t1Duration`, `t2Duration`, or `repetitions` parameters fall outside their acceptable ranges.
  ///
  /// ## Example
  /// ```dart
  /// var ledState = await controlLedBuzzer(
  ///   redInitialState: true,
  ///   greenInitialState: false,
  ///   t1Duration: 500,
  ///   t2Duration: 500,
  ///   repetitions: 3,
  ///   buzzerT1: true,
  ///   buzzerT2: false,
  /// );
  /// print('Red LED final state: ${ledState.red}');
  /// print('Green LED final state: ${ledState.green}');
  /// ```
  ///
  /// Note: Utilize this method to provide precise control over the visual and auditory feedback mechanisms of the RFID reader,
  /// enhancing the interactive experience for users.
  Future<LedState> controlLedBuzzer({
    bool? redFinalState,
    bool? greenFinalState,
    required bool redInitialState,
    required bool greenInitialState,
    bool redBlinking = false,
    bool greenBlinking = false,
    required int t1Duration,
    required int t2Duration,
    required int repetitions,
    bool buzzerT1 = false,
    bool buzzerT2 = false,
  }) async {
    if (t1Duration < 0 || 0xFF < t1Duration / 100) {
      throw Exception('Invalid t1Duration. Must be between 0ms and 25500ms');
    }

    if (t1Duration % 100 != 0) {
      throw Exception('Invalid t1Duration. Must be a multiple of 100ms');
    }

    if (t2Duration < 0 || 0xFF < t2Duration / 100) {
      throw Exception('Invalid t2Duration. Must be between 0ms and 25500ms');
    }

    if (t2Duration % 100 != 0) {
      throw Exception('Invalid t2Duration. Must be a multiple of 100ms');
    }

    if (repetitions < 0 || 0xFF < repetitions) {
      throw Exception('Invalid repetitions. Must be between 0 and 255');
    }

    final ledControlByte = int.parse(
      [
        greenBlinking ? '1' : '0',
        redBlinking ? '1' : '0',
        greenInitialState ? '1' : '0',
        redInitialState ? '1' : '0',
        greenFinalState != null ? '1' : '0',
        redFinalState != null ? '1' : '0',
        greenFinalState == true ? '1' : '0',
        redFinalState == true ? '1' : '0',
      ].join(''),
      radix: 2,
    );

    final buzzerControlByte = int.parse(
      [
        buzzerT2 ? '1' : '0',
        buzzerT1 ? '1' : '0',
      ].join(''),
      radix: 2,
    );

    final result = await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0x00,
        p1: 0x40,
        p2: ledControlByte,
      ),
      data: [
        t1Duration ~/ 100,
        t2Duration ~/ 100,
        repetitions,
        buzzerControlByte,
      ],
    );

    return LedState(
      red: result.sw2 & 0x01 == 0x01,
      green: result.sw2 & 0x02 == 0x02,
    );
  }

  /// Enables or disables the buzzer to sound upon card detection.
  ///
  /// This method configures the RFID reader to activate its buzzer when an RFID card is detected,
  /// providing audible feedback based on the enabled state.
  ///
  /// ## Parameters
  ///   - `enabled`: A boolean value indicating whether the buzzer should be enabled (true) or disabled (false).
  ///
  /// ## Throws
  ///   - Exceptions related to APDU transmission failures or if the RFID reader responds with an error.
  ///
  /// ## Example
  /// ```dart
  /// await setBuzzerOnDetection(enabled: true); // Enables the buzzer on card detection.
  /// ```
  ///
  /// Note: This configuration is particularly useful in scenarios requiring immediate user feedback
  /// upon card presence or absence.
  Future<void> setBuzzerOnDetection({required bool enabled}) async {
    await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0x00,
        p1: 0x52,
        p2: enabled ? 0xFF : 0x00,
      ),
      le: 0x00,
    );
  }

  /// Transmits a direct command to the RFID reader and returns the response.
  ///
  /// Sends a raw APDU command directly to the RFID reader, bypassing higher-level abstractions.
  /// This method allows for custom commands to be executed, providing flexibility for advanced operations.
  ///
  /// ## Parameters
  ///   - `data`: A list of integers representing the command to be transmitted to the reader.
  ///
  /// ## Returns
  ///   A list of integers representing the reader's response to the command.
  ///
  /// ## Throws
  ///   - Exceptions if the APDU command fails to transmit or if the response format is unexpected.
  ///
  /// ## Example
  /// ```dart
  /// var response = await transmitDirect(data: [0x00, 0xA4, 0x04, 0x00, 0x08]);
  /// print('Direct command response: $response');
  /// ```
  ///
  /// Note: Use with caution, as direct commands require detailed knowledge of the RFID reader's protocol.
  Future<List<int>> transmitDirect({required List<int> data}) async {
    return (await transmitApdu(
      ApduHeader(
        classNumber: 0xFF,
        instruction: 0x00,
        p1: 0x00,
        p2: 0x00,
      ),
      data: data,
    ))
        .data;
  }
}
