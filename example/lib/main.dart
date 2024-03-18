import 'package:flutter/material.dart';
import 'package:flutter_rfid/cards/mifare_ultralight_c.dart';
import 'package:flutter_rfid/readers/acr122u.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ACR122U _reader;
  late final MifareUltralightC _card;

  @override
  void initState() {
    super.initState();

    _reader = ACR122U();
    _card = MifareUltralightC(reader: _reader);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter RFID'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (!_reader.isConnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reader is not connected'),
                ),
              );
              return;
            }

            if (!_reader.isCardPresent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Card is not present'),
                ),
              );
              return;
            }

            try {
              final data = await _card.readData(blockNumber: 0x04, length: 4);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data: $data'),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error while reading: $e'),
                ),
              );
            }
          },
          child: const Text('Read data from card'),
        ),
      ),
    );
  }
}
