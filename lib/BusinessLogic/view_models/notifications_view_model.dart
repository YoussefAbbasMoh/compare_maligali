import '../Services/NotificationServices/firebase_messaging_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/notification_model.dart';
import '../Services/NotificationServices/local_notification_services.dart';
import '../utils/time_and_date_utils.dart';
import 'package:flutter/foundation.dart';
import '../utils/enums.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class NotificationsViewModel extends ChangeNotifier {
  LocalNotificationService service = LocalNotificationService();

  static bool _badgeNotifier = false;
  bool badgeNotifier() => _badgeNotifier;

  setBadgeNotifier(bool state) {
    _badgeNotifier = state;
    notifyListeners();
  }

  // 1- SUBSCRIPTION NOTIFICATION METHODS -------------------------------------

  NotificationModel testingForSubscriptionNotification(
      int receiptsNumb, int bundleReceipts, int half, int eighty, int all) {
    NotificationModel preSubscriptionNotif = NotificationModel(
      notificationBody: "",
      notificationDate: getNowDate(),
      notificationTitle: 'تنبيه الاشتراك',
      notificationType: NotificationTypes.SUBSCRIPTION_NOTIF,
    );

    if (receiptsNumb == half) {
      preSubscriptionNotif.setNotificationBody("استهلكت 50% من فواتيرك");
    } else if (receiptsNumb == eighty) {
      preSubscriptionNotif.setNotificationBody(
          "استهلكت 80% من فواتيرك\n بنفكرك تجدد الاشتراك عشان تقدر تستفيد بخدماتنا طول الشهر");
    } else if (receiptsNumb == all) {
      preSubscriptionNotif.setNotificationBody(
          "استهلكت 99% من فواتيرك\n كمل بيعك بطريقة منظمة و حديثة من خلال الباقات");
    }
    return preSubscriptionNotif;
  }

  NotificationModel onBundleFinishedNotification(bool monthSubscriptionEnded) {
    NotificationModel preSubscriptionNotif = NotificationModel(
      notificationBody: "",
      notificationDate: getNowDate(),
      notificationTitle: 'تنبيه الاشتراك',
      notificationType: NotificationTypes.SUBSCRIPTION_NOTIF,
    );

    preSubscriptionNotif.setNotificationBody(
        "فواتيرك خلصت ... متعطلش بيعك و الحق جدد الاشتراك");
    return preSubscriptionNotif;
  }

  NotificationModel subscriptionPayedNotification() {
    return NotificationModel(
      notificationBody: "تم تجديد الباقة بنجاح",
      notificationDate: getNowDate(),
      notificationTitle: 'تنبيه الاشتراك',
      notificationType: NotificationTypes.SUBSCRIPTION_NOTIF,
    );
  }

  sendSubscriptionNotification(
      {int? remainingReceiptsInBundle,
      int? bundleReceipts,
      bool? subscriptionEnded,
      bool? subscriptionPayed}) async {
    NotificationModel? subscriptionNotification;
    if (remainingReceiptsInBundle != null && bundleReceipts != null) {
      int half = bundleReceipts * 50 ~/ 100;
      int eighty = bundleReceipts * 20 ~/ 100;
      int all = bundleReceipts * 1 ~/ 100;

      if (remainingReceiptsInBundle == half ||
          remainingReceiptsInBundle == eighty ||
          remainingReceiptsInBundle == all) {
        subscriptionNotification = testingForSubscriptionNotification(
            remainingReceiptsInBundle, bundleReceipts, half, eighty, all);
      }
    }

    if (subscriptionEnded != null) {
      subscriptionNotification =
          onBundleFinishedNotification(subscriptionEnded);
    }

    if (subscriptionPayed != null) {
      subscriptionNotification = subscriptionPayedNotification();
    }

    if (subscriptionNotification != null) {
      service.initialize();
      await service.showNotificationWithPayload(
          id: 0,
          title: subscriptionNotification.notificationTitle,
          body: subscriptionNotification.notificationBody,
          payload: "payload");

      await writeNotifDetailsInFile(subscriptionNotification);

      setBadgeNotifier(true);
    }
  }

  // 2- FIREBASE / BULK NOTIFICATIONS FROM DEVELOPERS METHODS ------------------

  sendFirebaseMessage(RemoteMessage message) async {
    NotificationModel bundleNotif = NotificationModel(
        notificationBody: message.notification!.body!,
        notificationType: NotificationTypes.BUNDLE_NOTIF,
        notificationTitle: message.notification!.title!,
        notificationDate: getNowDate());
    writeNotifDetailsInFile(bundleNotif);
    setBadgeNotifier(true);
  }

  // 3- INVENTORY NOTIFICATIONS METHODS ----------------------------------------

  createInventoryNotificationBody({required String notifBody}) async {
    NotificationModel notif = NotificationModel(
        notificationBody: notifBody,
        notificationType: NotificationTypes.INVENTORY_NOTIF,
        notificationTitle: 'تنبيه من المخزن',
        notificationDate: getNowDate());

    service.initialize();
    await service.showNotificationWithPayload(
        id: 0,
        title: notif.notificationTitle,
        body: notif.notificationBody,
        payload: "payload");
    await writeNotifDetailsInFile(notif);
    setBadgeNotifier(true);
  }

  // => GENERAL NOTIFICATIONS METHODS ------------------------------------------

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/data.txt');
  }

  writeNotifDetailsInFile(NotificationModel notif) async {
    final file = await _localFile;
    String notifEncoded = convertNotificationObjToJson(notif);
    await file.writeAsString(notifEncoded, mode: FileMode.append);
    await file.writeAsString("\n", mode: FileMode.append);
  }

  convertNotificationObjToJson(NotificationModel notif) {
    String notifEncoded = jsonEncode(notif.convertToMap());

    return notifEncoded;
  }

  NotificationModel convertFromMapToNotificationObject(
      Map<String, String> notifMap) {
    return NotificationModel(
        notificationBody: notifMap["notificationBody"]!,
        notificationDate: notifMap["notificationDate"]!,
        notificationTitle: notifMap["notificationTitle"]!,
        notificationType: notificationTypesMap[notifMap["notificationType"]]!);
  }

  Future<List<NotificationModel>> readNotificationsFromMemory() async {
    List<NotificationModel> notifList = [];
    try {
      File file = await _localFile;
      List<String> notifJsons = await file.readAsLines();
      file.writeAsStringSync("");
      for (String notifJSON in notifJsons) {
        Map<String, String> notifMap =
            Map<String, String>.from(json.decode(notifJSON));
        Map<String, String>? notifMapReturned =
            deleteOldNotifications(notifMap);

        if (notifMapReturned != null) {
          await file.writeAsString(jsonEncode(notifMapReturned),
              mode: FileMode.append);
          await file.writeAsString("\n", mode: FileMode.append);

          notifList.add(convertFromMapToNotificationObject(notifMapReturned));
        } else {}
      }
      return notifList.reversed.toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return notifList.reversed.toList();
    }
  }

  Map<String, String>? deleteOldNotifications(Map<String, String> notifMap) {
    String? notifDate = notifMap["notificationDate"];
    if (notifDate != null) {
      List<String> notifDateList = notifDate.split("-");
      DateTime notifDateTime = DateTime(int.parse(notifDateList[2]),
          int.parse(notifDateList[1]), int.parse(notifDateList[0]));

      DateTime today = DateTime.now();
      int difference = today.difference(notifDateTime).inDays;

      if (difference > 3) {
        return null;
      } else {
        return notifMap;
      }
    }
    return null;
  }
}
