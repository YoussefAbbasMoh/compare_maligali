import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';
import 'package:maligali/Screens/Inventory/existing_inventory/existing_inventory_body.dart';

import '../../../scaffoldComponents/GeneralScaffold.dart';
import '../../../components/returnAppBar.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../adding_to_inventory_grocery/adding_to_inventory_Screen.dart';
import '../adding_to_inventory_non_grocery/adding_to_inventory_non_grocery_screen.dart';

//Entry point for inventory screen
class ExistingInventoryScreen extends StatefulWidget {
  static String routeName = "/ExistingInventoryScreen";
  const ExistingInventoryScreen({Key? key}) : super(key: key);

  @override
  State<ExistingInventoryScreen> createState() => _ExistingInventoryScreen();
}

class _ExistingInventoryScreen extends State<ExistingInventoryScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      curentPage: ExistingInventoryScreen.routeName,
      backGroundColor: purplePrimaryColor,
      floatingActionButton: SizedBox(
        width: 200.w,
        height: 50.h,
        child: FloatingActionButton.extended(
          label: const Text('ضيف منتج جديد'),
          extendedTextStyle: const TextStyle(
              color: white2BG,
              fontSize: mainFontSize,
              fontWeight: mainFontWeight),
          backgroundColor: redLightButtonsLightBG,
          onPressed: () {

            String storeType = StoreOwner.storeType;

            if(storeType == "grocery" || storeType == "cleaning" || storeType == "roasters") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (const AddingToInventoryScreen())))
                  .then((value) => setState(() {}));
            }
            else{
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => (
                          AddCustomProductToUserInventoryNonGroceryScreen())))
                  .then((value) => setState(() {}));
            }
            },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: ReturnAppBar(
        key: null,
        pageTitle: "منتجات المحل",
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
      body: const ExistingInventoryBody(),
    );
  }
}
