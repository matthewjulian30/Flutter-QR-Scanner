import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_qrscan/textpage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _hasNavigated = false; // Untuk mencegah spam navigasi

  // reassemble digunakan untuk restart kamera di Android
  // digunakan untuk fitur pause dan resume
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  // WIdget utama untuk tampilan UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 7, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.only(left: 50,right: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (result != null)
                      Text(
                        // 'Barcode Type: ${describeEnum(result!.format)}\nData: ${result!.code}',
                        '${result!.code}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     _buildButton('Flash', () async {
                    //       await controller?.toggleFlash();
                    //       setState(() {});
                    //     }, controller?.getFlashStatus()),
                    //     _buildButton('Flip Camera', () async {
                    //       await controller?.flipCamera();
                    //       setState(() {});
                    //     }, controller?.getCameraInfo()),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     _buildSimpleButton('Pause', () async {
                    //       await controller?.pauseCamera();
                    //     }),
                    //     _buildSimpleButton('Resume', () async {
                    //       await controller?.resumeCamera();
                    //     }),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget QR Scanner
  // scanArea -> ukuran area pemindaian berdasarkan ukuran layar
  // QRView
  // onQRViewCreated -> callback ketika scanner dibuat
  // overlay -> memberikan bentuk overlay dengan border merah
  // onPermissionSet -> callback ketika izin kamera diberikan atau ditolak
  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 150.0
            : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  // Menangani hasil scan
  // _onQRViewCreated
  // Menghubungkan controller QR scanner ke variabel controller
  // Hasil scan real time akan masuk ke result jika ada
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!_hasNavigated && scanData.code == 'http://en.m.wikipedia.org') {
        _hasNavigated = true; // Mencegah navigasi berulang
        controller.pauseCamera(); // Pause kamera agar tidak scan ulang

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TextPage()),
          ).then((_) {
            setState(() {
              _hasNavigated = false; // Reset setelah kembali dari page
              controller.resumeCamera(); // Resume kamera setelah kembali
            });
          });
        });
      }

      setState(() {
        result = scanData;
      });
    });
  }

  // Menangani izin kamera
  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No Permission')));
    }
  }

  // // Digunakan untuk tombol flash & flip camera
  // Widget _buildButton(
  //   String text,
  //   VoidCallback onPressed,
  //   Future<dynamic>? future,
  // ) {
  //   return Container(
  //     margin: const EdgeInsets.all(8),
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       child: FutureBuilder(
  //         future: future,
  //         builder: (context, snapshot) {
  //           return Text('$text: ${snapshot.data}');
  //         },
  //       ),
  //     ),
  //   );
  // }

  // // Digunakan untuk tombol pause & resume camera
  // Widget _buildSimpleButton(String text, VoidCallback onPressed) {
  //   return Container(
  //     margin: const EdgeInsets.all(8),
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       child: Text(text, style: const TextStyle(fontSize: 20)),
  //     ),
  //   );
  // }
}
