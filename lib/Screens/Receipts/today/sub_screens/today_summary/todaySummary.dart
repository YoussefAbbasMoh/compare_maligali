import '../../../../../BusinessLogic/Models/item_finished_in_inventory.dart';
import '../../../../../components/returnAppBar.dart';
import '../../../../../scaffoldComponents/GeneralScaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common_components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'todaySummaryBody.dart';
import '../../../home_screen.dart';

class TodaySummary extends StatefulWidget {
  const TodaySummary({Key? key}) : super(key: key);
  static String routeName = "/TodaySummary";

  @override
  State<TodaySummary> createState() => _TodaySummaryState();
}

class _TodaySummaryState extends State<TodaySummary> {
  List<ItemFinishedInInventory> itemsFinishedDataList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GeneralScaffold(
      curentPage: HomeScreen.routeName,
      backGroundColor: purplePrimaryColor,
      appBar: ReturnAppBar(
        key: null,
        pageTitle: "ملخص اليوم",
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




      body: TodaySummaryBody(),
    ));
  }
}
