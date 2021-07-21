import 'dart:io';

import 'package:flutter/material.dart';

class testPage extends StatefulWidget {
  const testPage({Key? key}) : super(key: key);

  @override
  _testPageState createState() => _testPageState();
}

class _testPageState extends State<testPage> {
  File file = File('/storage/emulated/0/Download/cacca.jpg');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            new Image.file(file),
          ],
        ),
      ),
    );
  }
}
