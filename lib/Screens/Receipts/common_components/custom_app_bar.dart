import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../scaffoldComponents/userIconButton.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';

/////////////this is a customized app bar that mainly used in screens under the Receipts screen that are related to today and previous screens
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Color appBarColor;
  final Color drawerIconColor;
  final Color backGroundColor;
  final Color textColor;
  final String pageTitle;
  final IconData icon;
  final void Function()? onPressed;
  late Widget? bottom; //optional body of the appbar

  CustomAppBar({
    required Key? key,
    this.appBarColor = textWhite,
    this.drawerIconColor = lightGreyButtons2,
    this.backGroundColor = textWhite,
    this.textColor = purplePrimaryColor,
    this.pageTitle = "",
    this.bottom,
    this.icon = Icons.menu_rounded,
    this.onPressed,
    required this.preferredSize,
  }) : super(key: key);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.appBarColor,
      toolbarHeight: 30,
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))
              .w),
      centerTitle: true,
      title: Text(
        widget.pageTitle,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: commonTextSize.sp,
            color: widget.textColor,
            fontWeight: commonTextWeight),
      ),
      actions: [
        IconButton(
          icon: Icon(
            widget.icon,
            size: 25.w,
            color: widget.drawerIconColor,
          ),
          onPressed: widget.onPressed ??
              () {
                Scaffold.of(context).openEndDrawer();
              },
        )
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(90.h),
        child: (widget.bottom == null)
            ? SizedBox(height: 0.0.h, width: double.infinity.w)
            : widget.bottom!,
      ),
    );
  }
}
