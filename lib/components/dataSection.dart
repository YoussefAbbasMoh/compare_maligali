import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class DataSection extends StatelessWidget {
  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  TextEditingController? detailsController;
  final void Function(String)? onChanged;
  final TextInputType type;
  final double boxWidth;
  final double boxHeight;
  final String title;
  final bool readOnly;
  final double font;
  final String hintText;

  DataSection({
    Key? key,
    this.readOnly = false,
    this.title = "",
    this.detailsController,
    this.onChanged,
    this.onEditingComplete,
    this.font = commonTextSize,
    this.validator,
    this.boxWidth = 180,
    this.boxHeight = 250,
    this.type = TextInputType.text,
    this.hintText = "0.0",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: tinyTextSize.sp,
              color: textBlack,
              fontWeight: commonTextWeight),
          textAlign: TextAlign.right,
        ),
        SizedBox(
          width: boxWidth.w,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: lightGreyButtons,
            ),
            child: TextFormField(
              maxLines: null,
              minLines: 1,
              readOnly: readOnly,
              keyboardType: type,
              validator: validator,
              onChanged: onChanged,
              onEditingComplete: onEditingComplete,
              controller: detailsController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: font.sp, color: darkRed, fontWeight: commonTextWeight),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: darkRed.withOpacity(0.5),fontSize: font.sp, fontWeight: commonTextWeight)

              ),
            ),
          ),
        ),
        SizedBox(height: 10.h)
      ],
    );
  }
}

class ViewDataSection extends StatelessWidget {
  final String detailsText;
  final String title;
  final double boxHeight;
  final double boxWidth;
  final TextAlign position;

  const ViewDataSection({
    Key? key,
    this.boxWidth = 180,
    this.boxHeight = 50,
    this.position = TextAlign.center,
    required this.title,
    required this.detailsText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: tinyTextSize.sp,
              color: textBlack,
              fontWeight: commonTextWeight),
          textAlign: TextAlign.right,
        ),
        SizedBox(
          height: boxHeight.h,
          width: boxWidth.w,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: lightGreyButtons,
            ),
            child: Center(
              child: Text(
                detailsText,
                textAlign: position,
                style: TextStyle(
                  fontSize: commonTextSize.sp,
                  fontWeight: commonTextWeight,
                  color: darkGreen,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class ProductNameViewDataSection extends StatelessWidget {
  final String detailsText;
  final String title;
  final double boxHeight;
  final double boxWidth;
  final TextAlign position;

  const ProductNameViewDataSection({
    Key? key,
    this.boxWidth = 180,
    this.boxHeight = 50,
    this.position = TextAlign.center,
    required this.title,
    required this.detailsText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: tinyTextSize.sp,
              color: textBlack,
              fontWeight: commonTextWeight),
          textAlign: TextAlign.right,
        ),
        SizedBox(
          width: boxWidth.w,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: lightGreyButtons,
            ),
            child: Center(
              child: Text(
                detailsText,
                textAlign: position,
                style: TextStyle(
                  fontSize: commonTextSize.sp,
                  fontWeight: commonTextWeight,
                  color: darkGreen,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}

class ReceiptDataSection extends StatelessWidget {
  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  TextEditingController? detailsController;
  final void Function(String)? onChanged;
  final TextInputType type;
  final double boxWidth;
  final double boxHeight;
  final String title;
  final bool readOnly;
  final double font;

  ReceiptDataSection({
    Key? key,
    this.readOnly = false,
    this.title = "",
    this.detailsController,
    this.onChanged,
    this.onEditingComplete,
    this.font = tinyTextSize,
    this.validator,
    this.boxWidth = 180,
    this.boxHeight = 50,
    this.type = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxWidth.w,
      height: boxHeight.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: textBlack, width: 2),
          borderRadius: BorderRadius.all(const Radius.circular(20).r),
          color: lightGreyButtons,
        ),
        child: Align(
          child: TextFormField(
            maxLines: null,
            minLines: 1,
            readOnly: readOnly,
            keyboardType: type,
            validator: validator,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            controller: detailsController,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: font, color: darkRed, fontWeight: commonTextWeight),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
