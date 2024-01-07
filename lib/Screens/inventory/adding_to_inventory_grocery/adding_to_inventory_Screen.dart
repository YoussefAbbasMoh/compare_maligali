import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maligali/Screens/inventory/adding_to_inventory_grocery/sub_screens/add_new_product_from_general_inventory/add_product_from_general_inventory_screen.dart';
import 'package:maligali/components/returnAppBar.dart';
import 'package:maligali/scaffoldComponents/GeneralScaffold.dart';
import '../../../../../components/searchByNameField.dart';
import '../../../BusinessLogic/Models/general_inventory_model.dart';
import '../../../BusinessLogic/Services/local_inventory_services/hive_services.dart';

import '../../../BusinessLogic/Services/local_inventory_services/general_inventory_services.dart';
import '../../../components/buttons.dart';

import '../../../../../constants.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'sub_screens/create_new_custom_product/add_custom_product_to_user_inventory_screen.dart';

//body responsilbe for managing products that have already been added to inventory

/*This page's main operation is  :
  1-allow user to search for a product in a collection of common products stored in local database (general inbventory) that is bundled with the application and add it to his own inventory(userInventory)
  2- if item doesn't exist then direct user to creating custom product screen */

class AddingToInventoryScreen extends StatefulWidget {
  static String routeName = "/AddingToInventoryScreen";
  const AddingToInventoryScreen({Key? key}) : super(key: key);

  @override
  State<AddingToInventoryScreen> createState() =>
      _AddingToInventoryScreenState();
}

class _AddingToInventoryScreenState extends State<AddingToInventoryScreen> {
  ///search  attributes///
  String? filter; //used to store the name the user is typing
  bool activateScanner =
      false; //used to determine if the scanner has been used and we should display its search result
  String _scanBarcode =
      "Unknown"; //used to store the barcode the scanner has just scanned

  ///function responsible for starting scanner and storing the barcode scanned
  Future<void> startScanner() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'رجوع', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    } catch (e) {
      barcodeScanRes = "Unknown";
    }

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
        curentPage: AddingToInventoryScreen.routeName,
        backGroundColor: purplePrimaryColor,
        appBar: ReturnAppBar(
          key: null,
          pageTitle: ('ضيف منتج جديد'),
          textColor: textWhite,
          appBarColor: purplePrimaryColor,
          preferredSize: Size.fromHeight(40.h),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 25, left: 14, bottom: 5, top: 14).w,
                  child:
                      searchGeneralInventoryButtonsRow()), //scan barcode button and search text field
              handleSearchType() //resposible for viewing the available sections and products inside them or a search result in generalInventory
            ],
          ),
        ));
  }

////////////////////////////////////
  //scan barcode button and search text field displayed above the main body
  Widget searchGeneralInventoryButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 230.w,
          child: SearchByNameField(
            width: 200.w,
            enabled: true,
            onChange: (text) {
              setState(() {
                //if the user starts typing, make sure scanner is deactivated and store what the user is typing
                activateScanner = false;
                filter = text;
              });
            },
            backGroundColor: lightGreyButtons,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: lightGreyButtons2,
            backgroundColor: lightGreyButtons,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30).w,
            ),
            fixedSize: Size(35.w, 50.h),
          ),
          child: Image.asset(
            "assets/images/barcode_icon.png",
          ),
          onPressed: ((() async {
            //if we click on the scanner icon , call its function and turn on its flag
            await startScanner();
            setState(() {
              activateScanner = true;
            });
          })),
        ),
      ],
    );
  }

  /////this functions displays the result of an ongoing search operation
  Widget handleSearchType() {
    //if the search was made by scanning a physical object
    if (activateScanner) {
      activateScanner =
          false; //we turn it off so that the scanner can be reused
      return productScannedView(_scanBarcode, context);
    } else {
      //if no search operation has taken place
      return (filter == null)
          ? entryToInventoryContainer()
          : (filter!.isEmpty)
              ? entryToInventoryContainer()
              //if a search by name is taking place
              : generlInventoryListView(filter, context);
    }
  }
  /////////////////////////////

  Widget productScannedView(String _scanBarcode, BuildContext context) {
    if (_scanBarcode == '-1') return entryToInventoryContainer();
    return FutureBuilder(
        future:
            HiveDatabaseManager.getProductFromGeneralInventory(_scanBarcode),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (snapshot.data == null)
                ? itemNotFoundInGeneralInventoryContainer(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: ui.TextDirection.rtl,
                    children: [
                      Container(
                          color: grayBG,
                          width: 350.w,
                          //height: 1.h,
                          child: ListTile(
                            title: Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, top: 10).r,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textDirection: ui.TextDirection.rtl,
                                children: [
                                  Text(
                                      (snapshot.data as GeneralInventory)
                                          .productName,
                                      textDirection: ui.TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: subFontSize.sp,
                                          fontWeight: subFontWeight)),
                                  Text(
                                      (snapshot.data as GeneralInventory)
                                          .barCode,
                                      style: TextStyle(
                                          color: lightGreyReceiptBG,
                                          fontSize: commonTextSize.sp,
                                          fontWeight: commonTextWeight)),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          (AddProductFromGeneralInvScreen(
                                              productBarCode: (snapshot.data
                                                      as GeneralInventory)
                                                  .barCode))));
                            },
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10,
                        ).r,
                        child: Text(
                            "الماسح قيد التجربة\n"
                            " لو ده منتجك دوس عليه لو مش هو عيد المسح ",
                            textDirection: ui.TextDirection.rtl,
                            style: TextStyle(
                              color: redLightButtonsLightBG,
                              fontSize: tinyTextSize.sp,
                            )),
                      )
                    ],
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: redLightButtonDarkBG,
              ),
            );
          }
        }));
  }
}

///////////////////////////////////////////////////////
///searching by name widgets///
//////responsilbe for viewing the list of search results when searching by name
Widget generlInventoryListView(String? filter, BuildContext context) {
  List<GeneralInventory> _items = GeneralInventoryServices()
      .searchGeneralInventoryByProductNameOrBarCode(
          filter); //we search using the variable that stores what the user is typing inside the textfield

  return (_items.isNotEmpty)
      ? Container(
          //if the search returned a result, display the list
          color: grayBG,
          //width: 350.w,
          height: 550.h,
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              return generalInventorySearchListTile(_items[index], context);
            },
          ))
      : itemNotFoundInGeneralInventoryContainer(
          context); //if it was empty , display the not found widget with option to manually add
}

///responsilbe for adding the individual product inside the list of search results

Widget generalInventorySearchListTile(
    GeneralInventory data, BuildContext context) {
  return ListTile(
    title: Padding(
      padding: const EdgeInsets.only(right: 5, top: 10).r,
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          SizedBox(
            width: 300.w,
            child: Text(data.productName,
                textDirection: ui.TextDirection.rtl,
                style: TextStyle(
                    fontSize: subFontSize.sp, fontWeight: subFontWeight)),
          ),
        ],
      ),
    ),
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              //if a product is selected, open the adding product from general inventoryscreen to add it
              builder: (context) => (AddProductFromGeneralInvScreen(
                    productBarCode: data.barCode,
                  ))));
    },
  );
}

////////////place holder widgets////////////////////
Widget entryToInventoryContainer() {
  return Padding(
    //displayed if no search operation is going and there are no items in inventory to view in sections

    padding: EdgeInsets.only(top: 60.r),
    child: Container(
        height: 250.h,
        width: 250.w,
        decoration: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage("assets/images/addItemToInventory2.png"),
              fit: BoxFit.fill,
            ))),
  );
}

Widget itemNotFoundInGeneralInventoryContainer(BuildContext context) {
  //displayed when we can't find the search result for a product

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 30).r,
        child: Text(
          "منتجك مش موجود\nفي قاعدة البيانات",
          style: TextStyle(
              fontSize: subFontSize.sp,
              color: textWhite,
              fontWeight: commonTextWeight),
          textAlign: TextAlign.right,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 30).r,
        child: DefaultButton(
          //displays a button that guides user to create custom product screen to add their product manually if it doesn't exist in preloaded general inventory
          onPressed: () async {
            Navigator.pushNamed(
                context, AddCustomProductToUserInventoryScreen.routeName);
          },
          width: 300.w,

          text: 'زود منتج جديد يدويا',
          // fontSize: mainFontSize.sp,
        ),
      ),
    ],
  );
}
/////////////////////////////
