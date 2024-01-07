import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Models/product_in_receipt_model.dart';
import '../../utils/time_and_date_utils.dart';
import 'package:flutter/foundation.dart';
import '../../Models/receipt_model.dart';
import 'create_and_delete_db_services.dart';

class ReceiptCollectionServices {
  CollectionReference userReceiptsCollectionReference =
      CreateAndDeleteDBServices().userDBReference().collection('userReceipts');
  UserInventoryServices userInvServicesObj = UserInventoryServices();

  addReceiptToDB(String receiptNumber, Map<String, dynamic> receiptData,
      String? changedReceiptHour, String? changedReceiptDate) async {
    DateTime now = DateTime.now();

    String receiptDate = changedReceiptDate ??
        reformatDateSplittedToCombined(
            now.day.toString(), now.month.toString(), now.year.toString());
    String receiptHour =
        changedReceiptHour ?? reformatHourSplitted(now.hour.toString());

    try {
      if (changedReceiptDate != null) {
        await userReceiptsCollectionReference
            .doc(receiptDate)
            .collection(receiptHour)
            .doc(receiptNumber)
            .update(receiptData);
      } else {
        await userReceiptsCollectionReference
            .doc(receiptDate)
            .collection(receiptHour)
            .doc(receiptNumber)
            .set(receiptData);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<Receipt> fetchReceiptDataFromDB(String receiptNumber,
      String receiptDate, String receiptTime, String amPm) async {
    DocumentReference receiptRef = userReceiptsCollectionReference
        .doc(receiptDate)
        .collection(convertTimeStringTo24Hr(receiptTime, amPm))
        .doc(receiptNumber);
    return Receipt(
        receiptNumber: receiptNumber,
        receiptDate: receiptDate,
        receiptTime: receiptTime,
        receiptBeforeSaleProfit: await receiptRef
            .get()
            .then((value) => value.get("receiptBeforeSaleProfit")),
        receiptAfterSaleProfit: await receiptRef
            .get()
            .then((value) => value.get("receiptAfterSaleProfit")),
        receiptRevenue:
            await receiptRef.get().then((value) => value.get("receiptRevenue")),
        totalProductsSold: await receiptRef
            .get()
            .then((value) => value.get("totalProductsSold")),
        itemsList: await getProductsListFromReceipt(
            await receiptRef.get().then((value) => value.get("itemsList"))));
  }

  Future<void> deleteReceiptFromDB(
      String receiptNumber, String receiptHour, String receiptDate) async {
    try {
      await userReceiptsCollectionReference
          .doc(receiptDate)
          .collection(receiptHour)
          .doc(receiptNumber)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Handling hourly collection receipts-----------------------------------------
  void deleteInitReceipt(String date, String time) async {
    try {
      await userReceiptsCollectionReference
          .doc(date)
          .collection(time)
          .doc("xxxx")
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Handling Receipts data------------------------------------------------------
  Future<List<ProductInReceipt>> getProductsListFromReceipt(
      Map<String, dynamic> productsMap) async {
    List<String> products = productsMap.keys.toList();

    List<ProductInReceipt> returnedList = [];
    for (String product in products) {
      // todo
      String? productName =
          await UserInventoryServices().getProductNameFromBarCode(product);

      returnedList.add(ProductInReceipt(
        barcode: product,
        productName: productName ?? "خطأ في التحميل",
        userBuyingPrice:
            double.parse(productsMap[product]!["userBuyingPrice"]!),
        productSellingPrice:
            double.parse(productsMap[product]!["productSellingPrice"]!),
        productBoughtCount: double.parse(productsMap[product]!["count"]!),
        numbItemsInCarton: await UserInventoryServices().getProductCountInCartoonFromBarCode(product),
      ));
    }
    return returnedList;
  }

  Future<ProductInReceipt> getProductDataForCustomReceiptProduct(
      {required String numberOfPackageInsideTheCarton,
      required String productName,
      required String barCode,
      required double countBought,
      // required double unitPurchasePrice,
      // required double unitSellingPrice
      }) async {
    return ProductInReceipt(
      productName: productName,
      barcode: barCode,
      // userBuyingPrice: unitPurchasePrice,
      // productSellingPrice: unitSellingPrice,
      productPriceWithSale: null,
      productOnSale: false,
      productBoughtCount: countBought,
      numbItemsInCarton: double.parse(numberOfPackageInsideTheCarton),
    );
  }
}
