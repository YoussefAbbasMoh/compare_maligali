import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/constants.dart';
import 'package:provider/provider.dart';
import '../../../../../BusinessLogic/view_models/receipts_view_models/common_receipt_view_models/receipt_view_model.dart';
import '../../../../../components/returnAppBar.dart';
import '../../../common_components/custom_app_bar.dart';
import '../../../home_screen.dart';
import 'newReceiptBody.dart';

class NewReceipt extends StatelessWidget {
  static String routeName = "/NewReceipt";
  const NewReceipt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ReceiptViewModel>(builder: (context, receiptVM, child) {
        return WillPopScope(
          onWillPop: () async {
            receiptVM.removeReceiptData();
            //Navigator.pushNamed(context, HomeScreen.routeName);
            return true;
          },
          child: Scaffold(
            appBar: ReturnAppBar(
              key: null,
              iconColor: purplePrimaryColor,
              pageTitle: "بيان جديد",
              textColor: purplePrimaryColor,
              appBarColor: textWhite,
              preferredSize: Size.fromHeight(40.h),
              onPressed: (){
                receiptVM.removeReceiptData();
                Navigator.pushNamed(context, HomeScreen.routeName);
              },
            ),
            body: const NewReceiptBody(),
          ),
        );
      }),
    );
  }
}
