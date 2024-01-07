import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class LocalNotificationService {
  final _localNotificationService = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationTrigger = BehaviorSubject();
  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("@drawable/ic_stat_maligali_logo");

    const InitializationSettings settings =
    InitializationSettings(android: androidInitializationSettings);

    await _localNotificationService.initialize(
      settings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      "channel_id",
      "channel_name",
      channelDescription: "description",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    return const NotificationDetails(android: androidNotificationDetails);
  }

  Future<void> showNotificationWithPayload({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details,
        payload: payload);
  }

  void onSelectNotification(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      onNotificationTrigger.add(response.payload);
    }
  }
}