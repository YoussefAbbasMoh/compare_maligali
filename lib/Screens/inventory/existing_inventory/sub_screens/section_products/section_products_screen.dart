import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/Screens/inventory/existing_inventory/sub_screens/product_information/product_information_screen.dart';
import 'package:maligali/components/returnAppBar.dart';
import 'package:maligali/scaffoldComponents/GeneralScaffold.dart';

import '../../../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';
import '../../../../../constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SectionProductsScreen extends StatefulWidget {
  static String routeName = "/SectionProductsScreen";
  SectionProductsScreen(
      {Key? key, required this.sectionsName, required this.sectionsCount})
      : super(key: key);
  int sectionsCount = 0;
  String sectionsName = "";

  @override
  State<SectionProductsScreen> createState() => _SectionProductsScreen();
}

class _SectionProductsScreen extends State<SectionProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
        curentPage: SectionProductsScreen.routeName,
        backGroundColor: purplePrimaryColor,
        appBar: ReturnAppBar(
          key: null,
          pageTitle: (widget.sectionsName),
          textColor: textWhite,
          appBarColor: purplePrimaryColor,
          preferredSize: Size.fromHeight(40.h),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 14,top: 14).w,
                  child: viewProductsInEverySection(
                      widget.sectionsName,
                      widget.sectionsCount,
                      getSectionProducts(
                        widget.sectionsName,
                      ))),
            ],
          ),
        ));
  }

  Widget viewProductsInEverySection(
      String secName, int productsCount, Widget box) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 550.h
      ),
      color: textWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "عدد المنتجات : " + productsCount.toString(),
                  textDirection: ui.TextDirection.rtl,
                  style: TextStyle(
                      fontSize: mainFontSize.sp,
                      fontWeight: mainFontWeight),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10).r,
              child: box),
        ],
      ),
    );
  }

  //middle function used to load the items in a selected section for the grid view before displaying it
  Widget getSectionProducts(String sectionName) {
    return FutureBuilder<List<UserInventory>>(
        future: InventoryPageVM().getAllProductsForSection(sectionName),
        builder: (context, productsSnapshot) {
          if (productsSnapshot.connectionState == ConnectionState.done) {
            if (productsSnapshot.hasError) {
              return Center(
                child: Text(
                  "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight),
                ),
              );
            } else if (productsSnapshot.hasData) {
              return theGridView(productsSnapshot.data!);
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  //responsible for displaying the products inside every section in a grid
  Widget theGridView(List<UserInventory> items) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.w,
        shrinkWrap: true,
        children: List.generate(items.length, (index) {
          return InkWell(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(const Radius.circular(20.0).w),
                    color: welcomeGradient2.withOpacity(0.1.sp)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(items.elementAt(index).productPhoto,
                        height: 70.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0).r,
                      child: Text(
                        items.elementAt(index).productName,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: tinyTextSize.sp,
                            fontWeight: tinyTextWeight),
                      ),
                    ),
                  ],
                )),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewData(
                          //if a product is selected then view its information
                          barCode: items.elementAt(index).barCode,
                          productName: items.elementAt(index).productName)));
            },
          );
        }),
      ),
    );
  }
}
