import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import 'buttons.dart';

class DeletePopup extends StatelessWidget {
  final void Function() noOperation;
  final void Function() yesOperation;
  final String text;
  const DeletePopup(
      {Key? key,
      required this.noOperation,
      required this.yesOperation,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 0.0).r,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(const Radius.circular(30).w)),
      scrollable: true,
      content: SizedBox(
        width: 250.w,
        //height: 120.h,
        child: Padding(
          padding: EdgeInsets.only(top:25.0.h, bottom:25.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: tinyTextSize.sp, fontWeight: tinyTextWeight),
              ),
              Icon(
                Icons.delete_outline_outlined,
                color: textBlack,
                size: 30.w,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultButton(
                text: "لا",
                width: 80.w,
                height: 30.h,
                onPressed: noOperation,
              ),
              SizedBox(
                width: 50.w,
              ),
              DefaultButton(
                  text: "ايوه",
                  width: 80.w,
                  height: 30.h,
                  onPressed: yesOperation),
            ],
          ),
        )
      ],
    );
  }
}
