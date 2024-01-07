import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'dart:ui' as ui;

class SearchByNameField extends StatelessWidget {
  final TextEditingController? searchController;
  String hintText;
  double width;
  double height;
  double font;
  bool enabled;
  bool autofocus;
  Color backGroundColor;
  void Function()? onTap;
  void Function(String text)? onChange;

  SearchByNameField(
      {Key? key,
      this.enabled = true,
      this.onChange,
      this.autofocus = false,
      this.width = 290,
      this.height = 45,
      this.font = tinyTextSize,
      this.backGroundColor = Colors.transparent,
      this.searchController,
      this.hintText = ' دور علي المنتج',
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: width.w,
      child: TextField(
        onChanged: onChange,
        autofocus: autofocus,
        textAlignVertical: TextAlignVertical.bottom,
        enabled: enabled,
        onTap: onTap,
        style: TextStyle(fontSize: font.sp, color: textBlack),
        textDirection: ui.TextDirection.rtl,
        controller: searchController,
        decoration: InputDecoration(
          filled: true, //<-- SEE HERE
          fillColor: backGroundColor,
          prefixIcon: Icon(
            Icons.search,
            size: 25.w,
          ),
          hintText: hintText,
          hintTextDirection: ui.TextDirection.rtl,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0).w),
        ),
      ),
    );
  }
}
