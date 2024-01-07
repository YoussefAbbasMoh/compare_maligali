import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Services/FireBaseServices/create_and_delete_db_services.dart';
import '../../components/buttons.dart';
import '../../components/returnAppBar.dart';
import '../../constants.dart';
import '../../scaffoldComponents/GeneralScaffold.dart';
import 'existing_inventory/existing_inventory_screen.dart';
import 'dart:math';

class InventoryEntrancePage extends StatefulWidget {
  const InventoryEntrancePage({Key? key}) : super(key: key);
  static String routeName = "/InventoryEntrancePage";

  @override
  State<InventoryEntrancePage> createState() => _InventoryEntrancePageState();
}

class _InventoryEntrancePageState extends State<InventoryEntrancePage> {
  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      curentPage: InventoryEntrancePage.routeName,
      backGroundColor: textWhite,
      appBar: ReturnAppBar(
        key: null,
        pageTitle: "المخزن",
        textColor: textWhite,
        appBarColor: purplePrimaryColor,
        bottom: Container(
          decoration: BoxDecoration(
            color: textWhite,
            borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))
                .w,
          ),
        ),
        preferredSize: Size.fromHeight(40.h),
      ),
      body: buttonsColumn(),
    );
  }

  Widget buttonsColumn() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 20.w),
            child: DefaultButton(
                text: "عرض الأقسام",
                onPressed: () {
                  Navigator.pushNamed(
                      context, ExistingInventoryScreen.routeName);
                },
                height: mainButtonsSize,
                width: MediaQuery.of(context).size.width,
                fontColor: textWhite,
                bgColor: purplePrimaryColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 15.w,
              ),
              const Expanded(
                  child: Divider(
                color: textBlack,
              )),
              SizedBox(
                width: 5.w,
              ),
              const Text(
                "مفاتيح ربط المخزن \n بمساعد مالي جالي",
                style: TextStyle(
                  fontSize: tinyTextSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 5.w,
              ),
              const Expanded(
                  child: Divider(
                color: textBlack,
              )),
              SizedBox(
                width: 15.w,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.w),
            child: DefaultButton(
                text: "دمج المخزن",
                onPressed: () async{
                  await mergeInventory();
                },
                fontColor: textBlack,
                bgColor: lightGreyButtons2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.w),
            child: DefaultButton(
                text: "حفظ المخزن",
                onPressed: () async {
                  await saveInventory();
                },
                fontColor: textBlack,
                bgColor: lightGreyButtons2),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 20.w),
            child: DefaultButton(
                text: "إنشاء كود اتصال جديد",
                onPressed: () {
                  createNewInventoryPassCode(context);
                },
                fontColor: textBlack,
                bgColor: lightGreyButtons2),
          ),
        ],
      ),
    );
  }

  final _chars = '1234567890';
  final Random _rnd = Random.secure();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  createNewInventoryPassCode(BuildContext context) async {
    String passCode = getRandomString(7);
    await CreateAndDeleteDBServices().userDBReference().update({'passCode': passCode});

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5.0.w),
                  child: const Text(
                    "كود الإتصال",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontWeight: mainFontWeight),
                  ),
                ),
                const Icon(
                  Icons.lock_open,
                  color: redLightButtonsLightBG,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'دخل كود الإتصال في التطبيق المساعد للسماح للمساعد بدخول المخزن',
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  passCode,
                  style: const TextStyle(
                      fontSize: commonTextSize, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            //buttons?
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: DefaultButton(
                      text: "تم",
                      width: 110,
                      height: 30,
                      fontSize: tinyTextSize,
                      onPressed: () async {
                        // todo
                        try{
                          await CreateAndDeleteDBServices().userDBReference().update({'passCode': FieldValue.delete()});
                        }
                        catch(e){}
                        Navigator.of(context).pop();
                      }),
                ),
              )
            ],
          );
        });
  }

  mergeInventory(){}
  saveInventory(){}

}
