import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../BusinessLogic/Models/mhalatko_order_models/order_model.dart';
import '../../BusinessLogic/Services/FireBaseServices/create_and_delete_db_services.dart';
import '../../BusinessLogic/view_models/mhalatko_orders_view_models/orders_view_model.dart';
import '../../components/buttons.dart';
import '../../constants.dart';
import 'order_detail_screen.dart';


class NewOrders extends StatefulWidget {
  const NewOrders({Key? key}) : super(key: key);

  @override
  State<NewOrders> createState() => _NewOrdersState();
}
class _NewOrdersState extends State<NewOrders> with AutomaticKeepAliveClientMixin<NewOrders> {
  late OrdersViewModel ordersVM;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
    ordersVM.listenToStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure that the mixin's build method is called

    return SingleChildScrollView(
      child: Consumer<OrdersViewModel>(builder: (context, ordersVM, child) {
        return FutureBuilder<bool>(
          future: ordersVM.loadAllOrders(),
          builder: (context, ordersSnapshot) {
            if (ordersSnapshot.connectionState == ConnectionState.done) {
              if (ordersSnapshot.hasError ||
                  ordersSnapshot.data == null ||
                  ordersSnapshot.data == false) {
                if (kDebugMode) {
                  print(ordersSnapshot.error);
                }
                return Center(
                  child: Text(
                    "حصل مشكلة في تحميل الطلبات \n اتأكد من اتصالك بالنت او عيد فتح البرنامج",
                    style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight,
                    ),
                  ),
                );
              } else if (ordersSnapshot.hasData &&
                  ordersVM.newOrdersList.isNotEmpty) {
                return ordersListView();
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.3.h,
                  ),
                  child: Center(
                    child: Text(
                      "مفيش طلبات جديدة",
                      style: TextStyle(
                        fontSize: mainFontSize.sp,
                        fontWeight: mainFontWeight,
                      ),
                    ),
                  ),
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }),
    );
  }
  Widget ordersListView() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ordersVM.newOrdersList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: 10.h, left: 10.w, right: 10.w, top: 10.h),
            child: orderTile(ordersVM.newOrdersList[index]),
          );
        });
  }

  Widget orderTile(Order orderData) {
    bool _active = false;
    // bool _seen = false;

    if (orderData.orderStatus.toString() == "Placed") {
      _active = false;
    } else if (orderData.orderStatus.toString() == "Seen") {
      _active = true;
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 3.0, color: lightGreyButtons),
          color: _active == false ? lightGreyButtons : textWhite,
          boxShadow: [
            BoxShadow(
              color: textBlack.withOpacity(0.3),
              // blurRadius: 5.r,
              // spreadRadius: 2.r,
              offset: Offset.fromDirection(2),
            )
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(20.r),
          ),
        ),
        child: tile(orderData, _active));
  }

  Widget tile(Order orderData, bool active) {
    return Padding(
      padding: const EdgeInsets.all(10.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,

        children: [
          titleRow(orderData, active),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(vertical: 8.0.h),
                child: Icon(
                  Icons.location_on,
                  color: purplePrimaryColor,
                  size: 18.sp,
                ),
              ),
              // SizedBox(
              //   width: 1.w,
              //   height: 1.h,
              // ),
              Flexible(
                child: Text(
                  orderData.clientAddress,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.phone,
                  color: purplePrimaryColor,
                  size: 18.sp,
                ),
                SizedBox(
                  width: 8.w,
                  height: 1.h,
                ),
                Text(
                  orderData.clientPhone,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ]),
          Divider(
            indent: 20.w,
            endIndent: 20.w,
            color: Colors.black38,
            thickness: 1.r,
          ),
          Text(
            "بيانات الطلب",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          totalOrderPrice(orderData),
          Text(
            "قيمة التوصيل: ${orderData.orderDeliveryPrice} ج ",
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
          Text(
            "عدد المنتجات المطلوبة: ${calculateOrderItemsCount(orderData.orderItems.values.toList())}",
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
          orderButtons(orderData, active),
        ],
      ),
    );
  }

  Widget titleRow(Order orderData, bool active) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                "${orderData.clientName} :أسم العميل",
                style: const TextStyle(fontSize: subFontSize),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(5.0).r,
              //   child: Image.asset(
              //     "assets/images/shopping_basket.png",
              //     alignment: AlignmentDirectional.center,
              //     height: 25.h,
              //     //  width: 35.w,
              //   ),
              // ),
              // const Expanded(child: SizedBox()),

              Text(
                "${orderData.orderNumber} :رقم الطلب",
                style: TextStyle(fontSize:tinyTextSize),
              ),

              //todo: distance from mhaltko
              // Text(
              //   "المسافة ${orderData.distanceByTime}",
              //   style: TextStyle(fontSize: 10.sp, color: redTextAlert),
              // )
            ],
          ),
          Expanded(child: SizedBox()),
          Container(
            height: 35.h,
            decoration: BoxDecoration(
              color: purpleAppbar,
              shape: BoxShape.circle,
              border: Border.all(
                color: textBlack,
                width: 1.5.r,
                style: BorderStyle.solid,
              ),),
            child: IconButton(
                icon: Icon(
                  Icons.phone,
                  // Specify the phone icon
                  color: Colors.white, // Set the color of the icon
                ),

                onPressed: () async {
                  Uri url = Uri.parse('tel:${orderData.clientPhone}');

                  Future<void> customLaunchUrl(Uri url) async {
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  }

                  customLaunchUrl(url);
                }),
          ),
        ],
      ),
    );
  }

  Widget orderButtons(Order orderData, bool active) {
    return Row(
      children: [
        active == false ?Padding(
          padding: const EdgeInsets.all(5.0).r,
          child: Image.asset(
            "assets/images/read.png",
            alignment: AlignmentDirectional.centerStart,
            height: 25.h,
            //  width: 35.w,
          ),
        ):Padding(
          padding: const EdgeInsets.all(5.0).r,
          child: Image.asset(
            "assets/images/seen.png",
            alignment: AlignmentDirectional.centerStart,
            height: 25.h,
            //  width: 35.w,
          ),
        ),
        // SizedBox(
        //   width: MediaQuery.of(context).size.width *0.15.w
        // ),
        Center(
          widthFactor: 1.6.w,
          child: DefaultButton(

              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 25,
              width: 150,
              text: "عرض التفاصيل",
              onPressed: () {
                active == false
                    ? CreateAndDeleteDBServices()
                    .customersDBReference(orderData.customerUid)
                    .collection("newOrders")
                    .doc(orderData.orderNumber)
                    .update({"orderStatus": "Seen"})
                    : print("hello");
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                ordersVM.setOrderDataInHand(orderData);

                Navigator.pushNamed(context, OrderDetailsScreen.routeName);
              }),
        ),
      ],
    );
  }

  Widget totalOrderPrice(Order orderData) {
    return Row(mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.rtl, children: [
          Text(
            " :إجمالي قيمة الطلب",
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
          FutureBuilder<String>(
              future: calculateTotalOrderCost(orderData),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print(snapshot.error);
                    }
                    return Center(
                      child: Text(
                        "غير معروف",
                        style: TextStyle(fontSize: 10.sp, color: redTextAlert),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data! + "ج ",
                      style: TextStyle(fontSize: 10.sp),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              })
        ]);
  }

  Future<String> calculateTotalOrderCost(Order orderData) async {
    // i made a new object called ordersVMobj to differentiate between each order as it was using only one object
    //called ordersVm which was declaired public in the start of the code
    OrdersViewModel ordersVMobj = OrdersViewModel();
    await ordersVMobj.getOrderItemsList(orderData);
    return ordersVMobj.calculateAfterSaleProfit().toString();
  }

  String calculateOrderItemsCount(List<String> orderItemsCounts) {
    double totalCount = 0;
    for (String count in orderItemsCounts) {
      totalCount += double.parse(count);
    }
    return totalCount.toStringAsPrecision(2);
  }
}

