import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/Screens/inventory/existing_inventory/existing_inventory_screen.dart';
import 'package:maligali/constants.dart';

import '../../../../../../BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import '../../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import '../../../../../../components/deletePopup.dart';
import '../../../../../../scaffoldComponents/GeneralScaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../BusinessLogic/utils/globalSnackBar.dart';
import 'package:maligali/components/buttons.dart';
import '../../../../../../components/returnAppBar.dart';
import '../../../../../../components/dataSection.dart';
import 'package:flutter/material.dart';
import '../../../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';
import 'components/return_product_popup_widget.dart';

/*this page is responsible for viewing detailed information about a single product in the user inventory
as well as allow the user to:
-set average purchase price
-set selling price per pack
-add packs to inventory
-add cartons to inventory
-return/burn cartons or packs
-delete product*/

class ViewData extends StatelessWidget {
  ///constructor and core attributes///
  ViewData({Key? key, required this.barCode, required this.productName})
      : super(key: key);
  final String productName;
  final String barCode; //used in all backend operations regarding this product

  final _formKey = GlobalKey<
      FormState>(); //key for the form that displays and edits product information

  //controllers for all product information
  final TextEditingController productNameCont = TextEditingController();
  final TextEditingController barcodeCont = TextEditingController();
  final TextEditingController averagePurchasePriceCont =
      TextEditingController();
  final TextEditingController sellingPricePerPackCont = TextEditingController();
  final TextEditingController numberOfCartonsInInventoryCont =
      TextEditingController();
  final TextEditingController numberOfPackagesOutsideCartonCont =
      TextEditingController();
  // final TextEditingController purchaseUnitCont = TextEditingController();
  // final TextEditingController saleUnitCont = TextEditingController();
  final TextEditingController numberOfPackageInsideTheCartonCont =
      TextEditingController();
  final TextEditingController sectionCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      curentPage: ExistingInventoryScreen.routeName,
      backGroundColor: purpleAppbar,
      appBar: ReturnAppBar(
        key: null,
        pageTitle: "منتج في المحل",
        textColor: textWhite,
        appBarColor: purplePrimaryColor,
        preferredSize: Size.fromHeight(40.h),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: FutureBuilder<UserInventory>(

              //get the information of the product that was selected from the previous screen through constructor
              future: UserInventoryServices()
                  .getUserInvProductDataForInventoryDisplay(barCode),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.done) {
                  if (productSnapshot.hasError) {
                    //if failed to load, show error message
                    return Center(
                      child: Text(
                        "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                        style: TextStyle(
                            fontSize: commonTextSize.sp,
                            fontWeight: commonTextWeight),
                      ),
                    );
                  }
                  else if (productSnapshot.hasData) {
                    //if product loaded succesfully
                    setControllersValues(productSnapshot.data!);

                    //this column contains the product information and picture
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10).r,
                          child: Stack(children: [
                            productDataDisplayColumn(productSnapshot
                                .data!), //all text based product information to the rught
                            productImageDisplay(productSnapshot.data!
                                .productPhoto), //product image to the left
                          ]),
                        ),
                        buttonsDisplayColumn(productSnapshot.data!), //
                      ],
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////
  ///functions for display product information///

  ///this function is responsible for displaying all text product information (all info except product image)
  ///this function is also responsible for setting : averagePurchasePrice - sellingPricePerPack
  ///and adding to numberOfCartonsInInventory- numberOfPackagesOutsideCarton
  Widget productDataDisplayColumn(UserInventory product) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
            color: textWhite,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  ProductNameViewDataSection(
                    title: " :اسم المنتج",
                    position: TextAlign.end,
                    detailsText: productNameCont.text,
                  ),
                  ViewDataSection(
                    title: " :الباركود",
                    detailsText: barcodeCont.text,
                  ),

                  ///setting average purchase price///
                  DataSection(
                    type: TextInputType.number,
                    validator: (value) {
                      bool isValid =
                          InventoryPageVM().checkForAveragePurchasePrice(
                              //validating new average purchase price
                              averagePurchasePriceCont.text,
                              sellingPricePerPackCont.text,
                              numberOfPackageInsideTheCartonCont.text);
                      return displayValidatorResult(
                          isValid, "  :  سعر شراء الكرتونة ");
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    onEditingComplete: () {
                      setState(() {});
                    },
                    title: "  :  سعر شراء الكرتونة ",
                    detailsController: averagePurchasePriceCont,
                  ),

                  ///setting selling price per pack
                  DataSection(
                    type: TextInputType.number,
                    validator: (value) {
                      bool isValid =
                          InventoryPageVM().checkForSellingPricePerPack(
                              //valdiating new selling price per pack
                              sellingPricePerPackCont.text,
                              averagePurchasePriceCont.text,
                              numberOfPackageInsideTheCartonCont.text);
                      return displayValidatorResult(
                          isValid, "سعر البيع للعبوة الواحدة");
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    onEditingComplete: () {},
                    title: "  : سعر البيع للعبوة الواحدة",
                    detailsController: sellingPricePerPackCont,
                  ),
                  // ViewDataSection(
                  //   title: " :وحدة شراء الجملة",
                  //   detailsText: purchaseUnitCont.text,
                  // ),
                  // ViewDataSection(
                  //   title: " :وحده بيع الفرط",
                  //   detailsText: saleUnitCont.text,
                  // ),
                  ViewDataSection(
                    title: " :عدد العلب جوا الكارتونة",
                    detailsText: numberOfPackageInsideTheCartonCont.text,
                  ),
                  ViewDataSection(
                    title: " :اسم القسم",
                    detailsText: sectionCont.text,
                  ),

                  ///adding cartons to inventory///
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DataSection(
                        type: TextInputType.number,
                        validator: (value) {
                          bool isValid = InventoryPageVM()
                              .checkForNumbOfCartonsAndProductsInInv(
                                  //validating newly added number of cartons
                                  numberOfPackagesOutsideCartonCont.text,
                                  numberOfCartonsInInventoryCont.text);
                          return displayValidatorResult(
                              isValid, "عدد الكراتين في المخزن");
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        onEditingComplete: () {
                          setState(() {});
                        },
                        title: "زود عدد كراتين",
                        detailsController: numberOfCartonsInInventoryCont,
                      ),
                      Text(

                          ///displaying existing number of cartons without adding///
                          "عندك" +
                              " ${product.numberOfCartonsInInventory} " +
                              "كرتونة",
                          style: TextStyle(
                              fontSize: tinyTextSize.sp,
                              color: darkRed,
                              fontWeight: commonTextWeight))
                    ],
                  ),

                  ///adding packs to inventory///
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DataSection(
                        type: TextInputType.number,
                        validator: (value) {
                          bool isValid = InventoryPageVM()
                              .checkForNumbOfCartonsAndProductsInInv(
                                  //validating newly added number of packs
                                  numberOfPackagesOutsideCartonCont.text,
                                  numberOfCartonsInInventoryCont.text);
                          return displayValidatorResult(
                              isValid, " :عدد العلب الفرط في المخزن");
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        onEditingComplete: () {
                          setState(() {});
                        },
                        title: "زود عدد فرط",
                        detailsController: numberOfPackagesOutsideCartonCont,
                      ),
                      Text(

                          ///displaying existing number of packs outside carton without adding///
                          "عندك" +
                              " ${product.numberOfPackagesOutsideCarton} " +
                              "فرط",
                          style: TextStyle(
                              fontSize: tinyTextSize.sp,
                              color: darkRed,
                              fontWeight: commonTextWeight)),
                    ],
                  ),

                  ///displaying total profit that will be obtained from selling NEWLY ADDED products
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        ///displaying existing number of packs without adding///
                        "اجمالي المكسب من الكمية الجديدة : " +
                            (InventoryPageVM()
                                .countTotalProfit(
                                    sellingPricePerPackCont.text,
                                    numberOfPackageInsideTheCartonCont.text,
                                    numberOfPackagesOutsideCartonCont.text,
                                    numberOfCartonsInInventoryCont.text,
                                    averagePurchasePriceCont.text)
                                .toStringAsFixed(2)),
                        style: TextStyle(
                            fontSize: tinyTextSize.sp,
                            color: textBlack,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

  //used to display the image of the product selected
  Widget productImageDisplay(String productPhoto) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15).r,
      child: Container(
          color: textWhite,
          width: 150.w,
          height: 230.h,
          child: Image.network(productPhoto, scale: 1)),
    );
  }

//////////////////////////////////////////////////////////////////////////////
  ///functions for returing/deleting/confirming-edit of products///
  ///
//responsible for showing three main buttons below the product information part that:
  /// 1- save edit
  /// 2- return/burn products
  /// 3-delete products
  Widget buttonsDisplayColumn(UserInventory productData) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 0.5.h,
            ),

            ///saving edits made in (averagePurchasePrice-sellingPricePerPack - add numberOfCartonsInInventory - add numberOfPacakagesOutsideCarton)
            DefaultButton(
              width: 250.w,
              text: 'تعديل البيانات',
              onPressed: () async {
                //if all edits are valid
                if(numberOfCartonsInInventoryCont.text == ""){
                  numberOfCartonsInInventoryCont.text = "0.0";
                }else if(numberOfPackagesOutsideCartonCont.text == ""){
                  numberOfPackagesOutsideCartonCont.text = "0.0";
                }
                if (_formKey.currentState!.validate()) {
                  displaySnackBar(text:"جاري التعديل");
                  String res = await InventoryPageVM()
                      .editingProductInfoOperation(
                          barCode,
                          productName,
                          numberOfCartonsInInventoryCont.text,
                          numberOfPackagesOutsideCartonCont.text,
                          averagePurchasePriceCont.text,
                          sellingPricePerPackCont.text,
                          getNowDate());
                  if (res == "done") {
                    //edits saved succesfully
                    displaySnackBar(text:"تم التعديل");
                    Navigator.pop(context);
                  } else {
                    //saving edits failed
                    displaySnackBar(text:" اعد المحاولة ... خطأ في حفظ البيانات");
                  }
                }
              },
            ),
            SizedBox(
              height: 25.h,
            ),
            SecondaryButton(
              ///return/burn product button
              width: 250.w,
              text: 'ارجاع / حرق المنتج',
              onPressed: () async {
                returningProductOperation(context, productData);
              },
            ),
            SizedBox(height: 25.h),
            SecondaryButton(
              width: 250.w,
              text: 'الغاء المنتج',
              onPressed: () async {
                //delete product button
                deletingProductOperation(context, getNowDate(), productData);
              },
            ),
            SizedBox(
              height: 25.h,
            ),
          ],
        );
      },
    );
  }

  // FUNCTIONS FOR DISPLAYING SCREEN DIFFERENT SECTIONS:
  // ---------------------------------------------------
  //responsilbe for showing the return product popup
  returningProductOperation(
      BuildContext context, UserInventory productData) async {
    showDialog(
        context: context,
        builder: (context) {
          return returnProductPopup(
            //<- this widget contains the logic and appropriate documentation
            productData,
            context,
          );
        });
  }

  //responsible for deleting a product from inventory
  deletingProductOperation(
      BuildContext context, String date, UserInventory product) {
    showDialog(
        context: context,
        builder: (context) {
          bool res = InventoryPageVM().checkForNoChangeInQuantity(
            product.barCode,
            "${product.numberOfCartonsInInventory}",
            "${product.numberOfPackagesOutsideCarton}",
          );
          print(res);
          return DeletePopup(
            //displace confirmation pop up for delete operation
            text: res==false?"متأكد انك عايز تمسح المنتج؟\n لسة باقي عندك كمية": 'متأكد انك عايز تمسح المنتج؟',
            yesOperation: () async {
              //if user presses yes and hasn not added any items before deletion

              // print("---------");
              // print(res);
              // print("---------");
              // if (res) {
                ///deleting product///
                String res = await InventoryPageVM().deleteProductOperation(
                    barCode,
                    productName,
                    numberOfCartonsInInventoryCont.text,
                    numberOfPackagesOutsideCartonCont.text,
                    averagePurchasePriceCont.text,
                    sellingPricePerPackCont.text,
                    //saleUnitCont.text,
                    date);
                if (res == "done") {
                  //if delete successful
                  displaySnackBar(text:"تم المسح");

                  Navigator.of(context)
                    ..pop(context)
                    ..pop()
                    ..pop();
                } else {
                  //if delete fails
                  displaySnackBar(text:" اعد المحاولة ... خطأ في مسح المنتج");
                }
              //}
              // else {
              //   //if user has just added items before deletion
              //   displaySnackBar(text:"خطأ مخزنك لسة فيه كميات من المنتج ده. احرق المنتج احسن");
              //   Navigator.of(context)
              //     ..pop(context);
              // }
            },
            noOperation: () {
              Navigator.pop(context, "deleted");
            },
          );
        });
  }

/////////////////////////////////////////////////////////
  ///helper functions///
  ///
  ///
  displayValidatorResult(bool isValid, String message) {
    //used to validate each form field and display a snackbar with an error message if invalid
    if (isValid == true) {
      return null;
    } else {
      displaySnackBar(text:"خطئ في تعديل $message");
      return "دخل الرقم صح";
    }
  }

  //used to quickly initialize the formfields with the product data
  setControllersValues(UserInventory productData) {
    productNameCont.text = productData.productName;
    barcodeCont.text = productData.barCode;
    averagePurchasePriceCont.text = productData.averagePurchasePrice.toString();

    sellingPricePerPackCont.text = productData.sellingPricePerPack.toString();
    numberOfCartonsInInventoryCont.text = "";
    numberOfPackagesOutsideCartonCont.text = "";
    // purchaseUnitCont.text = productData.purchaseUnit;
    // saleUnitCont.text = productData.saleUnit;
    numberOfPackageInsideTheCartonCont.text =
        productData.numberOfPackageInsideTheCarton.toString();
    sectionCont.text = productData.section;
  }
}
