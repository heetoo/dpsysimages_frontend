import 'package:dpsysimages/pages/photo_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DPSys Images',
      home: PhotoList(),
    );
  }
}
