import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'homepage.dart';

void main() async{
  await hiveInit();

  runApp(const MyApp());
}

hiveInit() async {
  await Hive.initFlutter();

  await Hive.openBox("mediaBox", crashRecovery: false);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Player Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}



