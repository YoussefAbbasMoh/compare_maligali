import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Screens/subscription/subscription _bundles_screen.dart';
import 'buttons.dart';
import '../constants.dart';

/*this function show a message that alerts a user his receipts / subscription bundle has ended and that he should renew with an option to press a button
to navigate straight to the subscription bundle page */
subscriptionBundleFinishedPopup(BuildContext context) {
  return Dialog(
    insetPadding: const EdgeInsets.all(10).w,
    backgroundColor: purpleAppbar,
    shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
      Radius.circular(30),
    ).w),
    child: Stack(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10).r,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20).r,
              child: InkWell(
                child: Icon(
                  Icons.arrow_back_ios,
                  textDirection: TextDirection.ltr,
                  size: 40.w,
                  color: textWhite,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: Text(
                "تجديد الاشتراك",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: mainFontSize.sp,
                  fontWeight: mainFontWeight,
                  color: textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 65).r,
        child: Container(
          decoration: BoxDecoration(
              color: authGradient3,
              borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))
                  .w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10).r,
                child: Image.asset(
                    'assets/images/subscriptionBundleFinishedPopup.png'),
              ),
              Text(
                "فواتيرك خلصت؟!\n جدد الباقة دلوقتي",
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    color: textWhite, fontSize: extraLargeTextSize.sp),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30).w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultButton(
                        text: "تجديد الباقة",
                        fontSize: subFontSize,
                        fontWeight: subFontWeight,
                        onPressed: () {
                          Navigator.pushNamed(
                              context, SubscriptionBundlesScreen.routeName);
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ]),
  );
}
