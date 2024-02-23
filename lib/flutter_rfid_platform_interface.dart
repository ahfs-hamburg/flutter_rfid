import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_rfid_method_channel.dart';

abstract class FlutterRfidPlatform extends PlatformInterface {
  /// Constructs a FlutterRfidPlatform.
  FlutterRfidPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterRfidPlatform _instance = MethodChannelFlutterRfid();

  /// The default instance of [FlutterRfidPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterRfid].
  static FlutterRfidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterRfidPlatform] when
  /// they register themselves.
  static set instance(FlutterRfidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> scanForReader() {
    throw UnimplementedError('scanForReader() has not been implemented.');
  }

  Future<void> scanForCard() {
    throw UnimplementedError('scanForCard() has not been implemented.');
  }

  Future<Uint8List> transmit(Uint8List data) {
    throw UnimplementedError('transmit() has not been implemented.');
  }

  Future<Uint8List?> getAtr() {
    throw UnimplementedError('getAtr() has not been implemented.');
  }

  void setOnReaderConnectedCallback(VoidCallback callback) {
    throw UnimplementedError(
        'setOnReaderConnectedCallback() has not been implemented.');
  }

  void setOnReaderDisconnectedCallback(VoidCallback callback) {
    throw UnimplementedError(
        'setOnReaderDisconnectedCallback() has not been implemented.');
  }

  void setOnCardPresentCallback(VoidCallback callback) {
    throw UnimplementedError(
        'setOnCardPresentCallback() has not been implemented.');
  }

  void setOnCardAbsentCallback(VoidCallback callback) {
    throw UnimplementedError(
        'setOnCardAbsentCallback() has not been implemented.');
  }
}
