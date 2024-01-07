import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'create_and_delete_db_services.dart';

class InventoryActivityServices {
  CollectionReference invActivitiesCollectionRef = CreateAndDeleteDBServices()
      .userDBReference()
      .collection("inventoryActivities");

  createNewActivity(Map<String, String> activityInformation) async {
    try {
      await invActivitiesCollectionRef
          .doc()
          .set(activityInformation, SetOptions(merge: true));
      return "done";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "fail";
    }
  }

  Map<String, String> prepareDataForCreateNewActivity(
    String productName,
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
    String averagePurchasePrice,
    String sellingPricePerPack,
    String date,
  ) {
    return {
      "activity": "CREATE_NEW",
      "Date": date,
      "productName": productName,
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
    };
  }

  Map<String, String> prepareDataForCreateFromGenInvActivity(
    String productName,
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
    String averagePurchasePrice,
    String sellingPricePerPack,
    String date,
  ) {
    return {
      "activity": "CREATE_FROM_GEN_INV",
      "Date": date,
      "productName": productName,
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
    };
  }

  Map<String, String> prepareDataForUpdateActivity(
    String productName,
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
    String averagePurchasePrice,
    String sellingPricePerPack,
    String date,
  ) {
    return {
      "activity": "UPDATE",
      "productName": productName,
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
      "Date": date,
    };
  }

  Map<String, String> prepareDataForReturnActivity(
    String productName,
    String numberOfItemsReturned,
    String averagePurchasePrice,
    String sellingPricePerPack,
    String date,
    String typeReturned,
    String totalReturnPrice,
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
  ) {
    return {
      "activity": "RETURN",
      "Date": date,
      "productName": productName,
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
      "BulkOrUnitReturn": typeReturned,
      "totalReturnPrice": totalReturnPrice,
      "numberOfItemsReturnController": numberOfItemsReturned,
    };
  }

  Map<String, String> prepareDataForDeleteActivity(
      String productName,
      String numberOfCartonsInInventory,
      String numberOfPackagesOutsideCarton,
      String averagePurchasePrice,
      String sellingPricePerPack,
      //String saleUnit,
      String date) {
    return {
      "activity": "DELETE",
      "date": date,
      "productName": productName,
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
      //"saleUnit": saleUnit,
    };
  }
}
