import 'package:flutter/cupertino.dart';

class StoreOwner extends ChangeNotifier {
  static String uid = " ";
  static String storeName = " ";
  static String shopGPSLocation = " ";
  static String storeType = " ";
  static String storeSize = " ";
  static String storeOwnerName = " ";
  static String storeOwnerNumber = " ";
  static String deliveryManCount = " ";
  static bool legalStatement = false;

  StoreOwner(
      {uid,
        storeName,
        shopGPSLocation,
        storeType,
        storeSize,
        storeOwnerName,
        storeOwnerNumber,
        deliveryManCount,
        legalStatement});

  Map<String, dynamic> getStoreOwnerData() {
    return {
      "uid": uid,
      "storeName": storeName,
      "shopGPSLocation": shopGPSLocation,
      "storeType": storeType,
      "storeSize": storeSize,
      "storeOwnerName": storeOwnerName,
      "storeOwnerNumber": storeOwnerNumber,
      "deliveryManCount": deliveryManCount,
      "legalStatement": legalStatement,
    };
  }

  updateOwnerData(
      {required String uidUpdated,
        required String storeNameUpdated,
        required String shopGPSLocationUpdated,
        required String storeTypeUpdated,
        required String storeSizeUpdated,
        required String storeOwnerNameUpdated,
        required String storeOwnerNumberUpdated,
        required String deliveryManCountUpdated,
        required bool legalStatementUpdated}) {
    uid = uidUpdated;
    storeName = storeNameUpdated;
    shopGPSLocation = shopGPSLocationUpdated;
    storeType = storeTypeUpdated;
    storeSize = storeSizeUpdated;
    storeOwnerName = storeOwnerNameUpdated;
    storeOwnerNumber = storeOwnerNumberUpdated;
    deliveryManCount = deliveryManCountUpdated;

    legalStatement = legalStatementUpdated;

    notifyListeners();
  }

  String getUid() {
    return uid;
  }
}