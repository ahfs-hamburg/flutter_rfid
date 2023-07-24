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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
