import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/constants.dart';
import 'dart:ui' as ui;
import '../../../components/buttons.dart';
import '../../../components/gradientContainer.dart';

//displays the information of a subscription bundle in a column with a unique message under each one

class BoxItem extends StatelessWidget {
  final String bundleName;
  final String bundleCost;
  final String numberOfMonths;
  final String discount;
  final String text;
  final void Function() onPressed;

  const BoxItem({
    Key? key,
    required this.bundleName,
    required this.bundleCost,
    required this.numberOfMonths,
    required this.discount,
    this.text = "",
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String costBeforeSale = (int.parse(bundleCost.split(" ")[0]) +
        int.parse(discount.split(" ")[0])).toString();

    return GradientContainer(
      width: 215.w,
      key: key,
      bgColor: textWhite,
      padding: 3,
      gradient1: gradbrown,
      gradient2: darkYellow,
      gradient3: grapyYellow,
      gradient4: beige,
      gradient5: gradbrown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GradientContainer(
            width: 215.w,
            topLeftContainerBorder: 20.w,
            topRightContainerBorder: 20.w,
            bottomLeftContainerBorder: 50.w,
            bottomRightContainerBorder: 50.w,
            topLeftBorder: 20.w,
            topRightBorder: 20.w,
            bottomLeftBorder: 50.w,
            bottomRightBorder: 50.w,
            key: key,
            bgColor: authGradient3,
            padding: 3,
            gradient1: gradbrown,
            gradient2: darkYellow,
            gradient3: grapyYellow,
            gradient4: beige,
            gradient5: gradbrown,
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  bundleName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: mainFontSize.sp,
                    fontWeight: mainFontWeight,
                    color: textWhite,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  bundleCost,
                  textDirection: ui.TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0.sp,
                    fontWeight: FontWeight.w600,
                    color: darkYellow,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Image.asset(
                  'assets/images/substiraction_box2.png',
                  alignment: AlignmentDirectional.center,
                  height: 72.h,
                  width: 92.57.w,
                ),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
          ),
          Container(
            //height:80.h,
            margin: const EdgeInsets.only(left: 20.0, right: 20.0).r,
            child: Column(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  text: TextSpan(
                    text: "عدد الشهور: ",
                    style: TextStyle(
                        color: textBlack,
                        fontSize: commonTextSize.sp,
                        fontWeight: mainFontWeight),
                    children: <TextSpan>[
                      TextSpan(
                          text: numberOfMonths,
                          style: TextStyle(
                              color: redTextAlert,
                              fontSize: commonTextSize.sp,
                              fontWeight: mainFontWeight)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  text: TextSpan(
                    text: "السعر قبل الخصم: ",
                    style: TextStyle(
                        color: textBlack,
                        fontSize: commonTextSize.sp,
                        fontWeight: mainFontWeight),
                    children: <TextSpan>[
                      TextSpan(
                          text: costBeforeSale,
                          style: TextStyle(
                              color: redTextAlert,
                              fontSize: commonTextSize.sp,
                              fontWeight: mainFontWeight)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  text: TextSpan(
                    text: "السعر بعد الخصم: ",
                    style: TextStyle(
                        color: textBlack,
                        fontSize: commonTextSize.sp,
                        fontWeight: mainFontWeight),
                    children: <TextSpan>[
                      TextSpan(
                          text: bundleCost,
                          style: TextStyle(
                              color: redTextAlert,
                              fontSize: commonTextSize.sp,
                              fontWeight: mainFontWeight)),
                    ],
                  ),
                ),

                SizedBox(
                  height: 8.h,
                ),
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  text: TextSpan(
                    text: "نسبة الخصم: ",
                    style: TextStyle(
                        color: textBlack,
                        fontSize: commonTextSize.sp,
                        fontWeight: mainFontWeight),
                    children: <TextSpan>[
                      TextSpan(
                          text: discount,
                          style: TextStyle(
                              color: redTextAlert,
                              fontSize: commonTextSize.sp,
                              fontWeight: mainFontWeight)),
                    ],
                  ),
                ),

                text.isEmpty?SizedBox(): Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: tinyTextSize.sp,
                    color: redTextAlert,
                    fontWeight: tinyTextWeight,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: DefaultButton(
              text: "اختيار",
              onPressed: onPressed,
              bgColor: authGradient3,
              fontSize: mainFontSize.sp,
              fontWeight: mainFontWeight,
            ),
          ),
        ],
      ),
    );
  }
}