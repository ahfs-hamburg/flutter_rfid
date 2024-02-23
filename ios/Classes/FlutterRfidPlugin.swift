import CryptoTokenKit
import Flutter
import UIKit

public class FlutterRfidPlugin: NSObject, FlutterPlugin {
  private var reader: Reader?
  private var channel: FlutterMethodChannel?

  override init() {
    super.init()
    initializeReader()
  }

  private func initializeReader() {
    if let readerInstance = Reader.createInstance() {
      readerInstance.delegate = self
      self.reader = readerInstance
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_rfid", binaryMessenger: registrar.messenger())
    let instance = FlutterRfidPlugin()
    instance.setMethodChannel(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func setMethodChannel(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "scanForReader":
      reader?.scanForReader()

    case "scanForCard":
      reader?.scanForCard()

    case "transmit":
      guard let args = call.arguments as? [String: FlutterStandardTypedData],
        let data = args["data"]?.data
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Data is missing", details: nil))
        return
      }
      reader?.transmit(data: [UInt8](data), result: result)

    case "getAtr":
      guard let atr = reader?.slot?.atr else {
        result(FlutterError(code: "NO_ATR", message: "ATR not available", details: nil))
        return
      }
      result(atr.bytes)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

extension FlutterRfidPlugin: ReaderDelegate {
  func didUpdateReaderState(success: Bool) {
    DispatchQueue.main.async {
      self.channel?.invokeMethod(
        success ? "onReaderConnected" : "onReaderDisconnected", arguments: nil)
    }
  }

  func didUpdateCardState(success: Bool) {
    DispatchQueue.main.async {
      self.channel?.invokeMethod(success ? "onCardPresent" : "onCardAbsent", arguments: nil)
    }
  }
}
