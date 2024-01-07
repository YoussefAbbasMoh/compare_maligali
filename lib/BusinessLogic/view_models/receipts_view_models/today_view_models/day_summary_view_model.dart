import '../../../Services/local_inventory_services/hive_services.dart';
import '../../../Services/local_inventory_services/user_inventory_services.dart';
import '../../../Services/FireBaseServices/coll_receipt_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Models/user_inventory_model.dart';
import '../../../utils/time_and_date_utils.dart';
import '../../../Models/summary_model.dart';

class DaySummaryViewModel {
  String date = "-";
  Map<String, int> productsCount = {};
  UserInventoryServices userInvServicesObj = UserInventoryServices();
  ReceiptCollectionServices receiptDBServicesObj = ReceiptCollectionServices();

  initSummaryData(String? fetchingDate) {
    DateTime now = DateTime.now();
    date = fetchingDate ??
        reformatDateSplittedToCombined(
            now.day.toString(), now.month.toString(), now.year.toString());
  }

  Future<DaySummary> getDaySummaryFromDB(String? previousDate) async {
    DocumentSnapshot<Object?> summaryReference = await receiptDBServicesObj
        .userReceiptsCollectionReference
        .doc(previousDate)
        .get();
    int numberOfReceiptsMade = 0;
    double numberOfProductsSold = 0;
    double totalDayProfit = 0.0;
    double totalDayRevenue = 0.0;
    String topSoldProductBarCode = "";
    String leastProductSoldBarCode = "";
    List<String> productsFinishedFromInventory = [];
    double topSoldProductCount = 0;
    double leastSoldProductCount = 0;

    if (summaryReference.exists) {
      numberOfReceiptsMade = summaryReference.get("numberOfReceiptsMade");
      numberOfProductsSold = summaryReference.get("numberOfProductsSold");
      totalDayProfit = summaryReference.get("totalDayProfit");
      totalDayRevenue = summaryReference.get("totalDayRevenue");
      topSoldProductBarCode = summaryReference.get("topSoldProductBarCode");
      leastProductSoldBarCode = summaryReference.get("leastProductSoldBarCode");
      productsFinishedFromInventory = List.castFrom<dynamic, String>(
          summaryReference.get("productsFinishedFromInventory"));
      topSoldProductCount = summaryReference.get("topSoldProductCount");
      leastSoldProductCount = summaryReference.get("leastSoldProductCount");
    }

    return DaySummary(
        numberOfProductsSold: numberOfProductsSold,
        numberOfReceiptsMade: numberOfReceiptsMade,
        totalDayProfit: totalDayProfit,
        totalDayRevenue: totalDayRevenue,
        topSoldProductBarCode: topSoldProductBarCode,
        leastProductSoldBarCode: leastProductSoldBarCode,
        productsFinishedFromInventory: productsFinishedFromInventory,
        topSoldProductCount: topSoldProductCount,
        leastSoldProductCount: leastSoldProductCount);
  }

  Future<Map<String, String>> fetchMostItemBought() async {
    CollectionReference firebaseFirestore =
        receiptDBServicesObj.userReceiptsCollectionReference;
    DocumentSnapshot<Object?>? daySnapshot;
    try {
      daySnapshot = await firebaseFirestore
          .doc(date)
          .get(const GetOptions(source: Source.cache));
    } catch (e) {
      print("couldn't find day summary in cache: $e");
      try {
        daySnapshot = await firebaseFirestore.doc(date).get();
      } catch (e) {
        print("couldn't find day summary in database: $e");
      }
    }

    if (daySnapshot!.data() == null) {
      return {
        "productName": "الخدمة غير متاحة",
        "imgPath": "",
        "productSoldCount": "0",
        // "productSaleUnit": "غير محدد"
      };
    }

    String topSoldProductCount =
        daySnapshot.get("topSoldProductCount").toString();
    String topSoldProductBarCode = daySnapshot.get("topSoldProductBarCode");

    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(
            topSoldProductBarCode);

    if (product == null) {
      return {
        "productName": "الخدمة غير متاحة",
        "imgPath": "",
        "productSoldCount": "0",
        // "productSaleUnit": "غير محدد"
      };
    }

    return {
      "productName": product.productName,
      "imgPath": product.productPhoto,
      "productSoldCount": topSoldProductCount,
      // "productSaleUnit": product.saleUnit
    };
  }
}
