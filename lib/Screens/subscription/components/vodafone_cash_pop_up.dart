import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/buttons.dart';
import '../../../constants.dart';

/*this function displays the message explaining how a user can subscribe to a certain bundle with the price passed to it in a pop up dialogue */
void vodafoneCashPopup(BuildContext context, String cost) {
  showDialog(
      context: context,
      builder: (_) {
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
                  Text(
                    "تجديد الاشتراك",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: mainFontSize.sp,
                      fontWeight: mainFontWeight,
                      color: textWhite,
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
                    ////////////////////////meesage explaining paymeny with the cost////////////////////////////
                    Text(
                      "ادفع عن طريق فودافون كاش مبلغ\n $cost\n علي الرقم: 01099112703\n\n وبعدين بلغ خدمة الاشتراكات علي الرقم: 01123648475",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          color: textWhite, fontSize: commonTextSize.sp),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30).w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultButton(
                              text: "رجوع",
                              fontSize: subFontSize,
                              fontWeight: subFontWeight,
                              onPressed: () {
                                Navigator.pop(context);
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
      });
}
