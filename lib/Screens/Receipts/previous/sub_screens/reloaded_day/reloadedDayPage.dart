import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/hourly_collection_model.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/previous_day_view_models/previous_day_page_view_model.dart';
import 'package:maligali/Screens/Receipts/common_components/receipts_summary_per_hour_widget.dart';
import 'package:maligali/constants.dart';
import 'package:maligali/scaffoldComponents/GeneralScaffold.dart';
import 'package:provider/provider.dart';
import '../../../../../components/returnAppBar.dart';
import '../../../common_sub_screens/receipts_during_hour/receipts_during_hour_screen.dart';
import '../../../home_screen.dart';

class ReloadedDayPage extends StatefulWidget {
  final DateTime dateSelected;
  static String routeName = "/reloadedDayPage";
  const ReloadedDayPage({Key? key, required this.dateSelected})
      : super(key: key);

  @override
  State<ReloadedDayPage> createState() => _ReloadedDayPageState();
}

class _ReloadedDayPageState extends State<ReloadedDayPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final height = (ScreenUtil().screenHeight - 120.h);

  @override
  void initState() {
    Provider.of<PreviousDayPageViewModel>(context, listen: false).previousDayPageVMDateInitializer(widget.dateSelected);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviousDayPageViewModel>(
      builder: (context, reloadedDayVM, child){
        return GeneralScaffold(
            curentPage: HomeScreen.routeName,
            backGroundColor: white2BG,
            appBar: ReturnAppBar(
              key: null,
              pageTitle: reloadedDayVM.date,
              textColor: purplePrimaryColor,
              appBarColor: textWhite,
              iconColor: purplePrimaryColor,
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

            body: SingleChildScrollView(
              child: FutureBuilder<String>(
                  future: reloadedDayVM.previousDayPageVMHoursInitializer(),
                  builder: (context, vmProvSnapshot) {
                    if (vmProvSnapshot.connectionState == ConnectionState.done) {
                      if (vmProvSnapshot.hasError) {
                        return Center(
                          child: Text(
                            "حصل مشكلة في تحميل الصفحة1 \n عيد فتح البرنامج"
                                "\n ${vmProvSnapshot.error}",
                            style: TextStyle(
                                fontSize: commonTextSize.sp,
                                fontWeight: commonTextWeight),
                          ),
                        );
                      } else if (vmProvSnapshot.hasData) {
                        return SafeArea(
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  height: height,
                                  child: VerticalDivider(
                                      color: purplePrimaryColor,
                                      thickness: 2.5.w,
                                      width: 95.w,
                                      indent: 15.h,
                                      endIndent: 20.h),
                                ),
                                reloadedDayVM.dayHourCollections.isEmpty?
                                const Center(child: Text("محررتش فواتير في اليوم ده"))
                                    :
                                SizedBox(
                                    height: height,
                                    child:
                                   receiptsListViewContainer(reloadedDayVM.dayHourCollections)),
                              ],
                            ));
                      }
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ));
      },
    );
  }


  Widget _sideHourContainer(String hour, String amPm,) {
    return Center(
      child: Text(
        "$amPm $hour",
        style: TextStyle(
            fontWeight:  tinyTextWeight,
            fontSize: tinyTextSize.sp,
            color: textBlack),
      ),
    );
  }


  Widget receiptsListViewContainer(Map<String,HourlyReceiptCollection> vmCollections) {
    List<String> keys = vmCollections.keys.toList(growable: false);
    return SizedBox(
      height: 100.h, //: 500.h,
      width: 400.w,
      child: SingleChildScrollView(
        reverse: true,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vmCollections.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                    child: RotatedBox(
                        quarterTurns: 1.bitLength,
                        child: SizedBox(
                            width: 90.w,
                            child: _sideHourContainer(vmCollections[keys[index]]!.time,
                                vmCollections[keys[index]]!.amPm))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10).r,
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 10,
                      ).r,
                      width: 275.w,
                      height: 116.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:  lightGreyButtons,
                            width: 1.5.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2.r,
                            blurRadius: 5.r,
                            offset: Offset(0, 3.w),
                          ),
                        ],
                        color: lightGreyButtons,
                        borderRadius:
                            BorderRadius.all(const Radius.circular(40).w),
                      ),
                      child: Consumer<PreviousDayPageViewModel>(
                        builder: (context, vm, child){
                        return ReceiptsSummaryPerHourWidget(
                          revenue: vmCollections[keys[index]]!.hourTotalRevenue.toStringAsFixed(1),
                          totalSalesProfit:
                              vmCollections[keys[index]]!.hourTotalProfit.toStringAsFixed(1),
                          itemsCount:
                              vmCollections[keys[index]]!.hourItemsSoldCount.toString(),
                          receiptsCount:
                              vmCollections[keys[index]]!.hourReceiptsCount.toString(),
                          onTap: () {
                            Navigator.pushNamed(
                                context, ReceiptsDuringHourScreen.routeName,
                                arguments: {
                                  "containerObject": vmCollections[keys[index]]
                                });
                          },
                        );}
                      ),
                    ),
                  ),
                ],
              ));
            }),
      ),
    );
  }
}
