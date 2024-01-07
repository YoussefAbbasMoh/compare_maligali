import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'dart:ui' as ui;

class DropDownContainer extends StatelessWidget {
  final String descriptionText;
  final List<Map<String, String>> dbList;

  const DropDownContainer({
    Key? key,
    required this.descriptionText,
    required this.dbList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 350.w,
          height: 65.h,
          decoration: BoxDecoration(
            color: purpleAppbar,
            borderRadius: BorderRadius.all(const Radius.circular(20).w),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 11.0,
          ).r,
          child: ExpansionTile(
            collapsedIconColor: textWhite,
            iconColor: textWhite,
            controlAffinity: ListTileControlAffinity.leading,
            title: Row(
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(width: 7.w),
                Container(
                    width: 30.w,
                    height: 40.h,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('assets/images/productsShelves.png'),
                      fit: BoxFit.fill,
                    ))),
                SizedBox(width: 30.w),
                SizedBox(
                  width: 170.w,
                  child: Text(descriptionText,
                      softWrap: false,
                      textDirection: ui.TextDirection.rtl,
                      style: TextStyle(
                        color: textWhite,
                        fontSize: commonTextSize.sp,
                      )),
                ),
              ],
            ),
            children: [
              Container(
                color: lightGreyButtons,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: dbList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        SizedBox(
                          width: 130.w,
                          child: Text(
                            dbList[index]["productName"]!,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        SizedBox(width: 30.w),
                        SizedBox(
                          width: 35.w,
                          child: Text(
                            dbList[index]["productCount"]!,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        SizedBox(
                          width: 85.w,
                          child: const Text(
                            "وحدة",
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ));
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
