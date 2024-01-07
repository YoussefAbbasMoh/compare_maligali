import 'BusinessLogic/Services/NotificationServices/firebase_messaging_services.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'BusinessLogic/Services/local_inventory_services/hive_services.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'BusinessLogic/Models/general_inventory_model.dart';
import 'BusinessLogic/utils/api_keys_firebase_config.dart';
import 'BusinessLogic/Models/user_inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'app/my_app.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(
  //     name: "MaliGali", options: DefaultFirebaseConfig.platformOptions);
  await FBMessagingServices().setupFlutterNotifications();
  FBMessagingServices().showFlutterNotification(message);
}

void main() async {
  if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "MaliGali",
    options: FirebaseOptions(
      apiKey: API_KEY_PART_1 + API_KEY_PART_2 + API_KEY_PART_3 + API_KEY_PART_4,
      appId: "1:66754744895:android:5e9736b7306a1e8949de8a",
      messagingSenderId: "66754744895",
      projectId: "maligali-5bac7",
    ),
  );

  // Check if a compatible version of Google Play services APK is available on the device
  GooglePlayServicesAvailability availability = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability(false);

  if (availability != GooglePlayServicesAvailability.success) {
    // Handle the case where Google Play services APK is not available on the device
    try {
      await GoogleApiAvailability.instance.makeGooglePlayServicesAvailable();
    } on PlatformException {
      // pass
    }
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Provider.debugCheckInvalidValueType = null;

  await AndroidAlarmManager.initialize();
  /////////////////////////initialize Hive database//////////////////////////////////
  Hive..initFlutter();
  Hive.registerAdapter(GeneralInventoryAdapter());
  Hive.registerAdapter(UserInventoryAdapter());
  /////////////////////////////////////////////////////////////////////////////////////

  //testing database
  await HiveDatabaseManager.initializeDataBase();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  runApp(MyApp());
}
