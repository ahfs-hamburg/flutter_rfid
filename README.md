# flutter_rfid

[![Dart tests](https://github.com/ahfs-hamburg/flutter_rfid/actions/workflows/ci.yml/badge.svg)](https://github.com/ahfs-hamburg/flutter_rfid/actions/workflows/ci.yml) [![Coverage Status](https://coveralls.io/repos/github/ahfs-hamburg/flutter_rfid/badge.svg?branch=main)](https://coveralls.io/github/ahfs-hamburg/flutter_rfid?branch=main) [![pub package](https://img.shields.io/pub/v/flutter_rfid.svg)](https://pub.dev/packages/flutter_rfid)

A Flutter plugin that provides integration with RFID readers, enabling Flutter applications to communicate with RFID tags. (iOS only)

## Supported Readers

| Reader      | iOS |
| ----------- | --- |
| ASC ACR122U | ✅  |

## Supported Cards

| Card                | iOS |
| ------------------- | --- |
| MIFARE Ultralight C | ✅  |

## Usage

To use this plugin, add `flutter_rfid` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

```dart
import 'package:flutter_rfid/flutter_rfid.dart';

RFIDReader reader = ACR122U();
MifareUltralightC card = MifareUltralightC(reader: reader);

// Read data from a MIFARE Ultralight C card
List<int> data = await card.readData(blockNumber: 4, length: 4);

// Write data to a MIFARE Ultralight C card
await card.writeData(blockNumber: 4, data: [0x01, 0x02, 0x03, 0x04]);
```
