// Halaman baru untuk menampilkan teks
import 'package:flutter/material.dart';

class TextPage extends StatelessWidget {
  // final dynamic data;
  final String data;

  TextPage({this.data = "Data tidak tersedia"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Page')),
      body: Center(
        // child: Text("Data: ${data.toString()}"),
        child: Text(this.data),
      ),
    );
  }
}
