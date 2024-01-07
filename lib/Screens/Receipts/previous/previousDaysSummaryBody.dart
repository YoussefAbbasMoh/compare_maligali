import 'package:maligali/BusinessLogic/Models/barChartModel.dart';
import 'package:maligali/Screens/Receipts/common_components/summaryChart.dart';
import 'package:maligali/Screens/Receipts/previous/sub_screens/reloaded_day/reloadedDayPage.dart';
import '../../../BusinessLogic/view_models/receipts_view_models/previous_day_view_models/previous_summary_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart';
import 'components/analysisContainers.dart';
import 'components/analysisDropDownContainer.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class PreviousDaysSummaryBody extends StatefulWidget {
  const PreviousDaysSummaryBody({Key? key}) : super(key: key);

  @override
  _PreviousDaysSummaryBodyState createState() =>
      _PreviousDaysSummaryBodyState();
}

class _PreviousDaysSummaryBodyState extends State<PreviousDaysSummaryBody> {
  PreviousSummaryViewModel obj = PreviousSummaryViewModel();
  Future<Map<String, dynamic>> Function(DateTime, DateTime)
      dataFetchingFunction = PreviousSummaryViewModel().getMonthSummary;

  DateTime _focusedDay = DateTime.now();
  DateTime startDate =
      DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime.utc(DateTime.now().year, DateTime.now().month, 1)
      .add(const Duration(days: 30));
  String format = "الشهر";
  String comparisonFormat = "شهور";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: double.infinity.w, height: 10.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).r,
              child: SizedBox(
                  width: 350.w,
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: dataFetchingFunction(startDate, endDate),
                      builder: (context, summarySnapshot) {
                        if (summarySnapshot.connectionState ==
                            ConnectionState.done) {
                          if (summarySnapshot.hasError) {
                            if (kDebugMode) {
                              print(summarySnapshot.error);
                            }
                            return Center(
                              child: Text(
                                "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                                style: TextStyle(
                                    fontSize: commonTextSize.sp,
                                    fontWeight: commonTextWeight),
                              ),
                            );
                          } else if (summarySnapshot.hasData) {
                            return Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "اللي كسبته في :" + format,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: textBlack,
                                        fontSize: subFontSize.sp,
                                        fontWeight: subFontWeight),
                                  ),
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                AnalysisContainers(
                                  result: summarySnapshot
                                      .data!["totalRevenueMadeForDay"]
                                      .toStringAsFixed(1),
                                  descriptionText: "صافي الربح :",
                                  imagePath: "assets/images/profit.png",
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                AnalysisContainers(
                                  imagePath: "assets/images/totalSale.png",
                                  result: summarySnapshot
                                      .data!["totalProfitMadeForDay"]
                                      .toStringAsFixed(1),
                                  descriptionText: 'مجمل المبيعات :',
                                ),
                                SizedBox(width: double.infinity, height: 10.h),
                                AnalysisContainers(
                                  result: summarySnapshot
                                      .data!["totalItemsSoldInDay"]
                                      .toString(), //numberOfSoldProducts.toString(),
                                  descriptionText: 'عدد المنتجات المباعه :',
                                  unit: " منتج",
                                  imagePath: "assets/images/totalItemsSold.png",
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                AnalysisContainers(
                                  result: summarySnapshot
                                      .data!["highestDayHavingSales"]
                                      .toString(), //mostSoldDay.toString(),
                                  descriptionText: 'اكثر يوم بيعت فيه :',
                                  unit: "",
                                  imagePath: 'assets/images/calendar.png',
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                DropDownContainer(
                                  descriptionText: "اكتر 5 منتجات اتباعت",
                                  dbList:
                                      summarySnapshot.data!["topFiveSoldItems"],
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                DropDownContainer(
                                  descriptionText: "اقل 5 منتجات اتباعت",
                                  dbList: summarySnapshot
                                      .data!["leastFiveSoldItems"],
                                ),
                                SizedBox(width: double.infinity.w, height: 5.h),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "مقارنه بين اخر 3 :" + comparisonFormat,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: textBlack,
                                        fontSize: subFontSize.sp,
                                        fontWeight: subFontWeight),
                                  ),
                                ),
                                SizedBox(width: double.infinity.w, height: 3.h),
                                summaryChartContainer(),
                                SizedBox(height: 12.h),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "لو عايز تراجع فواتير اي يوم دوس علي اليوم اللي انت محتاجه في النتيجه",
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: textBlack,
                                        fontSize: tinyTextSize.sp),
                                  ),
                                ),
                                SizedBox(
                                    width: double.infinity.w, height: 10.h),
                                TableCalendar(
                                    focusedDay: _focusedDay,
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    firstDay: DateTime.utc(2022, 12, 1),
                                    weekendDays: const [
                                      DateTime.friday,
                                      DateTime.saturday
                                    ],
                                    calendarFormat: CalendarFormat.month,
                                    availableCalendarFormats: const {
                                      CalendarFormat.month: 'شهر',
                                      CalendarFormat.twoWeeks: "نصف شهري",
                                      CalendarFormat.week: "اسبوع"
                                    },
                                    locale: "ar",
                                    headerStyle: HeaderStyle(
                                      titleTextStyle:
                                          TextStyle(fontSize: 17.0.sp),
                                      titleCentered: true,
                                      formatButtonDecoration: BoxDecoration(
                                        color: redTextAlert,
                                        borderRadius:
                                            BorderRadius.circular(10.0).w,
                                      ),
                                      formatButtonTextStyle:
                                          const TextStyle(color: textWhite),
                                      formatButtonShowsNext: false,
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: TextStyle(
                                          fontSize: 12.sp, color: textBlack),
                                      weekendStyle: TextStyle(
                                          fontSize: 12.sp, color: textBlack),
                                    ),
                                    calendarStyle: const CalendarStyle(
                                      todayDecoration: BoxDecoration(
                                          color: redTextAlert,
                                          shape: BoxShape.circle),
                                      selectedDecoration: BoxDecoration(
                                          color: lightGreyReceiptBG),
                                    ),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      Navigator.push(
                                          context,
                                          (MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) {
                                            return ReloadedDayPage(
                                              //TODO:
                                              dateSelected: selectedDay,
                                            );
                                          })));
                                    },
                                    onFormatChanged: (format) {},
                                    onPageChanged: (focusedDay) {
                                      if (focusedDay.month !=
                                          DateTime.now().month) {
                                        setState(() {
                                          _focusedDay = focusedDay;
                                          startDate = focusedDay;
                                          endDate = focusedDay
                                              .add(const Duration(days: 30));
                                        });
                                      } else {
                                        setState(() {
                                          _focusedDay = DateTime.now();
                                          startDate = DateTime.utc(
                                              _focusedDay.year,
                                              _focusedDay.month,
                                              1);
                                          endDate = startDate
                                              .add(const Duration(days: 30));
                                        });
                                      }
                                    }),
                              ],
                            );
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
                                      color: purplePrimaryColor),
                                ),
                                const CircularProgressIndicator(
                                  color: purplePrimaryColor,
                                ),
                              ]),
                        );
                      })),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryChartContainer() {
    return FutureBuilder<List<BarChartModel>>(
        future:
            obj.getGraphData(startDate, endDate, dataFetchingFunction, format),
        builder: (context, graphDataSnapshot) {
          if (graphDataSnapshot.connectionState == ConnectionState.done) {
            if (graphDataSnapshot.hasError) {
              if (kDebugMode) {
                print(graphDataSnapshot.error);
              }
              return Center(
                child: Text(
                  graphDataSnapshot.error.toString(),
                  //"حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight),
                ),
              );
            } else if (graphDataSnapshot.hasData) {
              return SummaryChart(
                data: graphDataSnapshot.data,
              );
            }
          }
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "جاري اعداد الرسم البياني",
                    style: TextStyle(
                        fontSize: commonTextSize.sp,
                        fontWeight: commonTextWeight,
                        color: purplePrimaryColor),
                  ),
                  const CircularProgressIndicator(
                    color: purplePrimaryColor,
                  ),
                ]),
          );
        });
  }
}
