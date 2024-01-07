import '../utils/enums.dart';

class NotificationModel {
  String notificationBody;
  String notificationDate;
  String notificationTitle;
  NotificationTypes notificationType;

  NotificationModel(
      {required this.notificationBody,
      required this.notificationDate,
      required this.notificationTitle,
      required this.notificationType});

  Map<String, String> convertToMap() {
    return {
      "notificationBody": notificationBody,
      "notificationDate": notificationDate,
      "notificationTitle": notificationTitle,
      "notificationType": notificationType.toString(),
    };
  }

  setNotificationBody(String newBody) {
    notificationBody = newBody;
  }
}
