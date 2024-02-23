import CryptoTokenKit

class Reader: NSObject {
  weak var delegate: ReaderDelegate?
  var manager: TKSmartCardSlotManager?
  var slot: TKSmartCardSlot?
  var card: TKSmartCard?

  private override init() {
    manager = TKSmartCardSlotManager.default
    super.init()
  }

  static func createInstance() -> Reader? {
    guard TKSmartCardSlotManager.default != nil else {
      print("TKSmartCardSlotManager.default is nil.")
      return nil
    }

    let instance = Reader()
    instance.observeSlotNamesChanges()
    instance.scanForReader()
    return instance
  }

  func observeSlotNamesChanges() {
    manager?.addObserver(self, forKeyPath: "slotNames", options: .new, context: nil)
  }

  func observeSlotStateChanges() {
    guard let slot = slot else { return }
    slot.addObserver(self, forKeyPath: "state", options: .new, context: nil)
  }

  deinit {
    manager?.removeObserver(self, forKeyPath: "slotNames")
    slot?.removeObserver(self, forKeyPath: "state")
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    DispatchQueue.main.async {
      if keyPath == "slotNames" {
        self.scanForReader()
      } else if keyPath == "state" {
        self.scanForCard()
      }
    }
  }

  func scanForReader() {
    guard let slotNames = manager?.slotNames, !slotNames.isEmpty else {
      self.slot = nil
      self.card = nil
      delegate?.didUpdateReaderState(success: false)
      return
    }

    let slotName = slotNames[0]
    manager?.getSlot(withName: slotName) { slot in
      self.slot = slot
      self.delegate?.didUpdateReaderState(success: slot != nil)
      if slot != nil {
        self.observeSlotStateChanges()
      }
    }
  }

  func scanForCard() {
    guard let state = slot?.state else {
      self.card?.endSession()
      self.card = nil
      delegate?.didUpdateCardState(success: false)
      return
    }

    switch state {
    case .validCard:
      processValidCard()

    case .empty:
      self.card?.endSession()
      self.card = nil
      delegate?.didUpdateCardState(success: false)

    default:
      break
    }
  }

  private func processValidCard() {
    if self.card == nil || !(self.card?.isValid ?? false) {
      guard let card = slot?.makeSmartCard() else {
        self.card?.endSession()
        self.card = nil
        delegate?.didUpdateCardState(success: false)
        return
      }

      card.beginSession(reply: { success, error in
        if success && error == nil {
          self.card = card
          self.delegate?.didUpdateCardState(success: true)
        } else {
          self.card = nil
          self.delegate?.didUpdateCardState(success: false)
        }
      })
    } else {
      delegate?.didUpdateCardState(success: true)
    }
  }

  func transmit(data: [UInt8], result: @escaping (Data) -> Void) {
    let dataObj = Data(data)
    card?.transmit(dataObj) { data, error in
      if let error = error {
        print("Transmission error: \(error.localizedDescription)")
        result(Data())
        return
      }

      if let data = data {
        result(data)
      } else {
        result(Data())
      }
    }
  }
}

protocol ReaderDelegate: AnyObject {
  func didUpdateReaderState(success: Bool)
  func didUpdateCardState(success: Bool)
}
