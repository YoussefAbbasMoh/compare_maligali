import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/constants.dart';
import 'package:flutter/material.dart';
import 'searchByBarcodeBody.dart';

class SearchByScanner extends StatefulWidget {
  static String routeName = "/ScanProduct";
  const SearchByScanner({Key? key}) : super(key: key);

  @override
  State<SearchByScanner> createState() => SearchByScannerState();
}

class SearchByScannerState extends State<SearchByScanner> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: InkWell(
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: textBlack,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                shadowColor: textBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0))
                      .w,
                ),
                backgroundColor: textWhite,
                centerTitle: true,
                title: Text('دور بالسيريال',
                    style: TextStyle(
                        fontSize: commonTextSize.sp,
                        color: textBlack,
                        fontWeight: mainFontWeight))),
            body: const SingleChildScrollView(child: ScanProductBody())));
  }
}
