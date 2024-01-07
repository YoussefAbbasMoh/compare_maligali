import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import '../../../../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/hour_view_model.dart';
import '../../../../BusinessLogic/Services/FireBaseServices/coll_receipt_services.dart';
import '../../../../../BusinessLogic/Models/product_in_receipt_model.dart';
import '../../../../../BusinessLogic/Models/hourly_collection_model.dart';
import '../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import '../../../../../components/searchByNameField.dart';
import '../../today/sub_screens/new_receipt/newReceipt.dart';
import '../../common_components/receipts_summary_per_hour_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ReceiptsDuringHourBody extends StatefulWidget {
  final HourlyReceiptCollection selectedCollection;
  const ReceiptsDuringHourBody({required this.selectedCollection, Key? key})
      : super(key: key);

  @override
  State<ReceiptsDuringHourBody> createState() => _ReceiptsDuringHourBodyState();
}

class _ReceiptsDuringHourBodyState extends State<ReceiptsDuringHourBody> {
  BuildContext? mainPageContext;


  @override
  initState() {
    Provider.of<HourReceiptViewModel>(context, listen: false).initializeHourCollectionData(widget.selectedCollection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainPageContext = context;
    return SingleChildScrollView(
      child: SafeArea(
        child: Consumer<HourReceiptViewModel>(
          builder: (context, hourVM, child){
            return Column(
              children: <Widget>[
                SizedBox(width: double.infinity.w, height: 10.h),
                Stack(alignment: AlignmentDirectional.topCenter, children: [
                  receiptsListView(hourVM),
                  Container(
                    padding:  EdgeInsets.only(
                      left: 40.w,
                      right: 30.w,
                    ),
                    width: 325.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: lightGreyButtons, width: 1.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5.w),
                          spreadRadius: 2.r,
                          blurRadius: 5.r,
                          offset: Offset(0.w, 3.w),
                        ),
                      ],
                      color: lightGreyButtons,
                      borderRadius: BorderRadius.all(const Radius.circular(40).w),
                    ),

                    child: ReceiptsSummaryPerHourWidget(
                      revenue:
                      hourVM.hourCollection!.hourTotalRevenue.toStringAsFixed(1),
                      receiptsCount:
                      hourVM.hourCollection!.hourReceiptsCount.toString(),
                      itemsCount:
                      hourVM.hourCollection!.hourItemsSoldCount.toString(),
                      totalSalesProfit:
                      hourVM.hourCollection!.hourTotalProfit.toStringAsFixed(1),
                    ),
                  ),
                ]),
              ],
            );
          }
        ),
      ),
    );
  }




///////////////////////////////////////////////////////////////
  Widget receiptsListView(HourReceiptViewModel vmInstance) {
    return SingleChildScrollView(
      child: Container(
        width: 325.w,
        decoration: BoxDecoration(
          border: Border.all(color: lightGreyButtons, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5.w),
              spreadRadius: 0.5.r,
              blurRadius: 0.3.r,
              offset: Offset(0.w, 3.w),
            ),
          ],
          color: textWhite,
          borderRadius: BorderRadius.vertical(top: const Radius.circular(40).w),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0).r,
          child: SizedBox(
            width: 325.w,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10.w,
                    height: MediaQuery.of(context).size.height *
                        0.68, //(ScreenUtil().screenHeight - 320.h),
                    child: VerticalDivider(
                        color: lightGreyButtons2,
                        thickness: 2.w,
                        width: 20.w,
                        endIndent: 5.h),
                  ),
                  SizedBox(
                    width: 290.w,
                    child: receiptsContainer(vmInstance),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget receiptsContainer(HourReceiptViewModel vmInstance) {
    CollectionReference firebaseFirestore = ReceiptCollectionServices()
        .userReceiptsCollectionReference
        .doc(vmInstance.dateSelected)
        .collection(vmInstance.hourSelected);

    return StreamBuilder<QuerySnapshot?>(
        stream: firebaseFirestore.snapshots().asBroadcastStream(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot?> receiptsSnapshot) {
          if (!receiptsSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: redLightButtonDarkBG,
              ),
            );
          } else {
            List<QueryDocumentSnapshot<Object?>> receipts =
                receiptsSnapshot.data!.docs.toList();
           receipts.removeWhere((element) => element.id == 'Summary');

            return ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: receipts.length,
              itemBuilder: (BuildContext context, int index) {
                return receiptListTile(vmInstance, receipts.elementAt(index));
              },
            );
          }
        });
  }

  Widget receiptListTile(HourReceiptViewModel vmInstance, QueryDocumentSnapshot document,
     ) {
    String receiptNumber = document.get("ReceiptNumber");
    String receiptTotalProfit = document.get("receiptAfterSaleProfit");
    String itemsInReceipt = document.get("totalProductsSold");
    String receiptDate = document.get("receiptDate");
    String receiptTime = document.get("receiptTime");

    List<ProductInReceipt>? receiptProducts;

    return FutureBuilder<List<ProductInReceipt>>(
      future: ReceiptCollectionServices()
          .getProductsListFromReceipt(document.get("itemsList")),
      builder: (context, snapshot) {
        receiptProducts = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return Center(
              child: Text(
                "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                style: TextStyle(
                    fontSize: commonTextSize.sp, fontWeight: commonTextWeight),
              ),
            );
          } else if (snapshot.hasData) {
            return InkWell(
              onTap: () {},
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          height: 30.h,
                          width: 25.w,
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              image: DecorationImage(
                                image: AssetImage("assets/images/reciptNo.png"),
                                fit: BoxFit.fitWidth,
                              ))),
                      SizedBox(width: 10.w),
                      Text("#" + receiptNumber,
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                              fontSize: commonTextSize.sp,
                              fontWeight: commonTextWeight)),
                      IconButton(
                          alignment: Alignment.topRight,
                          iconSize: 20.w,
                          icon: const Icon(Icons.delete_outline_outlined,
                              color: iconBlue1),
                          onPressed: () async {

                            print(receiptNumber);
                            await vmInstance.deleteWholeReceipt(mainPageContext!,
                                receiptNumber, vmInstance.dateSelected, vmInstance.hourSelected);
                          }),
                      Consumer<ReceiptViewModel>(
                          builder: (context, receiptVM, child) {
                        return IconButton(
                            alignment: Alignment.topRight,
                            iconSize: 20.w,
                            icon: const Icon(Icons.create_outlined,
                                color: iconBlue2),
                            onPressed: () {
                              receiptVM.loadPreviousReceipt(vmInstance.hourSelected, receiptDate,
                                  receiptTime, receiptNumber, receiptProducts!);
                              Navigator.pushNamed(
                                  context, NewReceipt.routeName);
                            });
                      }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(itemsInReceipt.toString(),
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                              fontSize: tinyTextSize.sp,
                              fontWeight: tinyTextWeight)),
                      Text("عدد المشتروات:  ",
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                            fontSize: tinyTextSize.sp,
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(receiptTotalProfit.toString() + " ج",
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                            fontSize: tinyTextSize.sp,
                            fontWeight: tinyTextWeight,
                          )),
                      Text("اجمالي الفاتوره:  ",
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                            fontSize: tinyTextSize.sp,
                          )),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Divider(
                    thickness: 2.h,
                  )
                ],
              ),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
