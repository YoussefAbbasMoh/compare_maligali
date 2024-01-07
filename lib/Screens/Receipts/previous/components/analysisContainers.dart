import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';

class AnalysisContainers extends StatelessWidget {
  final String descriptionText;
  final String result;
  final String imagePath;
  late String unit;

  AnalysisContainers(
      {Key? key,
      required this.descriptionText,
      required this.result,
      required this.imagePath,
      this.unit = " ج"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: purpleAppbar,
        borderRadius: BorderRadius.all(const Radius.circular(20).r),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(width: 20.w, height: double.infinity.h),
          Container(
              width: 30.w,
              height: 40.h,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.fill,
              ))),
          SizedBox(width: 5.w, height: double.infinity.h),
          SizedBox(
            width: 220.w,
            child: Column(
              children: [
                Text(
                  descriptionText,
                  textDirection: TextDirection.rtl,
                  style:
                      TextStyle(color: textWhite, fontSize: commonTextSize.sp),
                ),
                Text(
                  result.toString() + unit,
                  textDirection: TextDirection.rtl,
                  style:
                      TextStyle(color: textWhite, fontSize: commonTextSize.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
