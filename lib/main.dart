import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:al_downloader/al_downloader.dart';
import 'functions/notification.dart';

import 'pages/homepage.dart';

void main() async{
  await hiveInit();
  ALDownloader.initialize();
  NotificationService().init();

  runApp(const MyApp());
}


hiveInit() async {
  await Hive.initFlutter();

  await Hive.openBox("mediaBox", crashRecovery: true);
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



