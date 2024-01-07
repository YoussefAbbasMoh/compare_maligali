import '../../../../../../../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/general_inventory_services.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import '../../../../../../../BusinessLogic/Models/product_in_receipt_model.dart';
import '../../../../../../../components/incrementDecrementItemCountField.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../components/buttons.dart';
import '../../../../../../../constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../newReceipt.dart';
import 'dart:ui' as ui;

class ScanProductBody extends StatefulWidget {
  const ScanProductBody({Key? key}) : super(key: key);

  @override
  State<ScanProductBody> createState() => _ScanProductBodyState();
}

class _ScanProductBodyState extends State<ScanProductBody> {

  @override
  void dispose() {
    clearControllersValues();
    super.dispose();
  }

  ProductInReceipt? productDetected;

  UserInventoryServices userInvServicesObj = UserInventoryServices();
  GeneralInventoryServices generalInvServicesObj = GeneralInventoryServices();

  bool productInUserInv = false;
  bool productInGenInv = false;

  TextEditingController productName = TextEditingController(text: "");
   TextEditingController barCode = TextEditingController(text: "");
  // TextEditingController unitPurchasePrice = TextEditingController(text: "");
  // TextEditingController unitSellingPrice = TextEditingController(text: "");
  TextEditingController numberOfPackagesInCartoon =
      TextEditingController(text: "");

  Future<String> barCodeScanner() async {
    String barcodeScanRes = "unknown";
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'رجوع', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'unknown';
    }

    if (!mounted) {
      return "unknown";
    }
    return barcodeScanRes;
  }

  late String barCodeScanned;
  @override
  void initState() {
    super.initState();
  }

  Future<String> initScanner() async {
    final scanResult = await barCodeScanner();
    if (scanResult == "-1") {
      barCode.text = "";
    }
    return scanResult;
  }

  @override
  Widget build(BuildContext context) {
    ItemCountField incDecButton = ItemCountField();
    return FutureBuilder<String>(
        future: initScanner(),
        builder: (context, barcodeSnapshot) {
          if (barcodeSnapshot.connectionState == ConnectionState.done) {
            if (barcodeSnapshot.hasError) {
              return Center(
                child: Text(
                  "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight),
                ),
              );
            } else if (barcodeSnapshot.hasData) {
              barCodeScanned = barcodeSnapshot.data!;
              if (barCodeScanned == '-1') {
                Future.microtask(() => Navigator.of(context).pop());
                return Container();
              }
              return Column(
                children: <Widget>[
                  SizedBox(width: double.infinity.w, height: 20.h),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(30).w)),
                      width: 330.w,
                      child: dataContainer(barCodeScanned, incDecButton)),
                  SizedBox(width: double.infinity.w, height: 20.h),
                  incDecButton,
                  SizedBox(width: double.infinity.w, height: 40.h),
                  Consumer<ReceiptViewModel>(
                      builder: (context, receiptVM, child) {
                    return DefaultButton(
                      bgColor: darkRed,
                      text: "زود منتج تاني",
                      onPressed: () async {
                        productDetected!.productBoughtCount =
                            incDecButton.getCount();

                        await addProductToReceipt(receiptVM);
                        setState(() {
                          productDetected = ProductInReceipt();
                          clearControllersValues();
                        });
                      },
                    );
                  }),
                  SizedBox(width: double.infinity.w, height: 30.h),
                  Consumer<ReceiptViewModel>(
                      builder: (context, receiptVM, child) {
                    return SecondaryButton(
                      fontSize: subFontSize,
                      width: 250.w,
                      height: 55.h,
                      text: "خلصت الفاتوره",
                      onPressed: () async {
                        productDetected!.productBoughtCount =
                            incDecButton.getCount();
                        await addProductToReceipt(receiptVM);
                        Navigator.pushNamed(context, NewReceipt.routeName);
                      },
                    );
                  }),
                  SizedBox(width: double.infinity.w, height: 10.h),
                ],
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  clearControllersValues() {
    productName.text = "";
     barCode.text = "";
    // unitPurchasePrice.text = "";
    // unitSellingPrice.text = "";
    numberOfPackagesInCartoon.text = "";
  }

  addProductToReceipt(ReceiptViewModel receiptVM) async {
    if (productDetected != null && productDetected!.productName != "منتج غير معروف") {
      receiptVM.addToProductsList([productDetected!]);
    }
  }

  Widget dataContainer(String scannedBarCode, ItemCountField incDecButton) {
    Map<String, String> productData =
        searchForProductInInventory(scannedBarCode);

    final ValueListenable<double> count = incDecButton.number;

    return ValueListenableBuilder<double>(
        valueListenable: count,
        builder: (context, value, child) {
          return Padding(
              padding: const EdgeInsets.only(right: 20).r,
              child: ((barCodeScanned == "unknown") || (productData.isEmpty))
                  ? dataColumnIfItemInUserInv(
                      // product is unknown or returned empty - scanner failed for any reason
                      productName: "منتج غير معروف",
                      barcode: "-",
                      productPrice: "0.0",
                      count: 0)
                  : dataColumnIfItemInUserInv(
                      productName: productData["productName"]!,
                      barcode: productData["barcode"]!,
                      productPrice: productData["productPrice"]!,
                      count: count.value));
        });
  }

  Map<String, String> searchForProductInInventory(String barCode) {
    String tempBarCode;
    if (barCode == "-1") {
      tempBarCode = "";
    } else {
      tempBarCode = barCode;
    }

    String productName = "";
    String barcode = "";
    String productPrice = "";

    List<UserInventory> userInvItems = userInvServicesObj
        .searchUserInventoryByProductNameOrBarCode(tempBarCode);

    if (userInvItems.isNotEmpty) {
      UserInventory item = userInvItems.toList()[0];

      productName = item.productName;
      barcode = item.barCode;
      productPrice = item.sellingPricePerPack.toString();

      return {
        "productName": productName,
        "barcode": barcode,
        "productPrice": productPrice,
      };
    }
    else {
      String firstPartOfBarcode = tempBarCode.substring(0, 7);
      List<UserInventory> userInvItems = userInvServicesObj
          .searchUserInventoryByProductNameOrBarCode(firstPartOfBarcode);

      if (userInvItems.isNotEmpty) {
        UserInventory item = userInvItems.toList()[0];

        productName = item.productName;
        barcode = item.barCode;
        productPrice = item.sellingPricePerPack.toString();

        return {
          "productName": productName,
          "barcode": barcode,
          "productPrice": productPrice,
        };

      }
    }
    return {};
  }

  Widget dataColumnIfItemInUserInv(
      {required String productName,
      required String barcode,
      required String productPrice,
      required double count}) {
    return FutureBuilder<ProductInReceipt>(
        future: userInvServicesObj.getProductDataForReceipt(barcode, count),
        builder: (context, snapshot) {
          productDetected = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: ui.TextDirection.rtl,
            children: <Widget>[
              SizedBox(width: double.infinity.w, height: 20.h),
              Text(
                productName,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                    fontSize: subFontSize.sp, fontWeight: subFontWeight),
              ),
              Text(
                barcode,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                    color: lightGreyReceiptBG,
                    fontSize: commonTextSize.sp,
                    fontWeight: commonTextWeight),
              ),
              SizedBox(width: double.infinity.w, height: 20.h),
              Text(
                "سعر المنتج : "
                "$productPrice",
                style: TextStyle(
                    fontSize: tinyTextSize.sp, fontWeight: commonTextWeight),
              ),
              SizedBox(width: double.infinity.w, height: 10.h),
              Text(
                "- :بعد العرض ",
                style: TextStyle(
                    fontSize: tinyTextSize.sp, fontWeight: commonTextWeight),
              ),
              Text("اجمالي السعر : "
                  "${count * double.parse(productPrice)}"),
            ],
          );
        });
  }

}
