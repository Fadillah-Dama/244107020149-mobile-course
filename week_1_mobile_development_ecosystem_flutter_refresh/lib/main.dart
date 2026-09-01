import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa'),
          elevation: 0,
          scrolledUnderElevation: 0, // Prevents Material 3 tinting on scroll
          shape: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0,
            ),
          ),
        ),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 50,
              ),
            ),
            SizedBox(height: 16),
            Text('Fadillah Dama Rifky', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('NIM: 244107020149', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Program Studi: D4 Teknik Informatika', style: TextStyle(fontSize: 16)),
            Text('Pemrograman Mobile — Minggu 1', style: TextStyle(fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}