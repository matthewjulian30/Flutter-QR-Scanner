// Halaman baru untuk menampilkan teks
import 'package:flutter/material.dart';

class TextPage extends StatelessWidget {
  const TextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Scan")),
      body: const Center(
        child: Text(
          "QR Code berhasil dipindai!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}