import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:iriscv_board/riscv/emulator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RISC-V Emulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmulatorHomePage(),
    );
  }
}

class EmulatorHomePage extends StatefulWidget {
  @override
  _EmulatorHomePageState createState() => _EmulatorHomePageState();
}

class _EmulatorHomePageState extends State<EmulatorHomePage> {
  String _status = "Press the button to load a binary file.";

  void _loadAndRunBinary() async {
    // Use file_picker to select a binary file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      File binaryFile = File(result.files.single.path!);

      // Read the file and create a byte buffer
      Uint8List fileBytes = await binaryFile.readAsBytes();

      // Initialize the emulator components
      Emulator emulator = Emulator(memorySize: fileBytes.length);

      // Load the binary file into memory (this would be emulator specific)
      emulator.load(fileBytes);

      // Run the emulator
      emulator.run(); // This should be designed to not block the UI thread

      setState(() {
        _status = "Emulation started.";
      });
    } else {
      // User canceled the picker
      setState(() {
        _status = "File load cancelled.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RISC-V Emulator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _status,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAndRunBinary,
              child: const Text('Load and Run Binary'),
            ),
          ],
        ),
      ),
    );
  }
}
