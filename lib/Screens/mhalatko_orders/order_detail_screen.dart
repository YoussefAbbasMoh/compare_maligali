import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../BusinessLogic/Models/product_in_receipt_model.dart';
import '../../BusinessLogic/Models/store_owner_model.dart';
import '../../BusinessLogic/Services/FireBaseServices/coll_user_customers_services.dart';
import '../../BusinessLogic/utils/globalSnackBar.dart';
import '../../BusinessLogic/view_models/mhalatko_orders_view_models/orders_view_model.dart';
import '../../components/buttons.dart';
import '../../components/returnAppBar.dart';
import '../../constants.dart';
import '../../scaffoldComponents/GeneralScaffold.dart';
import '../Receipts/home_screen.dart';
import 'orders_notification_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);
  static String routeName = "/OrderDetailsScreen";

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrdersViewModel orderVM ;
  @override
  void initState() {
    // TODO: implement initState
    orderVM = Provider.of<OrdersViewModel>(context, listen: false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    String orderNumber = orderVM
        .orderSelected!
        .orderNumber;
    return GeneralScaffold(
        backGroundColor: white2BG,
        appBar: ReturnAppBar(
          onPressed: () {
            orderVM.clearOrderDataInHand();
            Navigator.pop(context);
          },
          iconColor: textBlack,
          key: null,
          pageTitle: "اوردر رقم: " + orderNumber,
          preferredSize: Size.fromHeight(40.h),
        ),
        curentPage: OrderDetailsScreen.routeName,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 15.0.h),
            child: Column(
              children: [
                receiptBlock(),
                whatsAppBottomRow(),
              ],
            ),
          ),
        ));
  }

  Widget receiptBlock() {
    return Consumer<OrdersViewModel>(
      builder: (context, orderVM, child){
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderVM.date,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: tinyTextSize.sp),
                ),
                Text(
                  orderVM.time,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: tinyTextSize.sp),
                ),
              ],
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

                  Text(orderVM.getTotalOrderCost().toString(), style: TextStyle(fontSize: commonTextSize.sp, fontWeight: commonTextWeight),
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
              padding:  EdgeInsets.only(right: 7.w, left: 7.w, bottom: 8.h, top: 10.h),
              child: receiptTitlesRow(),
            ),
            Padding(
              padding:  EdgeInsets.only(bottom: 8.h),
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
      },
    );
  }

  Widget receiptTitlesRow() {
    List<ProductInReceipt> productsBought = Provider.of<OrdersViewModel>(context, listen: false).productsInOrder;
    return Table(
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
          TableRow(
              children: [
                Text((item.productSellingPrice * item.productBoughtCount)
                    .toStringAsFixed(2),
                    textAlign: TextAlign.center
                ),
                Text(item.productSellingPrice.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: Text(item.productName,
                      textAlign: TextAlign.right),
                ),
                Text(item.productBoughtCount.toStringAsFixed(2),
                  textAlign: TextAlign.center,),
              ]),
      ],
    );
  }

  Widget whatsAppBottomRow(){
    String _canSend = Provider.of<OrdersViewModel>(context, listen: false).orderSelected!.orderStatus;
    bool isEnabled = true;

    if(_canSend == "new"){
      isEnabled = true;
    }

     if(orderVM.orderSelected?.orderStatus == "Placed" || orderVM.orderSelected?.orderStatus == "Seen"){
       return Center(
         child: Row(
           children: [
             DefaultButton(
                 fontColor: textBlack,
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w500,
                 height: 25.h,
                 width: 130.w,
                 bgColor: lightGreyButtons,
                 text: "رفض الطلب",
                 onPressed: () async {
                   rejectOrder();
                   displaySnackBar(text: "تم رفض الطلب");
                 }),

            const Expanded(child: SizedBox()),
             DefaultButton(
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w500,
                 height: 25.h,
                 width: 130.w,
                 bgColor: purpleAppbar,
                 text: "قبول الطلب",
                 onPressed: () async {
                   await endReceiptForWhatsapp();
                   displaySnackBar(text: "تم تحرير الفاتورة");
                 }),
           ],
         ),
       );}
     else if(orderVM.orderSelected?.orderStatus == "OnDelivery" ){
       return DefaultButton(
           fontSize: 12.sp,
           fontWeight: FontWeight.w500,
           height: 25.h,
           width: 130.w,
           bgColor: purpleAppbar,
           text: "تاكيد التوصيل",
           onPressed: () async {
             delivered();
             displaySnackBar(text: "تم تاكيد التوصيل");
           });
     }
    else{ return const SizedBox();}
    Padding(
      padding: EdgeInsets.only(top:5.0.h),
      child: Text(isEnabled?"أرسل الفاتورة للحفظ":"تم ارسال الفاتورة", style: const TextStyle(fontSize: commonTextSize, fontWeight: commonTextWeight),),
    );
  }
  Future<void> delivered() async{
    displaySnackBar(text: "جاري تاكيد التوصيل");
    await orderVM.confirmDelivery(orderVM
        .orderSelected!);
    Navigator.pushNamedAndRemoveUntil(
        context, OrdersNotificationsScreen.routeName, (route) => false);
  }

  Future<void> rejectOrder() async{
    displaySnackBar(text: "جاري رفض الطلب");
    await orderVM.rejectOrder(orderVM
        .orderSelected!);
    Navigator.pushNamedAndRemoveUntil(
        context, OrdersNotificationsScreen.routeName, (route) => false);
  }

  Future<void> endReceiptForWhatsapp() async {

    await orderVM.addReceiptToDB(context);
    displaySnackBar(text:"تم حفظ الفاتورة");
    // await shareViaWhatsapp(orderVM.orderSelected!.clientPhone, orderVM.orderNumber);
    await orderVM.completeSale();
    await orderVM.endReceiptVM(context,orderVM
        .orderSelected!);

    Navigator.pushNamedAndRemoveUntil(
        context, OrdersNotificationsScreen.routeName, (route) => false);
  }

  shareViaWhatsapp(String phoneNumber, String orderNumber) async {
    var url = "https://wa.me/";
    //Uri uri = Uri.parse(url + phoneNumber + "/?text=${generateReceiptText()}");

    if (phoneNumber.length <= 13) {
      await canLaunch((url + phoneNumber + "/?text=${generateReceiptText()}")) //canLaunchUrl(uri)
          ? await launch((url + phoneNumber + "/?text=${generateReceiptText()}"))
          : throw 'could not launch $url';
    }
    else{
      phoneNumber = "2"+phoneNumber;
      await canLaunch(url + phoneNumber + "/?text=${generateReceiptText()}")
          ? await launch(url + phoneNumber + "/?text=${generateReceiptText()}")
          : throw 'could not launch $url';
    }
    UserCustomersServices()
        .addNewReceiptToCustomer(phoneNumber, orderNumber );
  }

  String generateReceiptText() {
    OrdersViewModel orderVM = Provider.of<OrdersViewModel>(context, listen: false);

    String upperBlockText = (StoreOwner.legalStatement
        ? "_تحرر من_ : " + "*${StoreOwner.storeName}*" + "\n"
        : "") +
        "_بيان_ : " +
        "*${orderVM.orderNumber}*" +
        "\n" +
        "_التاريخ_ : " +
        "*${orderVM.date.replaceAll("-", "/")}*" +
        "\n" +
        "_الوقت_ : " +
        "*${orderVM.time}*" +
        "\n\n" +
        "---------------------------------" +
        "\n\n";
    //////////////////
    String middleBlockText = "_المنتجات_ : ";

    List<ProductInReceipt> productsBought = orderVM.productsInOrder;

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
        "~${orderVM.calculateBeforeSaleProfit().toStringAsFixed(2)}ج~" +
        "\n" +
        "_بعد الخصم_ : " +
        "*${orderVM.calculateAfterSaleProfit().toStringAsFixed(2)}ج*" +
        "\n" +
        "\n\n" +
        "*${(StoreOwner.legalStatement) ? "الاسعار شاملة الضريبة علي المنتجات الخاضعة لضريبة القيمه المضافة" : ""}*";

    return upperBlockText + middleBlockText + lowerBlockText;
  }
}
