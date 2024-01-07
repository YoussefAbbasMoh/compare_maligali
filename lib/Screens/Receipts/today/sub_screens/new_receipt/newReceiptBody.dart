import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';
import 'dart:ui' as ui;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../BusinessLogic/Models/product_in_receipt_model.dart';
import '../../../../../BusinessLogic/Services/FireBaseServices/coll_user_customers_services.dart';
import '../../../../../BusinessLogic/utils/globalSnackBar.dart';
import '../../../../../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import '../../../../../BusinessLogic/view_models/update_user_info.dart';
import '../../../../../components/buttons.dart';
import '../../../../../components/customTextField.dart';
import 'sub_screens/search_by_barcode/searchByBarcode.dart';
import '../../../../../constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'sub_screens/search_by_name/searchByName.dart';
import '../../../home_screen.dart';
import 'dart:async';

class NewReceiptBody extends StatefulWidget {
  const NewReceiptBody({Key? key}) : super(key: key);

  @override
  State<NewReceiptBody> createState() => _NewReceiptBodyState();
}

class _NewReceiptBodyState extends State<NewReceiptBody> {
  GlobalKey imageKey = GlobalKey();

  ReceiptViewModel? _receiptVM;

  String? date;
  String? time;

  TextEditingController totalReceiptCostController =
      TextEditingController(text: "0.0");
  TextEditingController payedMoneyController =
      TextEditingController(text: "0.0");

  @override
  void initState() {
    super.initState();
  }

  Future<String> initProvider() async {
    _receiptVM = Provider.of<ReceiptViewModel>(context, listen: false);
    if (_receiptVM?.receiptReloaded == false) {
      await _receiptVM!.initNewReceiptVM(context);
    }

    date = _receiptVM!.day + "-" + _receiptVM!.month + "-" + _receiptVM!.year;
    time = _receiptVM!.hour + ":" + _receiptVM!.min;
    totalReceiptCostController.text =
        _receiptVM!.calculateAfterSaleProfit().toStringAsFixed(2);

    return "done";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<String>(
          future: initProvider(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                    style: TextStyle(
                        fontSize: commonTextSize.sp,
                        fontWeight: commonTextWeight),
                  ),
                );
              } else if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Card(
                    shadowColor: textBlack,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: textBlack, width: 3.w),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(35.r))),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0.h),
                          child: searchingProductsButtonsRow(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.r)),
                              color: darkBeige,
                            ),
                            child: receiptBlock(),
                          ),
                        ),
                        // SizedBox(width: double.infinity.w, height: 5.h),
                        SizedBox(
                          width: 330.w,
                          child: bottomButtonsRow(),
                        ),
                        SizedBox(width: double.infinity.w, height: 10.h),
                      ],
                    ),
                  ),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  Widget receiptBlock() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5.h),
          child: Stack(
            textDirection: TextDirection.rtl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<UpdateUserInfoViewModel>(
                      builder: (context, userInfo, child) {
                    return Text(
                        StoreOwner.legalStatement
                            ? "تحرر من " + userInfo.shopNameController.text
                            : "",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: commonTextSize.sp,
                        ));
                  }),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.85), // border color
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.r), // border width
                    child: Container(
                      child: Image.asset(
                          "assets/images/maligali_logo.png"), // or ClipRRect if you need to clip the content
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: purplePrimaryColor, // inner circle color
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          "بيان " + _receiptVM!.receiptNumber + " # ",
          style: TextStyle(
            fontSize: tinyTextSize.sp,
          ),
          textDirection: ui.TextDirection.rtl,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: tinyTextSize.sp),
              ),
              Text(
                time!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: tinyTextSize.sp),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ج',
                style: TextStyle(fontSize: commonTextSize.sp),
                textDirection: ui.TextDirection.rtl,
              ),
              SizedBox(
                width: 170.w,
                height: 50.h,
                child: TextField(
                  style: TextStyle(fontSize: mainFontSize.sp),
                  textAlign: TextAlign.center,
                  textDirection: ui.TextDirection.rtl,
                  controller: totalReceiptCostController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _receiptVM!.setTotalReceiptCostController(value);
                  },
                ),
              ),
              Text(
                'اجمالي الفاتورة: ',
                style: TextStyle(fontSize: tinyTextSize.sp),
                textDirection: ui.TextDirection.rtl,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 15.w, left: 15.w, top: 7.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: ui.TextDirection.rtl,
            children: [
              Text(
                "قيمة الخصم:",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: tinyTextSize.sp,
                ),
              ),
              Consumer<ReceiptViewModel>(
                  builder: (context, receiptConsumer, child) {
                return Padding(
                  padding: EdgeInsets.only(right: 10.0.w),
                  child: Text(
                      "${receiptConsumer.discountValue.toStringAsFixed(2)} ج ",
                      style: TextStyle(
                        fontSize: commonTextSize.sp,
                      ),
                      textDirection: ui.TextDirection.rtl),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: 7.w, left: 7.w, bottom: 8.h, top: 10.h),
          child: receiptTitlesRow(),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: receiptSummaryRow(),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Center(
            child: Text(
                (StoreOwner.legalStatement)
                    ? "الاسعار شاملة الضريبة علي المنتجات الخاضعة لضريبة القيمه المضافة"
                    : "",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: 10.sp,
                    color: textBlack,
                    fontWeight: tinyTextWeight)),
          ),
        ),
      ],
    );
  }

  Widget receiptTitlesRow() {
    List<ProductInReceipt> productsBought = _receiptVM!.getProductsList();

    return Table(
      // defaultColumnWidth: const FixedColumnWidth(120.0),
      border: TableBorder.all(
        color: Colors.black,
        style: BorderStyle.solid,
        width: 2.w,
      ),
      columnWidths: {
        0: FixedColumnWidth(70.w), // fixed to 100 width
        1: FlexColumnWidth(20.w),
        2: FixedColumnWidth(150.w),
        3: FixedColumnWidth(55.w), //fixed to 100 width
      },
      children: [
        TableRow(children: [
          Column(children: [
            Text('اجمالي',
                style: TextStyle(
                    fontSize: extraTinyTextSize.sp, fontWeight: tinyTextWeight))
          ]),
          Column(children: [
            Text('السعر',
                style: TextStyle(
                    fontSize: extraTinyTextSize.sp, fontWeight: tinyTextWeight))
          ]),
          Column(children: [
            Text("اسم المنتج",
                style: TextStyle(
                    fontSize: extraTinyTextSize.sp, fontWeight: tinyTextWeight))
          ]),
          Column(children: [
            Text('الكمية',
                style: TextStyle(
                    fontSize: extraTinyTextSize.sp, fontWeight: tinyTextWeight))
          ]),
        ]),
        for (var item in productsBought)
          TableRow(children: [
            Text(
                (item.productSellingPrice * item.productBoughtCount)
                    .toStringAsFixed(2),
                textAlign: TextAlign.center),
            Text(
              item.productSellingPrice.toStringAsFixed(2),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.only(right: 3.w),
              child: Text(item.productName, textAlign: TextAlign.right),
            ),
            Column(children: [
              Text(item.productBoughtCount.toStringAsFixed(2)),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  print("is deletting");
                  print(productsBought);
                  productsBought.remove(item);

                  setState(() {});
                  print(productsBought);
// remove the row data
                },
              ),
            ]),
          ]),
      ],
    );
  }

  Widget receiptSummaryRow() {
    return Padding(
      padding: EdgeInsets.only(right: 7.w, left: 7.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ج',
                style: TextStyle(fontSize: commonTextSize.sp),
                textDirection: ui.TextDirection.rtl,
              ),
              SizedBox(
                width: 180.w,
                height: 40.h,
                child: TextField(
                  style: TextStyle(fontSize: commonTextSize.sp),
                  textAlign: TextAlign.center,
                  textDirection: ui.TextDirection.rtl,
                  controller: payedMoneyController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    print(value);
                    _receiptVM!.setPayedMoneyController(value);
                    // todo
                  },
                ),
              ),
              Text(
                'المدفوع: ',
                style: TextStyle(
                    fontSize: tinyTextSize.sp, fontWeight: tinyTextWeight),
                textDirection: ui.TextDirection.rtl,
              ),
            ],
          ),
          Consumer<ReceiptViewModel>(
              builder: (context, receiptConsumer, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              textDirection: ui.TextDirection.rtl,
              children: [
                Text(
                  "الباقي:",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: tinyTextSize.sp, fontWeight: tinyTextWeight),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.0.w, left: 8.0.w),
                  child: Text(
                      "${receiptConsumer.returnedChange.toStringAsFixed(2)} ج",
                      style: TextStyle(
                          fontSize: commonTextSize.sp,
                          color: receiptConsumer.returnedChange < 0
                              ? redTextAlert
                              : textBlack),
                      textDirection: ui.TextDirection.rtl),
                ),
                receiptConsumer.returnedChange < 0
                    ? const Text(
                        "المدفوع اقل من قيمة الفاتورة",
                        style: TextStyle(color: redTextAlert),
                      )
                    : const SizedBox()
              ],
            );
          })
        ],
      ),
    );
  }

  // buttons Rows: -------------------------------------------------------
  Widget searchingProductsButtonsRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 30).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shadowColor: lightGreyButtons2,
              backgroundColor: lightGreyButtons,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30).w,
              ),
              fixedSize: Size(190.w, 40.h),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5).r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 23.w),
                Text(
                  'دور علي منتج',
                  style: TextStyle(
                      fontSize: tinyTextSize.sp,
                      fontWeight: tinyTextWeight,
                      color: darkGreen),
                ),
                Icon(
                  Icons.search,
                  size: 25.w,
                  color: darkGreen,
                )
              ],
            ),
            onPressed: () async {
              Navigator.pushNamed(context, SearchByName.routeName);
            },
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: lightGreyButtons2,
                backgroundColor: lightGreyButtons,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30).w,
                ),
                fixedSize: Size(35.w, 50.h),
              ),
              child: Image.asset(
                "assets/images/barcode_icon.png",
                height: 30.h,
                width: 30.w,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SearchByScanner(),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget bottomButtonsRow() {
    final TextEditingController _customerNumberController =
        TextEditingController();
    _customerNumberController.text = "";
    String customerPhoneNo = "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: ui.TextDirection.rtl,
      children: [
        CustomTextField(
          controller: _customerNumberController,
          onChanged: (value) {
            customerPhoneNo = "2" + value;
          },
          keyboardType: TextInputType.phone,
          hintText: "00 000 000 010",
          labelText: "رقم تليفون الزبون",
          initialColor: textBlack,
          fontStyle: const TextStyle(color: textBlack, fontSize: tinyTextSize),
          hintStyle:
              TextStyle(color: lightGreyReceiptBG, fontSize: subFontSize.sp),
          topPadding: 0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: ui.TextDirection.rtl,
            children: [
              DefaultButton(
                fontSize: subFontSize.sp,
                fontWeight: subFontWeight,
                text: "تحرير البيان",
                height: mediumButtonSize.h,
                onPressed: () async {
                  await _receiptVM!.completeSale();
                  await endReceipt();
                },
              ),
              Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: lightGreyButtons,
                  boxShadow: [
                    BoxShadow(
                        color: purpleAppbar,
                        offset: Offset(1.5, 2.5),
                        blurRadius: 5.0,
                        blurStyle: BlurStyle.normal),
                  ],
                ),
                child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.green, size: 40.w),
                    onPressed: () async {
                      await endReceiptForWhatsapp(customerPhoneNo);
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> endReceiptForWhatsapp(String whatsappPhone) async {
    print("in end Receipt for whatsapp function");
    await _receiptVM!.addReceiptToDB(context, date, time);
    displaySnackBar(text: "تم حفظ الفاتورة");
    //await
    _receiptVM!.completeSale();
    print(_receiptVM!.getProductsList());
    await shareViaWhatsapp(whatsappPhone);
    await _receiptVM!.endReceiptVM(context);
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.routeName, (route) => false);
  }

  // End Receipt Operation: ----------------------------------------------------
  Future<void> endReceipt() async {
    await _receiptVM!.addReceiptToDB(context, date, time);
    displaySnackBar(text: "تم حفظ الفاتورة");
    await _receiptVM!.endReceiptVM(context);
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.routeName, (route) => false);
  }

  shareViaWhatsapp(String phoneNumber) async {
    var url = "https://wa.me/";

    print("in share Via Whatsapp function");
    print(phoneNumber.length);
    print(phoneNumber);
    if (phoneNumber.length == 12) {
      await canLaunch(url + phoneNumber + "/?text=${generateReceiptText()}")
          ? await launch(url + phoneNumber + "/?text=${generateReceiptText()}")
          : throw 'could not launch $url';
    }
    UserCustomersServices()
        .addNewReceiptToCustomer(phoneNumber, _receiptVM!.receiptNumber);
  }

  String generateReceiptText() {
    String upperBlockText = (StoreOwner.legalStatement
            ? "_تحرر من_ : " + "*${StoreOwner.storeName}*" + "\n"
            : "") +
        "_بيان_ : " +
        "*${_receiptVM!.receiptNumber}*" +
        "\n" +
        "_التاريخ_ : " +
        "*${date!.replaceAll("-", "/")}*" +
        "\n" +
        "_الوقت_ : " +
        "*${time!}*" +
        "\n\n" +
        "---------------------------------" +
        "\n\n";
    //////////////////
    String middleBlockText = "_المنتجات_ : ";

    List<ProductInReceipt> productsBought = _receiptVM!.getProductsList();

    for (ProductInReceipt product in productsBought) {
      middleBlockText += "\n\n" +
          "_اسم المنتج_ : " +
          "*${product.productName}*" +
          "\n" +
          "_العدد_ : " +
          "*${product.productBoughtCount}*" +
          "\n" +
          "_قبل الخصم_ : " +
          "~${(product.productPriceWithSale ?? product.productSellingPrice * product.productBoughtCount).toStringAsFixed(2)}~" +
          "\n" +
          "_القيمة_ : " +
          "*${(product.productPriceWithSale ?? product.productSellingPrice * product.productBoughtCount).toStringAsFixed(2)}*";
    }

    middleBlockText += "\n\n" + "---------------------------------" + "\n\n";

    ///////////////////////////////////////////////
    String lowerBlockText = "اجمالي القيمة : " +
        "\n\n" +
        "_قبل الخصم_ : " +
        "~${_receiptVM?.calculateBeforeSaleProfit().toStringAsFixed(2)}ج~" +
        "\n" +
        "_بعد الخصم_ : " +
        "*${_receiptVM?.calculateAfterSaleProfit().toStringAsFixed(2)}ج*" +
        "\n" +
        "\n\n" +
        "${(StoreOwner.legalStatement) ? "الاسعار شاملة الضريبة علي المنتجات الخاضعة لضريبة القيمه المضافة" : ""}";

    //////////////////////////////////////////////////
    String mhalatkoAdvertisingText = "\n\n" +
        "*********************************" + "\n" +
        "_دلوقتي تقدر تطلب الاوردر من محل_" +
        "*${StoreOwner.storeName}*" +
        " _من خلال تطبيق:_" +
        "*محلاتكو*" +
        "\n" +
        "*لينك التطبيق للأندرويد: *" +
        "https://play.google.com/store/apps/details?id=com.absai.Bqala_Go" +
        "\n\n";

    return upperBlockText +
        middleBlockText +
        lowerBlockText +
        mhalatkoAdvertisingText;
  }
}
