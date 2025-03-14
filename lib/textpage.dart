import 'dart:io';

import 'package:flutter/material.dart';

class TextPage extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;

  // Konstruktor dengan default value
  const TextPage({super.key, this.dataList = const []});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hasil Scan')),
      body:
          dataList.isNotEmpty
              ? ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final item = dataList[index];
                  String imageUrl = item['gambar'].toString();
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Text(item['nama']),
                        Image.asset(
                          "assets/$imageUrl",
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                        Text(item['gambar']),
                        Text(item['belakang']),
                        Text(item['kadar']),
                        Text(item['berat']),
                      ],
                    ),
                  );
                },
              )
              : Center(
                child: Text(
                  'Data tidak tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
    );
  }
}
