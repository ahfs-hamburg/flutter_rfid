
import 'flutter_rfid_platform_interface.dart';

class FlutterRfid {
  Future<String?> getPlatformVersion() {
    return FlutterRfidPlatform.instance.getPlatformVersion();
  }
}
