import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants.dart';
import '../../../../../scaffoldComponents/GeneralScaffold.dart';
import '../../../../components/returnAppBar.dart';
import '../../home_screen.dart';
import 'receiptsDuringHourBody.dart';

/*this screen is responsbile for viewing a list containing individual receipts present inside a single receipts per hour summary /receipts hourly collection
the specific summary/collection of receipts to load is passed to this screen through route arguments (look it up)

 */
class ReceiptsDuringHourScreen extends StatelessWidget {
  static String routeName =
      "/ReceiptsDuringHourScreen"; //route name for navigator
  final arguments; //receipts of specific hourly collection that will be passed to this screen

  const ReceiptsDuringHourScreen(this.arguments, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
        curentPage: HomeScreen.routeName,
        backGroundColor: white2BG,
        appBar: ReturnAppBar(
          key: null,
          pageTitle: "فواتير" +
              " " +
              arguments["containerObject"].time +
              " " +
              arguments["containerObject"].amPm,
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



        /////actual body of the screen, we pass the recipts of that specifc hour to it using route argumetns (think parameters)

        body: ReceiptsDuringHourBody(
          selectedCollection: arguments["containerObject"],
        ));
  }
}
