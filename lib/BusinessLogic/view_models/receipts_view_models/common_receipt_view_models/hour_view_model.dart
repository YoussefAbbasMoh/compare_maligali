import 'package:flutter/material.dart';
import 'package:maligali/BusinessLogic/Models/product_in_receipt_model.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import 'package:provider/provider.dart';
import '../../../Models/summary_model.dart';
import '../../../Services/FireBaseServices/coll_receipt_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Models/hourly_collection_model.dart';
import '../../../utils/globalSnackBar.dart';
import '../../../utils/time_and_date_utils.dart';
import 'package:flutter/foundation.dart';

import '../previous_day_view_models/previous_day_page_view_model.dart';
import '../today_view_models/start_day_provider.dart';

class HourReceiptViewModel extends ChangeNotifier {
  String hourSelected = "";
  String dateSelected = "";
  HourlyReceiptCollection? hourCollection;

  initializeHourCollectionData(HourlyReceiptCollection selectedCollection) {
    hourSelected = convertTimeStringTo24Hr(
        selectedCollection.time, selectedCollection.amPm);
    dateSelected = selectedCollection.date;

    hourCollection = HourlyReceiptCollection(
        date: selectedCollection.date,
        time: selectedCollection.time,
        amPm: selectedCollection.amPm,
        hourTotalProfit: selectedCollection.hourTotalProfit,
        hourTotalRevenue: selectedCollection.hourTotalRevenue,
        hourItemsSoldCount: selectedCollection.hourItemsSoldCount,
        hourReceiptsCount: selectedCollection.hourReceiptsCount,
        topSoldProductBarCode: selectedCollection.topSoldProductBarCode,
        leastProductSoldBarCode: selectedCollection.leastProductSoldBarCode,
        productsFinishedFromInventory:
            selectedCollection.productsFinishedFromInventory,
        topSoldProductCount: selectedCollection.topSoldProductCount,
        leastProductSoldCount: selectedCollection.leastProductSoldCount);
  }

  updateHourAndDaySummariesAfterReceiptEdit(BuildContext context) async {
    String today = getNowDate();
    bool case1 = (today != dateSelected);
    bool case2 = (StartDayProvider.dayStarted == false);
    bool case3 = (dateSelected != "");
    if ( case3 && (case1 || (!case1 && case2))) {
      HourlyReceiptCollection hourCollectionDataBeforeUpdate = hourCollection!;
      hourCollection = await TodayPageViewModel().createOrUpdateCurrentHourSummaryInDB(
          date: dateSelected, hourInFormat: hourSelected);
      await updateOldHourCollection();
      await Provider.of<PreviousDayPageViewModel>(context, listen: false).updateHourDataINVM(hourSelected);
      await updateOldDayCollectionOnUpdate(hourCollectionDataBeforeUpdate);
    }
    notifyListeners();
  }

  UserInventoryServices userInvServicesObj = UserInventoryServices();
  ReceiptCollectionServices receiptDBServicesObj = ReceiptCollectionServices();

  updateOldDayCollectionOnUpdate(
      HourlyReceiptCollection hourCollectionDataBeforeUpdate) async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    DaySummary? daySummaryBeforeUpdate;
    String? dayStartHour;
    await firebaseFirestore.doc(dateSelected).get().then((value) {
      daySummaryBeforeUpdate = DaySummary(
          numberOfProductsSold: value.get("numberOfProductsSold"),
          numberOfReceiptsMade: value.get("numberOfReceiptsMade"),
          totalDayProfit: value.get("totalDayProfit"),
          totalDayRevenue: value.get("totalDayRevenue"),
          topSoldProductBarCode: value.get("topSoldProductBarCode"),
          leastProductSoldBarCode: value.get("leastProductSoldBarCode"),
          productsFinishedFromInventory:
          List.castFrom<dynamic, String>(value.get("productsFinishedFromInventory")), // todo
          topSoldProductCount: value.get("topSoldProductCount"),
          leastSoldProductCount: value.get("leastSoldProductCount"));
      dayStartHour = value.get("startHour");
    });
    DaySummary subtractedDaySummary = subtractHourDataFromDaySummary(
        hourCollectionDataBeforeUpdate, daySummaryBeforeUpdate!);

    DaySummary updatedDaySummary = addHourDataToDaySummary(hourCollection!, subtractedDaySummary);

    await updateOldDaySummary(dayStartHour!, updatedDaySummary);

  }

  DaySummary addHourDataToDaySummary(
      HourlyReceiptCollection hourCollectionDataAfterUpdate,
      DaySummary subtractedDaySummary) {
    DaySummary addedDaySummary = DaySummary(
        numberOfProductsSold: subtractedDaySummary.numberOfProductsSold + hourCollectionDataAfterUpdate.hourItemsSoldCount,
        numberOfReceiptsMade: subtractedDaySummary.numberOfReceiptsMade + hourCollectionDataAfterUpdate.hourReceiptsCount,
        totalDayProfit: subtractedDaySummary.totalDayProfit + hourCollectionDataAfterUpdate.hourTotalProfit,
        totalDayRevenue: subtractedDaySummary.totalDayRevenue + hourCollectionDataAfterUpdate.hourTotalRevenue,
        topSoldProductBarCode: subtractedDaySummary.topSoldProductBarCode,
        leastProductSoldBarCode: subtractedDaySummary.leastProductSoldBarCode,
        productsFinishedFromInventory: subtractedDaySummary.productsFinishedFromInventory,
        topSoldProductCount: subtractedDaySummary.topSoldProductCount,
        leastSoldProductCount: subtractedDaySummary.leastSoldProductCount);

    return addedDaySummary;
  }

  DaySummary subtractHourDataFromDaySummary(
      HourlyReceiptCollection hourCollectionDataBeforeUpdate,
      DaySummary daySummaryBeforeUpdate) {
    DaySummary subtractedDaySummary = DaySummary(
        numberOfProductsSold: daySummaryBeforeUpdate.numberOfProductsSold - hourCollectionDataBeforeUpdate.hourItemsSoldCount,
        numberOfReceiptsMade: daySummaryBeforeUpdate.numberOfReceiptsMade - hourCollectionDataBeforeUpdate.hourReceiptsCount,
        totalDayProfit: daySummaryBeforeUpdate.totalDayProfit - hourCollectionDataBeforeUpdate.hourTotalProfit,
        totalDayRevenue: daySummaryBeforeUpdate.totalDayRevenue - hourCollectionDataBeforeUpdate.hourTotalRevenue,
        topSoldProductBarCode: daySummaryBeforeUpdate.topSoldProductBarCode,
        leastProductSoldBarCode: daySummaryBeforeUpdate.leastProductSoldBarCode,
        productsFinishedFromInventory: daySummaryBeforeUpdate.productsFinishedFromInventory,
        topSoldProductCount: daySummaryBeforeUpdate.topSoldProductCount,
        leastSoldProductCount: daySummaryBeforeUpdate.leastSoldProductCount);

    return subtractedDaySummary;
  }

  updateOldHourCollection() async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    Map<String, dynamic>? collSummary;

    collSummary = HourlyReceiptCollection.toMap(hourCollection!);

    await firebaseFirestore
        .doc(dateSelected)
        .collection(hourSelected)
        .doc("Summary")
        .update(collSummary);
  }

  updateOldDaySummary(String dayStartHour, DaySummary updatedDaySummary) async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    Map<String, dynamic>? updatedDaySummaryMap;

    updatedDaySummaryMap = DaySummary.toMap(dayStartHour, updatedDaySummary);

    await firebaseFirestore
        .doc(dateSelected)
        .update(updatedDaySummaryMap).then((value) => displaySnackBar(text: 'تم تعديل بيانات الفاتورة'));
  }

  Future<HourlyReceiptCollection?> fetchOrGenerateHourSummaryFromDB(
      {required String date, required String collHour}) async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    HourlyReceiptCollection? tempHourCollection;

    DocumentSnapshot<Map<String, dynamic>> receiptSnapshot =
        (await firebaseFirestore
            .doc(date)
            .collection(collHour)
            .doc("Summary")
            .get());

    double hourTotalProfit = 0.0;
    double hourTotalRevenue = 0.0;
    int hourItemsSoldCount = 0;
    int hourReceiptsCount = 0;
    String topSoldProductBarCode = "";
    String leastProductSoldBarCode = "";
    List<dynamic> productsFinishedFromInventory = [];
    double topSoldProductCount = 0;
    double leastProductSoldCount = 0;
    try {
      if (receiptSnapshot.exists && receiptSnapshot.data()!.isNotEmpty) {
        hourTotalProfit = receiptSnapshot.get("hourTotalProfit");
        hourTotalRevenue = receiptSnapshot.get("hourTotalRevenue");
        hourItemsSoldCount = receiptSnapshot.get("hourItemsSoldCount");
        hourReceiptsCount = (receiptSnapshot.get("hourReceiptsCount"));
        topSoldProductBarCode = receiptSnapshot.get("topSoldProductBarCode");
        leastProductSoldBarCode =
            receiptSnapshot.get("leastProductSoldBarCode");
        productsFinishedFromInventory =
            receiptSnapshot.get("productsFinishedFromInventory");
        topSoldProductCount = receiptSnapshot.get("topSoldProductCount");
        leastProductSoldCount = receiptSnapshot.get("leastProductSoldCount");
      } else {
        tempHourCollection = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("2- $e");
      }
    }
    tempHourCollection = HourlyReceiptCollection(
        amPm: amPmFrom24HrFormat(collHour),
        date: date,
        time: displayTime12HrFormat(collHour),
        hourItemsSoldCount: hourItemsSoldCount,
        hourReceiptsCount: hourReceiptsCount,
        hourTotalProfit: hourTotalProfit,
        hourTotalRevenue: hourTotalRevenue,
        topSoldProductBarCode: topSoldProductBarCode,
        leastProductSoldBarCode: leastProductSoldBarCode,
        productsFinishedFromInventory:
            productsFinishedFromInventory.cast<String>(),
        topSoldProductCount: topSoldProductCount,
        leastProductSoldCount: leastProductSoldCount);

    return tempHourCollection;
  }

  Future<HourlyReceiptCollection?> fetchWorkedHourSummaryOnlyFromDB(
      {required String date, required String collHour}) async {
    print(date);
    print(collHour);
    print("----");

    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;

    DocumentSnapshot<Map<String, dynamic>> receiptSnapshot =
        (await firebaseFirestore
            .doc(date)
            .collection(collHour)
            .doc("Summary")
            .get());

    HourlyReceiptCollection? workedHourCollection;
    try {
      print(receiptSnapshot);
      print("done + ${collHour}");

      if (receiptSnapshot.exists && receiptSnapshot.data()!.isNotEmpty) {
        workedHourCollection = HourlyReceiptCollection(
            amPm: amPmFrom24HrFormat(collHour),
            date: date,
            time: displayTime12HrFormat(collHour),
            hourTotalProfit: receiptSnapshot.get("hourTotalProfit"),
            hourTotalRevenue: receiptSnapshot.get("hourTotalRevenue"),
            hourItemsSoldCount: receiptSnapshot.get("hourItemsSoldCount"),
            hourReceiptsCount: receiptSnapshot.get("hourReceiptsCount"),
            topSoldProductBarCode: receiptSnapshot.get("topSoldProductBarCode"),
            leastProductSoldBarCode:
                receiptSnapshot.get("leastProductSoldBarCode"),
            productsFinishedFromInventory: receiptSnapshot
                .get("productsFinishedFromInventory")
                .cast<String>(),
            topSoldProductCount: receiptSnapshot.get("topSoldProductCount"),
            leastProductSoldCount:
                receiptSnapshot.get("leastProductSoldCount"));
      } else {
        workedHourCollection = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("2- $e");
      }
    }

    return workedHourCollection;
  }

  HourlyReceiptCollection initializeEmptyHourCollection(
      String collHour, String date) {
    print(
        "NOTE CODE 1: FROM INSIDE 'initializeEmptyHourCollection' function: start... ");

    // create empty collection Summary for a specific date and hour
    double hourTotalProfit = 0.0;
    double hourTotalRevenue = 0.0;
    int hourItemsSoldCount = 0;
    int hourReceiptsCount = 0;

    HourlyReceiptCollection res = HourlyReceiptCollection(
        amPm: amPmFrom24HrFormat(collHour),
        date: date,
        time: displayTime12HrFormat(collHour),
        hourItemsSoldCount: hourItemsSoldCount,
        hourReceiptsCount: hourReceiptsCount,
        hourTotalProfit: hourTotalProfit,
        hourTotalRevenue: hourTotalRevenue,
        topSoldProductBarCode: '',
        leastProductSoldBarCode: '',
        productsFinishedFromInventory: [],
        topSoldProductCount: 0,
        leastProductSoldCount: 0);

    print(
        "NOTE CODE 2: FROM INSIDE 'initializeEmptyHourCollection' function: end... \n created collection is: ${res.toString()}");

    return res;
  }

  deleteWholeReceipt(BuildContext context, String receiptNumber, String date, String time) async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    HourlyReceiptCollection? hourCollectionDataBeforeUpdate = hourCollection;
    if (hourCollection == null) {
      hourCollectionDataBeforeUpdate = (await fetchOrGenerateHourSummaryFromDB(date: date, collHour: time))!;
      hourCollection = hourCollectionDataBeforeUpdate;
    }
    DocumentSnapshot<Map<String, dynamic>> docRef = await firebaseFirestore
        .doc(hourCollection?.date)
        .collection(time)
        .doc(receiptNumber)
        .get();

    hourCollection?.hourTotalRevenue -=
        double.parse(docRef.get("receiptRevenue"));
    hourCollection?.hourTotalProfit -=
        double.parse(docRef.get("receiptAfterSaleProfit"));
    hourCollection?.hourItemsSoldCount -=
        int.parse(docRef.get("totalProductsSold"));
    hourCollection?.hourReceiptsCount -= 1;

    List<ProductInReceipt> products = await receiptDBServicesObj
        .getProductsListFromReceipt(docRef.get("itemsList"));
    for (ProductInReceipt product in products) {
      await userInvServicesObj.returnProductToUserInventoryDB(
          product.barcode, product.productBoughtCount);
    }

    await receiptDBServicesObj.deleteReceiptFromDB(
        receiptNumber, time, hourCollection!.date);
    final vm = TodayPageViewModel();
    print("----------------------");
    print(hourCollection!.date);
    print("----------------------");
    await vm.createOrUpdateCurrentHourSummaryInDB(
        hourInFormat: reformatHourSplitted(time), date: hourCollection!.date);
    await updateOldDayCollectionOnUpdate(hourCollectionDataBeforeUpdate!);

    await Provider.of<PreviousDayPageViewModel>(context, listen: false).updateHourDataINVM(time);
    notifyListeners();
  }
}
