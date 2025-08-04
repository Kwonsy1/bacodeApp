import 'package:flutter/material.dart';
import 'package:bacodeapp/screens/barcode_scanner_screen.dart';

void main() {
  runApp(const BarcodeApp());
}

class BarcodeApp extends StatelessWidget {
  const BarcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BarcodeScannerScreen(),
    );
  }
}

