import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import 'package:maligali/components/buttons.dart';
import 'package:maligali/components/incrementDecrementItemCountField.dart';
import 'package:maligali/components/searchByNameField.dart';

import 'package:roundcheckbox/roundcheckbox.dart';
import '../../../../../../../components/returnAppBar.dart';
import '../../../../../../../constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../newReceipt.dart';
import 'dart:ui' as ui;

class SearchByName extends StatefulWidget {
  static String routeName = "/SearchByName";
  const SearchByName({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchByNameState();
  }
}

class _SearchByNameState extends State<SearchByName> {
  UserInventoryServices userInvServicesObj = UserInventoryServices();

  String? filter;

  @override
  @override
  Widget build(BuildContext context) {
    ReceiptViewModel receiptVM = Provider.of<ReceiptViewModel>(context, listen: false);
    return SafeArea(
      child: Scaffold(
          appBar: ReturnAppBar(
        key: null,
        iconColor: purplePrimaryColor,
        pageTitle: "دور باسم المنتج",
        textColor: purplePrimaryColor,
        appBarColor: textWhite,
        preferredSize: Size.fromHeight(40.h),
        onPressed: (){
          receiptVM.emptyOnSearchingList();
          receiptVM.emptyProductsList();
          Navigator.pop(context);
        },
      ),
          body: Column(
            children: <Widget>[
              SizedBox(width: double.infinity.w, height: 20.h),
              SearchByNameField(onChange: (text) {
                if (text != null && text != filter) {
                  setState(() {
                    filter = text;
                  });
                }
              }),
              SizedBox(width: double.infinity.w, height: 10.h),
              searchByNameListView(userInvServicesObj
                  .searchUserInventoryByProductNameOrBarCode(filter)),
              Container(
                color: grayBG,
                width: double.infinity.w,
                height: 105.h,
                child: Center(
                  child: Consumer<ReceiptViewModel>(
                      builder: (context, receiptVM, child) {
                    return DefaultButton(
                      bgColor: darkRed,
                      width: 250.w,
                      height: 60.h,
                      text: "خلصت الفاتوره",
                      onPressed: () {
                        receiptVM.addToProductsList(
                            receiptVM.getOnSearchingList().values.toList());
                        receiptVM.emptyOnSearchingList();

                        Navigator.pushNamed(context, NewReceipt.routeName);
                      },
                    );
                  }),
                ),
              ),
            ],
          )),
    );
  }

  Widget searchByNameListView(List<UserInventory> items) {
    if (filter == null || filter?.trim() == "") {
      return const Center(
        child: Text(
          "نتيجة البحث هتطلع هنا",
          style:
              TextStyle(fontSize: commonTextSize, fontWeight: commonTextWeight),
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "المنتج مش موجود في مخزنك",
          style:
              TextStyle(fontSize: commonTextSize, fontWeight: commonTextWeight),
        ),
      );
    }
    return Expanded(
        child: Container(
            color: grayBG,
            width: 360.w,
            child: ListView(children: [
              ...items.map(
                (UserInventory data) {
                  return createListTile(data.productName, data.barCode,
                      data.sellingPricePerPack.toStringAsFixed(2), true);
                },
              )
            ])));
  }

  Widget createListTile(
      String productName, String barCode, String productPrice, bool selected) {
    ItemCountField incDecButton = ItemCountField();

    return ExpansionTile(
      title: SizedBox(
        child: Row(
          textDirection: ui.TextDirection.rtl,
          children: [
            SizedBox(
              width: 160.w,
              child: Text(productName,
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight)),
            ),
            SizedBox(width: 20.w),
            SizedBox(
              width: 65.w,
              child: Text(productPrice + " جم",
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight)),
            ),
            Consumer<ReceiptViewModel>(builder: (context, receiptVM, child) {
              final ValueListenable<double> number = incDecButton.number;
              return ValueListenableBuilder<double>(
                  valueListenable: number,
                  builder: (context, value, child) {
                    return RoundCheckBox(
                      disabledColor: lightGreyReceiptBG,
                      isChecked: false,
                      onTap: number.value == 0
                          ? null
                          : (selected) async {
                              if (selected != null) {
                                if (selected == true) {
                                  if (incDecButton.getCount() == 0) {
                                    incDecButton.counterController.text = "1";
                                  }
                                  final product = await userInvServicesObj
                                      .getProductDataForReceipt(
                                          barCode, incDecButton.getCount());
                                  receiptVM.addToOnSearchingList(product);
                                } else {
                                  receiptVM.removeFromOnSearchList(productName);
                                }
                              }
                            },
                    );
                  });
            }),
          ],
        ),
      ),
      children: <Widget>[incDecButton],
    );
  }
}

//TODO: احل مشكلة انه لازم يتأكد انه مختار كل المنتجات اللي اتشرت قبل م يقفل او يختار المنتج
