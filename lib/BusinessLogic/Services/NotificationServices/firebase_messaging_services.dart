import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../view_models/notifications_view_model.dart';

class FBMessagingServices {
  Future<String?> receiveToken = FirebaseMessaging.instance.getToken();

  bool isFlutterLocalNotificationsInitialized = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<String?> getToken() async {
    FBMessagingServices().receiveToken.then((value) {
      return value;
    });
    return null;
  }

  Future<void> setupFlutterNotifications() async {
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      isFlutterLocalNotificationsInitialized = true;
    }
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  void initListenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
      NotificationsViewModel().sendFirebaseMessage(message);
    });
  }
}
