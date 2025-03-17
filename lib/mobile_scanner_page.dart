// file: mobile_scanner_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerPage extends StatelessWidget {
  const MobileScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("iOS Scanner")),
      body: MobileScanner(
        onDetect: (capture) {
          final Barcode barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null) {
            print('MobileScanner result: $code');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Scanned: $code')));
          }
        },
      ),
    );
  }
}
