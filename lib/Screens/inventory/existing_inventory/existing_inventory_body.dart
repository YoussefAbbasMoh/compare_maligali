import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/Screens/Inventory/existing_inventory/sub_screens/product_information/product_information_screen.dart';
import 'package:maligali/Screens/inventory/existing_inventory/sub_screens/section_products/section_products_screen.dart';
import '../../../BusinessLogic/Services/local_inventory_services/hive_services.dart';
import '../../../BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/searchByNameField.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'dart:ui' as ui;

import '../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';

//body responsilbe for managing products that have already been added to inventory

/*This page does two main things :
  1-allow users to view products inside their inventory based on the products sections 
  2-search for a product accross the entire inventory with its name or barcode
  3- if a product is selected, direct user to detailed product information screen  */

class ExistingInventoryBody extends StatefulWidget {
  const ExistingInventoryBody({Key? key}) : super(key: key);

  @override
  State<ExistingInventoryBody> createState() => _ExistingInventoryBodyState();
}

class _ExistingInventoryBodyState extends State<ExistingInventoryBody> {
  ///search  attributes///
  String? filter; //used to store the name the user is typing
  bool activateScanner =
      false; //used to determine if the scanner has been used and we should display its search result
  String _scanBarcode =
      "Unknown"; //used to store the barcode the scanner has just scanned

  ///sections attributes//



  UserInventoryServices userInv = UserInventoryServices();

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
    return Consumer<InventoryPageVM>(
      builder: (context, inventoryVM, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 20, left: 14, top: 7).r,
                  child: searchUserInventoryButtonsRow()), //scan barcode button and search text field
              Padding(
                padding: const EdgeInsets.only(right: 20).r,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    //count of all items in userinventory
                    "اجمالي اصناف المنتجات في المحل: " +
                        inventoryVM
                            .getAllProductsInUserInventoryCount()
                            .toString(),
                    textDirection: TextDirection.rtl,
                    style:
                    const TextStyle(color: textWhite, fontSize: tinyTextSize),
                  ),
                ),
              ),
              Padding(
                //sum of averagePurchasePrice of all products
                padding: const EdgeInsets.only(right: 20).r,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "اجمالي قيمة المحل: " +
                        inventoryVM
                            .countTotalProfitAllProducts()
                            .toStringAsFixed(2),
                    textDirection: TextDirection.rtl,
                    style:
                    const TextStyle(color: textWhite, fontSize: tinyTextSize),
                  ),
                ),
              ),
              handleBody(), //resposible for viewing the available sections and products inside them or a search result in user inventory
            ],
          ),
        );
      },
    );
  }

  /////////////////////////////////////////////////

  //scan barcode button and search text field displayed above the main body
  Widget searchUserInventoryButtonsRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SearchByNameField(
          width: 200.w,
          enabled: true,
          onChange: (text) {
            //if the user starts typing, make sure scanner is deactivated and store what the user is typing
            setState(() {
              activateScanner = false;
              filter = text;
            });
          },
          backGroundColor: lightGreyButtons,
        ),
       // SizedBox(width: 20.w),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: lightGreyButtons2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30).w,
            ),
            backgroundColor: lightGreyButtons,
            fixedSize: Size(35.w, 50.h),
          ),
          child: Image.asset(
            "assets/images/barcode_icon.png",
          ),
          onPressed: (() async {
            //if we click on the scanner icon , call its function and turn on its flag
            await startScanner();
            setState(() {
              activateScanner = true;
            });
          }),
        ),
      ],
    );
  }

  /////this functions decides whether the body should contain product sections or a search result
  Widget handleBody() {
    /*if there is no search operation happening (determined by the values of the search variables) */
    if (!activateScanner && (filter == null || (filter?.isEmpty ?? false))) {
      return categoriesListView(); //display sections of products in the users inventory
    } else {
      return handleSearchType(); //else display the search result based on how the search was made
    }
  }

  /////this functions displays the result of an ongoing search operation
  Widget handleSearchType() {
    //if the search was made by scanning a physical object
    if (activateScanner) {
      activateScanner =
          false; //we turn it off so that the scanner can be reused
      return userInventoryProductScannedView(_scanBarcode, context);
    } else {
      //if no search operation has taken place
      return (filter == null)
          ? entryToInventoryContainer()
          : (filter!.isEmpty)
              ? entryToInventoryContainer()
              //if a search by name is taking place
              : userlInventoryListView(filter, context);
    }
  }

  ////////////place holder widgets////////////////////
  Widget itemNotFoundInUserInventoryContainer() {
    //displayed when we can't find the search result for a product
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
            child: Text(
          "المنتج مش موجود عندك",
          style: TextStyle(
              fontSize: subFontSize.sp,
              fontWeight: subFontWeight,
              color: textWhite),
        )),
        Image.asset(
          "assets/images/empty_box2.png",
          scale: 1,
        ),
      ],
    );
  }

  Widget entryToInventoryContainer() {
    //displayed if no search operation is going and there are no items in inventory to view in sections
    return Padding(
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

  ///////////////////////////////////////////////////////
  ///searching by name widgets///
  //////responsilbe for viewing the list of search results when searching by name
  Widget userlInventoryListView(String? filter, BuildContext context, ) {
    List<UserInventory> _items = userInv.searchUserInventoryByProductNameOrBarCode(
        filter); //we search using the variable that stores what the user is typing inside the textfield

    return (_items
            .isNotEmpty) //if the search returned a result, display the list
        ? Container(
            color: grayBG,
            width: 350.w,
            height: 450.h,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return userInventorySearchListTile(_items[index], context);
              },
            ))
        : itemNotFoundInUserInventoryContainer(); //if it was empty , display the not found widget
  }

  ///responsilbe for viewing the individual product inside the list of search results
  Widget userInventorySearchListTile(UserInventory data, BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(right: 10, top: 10).r,
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
                builder: (context) => (ViewData(
                      //if a product is selected, open its full information in a separate screen
                      productName: data.productName,
                      barCode: data.barCode,
                    ))));
      },
    );
  }

  ///searching by Scanner widgets///
  ///responsible for displaying the single search result of scanning a barcode manually
  Widget userInventoryProductScannedView(
      String _scanBarcode, BuildContext context) {
    if (_scanBarcode == '-1') return handleBody();
    return FutureBuilder(
        future: HiveDatabaseManager.getProductFromUserInventory(
            _scanBarcode), //we can use this function directly since we are searching for a single item , otherwise use searchUserInventoryByProductNameOrBarCode(filter);//we search using the variable that stores what the user is typing inside the textfield

        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (snapshot.data == null)
                ? itemNotFoundInUserInventoryContainer() //returns null if nothing is found, so we display no item found when null is returned from above
                //if a result is found, display its information as shown below
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
                                      (snapshot.data as UserInventory)
                                          .productName,
                                      textDirection: ui.TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: subFontSize.sp,
                                          fontWeight: subFontWeight)),
                                  Text((snapshot.data as UserInventory).barCode,
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
                                      builder: (context) => (ViewData(
                                          //open the product information of the found product if it is selected
                                          barCode:
                                              (snapshot.data as UserInventory)
                                                  .barCode,
                                          productName:
                                              (snapshot.data as UserInventory)
                                                  .productName))));
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

  ///////////////////////////////////////////////////////
  ///section functions/////////////////////////
  ///responsible for displaying the sections of products inside the users inventory if no search operation is taking place
  categoriesListView() {
    return SizedBox(
        height: 490.h,
        child:
            Consumer<InventoryPageVM>(builder: (context, inventoryVM, child) {
          return FutureBuilder(
            future: inventoryVM.getAvailableSectionsInUserInventory(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return ListView.builder(
                  itemCount: inventoryVM.uniquesSectionsCount.length + 1,
                  itemBuilder: (context, index) {
                    return (index == inventoryVM.uniquesSectionsCount.length)
                        ? Padding(padding: EdgeInsets.all(20.h))
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 10).r,
                            child: Container(
                              color: textWhite,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: ListTile(
                                      title: Text(
                                        inventoryVM.uniquesSectionsCount.keys
                                            .elementAt(index),
                                        textDirection: ui.TextDirection.rtl,
                                        style: TextStyle(
                                            fontSize: mainFontSize.sp,
                                            fontWeight: mainFontWeight),
                                      ),
                                      subtitle: Text(
                                        "عدد المنتجات : " +
                                            inventoryVM.uniquesSectionsCount.values
                                                .elementAt(index)
                                                .toString(),
                                        textDirection: ui.TextDirection.rtl,
                                        style: TextStyle(
                                            fontSize: tinyTextSize.sp,
                                            fontWeight: tinyTextWeight),
                                      )),
                                  onTap: () {
                                    /*when a section is selected, we get the items inside that section and use it to create the grid view containing the products in that section
                                      we then add the grid view widget to the end of the stack so that when the page is reloaded, the grid view will appear instead of the product sections
                                      the user can return to the previous sections widget with the back button at the top of the gridview, which empties the stack
                                      this way we can add nested sections without needing to exit the page 
                                       */
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SectionProductsScreen(
                                                  sectionsName: inventoryVM
                                                      .uniquesSectionsCount.keys
                                                      .elementAt(index),
                                                  sectionsCount: inventoryVM
                                                      .uniquesSectionsCount.values
                                                      .elementAt(index),
                                                )));
                                  },
                                ),
                              ),
                            ),
                          );
                  });
            },
          );
        }));
  }
}
