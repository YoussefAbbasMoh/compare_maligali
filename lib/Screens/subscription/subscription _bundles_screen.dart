import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../BusinessLogic/Models/fawry_payment_model.dart';
import '../../BusinessLogic/view_models/subscriptions_view_model.dart';
import '../../components/returnAppBar.dart';
import '../../constants.dart';
import '../../scaffoldComponents/GeneralScaffold.dart';
import 'components/box_item.dart';
import 'components/vodafone_cash_pop_up.dart';

/*This screen is responsible for allowing the user to pick a bundle that he wants to scubscribe to in order to get receipts to use in his app
 - after the user picks a bundle to buy, he is shown a message that explains how he can pay for it

 there are three available packages currently:-
 -package 1 month , 180EGP
 -package 2 months , 345EGP
 -package 3 months , 517EGP

 */
class SubscriptionBundlesScreen extends StatefulWidget {
  SubscriptionBundlesScreen({Key? key}) : super(key: key);
  //route name for navigator
  static String routeName = "/SubscriptionBundlesScreen";
  @override
  State<SubscriptionBundlesScreen> createState() =>
      _SubscriptionBundlesScreenState();
}

class _SubscriptionBundlesScreenState extends State<SubscriptionBundlesScreen> {
  //the details of each avialable bundle package is loaded from subscription enums
  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      backGroundColor: purplePrimaryColor,
      appBar: ReturnAppBar(
        onPressed: () {
          Navigator.pop(context);
        },
        ////////////page title///////////////
        appBarColor: purplePrimaryColor,
        iconColor: textWhite,
        textColor: textWhite,
        key: null,
        pageTitle: "الاشتراك الشهري",
        preferredSize: Size.fromHeight(40.h),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder<List<Map<String, String>>>(
        future: SubscriptionsViewModel().getSubscriptionDataFromFirebase(),
        builder: (context, bundleDataSnapshot) {
          if (bundleDataSnapshot.connectionState == ConnectionState.done) {
            if (bundleDataSnapshot.hasError) {
              if (kDebugMode) {
                print(bundleDataSnapshot.error);
              }
              return Center(
                child: Text(
                  "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight),
                ),
              );
            } else if (bundleDataSnapshot.hasData) {
              List<Map<String, String>> bundleData = bundleDataSnapshot.data!;
              return SizedBox(
                height: 530.h,
                child: ListView.builder(
                    shrinkWrap: true,
                    controller: ScrollController(
                        initialScrollOffset: ScreenUtil().screenWidth / 1.44.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: bundleData.length,
                    padding: const EdgeInsets.all(30).r,
                    itemBuilder: (BuildContext context, int index) {
                      // we get the details and load them to their respective BoxItem
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10).r,
                        child: BoxItem(
                          //box item is the widget that displays the information of the package that is passed to it in a column
                          //text: bundleData[index],
                          discount: bundleData[index]["bundleDiscount"]!,
                          bundleName: bundleData[index]["bundleName"]!,
                          numberOfMonths: bundleData[index]["numberOfMonths"]!,
                          bundleCost: bundleData[index]["bundleCost"]!,
                          onPressed: () async {
                            //when a bundle is selected
                            if (kDebugMode) {
                              print(bundleData[index]["bundleName"]);
                            }
                           // vodafoneCashPopup(context, bundleData[index]["bundleCost"]!);

                            await PaymentModel(null).urlDeclaration(bundleData[index]);

                            //display the message explaining how to transfer money through vodafone cash with the price of this specific bundle
                            // await SubscriptionsViewModel().changeStatusToSubscribed("1");
                            //  Navigator.pop(context);
                          },
                        ),
                      );
                    }),
              );
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      )),
      curentPage: SubscriptionBundlesScreen.routeName,
    );
  }
}
