import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../view_models/subscriptions_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/store_owner_model.dart';
import 'package:flutter/foundation.dart';

import 'globalSnackBar.dart';

//TODO: Convert utils function to a combined class

const storage = FlutterSecureStorage();

Future<void> clearTokenAndData() async {
  await storage.write(key: "uid", value: null);
  await storage.write(key: "number", value: null);
}

Future<void> storeTokenAndData(String userUid, String userPhoneNumber) async {
  try {
    await storage.write(key: "uid", value: userUid);
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  await storage.write(key: "number", value: userPhoneNumber);
  //await fetchUserDataFromDB();
}

Future<String?> getToken() async {
  // Reads user's token for user auth state persistence
  String? userUid = await storage.read(key: "uid");

  if (userUid != null) {
    await _setStoreOwnerObjByFetchingUserData(userUid);
  }

  return userUid;
}

_setStoreOwnerObjByFetchingUserData(String userUid) async {
  // set user's data after fetching token from memory
  Future<DocumentSnapshot<Map<String, dynamic>>> _userCollection =
  FirebaseFirestore.instance.collection('users').doc(userUid).get();

  var querySnapshot = await _userCollection;

  await StoreOwner().updateOwnerData(
    uidUpdated: userUid,
    storeNameUpdated: querySnapshot.get("shopName"),
    shopGPSLocationUpdated: querySnapshot.get("shopGPSLocation"),
    storeTypeUpdated: querySnapshot.get("shopType"),
    storeSizeUpdated: querySnapshot.get("shopSize"),
    storeOwnerNameUpdated: querySnapshot.get("ownerName"),
    storeOwnerNumberUpdated: querySnapshot.get("ownerNumber"),
    //bundleReceiptsCountUpdated: "100",//querySnapshot.get("bundleReceiptsCount"),
    //subscriptionStatusUpdated: querySnapshot.get("subscriptionStatus"),
    deliveryManCountUpdated: querySnapshot.get("deliveryManCount"),
    legalStatementUpdated: querySnapshot.get("legalStatement"),
  );
}

setStartDayHour(String startDayHour) async {
  // store (in memory) hour of day starting for creating new receipts
  await storage.write(key: 'startDayHour', value: startDayHour);
}

resetStartDayHour() async {
  // reset (in memory) hour of day starting to -1 trigger
  String? startHour = await fetchStartHour();
  displaySnackBar(text:"the start hour is: $startHour");
  await storage.write(key: 'startDayHour', value: "-1");
}

Future<String?> fetchStartHour() async {
  // fetch (from memory) hour of day starting for creating new receipts
  String? fetchedStartHour = await storage.read(key: "startDayHour");
  return fetchedStartHour;
}

setCurrentWorkingHour(String currentWorkingHour) async {
  // store (in memory) hour of day starting for creating new receipts
  await storage.write(key: 'currentWorkingHour', value: currentWorkingHour);
}

resetCurrentWorkingHour() async {
  // reset (in memory) hour of day starting to -1 trigger
  await storage.write(key: 'currentWorkingHour', value: "-1");
}

Future<String?> fetchCurrentWorkingHour() async {
  // fetch (from memory) hour of day starting for creating new receipts
  String? fetchedCurrentWorkingHour =
  (await storage.read(key: "currentWorkingHour"));
  return fetchedCurrentWorkingHour;
}

storeReceiptsCountOnRestartingDay(int loadedCount) async {
  await storage.write(key: "dayReceiptsCount", value: loadedCount.toString());
}

storeReceiptsCountOfDay() async {
  int pastCount = await fetchReceiptsCountFromStorage();
  await storage.write(
      key: "dayReceiptsCount", value: (pastCount + 1).toString());
}

Future<int> fetchReceiptsCountFromStorage() async {
  int returnedCount;
  String? count = await storage.read(key: "dayReceiptsCount");
  if (count == null) {
    returnedCount = 0;
  } else {
    returnedCount = int.parse(count);
  }
  return returnedCount;
}

clearReceiptsCount() async {
  //used in case day is ended
  await storage.write(key: "dayReceiptsCount", value: "0");
}

// -------------------------------------------------------------------
// ----------------- SUBSCRIPTION STORED ATTRIBUTES ------------------
Future<int> fetchRemainingFreeTrialReceipts() async {
  // fetch (from memory) hour of day starting for creating new receipts
  String? fetchedFreeTrialReceipts = (await storage.read(key: "FreeTrialReceipts"));
  return int.parse(fetchedFreeTrialReceipts ?? "3");
}

updateRemainingFreeTrialReceipts() async {
  int receiptsRemaining = await fetchRemainingFreeTrialReceipts();
  await storage.write(key: 'FreeTrialReceipts', value: (receiptsRemaining-1).toString());
}

setFreeTrialReceiptsCount() async {
  int freeTrialReceipts = await SubscriptionsViewModel().getFreeTrailDataFromFirebase();
  await storage.write(key: 'FreeTrialReceipts', value: freeTrialReceipts.toString());
}

clearFreeTrialReceiptsCount() async {
  await storage.delete(key: "FreeTrialReceipts");
}


Future<String?> fetchSubscriptionStatus() async {
  // fetch (from memory) hour of day starting for creating new receipts
  String? fetchedSubscriptionStatus = (await storage.read(key: "SubscriptionStatus"));

  return fetchedSubscriptionStatus;
}

setSubscriptionStatusToSubscribed() async {
  // store (in memory) SubscriptionStatus after being updated
  await storage.write(key: 'SubscriptionStatus', value: "SUBSCRIBED");
}

setSubscriptionStatusToUnSubscribed() async {
  // store (in memory) SubscriptionStatus after being updated
  await storage.write(key: 'SubscriptionStatus', value: "UNSUBSCRIBED");
}

setSubscriptionStatusToFreeTrial() async {
  // store (in memory) SubscriptionStatus after being updated
  await storage.write(key: 'SubscriptionStatus', value: "FREE_TRIAL");
}



Future<String?> fetchMerchantRefNumb() async {
  // fetch (from memory) hour of day starting for creating new receipts
  String? fetchedMerchantRefNumb = (await storage.read(key: "MerchantRefNumb"));
  return fetchedMerchantRefNumb;
}

setMerchantRefNumb(String merchantRefNumb) async {
  // store (in memory) hour of day starting for creating new receipts
  await storage.write(key: 'MerchantRefNumb', value: merchantRefNumb);
}

resetMerchantRefNumb() async {
  // reset (in memory) hour of day starting to -1 trigger
  await storage.write(key: 'MerchantRefNumb', value: null);
}

clearStorageAttributes() async {
  // clears all attributes in memory if user selects to sign out
  await storage.deleteAll();
}