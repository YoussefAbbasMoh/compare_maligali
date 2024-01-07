import 'package:maligali/BusinessLogic/Services/local_inventory_services/hive_services.dart';

import '../../../../../BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import '../../../../../BusinessLogic/view_models/receipts_view_models/today_view_models/day_summary_view_model.dart';
import '../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import '../../../../../BusinessLogic/Models/barChartModel.dart';
import '../../../../../BusinessLogic/Models/summary_model.dart';
import '../../../../../components/gradientContainer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../../../../components/buttons.dart';
import '../../../common_components/summaryChart.dart';
import '../../../../../constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../home_screen.dart';

class TodaySummaryBody extends StatelessWidget {
  TodaySummaryBody({Key? key}) : super(key: key);

  DaySummary? todaySummary;
  DaySummary? yesterdaySummary;
  DaySummary? previousDaySummary;
  DaySummaryViewModel obj = DaySummaryViewModel();
  Map<String, String>? itemMostBought;

  Future<String> prepareData() async {
    DateTime today = DateTime.now();
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    DateTime previousDay = DateTime.now().subtract(const Duration(days: 2));
    obj.initSummaryData(null);

    todaySummary = await obj.getDaySummaryFromDB(reformatDateSplittedToCombined(
        today.day.toString(), today.month.toString(), today.year.toString()));
    yesterdaySummary = await obj.getDaySummaryFromDB(
        reformatDateSplittedToCombined(yesterday.day.toString(),
            yesterday.month.toString(), yesterday.year.toString()));
    previousDaySummary = await obj.getDaySummaryFromDB(
        reformatDateSplittedToCombined(previousDay.day.toString(),
            previousDay.month.toString(), previousDay.year.toString()));
    return "done";
  }

  List<BarChartModel> getGraphData() {
    return [
      BarChartModel(
        day: "اول امبارح",
        profit: (previousDaySummary?.totalDayProfit.round())!,
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
      BarChartModel(
        day: "امبارح",
        profit: (yesterdaySummary?.totalDayProfit.round())!,
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
      BarChartModel(
        day: "انهاردة",
        profit: (todaySummary?.totalDayProfit.round())!,
        color: charts.ColorUtil.fromDartColor(textYellow),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        FutureBuilder<String>(
            future: prepareData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  if (kDebugMode) {
                    print(snapshot.error);
                  }
                  return Center(
                    child: Text(
                      "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                      style: TextStyle(
                          fontSize: commonTextSize.sp,
                          fontWeight: commonTextWeight),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Column(children: <Widget>[
                    SizedBox(height: 20.h),
                    createContainer1(),
                    Padding(
                      padding: const EdgeInsets.all(12.0).w,
                      child: SizedBox(
                          height: 350.h,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                createContainer2Left(),
                                SizedBox(width: 12.w, height: 350.h),
                                createContainer2Right(),
                              ])),
                    ),
                    SummaryChart(
                      data: getGraphData(),
                    ),
                  ]);
                }
              }
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "جاري اعداد الملخصات",
                        style: TextStyle(
                            fontSize: commonTextSize.sp,
                            fontWeight: commonTextWeight,
                            color: textWhite),
                      ),
                      const CircularProgressIndicator(
                        color: textWhite,
                      ),
                    ]),
              );
            }),
        SizedBox(height: 12.h),
        DefaultButton(
          text: 'انهاء اليوم',
          onPressed: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: ((context) => const Center(
                      child: CircularProgressIndicator(),
                    )));
            await Provider.of<TodayPageViewModel>(context,
                    listen: false)
                .endDay();
            uploadInventoryData(context);
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.routeName, (route) => false);
          },
        ),
        SizedBox(
          height: 25.h,
        ),
      ],
    ));
  }

  void uploadInventoryData(BuildContext context, [bool mounted = true]) async {
    // show the loading dialog
    showDialog(
        // The user CANNOT close this dialog  by pressing outside it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: textWhite,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Center(
                      child: Icon(
                    Icons.error_outline_outlined,
                    color: darkRed,
                  )),
                  Center(
                    child: Text(
                      "جاري رفع بيانات المحل",
                      style: TextStyle(
                          fontWeight: subFontWeight,
                          fontSize: subFontSize,
                          color: darkRed),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      ' برجاء عدم اغلاق التطبيق تجنبا لأي خطأ خلال الرفع و الحفاظ علي سلامة بياناتك',
                      style: TextStyle(
                          fontWeight: commonTextWeight,
                          fontSize: commonTextSize,
                          color: textBlack)),
                  // The loading indicator
                  SizedBox(
                    height: 15,
                  ),
                  CircularProgressIndicator(),
                  // Some text
                ],
              ),
            ),
          );
        });

    // Your asynchronous computation here (fetching data from an API, processing files, inserting something to the database, etc)
    await HiveDatabaseManager.backUpUserInventoryProducts();

    // Close the dialog programmatically
    // We use "mounted" variable to get rid of the "Do not use BuildContexts across async gaps" warning
    print(mounted);
    if (mounted == false) return;
  }

  Widget createContainer1() {
    return Padding(
      padding: const EdgeInsets.all(12.0).w,
      child: GradientContainer(
        key: key,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/profit.png',
              width: 90.w,
            ),
            SizedBox(width: 25.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "المبيعات",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: textWhite,
                      fontSize: mainFontSize.sp,
                      fontWeight: mainFontWeight),
                ),
                Text(
                  (todaySummary?.totalDayProfit.toStringAsFixed(1))! + " ج",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: textYellow, fontSize: extraLargeTextSize.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "صافي الربح",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: textWhite,
                      fontSize: mainFontSize.sp,
                      fontWeight: mainFontWeight),
                ),
                Text(
                  (todaySummary?.totalDayRevenue.toStringAsFixed(1))! + " ج",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: redTextAlert, fontSize: extraLargeTextSize.sp),
                ),
              ],
            ),
          ],
        ),
        width: ScreenUtil().screenWidth,
      ),
    );
  }

  Widget createContainer2Left() {
    return Expanded(
      flex: 1,
      child: GradientContainer(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "عدد الفواتير \n انهاردة",
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: textWhite,
                  fontSize: mainFontSize.sp,
                  fontWeight: mainFontWeight),
            ),
            Text(
              (todaySummary?.numberOfReceiptsMade.toString())!,
              textDirection: TextDirection.rtl,
              style:
                  TextStyle(color: textYellow, fontSize: extraLargeTextSize.sp),
            ),
            Text(
              "عدد البضايع\n اللي اتباعت",
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: textWhite,
                  fontSize: mainFontSize.sp,
                  fontWeight: mainFontWeight),
            ),
            Text(
              (todaySummary?.numberOfProductsSold.toString())!,
              textDirection: TextDirection.rtl,
              style:
                  TextStyle(color: textYellow, fontSize: extraLargeTextSize.sp),
            ),
          ],
        ),
        width: ScreenUtil().screenWidth,
      ),
    );
  }

  Widget createContainer2Right() {
    return Expanded(
      flex: 1,
      child: GradientContainer(
        key: key,
        child: FutureBuilder<Map<String, String>>(
            future: obj.fetchMostItemBought(),
            builder: (context, mostItemBoughtSnapshot) {
              if (mostItemBoughtSnapshot.connectionState ==
                  ConnectionState.done) {
                if (mostItemBoughtSnapshot.hasError) {
                  if (kDebugMode) {
                    print(mostItemBoughtSnapshot.error);
                  }
                  return Center(
                    child: Icon(Icons.broken_image,
                        color: lightGreyButtons2, size: 20.w),
                  );
                } else if (mostItemBoughtSnapshot.hasData) {
                  itemMostBought = mostItemBoughtSnapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "اكثر منتج \n اتباع انهاردة",
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: textWhite,
                            fontSize: mainFontSize.sp,
                            fontWeight: mainFontWeight),
                      ),
                      Text(
                        "${mostItemBoughtSnapshot.data!["productName"]}",
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: textWhite,
                            fontSize: commonTextSize.sp,
                            fontWeight: commonTextWeight),
                      ),
                      SizedBox(
                        height: 100.h,
                        child: (mostItemBoughtSnapshot.data!["imgPath"]! != "")
                            ? Image.network(
                                mostItemBoughtSnapshot.data!["imgPath"]!,
                                scale: 1)
                            : const Icon(Icons.image_not_supported,
                                color: lightGreyReceiptBG, size: 50),
                      ),
                      Text(
                        mostItemBoughtSnapshot.data!["productSoldCount"]! //+
                            // "  "
                            // +
                            // mostItemBoughtSnapshot.data!["productSaleUnit"]!
                        ,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: redTextAlert,
                            fontSize: extraLargeTextSize.sp),
                      ),
                    ],
                  );
                }
              }
              return const Center(
                  child: CircularProgressIndicator(
                color: textWhite,
              ));
            }),
        width: ScreenUtil().screenWidth,
      ),
    );
  }
}
