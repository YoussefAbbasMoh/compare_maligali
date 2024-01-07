import 'package:flutter/foundation.dart';
import 'package:maligali/BusinessLogic/utils/globalSnackBar.dart';
import 'package:provider/provider.dart';

import '../../../../BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common_components/receipts_summary_per_hour_widget.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../common_sub_screens/receipts_during_hour/receipts_during_hour_screen.dart';

/*this widget is responsible for creating a list that contains
ReceiptsSummaryPerHour widgets that contain a small summary of all receipts sold during a certain hour
each ReceiptSummaryPerHour widget has a hourTextWidget next to it that shows the hour these receipts belong to

*****this widget also calls the view model functions resposnsible for getting the data that will be loaded in each summary

 */
class ReceiptsSummaryPerHourListView extends StatefulWidget {
  const ReceiptsSummaryPerHourListView({Key? key}) : super(key: key);

  @override
  State<ReceiptsSummaryPerHourListView> createState() =>
      _ReceiptsSummaryPerHourListViewState();
}

class _ReceiptsSummaryPerHourListViewState
    extends State<ReceiptsSummaryPerHourListView> {
  @override
  void didChangeDependencies() {
    //basicaly if a parent widget changes, refresh this widget
    Provider.of<TodayPageViewModel>(context, listen: false)
        .setChangedWidgetDependency();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return receiptsListViewContainer();
  }

//////////////////////////////////////body of the list view////////////////////////////
  Widget receiptsListViewContainer() {
    return Consumer<TodayPageViewModel>(
        //load receipt data from the view model
        builder: (context, todayPageVM, child) {
      return FutureBuilder<bool>(
          future: todayPageVM
              .mainOperations(), //this function is responsible for choosing the data it will load for the receipts based on what the user is doing/has done (just opened the app, refreshed the screen,restarted the app, naviagted back to screen)
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              //if the data has been loaded
              if (snapshot.hasError) {
                //if data is faulty
                if (kDebugMode) {
                  print(snapshot.error);
                }
                return Center(
                  child: Text(
                    //tell the user to refresh page/restart the application
                    "حصل مشكلة في تحميل الصفحة1 \n عيد فتح البرنامج"
                    "\n ${snapshot.error}",
                    style: TextStyle(
                        fontSize: commonTextSize.sp,
                        fontWeight: commonTextWeight),
                  ),
                );
              } else if (snapshot.hasData) {
                //if data loaded correctly
                if (snapshot.data == false) {
                  //if it is null
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    displaySnackBar(text:"الساعة عدت 12 ... تم بدأ يوم جديد");
                  });
                }
                ///////////////////loading the receipts summaries data to a local variable/////////////
                List receiptsHourSummariesList = todayPageVM
                    .overallCollectionsMap.values
                    .toList()
                    .reversed
                    .toList();

                return SizedBox(
                    child: SingleChildScrollView(
                  reverse: false,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: receiptsHourSummariesList.length,
                      itemBuilder: (context, index) {
                        ///////////////////////each individual item in list view
                        return ListTile(
                            title: Row(
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              ///////////////widget displaying hour of the summary///////////////////////
                              child: RotatedBox(
                                  //rotate the hour to fit vertically next to the summary
                                  quarterTurns: 1.bitLength,
                                  child: SizedBox(
                                      width: 90.w,
                                      child: _hourTextWidget(
                                          receiptsHourSummariesList[index].time,
                                          receiptsHourSummariesList[index].amPm,
                                          index == 0))),
                            ),
                            ////////////////////receipt per hour widget/////////////////////////
                            Padding(
                              padding:  EdgeInsets.only(top: 10.h),
                              child: Container(
                                padding:  EdgeInsets.only(
                                  left: 1.w,
                                  right: 5.w,
                                ),
                                width: 275.w,
                                height: 116.h,
                                ///////////custom decoration for the container of each summary//////////////
                                decoration: hourContainerDecoration(index == 0),
                                child: ReceiptsSummaryPerHourWidget(
                                  revenue: receiptsHourSummariesList[index]
                                      .hourTotalRevenue
                                      .toStringAsFixed(1),
                                  totalSalesProfit:
                                      receiptsHourSummariesList[index]
                                          .hourTotalProfit
                                          .toStringAsFixed(1),
                                  itemsCount: receiptsHourSummariesList[index]
                                      .hourItemsSoldCount
                                      .toString(),
                                  receiptsCount:
                                      receiptsHourSummariesList[index]
                                          .hourReceiptsCount
                                          .toString(),
                                  onTap: () {
                                    //if a specific summary is pressed
                                    Navigator.pushNamed(
                                        //navigate to ReceiptsDuringHourScreen to view all receipts in that summary and pass the specific summary to it
                                        context,
                                        ReceiptsDuringHourScreen.routeName,
                                        arguments: {
                                          "containerObject":
                                              receiptsHourSummariesList[index]
                                        });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ));
                      }),
                ));
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
    });
  }

//widget that displays the hour corresponding to a specifc summary of receipts per hour
  Widget _hourTextWidget(String hour, String amPm, bool isCurrentHour) {
    return Center(
      child: Text(
        "$amPm $hour",
        style: TextStyle(
            ///////////////if the hour of this summary corresponds to the hour we are currently in make the font red to highlight it
            fontWeight: isCurrentHour ? mainFontWeight : tinyTextWeight,
            fontSize: tinyTextSize.sp,
            color: isCurrentHour ? redLightButtonsLightBG : textBlack),
      ),
    );
  }

  /////////custom decoration for the rectangular containers that contain the summary of receipts per that hour///////
  BoxDecoration hourContainerDecoration(bool isCurrentHour) {
    return BoxDecoration(
      border: Border.all(
          color: isCurrentHour
              ? redLightButtonsLightBG
              : lightGreyButtons, /////if hour of this specific summary is the current hour of day we make its border red to highlight it
          width: 1.5.w),
      boxShadow: [
        BoxShadow(
          color: isCurrentHour ////////also make it shadow red if true
              ? redLightButtonsLightBG.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5),
          spreadRadius: 2.r,
          blurRadius: 5.r,
          offset: Offset(0, (isCurrentHour ? 0 : 3).w),
        ),
      ],
      color: lightGreyButtons,
      borderRadius: BorderRadius.all(const Radius.circular(40).w),
    );
  }
}
