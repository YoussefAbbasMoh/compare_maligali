import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/returnAppBar.dart';
import 'update_info_body.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

//responsible for allowing an existing user to update his information
class UpdateInfoScreen extends StatelessWidget {
  UpdateInfoScreen({Key? key}) : super(key: key);
  static String routeName = "/UpdateInfo"; //route name for navigator

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: purplePrimaryColor,
      appBar: ReturnAppBar(
        key: null,
        pageTitle: "تحديث بيانتك",
        textColor: textWhite,
        appBarColor: purplePrimaryColor,
        bottom: Container(
          decoration: BoxDecoration(
            color: textWhite,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))
                .w,
          ),
        ),
        preferredSize: Size.fromHeight(40.h),
      ),




      body: const UpdateInfoBody(), //body of the screen
    );
  }
}
