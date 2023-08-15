import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:al_downloader/al_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'functions/notification.dart';
import 'package:flutter_background/flutter_background.dart';

import 'pages/homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText: "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  await Permission.notification.request();
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



