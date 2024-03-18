import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_rfid_platform_interface.dart';

/// An implementation of [FlutterRfidPlatform] that uses method channels.
class MethodChannelFlutterRfid extends FlutterRfidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_rfid');

  VoidCallback? onReaderConnectedCallback;
  VoidCallback? onReaderDisconnectedCallback;
  VoidCallback? onCardPresentCallback;
  VoidCallback? onCardAbsentCallback;

  MethodChannelFlutterRfid() {
    _init();
  }

  // Receive data from native platform
  Future<void> _init() async {
    WidgetsFlutterBinding.ensureInitialized();
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onReaderConnected':
          _onReaderConnected();
          break;
        case 'onReaderDisconnected':
          _onReaderDisconnected();
          break;
        case 'onCardPresent':
          _onCardPresent();
          break;
        case 'onCardAbsent':
          _onCardAbsent();
          break;
      }
    });
  }

  @override
  Future<void> scanForReader() async {
    await methodChannel.invokeMethod<void>('scanForReader');
  }

  @override
  Future<void> scanForCard() async {
    await methodChannel.invokeMethod<void>('scanForCard');
  }

  @override
  Future<Uint8List> transmit(Uint8List data) async {
    final result =
        await methodChannel.invokeMethod<Uint8List>('transmit', {'data': data});
    return result!;
  }

  @override
  Future<Uint8List?> getAtr() async {
    final result = await methodChannel.invokeMethod<Uint8List>('getAtr');
    return result!;
  }

  void _onReaderConnected() {
    if (onReaderConnectedCallback != null) {
      onReaderConnectedCallback!();
    }
  }

  void _onReaderDisconnected() {
    if (onReaderDisconnectedCallback != null) {
      onReaderDisconnectedCallback!();
    }
  }

  void _onCardPresent() {
    if (onCardPresentCallback != null) {
      onCardPresentCallback!();
    }
  }

  void _onCardAbsent() {
    if (onCardAbsentCallback != null) {
      onCardAbsentCallback!();
    }
  }

  @override
  void setOnReaderConnectedCallback(VoidCallback callback) {
    onReaderConnectedCallback = callback;
  }

  @override
  void setOnReaderDisconnectedCallback(VoidCallback callback) {
    onReaderDisconnectedCallback = callback;
  }

  @override
  void setOnCardPresentCallback(VoidCallback callback) {
    onCardPresentCallback = callback;
  }

  @override
  void setOnCardAbsentCallback(VoidCallback callback) {
    onCardAbsentCallback = callback;
  }
}
