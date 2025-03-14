import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_qrscan/textpage.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                      'Barcode Type: ${(result!.format)}   Data: ${result!.code}',
                    )
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text('Flash: ${snapshot.data}');
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Text(
                                  'Camera facing ${(snapshot.data!)}',
                                );
                              } else {
                                return const Text('loading');
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text(
                            'pause',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text(
                            'resume',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea =
        (MediaQuery.of(context).size.width < 400 ||
                MediaQuery.of(context).size.height < 400)
            ? 150.0
            : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
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

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //     });
  //   });
  // }

  // Future<void> fetchData() async {
  //   const String url =
  //       'https://staging.lotusarchi.com/search/GSLAJ'; // Contoh API
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('Data dari API: $data'); // Cetak ke console
  //     } else {
  //       print('Gagal mengambil data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<List<Map<String, dynamic>>?> fetchData(String searchQuery) async {
    final String url =
        'https://staging.lotusarchi.com/search/$searchQuery'; // API contoh
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .cast<
              Map<String, dynamic>
            >(); // Konversi List<dynamic> ke List<Map<String, dynamic>>
      } else {
        print('Gagal mengambil data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      String scannedCode = scanData.code ?? "";

      if (scannedCode.isNotEmpty) {
        print('QR Code terbaca: $scannedCode');

        // Fetch data dari API berdasarkan hasil QR Code yang dipindai
        List<Map<String, dynamic>>? apiData = await fetchData(scannedCode);

        if (apiData != null && apiData.isNotEmpty) {
          // Ambil data pertama dari API
          String dataNama = apiData[0]['nama'] ?? "Data tidak tersedia";

          print('Data dari API: $dataNama');

          controller.pauseCamera(); // Pause kamera agar tidak scan berulang

          // Navigasi ke halaman baru
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextPage(data: dataNama)),
          ).then((_) {
            controller.resumeCamera(); // Resume kamera setelah kembali
          });
        } else {
          print('Data tidak ditemukan untuk QR Code: $scannedCode');
        }
      }
    });
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });

  //   controller.scannedDataStream.listen((scanData) async {
  //     setState(() {
  //       result = scanData;
  //     });

  //     if (scanData.code == "GSLAJL03") {
  //       List<Map<String, dynamic>>? apiData =
  //           await fetchData("GSLAJL03"); // Ambil data dari API

  //       if (apiData != null && apiData.isNotEmpty) {
  //         print(
  //           'Data dari API: ${apiData[0]['nama']}',
  //         ); // Cetak item pertama dari JSON
  //       } else {
  //         print('Gagal mengambil data dari API');
  //       }

  //       controller
  //           .pauseCamera(); // Pause kamera untuk mencegah pemindaian berulang

  //       // Navigasi ke halaman baru
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => TextPage(data: apiData?[0]['nama']),
  //         ), // Ganti dengan halaman tujuan
  //       ).then((_) {
  //         controller
  //             .resumeCamera(); // Resume kamera setelah kembali dari halaman lain
  //       });
  //     }
  //   });
  // }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p' as num);
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('no Permission')));
    }
  }
}
