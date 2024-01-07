import 'package:flutter/foundation.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';
import 'package:maligali/components/returnAppBar.dart';
import 'package:maligali/scaffoldComponents/GeneralScaffold.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import '../../../../../../components/incrementDecrementItemCountField.dart';
import '../../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../BusinessLogic/utils/globalSnackBar.dart';
import '../../../../../../components/dataSection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../../../constants.dart';
import 'dart:ui' as ui;

import '../../../../../BusinessLogic/view_models/inventory_view_models/add_to_user_inventory_view_model.dart';
import '../../../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';
import '../adding_to_inventory_grocery/sub_screens/create_new_custom_product/components/photo_capture_container_widget.dart';

/*
if a user wants to add a product that he couldn't find in general inventory, this screen is responsible for the operation
this screen allows the user to prdovide  information about the product set:
1- productName
2- barCode (manually or generated)
3- average purchase price
4- selling Price Per Pack
5- number of packs inside a single carton of this product
6- saleUnit
7- purchaseUnit
8- section
9- the number of cartons to be added to inventory
10- the number of packs outside cartons to be added to inventory if any (فرط)
11- productPhoto
 */
class AddCustomProductToUserInventoryNonGroceryScreen extends StatelessWidget {
  //attributes and constructors
  static String routeName =
      "/AddCustomProductToUserInventoryNonGroceryScreen"; //screen route name for navigator
  AddCustomProductToUserInventoryNonGroceryScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<
      FormState>(); //key for the form that displays and edits product information
  //these two widgets are stored as attributes to make connecting them to the rest of the screen easier
  late ItemCountField incDecNoOfCartons =
  ItemCountField(); //Widget that adds a number of cartons to the users inventory
  late ItemCountField incDecNoOfSingleProduct =
  ItemCountField(); //Widget that adds a number of packs to the users inventory

  //controllers for all product information
  final TextEditingController productNameCont = TextEditingController();
  final TextEditingController barcodeCont = TextEditingController();
  final TextEditingController averagePurchasePriceCont =
  TextEditingController();
  final TextEditingController sellingPricePerPackCont = TextEditingController();
  final TextEditingController numberOfCartonsInInventoryCont =
  TextEditingController();
  // final TextEditingContr`oller purchaseUnitCont = TextEditingController();
  // final TextEditingController saleUnitCont = TextEditingController();
  final TextEditingController numberOfPackageInsideTheCartonCont =
  TextEditingController();
  final TextEditingController sectionCont = TextEditingController();

  //this widget displays the photo that the user takes for the new product, we stored as an attribute to access it easily across the screen
  final PhotoCaptureContainer photoContainerOBJ = PhotoCaptureContainer();

  //dropdown boxes used in screen , stored as attributes for ease of access
  // DropdownBox invSectionsDropdownBox = DropdownBox(
  //   title: "اسم القسم",
  //   options: sectionNameList,
  //   titleImageUrl: "assets/images/food-stand.png",
  // );
  //
  // DropdownBox productPurchaseUnitDropdownBox = DropdownBox(
  //   title: "وحدة الشراء",
  //   options: purchaseUnitList,
  //   titleImageUrl: "assets/images/stack_inventory.png",
  // );
  //
  // DropdownBox productSaleUnitDropdownBox = DropdownBox(
  //   title: "وحدة البيع",
  //   options: saleUnitList,
  //   titleImageUrl: "assets/images/sale_unit1.png",
  // );

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
        curentPage: AddCustomProductToUserInventoryNonGroceryScreen.routeName,
        backGroundColor: purpleAppbar,
        appBar: ReturnAppBar(
          key: null,
          pageTitle: "اضافة منتج جديد",
          textColor: textWhite,
          appBarColor: purplePrimaryColor,
          preferredSize: const Size.fromHeight(40),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10).r,
                  child:
                  productInfromationColumn(), //upper part of the screen that allows user to enter all new product information and a photo
                ),
                //////////////////////////////////
                Text(
                  "حدد عدد الفرط اللي عندك",
                  style: TextStyle(fontSize: tinyTextSize.sp, color: textWhite),
                  textAlign: TextAlign.right,
                ),
                incDecNoOfSingleProduct, //widget that determines number of packs to be added
                SizedBox(
                  height: 20.h,
                ),
                //////////////////////////////////
                Text(
                  "حدد عدد الكراتين اللي عندك",
                  style: TextStyle(fontSize: tinyTextSize.sp, color: textWhite),
                  textAlign: TextAlign.right,
                ),
                incDecNoOfCartons, //widget that determines number of cartons to be added
                SizedBox(
                  height: 20.h,
                ),
                ///////////////////////////
                createProductButton(), //button that initiates the adding operation
                SizedBox(
                  height: 25.h,
                ),
              ],
            ),
          ),
        ));
  }

  //////////////////////////////////////////////////////
  ///This function is responsible for entering setting some information of the new product , it sets:
  ///productName - barCode - averagePurchasePrice - sellingPricePerPack - numberOfPackagesInsideCarton
  Widget productInfromationColumn() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              Container(
                color: textWhite,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 10).r,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ///////////product name//////////////
                      DataSection(
                        validator: (value) {
                          if (productNameCont.text == "") {
                            displaySnackBar(text:"خطئ في تعديل اسم المنتج");
                            return "ادخل البيانات صح";
                          }
                          return null;
                        },
                        onChanged: (value) {},
                        title: " :اسم المنتج",
                        detailsController: productNameCont,
                        hintText: "",
                      ),
                      /////////////barcode///////////////////
                      DataSection(
                        hintText : "",
                        type: TextInputType.number,
                        validator: (value) {
                          return null;
                        },
                        onChanged: (value) {},
                        title: " : الباركود",
                        detailsController: barcodeCont,
                      ),
                      const Text(
                        "اذا لم يكن للمنتج باركود رسمي\n اترك المساحة فارغة",
                        textDirection: ui.TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: tinyTextWeight,
                            color: redTextAlert),
                      ),
                      ///////////////////average purchase price//////////////////
                      DataSection(
                        type: TextInputType.number,
                        validator: (value) {
                          bool isValid = InventoryPageVM()
                              .checkForAveragePurchasePrice(
                              averagePurchasePriceCont.text,
                              sellingPricePerPackCont.text,
                              numberOfPackageInsideTheCartonCont.text);
                          return displayValidatorResult(
                              isValid, " سعر شراء الكرتونة");
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        title: "  :  سعر شراء الكرتونة",
                        detailsController: averagePurchasePriceCont,
                      ),
                      ///////////////////sellingPricePerPack/////////////
                      DataSection(
                        type: TextInputType.number,
                        validator: (value) {
                          bool isValid = InventoryPageVM()
                              .checkForSellingPricePerPack(
                              sellingPricePerPackCont.text,
                              averagePurchasePriceCont.text,
                              numberOfPackageInsideTheCartonCont.text);
                          return displayValidatorResult(
                              isValid, "سعر البيع للعبوة الواحدة");
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        title: "  : سعر البيع للعبوة الواحدة",
                        detailsController: sellingPricePerPackCont,
                      ),
                      ///////////////////number of packages inside carton///////////////////////
                      DataSection(
                        type: TextInputType.number,
                        validator: (value) {
                          if (numberOfPackageInsideTheCartonCont.text == "") {
                            displaySnackBar(text:"خطئ في تعديل عدد العلب جوا الكارتونة");
                            return "ادخل الرقم صح";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        title: " : عدد العلب جوا الكارتونة",
                        detailsController: numberOfPackageInsideTheCartonCont,
                      ),
                      // DataSection(
                      //   hintText: "",
                      //   type: TextInputType.text,
                      //   validator: (value) {
                      //     if (purchaseUnitCont.text == "") {
                      //       displaySnackBar(text:"خطئ في ادخال وحدة شراء الجملة");
                      //       return "دخل وحدة شراء صحيحة";
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (value) {
                      //     setState(() {});
                      //   },
                      //   title: ": وحدة شراء الجملة ",
                      //   detailsController: purchaseUnitCont,
                      // ),
                      // DataSection(
                      //   hintText: "",
                      //   type: TextInputType.text,
                      //   validator: (value) {
                      //     if (saleUnitCont.text == "") {
                      //       displaySnackBar(text:"خطئ في ادخال وحدة بيع المنتج (فرط)");
                      //       return "دخل وحدة بيع صحيحة";
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (value) {
                      //     setState(() {});
                      //   },
                      //   title: ": وحدة بيع الفرط ",
                      //   detailsController: saleUnitCont,
                      // ),
                      DataSection(
                        hintText: "",
                        type: TextInputType.text,
                        validator: (value) {
                          if (sectionCont.text == "") {
                            displaySnackBar(text:"خطئ في ادخال قسم المنتج");
                            return "دخل اسم القسم";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        title: ": اسم القسم ",
                        detailsController: sectionCont,
                      ),
                      totalProfitRow(incDecNoOfCartons, incDecNoOfSingleProduct),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 15).r,
                child: Container(
                  color: lightGreyButtons2,
                  width: 150.w,
                  height: 230.h,
                  child: photoContainerOBJ,
                ),
              ),
            ],
          );
        });
  }

/*responsilbe for displaying the total profit that will be gained from selling the amount of products the user enters
based on the average purchase price and the selling price per single pack*/
  Widget totalProfitRow(
      ItemCountField incDecButton1, ItemCountField incDecButton2) {
    final ValueListenable<double> cartonsCount = incDecButton1
        .number; //listen to changes in the widget that adds cartons in order to update the screen when the user increments cartons
    final ValueListenable<double> singleProductCount = incDecButton2
        .number; //listen to changes in the widget that adds packs in order to update the screen when the user increments packs

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Consumer<InventoryPageVM>(builder: (context, invPageVM, child) {
          return MultiValueListenableBuilder(
            //when the user incremetns cartons or packs
              valueListenables: [
                cartonsCount,
                singleProductCount,
              ],
              builder: (context, value, child) {
                //calculate total profit with the number of packs and cartons and the prices set in product information column
                double totalProfit = invPageVM.countTotalProfit(
                    sellingPricePerPackCont.text,
                    numberOfPackageInsideTheCartonCont.text,
                    singleProductCount.value.toString(),
                    cartonsCount.value.toString(),
                    averagePurchasePriceCont.text);
                if (totalProfit >= 0) {
                  return Text(
                    "اجمالي المكسب  : " +
                        totalProfit.toStringAsFixed(
                            2), //controls the amount of shown decimals after float point
                    style: TextStyle(
                        fontSize: tinyTextSize.sp,
                        color: textBlack,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  );
                } else {
                  return Text(
                    "اجمالي المكسب  : " +
                        "خطء في ادخال\n سعر الشراء او سعر البيع",
                    style: TextStyle(
                        fontSize: tinyTextSize.sp,
                        color: redTextAlert,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  );
                }
              });
        }),
      ],
    );
  }

  /*this function checks if all form fields, dropdown selections and entered amounts are correct, if so it uploads the product image
  to storage if it exists and adds the product to the users inventory , this function also generates a barcode for the object if one isn't given*/
  Widget createProductButton() {
    return Consumer<AddToUserInvVM>(builder: (context, addToInvVM, child) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shadowColor: lightGreyButtons2,
          backgroundColor: redLightButtonsLightBG,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          fixedSize: Size(200.w, 50.h),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5).r,
        ),
        child: Text(
          'زود المنتج في مخزنك',
          style: TextStyle(
              fontSize: tinyTextSize.sp,
              fontWeight: tinyTextWeight,
              color: textWhite),
        ),
        //////////////
        onPressed: () async {
          //intiates the adding process
          if (_formKey.currentState!.validate()) {
            //if all fields and amounts are valid
            String productPhotoNewLink = "";
            displaySnackBar(text:"جاري التسجيل ... برجاء الانتظار");
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: ((context) => const Center(
                  child: CircularProgressIndicator(),
                )));

            //checkForDropDowns(); //make sure drop down options for saleUnit,purchaseUnit,and section are selected, else gives each a default value

            if (barcodeCont.text == "") {
              //if barcode field is empty

              barcodeCont.text = addToInvVM
                  .generateBarCodeNoDropDown(sectionCont.text, StoreOwner.storeType); //generate barcode
            }

            //uploading product image if it is taken
            final itemPhotoCaptured = photoContainerOBJ
                .getPhotoFile(); //if a photo has been captured inside the container
            if (itemPhotoCaptured != null) {
              if (itemPhotoCaptured!.path != "unknown") {
                //if captured photo path is valid
                productPhotoNewLink = (await addToInvVM.uploadImageToStorage(
                    itemPhotoCaptured))!; //upload photo and save its link
              }
            }
            //adding the custom product to inventory
            String res =
            await addToInvVM.creatingAndAddNewProductToUserInventory(
              context: context,
              existInGenInv: false,
              numberOfCartonsInInventory: incDecNoOfCartons.getCount().toString(),
              productName: productNameCont.text,
              barcode: barcodeCont.text,
              averagePurchasePrice: averagePurchasePriceCont.text,
              sellingPricePerPack: sellingPricePerPackCont.text,
              numberOfPackageInsideTheCarton: numberOfPackageInsideTheCartonCont.text,
              numberOfPackagesOutsideCarton: incDecNoOfSingleProduct.getCount().toString(),
              productPhoto: productPhotoNewLink,
              section: sectionCont.text,
              date: getNowDate(),
            );
            if (res == "done") {
              displaySnackBar(text:"تم الاضافة");
              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              displaySnackBar(text:" اعد المحاولة ... خطأ في حفظ البيانات");
              Navigator.pop(context);
            }
          }
        },
      );
    });
  }

  ////////////utility functions////
  ///this function is responsible for setting product saleUnit, purchaseUnit, and section, if the user doesn't set them manually they will be given default values
  // checkForDropDowns() {
  //   if (invSectionsDropdownBox.controllerNameGetter() != "") {
  //     //if section is chosen
  //     sectionCont.text =
  //         invSectionsDropdownBox.controllerNameGetter(); //set as chosen
  //   } else {
  //     sectionCont.text = "اخري"; //set default value
  //   }
  //   if (productPurchaseUnitDropdownBox.controllerNameGetter() != "") {
  //     //if purchase unit is chosen
  //     purchaseUnitCont.text =
  //         productPurchaseUnitDropdownBox.controllerNameGetter(); //set chosen
  //   } else {
  //     purchaseUnitCont.text = "قطعة"; //set default value
  //   }
  //   if (productSaleUnitDropdownBox.controllerNameGetter() != "") {
  //     //if sale unit is chosen
  //     saleUnitCont.text =
  //         productSaleUnitDropdownBox.controllerNameGetter(); //set chosen
  //   } else {
  //     saleUnitCont.text = "قطعة"; //set default value
  //   }
  // }

  ///used to display error message if one of the form fields has an invalid value in it
  displayValidatorResult(bool isValid, String message) {
    if (isValid == true) {
      return null;
    } else {
      displaySnackBar(text:"خطئ في تعديل $message");
      return "دخل الرقم صح";
    }
  }
}
