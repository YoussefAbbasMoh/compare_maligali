enum OrderStates {
  received, // order is received by shop owner side, but was not seen yet
  packed, // order is seen by the shop owner, and is being packed
  onTheWay, // order is sent with a delivery to reach the customer
  delivered, // order is delivered to the customer
  rejected, // order is rejected by the shop
  delayed, // order is delayed in delivery
}


enum NotificationTypes {
  INVENTORY_NOTIF,
  ADVICE_NOTIF,
  ADMINISTRATIVE_NOTIF,
  BUNDLE_NOTIF,
  SUBSCRIPTION_NOTIF
}

Map<String, NotificationTypes> notificationTypesMap = {
  "NotificationTypes.INVENTORY_NOTIF": NotificationTypes.INVENTORY_NOTIF,
  "NotificationTypes.ADVICE_NOTIF": NotificationTypes.ADVICE_NOTIF,
  "NotificationTypes.ADVERTISE_NOTIF": NotificationTypes.ADMINISTRATIVE_NOTIF,
  "NotificationTypes.BUNDLE_NOTIF": NotificationTypes.BUNDLE_NOTIF,
  "NotificationTypes.SUBSCRIPTION_NOTIF": NotificationTypes.SUBSCRIPTION_NOTIF,
};

enum FawryPayCheckPaymentResults {
  CONNECTION_FAILURE,
  NO_MERCHANT_REF_NUMBER,
  SUBSCRIBED,
  UNSUBSCRIBED
}

Map<int, String> arabicMonths = {
  1: "يناير",
  2: "فبراير",
  3: "مارس",
  4: "ابريل",
  5: "مايو",
  6: "يونيا",
  7: "يوليا",
  8: "اغسطس",
  9: "سبتمبر",
  10: "اكتوبر",
  11: "نوفمبر",
  12: "ديسمبر",
};
