import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_rfid/flutter_rfid_platform_interface.dart';
import 'package:flutter_rfid/src/rfid/core/reader.dart';
import 'package:flutter_rfid/src/rfid/protocols/adpu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterRfidPlatform
    with MockPlatformInterfaceMixin
    implements FlutterRfidPlatform {
  final List<VoidCallback> onReaderConnectedCallbacks = [];
  final List<VoidCallback> onReaderDisconnectedCallbacks = [];
  final List<VoidCallback> onCardPresentCallbacks = [];
  final List<VoidCallback> onCardAbsentCallbacks = [];

  @override
  Future<void> scanForReader() async {}

  @override
  Future<void> scanForCard() async {}

  @override
  Future<Uint8List> transmit(Uint8List data) {
    if (data[1] == 0xFF) {
      return Future.value(Uint8List.fromList([0x63, 0x00]));
    }

    return Future.value(Uint8List.fromList([0x90, 0x00]));
  }

  @override
  Future<Uint8List?> getAtr() {
    return Future.value(null);
  }

  @override
  void setOnReaderConnectedCallback(VoidCallback callback) {
    onReaderConnectedCallbacks.add(callback);
  }

  @override
  void setOnReaderDisconnectedCallback(VoidCallback callback) {
    onReaderDisconnectedCallbacks.add(callback);
  }

  @override
  void setOnCardPresentCallback(VoidCallback callback) {
    onCardPresentCallbacks.add(callback);
  }

  @override
  void setOnCardAbsentCallback(VoidCallback callback) {
    onCardAbsentCallbacks.add(callback);
  }

  void callReaderConnected() {
    for (final callback in onReaderConnectedCallbacks) {
      callback();
    }
  }

  void callReaderDisconnected() {
    for (final callback in onReaderDisconnectedCallbacks) {
      callback();
    }
  }

  void callCardPresent() {
    for (final callback in onCardPresentCallbacks) {
      callback();
    }
  }

  void callCardAbsent() {
    for (final callback in onCardAbsentCallbacks) {
      callback();
    }
  }
}

class MockedReader extends RFIDReader {
  static const BLOCK_SIZE = 4;
  static const DATA_ADDRESS_START = 4;
  static const DATA_ADDRESS_END = 39;

  var data = List<int>.generate(
      ((DATA_ADDRESS_END + 1) - DATA_ADDRESS_START) * BLOCK_SIZE,
      (index) => index);

  @override
  Future<List<int>> readBlock({
    required int blockNumber,
    required int length,
  }) {
    final startIndex = (blockNumber - DATA_ADDRESS_START) * BLOCK_SIZE;

    return Future.value(
      data.sublist(startIndex, startIndex + length),
    );
  }

  @override
  Future<bool> writeBlock({
    required int blockNumber,
    required List<int> data,
  }) {
    final startIndex = (blockNumber - DATA_ADDRESS_START) * BLOCK_SIZE;

    // Update the specified block with the new data
    for (int i = 0; i < data.length; i++) {
      if (startIndex + i < this.data.length) {
        this.data[startIndex + i] = data[i];
      }
    }

    return Future.value(true);
  }

  @override
  Future<bool> authenticate({
    required int blockNumber,
    required List<int> key,
  }) {
    return Future.value(true);
  }

  @override
  Future<bool> authenticate3DES({
    required List<int> key,
  }) {
    return Future.value(true);
  }
}

void main() {
  group('RFIDReader', () {
    late MockFlutterRfidPlatform platform;
    late RFIDReader reader;

    setUp(() {
      platform = MockFlutterRfidPlatform();
      FlutterRfidPlatform.instance = platform;
      reader = MockedReader();
    });

    group('transmitApdu', () {
      test('should return the response from the platform', () async {
        final response = await reader.transmitApdu(
          ApduHeader(
            classNumber: 0x00,
            instruction: 0x00,
            p1: 0x00,
            p2: 0x00,
          ),
          data: Uint8List.fromList([0x00]),
        );

        expect(response.sw1, equals(0x90));
        expect(response.sw2, equals(0x00));
        expect(response.data, equals([]));
      });

      test('should throw an exception if the data is empty', () async {
        try {
          await reader.transmitApdu(
            ApduHeader(
              classNumber: 0x00,
              instruction: 0xFF,
              p1: 0x00,
              p2: 0x00,
            ),
            data: Uint8List(0),
          );

          fail('Should have thrown an exception');
        } catch (e) {
          expect(e.toString(), equals('Exception: Error: 99 0'));
        }
      });
    });

    group('onReaderConnectedCallback', () {
      test('should call the callback when the reader is connected', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnReaderConnectedCallback(callback);

        expect(callbackCalled, equals(false));

        platform.callReaderConnected();

        expect(callbackCalled, equals(true));
      });

      test('should remove the callback when the reader is disconnected', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnReaderConnectedCallback(callback);

        expect(callbackCalled, equals(false));

        reader.removeOnReaderConnectedCallback(callback);
        platform.callReaderConnected();

        expect(callbackCalled, equals(false));
      });
    });

    group('onReaderDisconnectedCallback', () {
      test('should call the callback when the reader is disconnected', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnReaderDisconnectedCallback(callback);

        expect(callbackCalled, equals(false));

        platform.callReaderDisconnected();

        expect(callbackCalled, equals(true));
      });

      test('should remove the callback when the reader is disconnected', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnReaderDisconnectedCallback(callback);

        expect(callbackCalled, equals(false));

        reader.removeOnReaderDisconnectedCallback(callback);
        platform.callReaderDisconnected();

        expect(callbackCalled, equals(false));
      });
    });

    group('onCardPresentCallback', () {
      test('should call the callback when a card is present', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardPresentCallback(callback);

        expect(callbackCalled, equals(false));

        platform.callCardPresent();

        expect(callbackCalled, equals(true));
      });

      test('should remove the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardPresentCallback(callback);

        expect(callbackCalled, equals(false));

        reader.removeOnCardPresentCallback(callback);
        platform.callCardPresent();

        expect(callbackCalled, equals(false));
      });
    });

    group('onCardAbsentCallback', () {
      test('should call the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardAbsentCallback(callback);

        expect(callbackCalled, equals(false));

        platform.callCardAbsent();

        expect(callbackCalled, equals(true));
      });

      test('should remove the callback when a card is absent', () {
        bool callbackCalled = false;

        void callback() {
          callbackCalled = true;
        }

        reader.addOnCardAbsentCallback(callback);

        expect(callbackCalled, equals(false));

        reader.removeOnCardAbsentCallback(callback);
        platform.callCardAbsent();

        expect(callbackCalled, equals(false));
      });
    });
  });
}
