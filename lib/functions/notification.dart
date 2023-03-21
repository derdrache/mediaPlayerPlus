import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
  const AndroidInitializationSettings('@mipmap/ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    init();
  }

  void init() async {
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void createNotification(int progress, int id, title) {
    var notificationBody = progress < 100 ? "downloading.." : "Done";

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        id.toString(), id.toString(),
        channelDescription: id.toString(),
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: 100,
        progress: progress);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics
    );

    _flutterLocalNotificationsPlugin.show(id, title,
        notificationBody, platformChannelSpecifics,
        payload: 'item x');
  }

  void remove(int id){
    _flutterLocalNotificationsPlugin.cancel(id);
  }
}