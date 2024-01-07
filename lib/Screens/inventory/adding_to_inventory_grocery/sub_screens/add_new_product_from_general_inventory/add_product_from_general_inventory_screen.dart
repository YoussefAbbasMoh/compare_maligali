import 'package:flutter/foundation.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/user_inventory_services.dart';
import '../../../../../BusinessLogic/view_models/inventory_view_models/add_to_user_inventory_view_model.dart';
import '../../../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';
import '../../../../../components/incrementDecrementItemCountField.dart';
import '../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import '../../../../../scaffoldComponents/GeneralScaffold.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../BusinessLogic/utils/globalSnackBar.dart';
import '../../../../../components/returnAppBar.dart';
import '../../../../../components/dataSection.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

import '../../adding_to_inventory_Screen.dart';

/*
if a product from general inventory has been selected to be added to the user's inventory, this screen is responsible for the operation
this screen shows detailed information about the product and allows the user to set:
1-average purchase price
2- selling Price Per Pack
3- number of packs inside a single carton of this product
4- the number of cartons to be added to inventory
5- the number of packs outside cartons to be added to inventory if any (فرط)

 */
class AddProductFromGeneralInvScreen extends StatelessWidget {
  ///attributes and constructors
  static String routeName =
      "/AddProductFromGeneralInventoryToUserInventory"; //screen route name for navigator
  final String?
      productBarCode; //used in all backend operations regarding this product

  final _formKey = GlobalKey<
      FormState>(); //key for the form that displays and edits product information

  //these two widgets are stored as attributes to make connecting them to the rest of the screen easier
  late ItemCountField incDecNoOfCartons =
      ItemCountField(); //Widget that adds a number of cartons to the users inventory
  late ItemCountField incDecNoOfSingleProduct =
      ItemCountField(); //Widget that adds a number of packs to the users inventory

  AddProductFromGeneralInvScreen({Key? key, required this.productBarCode})
      : super(key: key);

  //controllers for all product information
  final TextEditingController productNameCont = TextEditingController();
  final TextEditingController barcodeCont = TextEditingController();
  final TextEditingController averagePurchasePriceCont =
      TextEditingController();
  final TextEditingController sellingPricePerPackCont = TextEditingController();
  // final TextEditingController purchaseUnitCont = TextEditingController();
  // final TextEditingController saleUnitCont = TextEditingController();
  final TextEditingController productPhotoCont = TextEditingController();
  final TextEditingController sectionCont = TextEditingController();
  final TextEditingController numberOfPackageInsideTheCartonCont =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GeneralScaffold(
      curentPage: AddingToInventoryScreen.routeName,
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
                      productInformationColumn()), //upper column of the screen containing all product information for viewing and editing
              //////////////////
              Text(
                "حدد عدد الفرط اللي عندك",
                style: TextStyle(fontSize: tinyTextSize.sp, color: textWhite),
                textAlign: TextAlign.right,
              ),
              incDecNoOfSingleProduct, //widget that determines number of packs to be added
              SizedBox(
                height: 20.h,
              ),
              ////////////////
              Text(
                "حدد عدد الكراتين اللي عندك",
                style: TextStyle(fontSize: tinyTextSize.sp, color: textWhite),
                textAlign: TextAlign.right,
              ),
              incDecNoOfCartons, //widget that determines number of cartons to be added
              SizedBox(
                height: 20.h,
              ),
              ////////////////////
              createProductButton(), //button that initiates the adding operation
              SizedBox(
                height: 25.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

/////////////////////////////////////////////////////////////
  ///this function is responsible for viewing product information and photo as well as set: averagePurchasePrice - sellingPricePerPack - numberOfPackagesInsideCarton
  Widget productInformationColumn() {
    return FutureBuilder<UserInventory>(
        future: UserInventoryServices()
            .getGeneralInvProductDataForCreatingNewProduct(productBarCode!),
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.done) {
            if (productSnapshot.hasError) {
              return Center(
                child: Text(
                  "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                  style: TextStyle(
                      fontSize: commonTextSize.sp,
                      fontWeight: commonTextWeight),
                ),
              );
            } else if (productSnapshot.hasData) {
              setControllersValues(productSnapshot.data!);
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Stack(
                  children: [
                    Container(
                      color: textWhite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10)
                            .r,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ProductNameViewDataSection(
                              detailsText: productNameCont.text,
                              title: ': اسم المنتج',
                            ),
                            ViewDataSection(
                              detailsText: barcodeCont.text,
                              title: ':الباركود',
                            ),

                            ///setting averagePurchasePrice///
                            DataSection(
                              type: TextInputType.number,
                              validator: (value) {
                                //validating
                                bool isValid = InventoryPageVM()
                                    .checkForAveragePurchasePrice(
                                        averagePurchasePriceCont.text,
                                        sellingPricePerPackCont.text,
                                        numberOfPackageInsideTheCartonCont
                                            .text);
                                return displayValidatorResult(
                                    isValid, "سعر شراء الكرتونة");
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              title: "  : سعر شراء الكرتونة",
                              detailsController: averagePurchasePriceCont,
                            ),
                            ////////////////////////
                            ///setting sellingPricePerPack
                            DataSection(
                              type: TextInputType.number,
                              validator: (value) {
                                //validating
                                bool isValid = InventoryPageVM()
                                    .checkForSellingPricePerPack(
                                        sellingPricePerPackCont.text,
                                        averagePurchasePriceCont.text,
                                        numberOfPackageInsideTheCartonCont
                                            .text);
                                return displayValidatorResult(
                                    isValid, "سعر البيع للعبوة الواحدة");
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              title: "  : سعر البيع للعبوة الواحدة",
                              detailsController: sellingPricePerPackCont,
                            ),
                            //////////////////////////
                            // ViewDataSection(
                            //   detailsText: purchaseUnitCont.text,
                            //   title: ': وحدة شراء الجملة',
                            // ),
                            // ViewDataSection(
                            //   detailsText: saleUnitCont.text,
                            //   title: ': وحدة بيع الفرط',
                            // ),
                            ////////////////////////
                            ///setting numberOfPackagesInsideCarton///
                            DataSection(
                              type: TextInputType.number,
                              validator: (value) {
                                //validating
                                if (numberOfPackageInsideTheCartonCont.text ==
                                    "") {
                                  displaySnackBar(
                                      text:
                                          "خطئ في تعديل عدد العلب جوا الكارتونة");
                                  return "ادخل الرقم صح";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                              title: " : عدد العلب جوا الكارتونة",
                              detailsController:
                                  numberOfPackageInsideTheCartonCont,
                            ),
                            ViewDataSection(
                              detailsText: sectionCont.text,
                              title: ': اسم القسم',
                            ),
                            totalProfitRow(
                                incDecNoOfCartons, incDecNoOfSingleProduct),

                            ///text that displays the total profit that would be gained from selling the added products
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 15).r,
                      child: Container(
                          color: textWhite,
                          width: 150.w,
                          height: 230.h,
                          child: Image.network(
                            productSnapshot.data!.productPhoto,
                            scale: 1,
                          )),
                    ),
                  ],
                );
              });
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
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
              valueListenables: [
                cartonsCount,
                singleProductCount,
              ],
              builder: (context, value, child) {
                //when the user incremetns cartons or packs
                double totalProfit = invPageVM.countTotalProfit(
                    //calculate total profit with the number of packs and cartons and the prices set in product information column
                    sellingPricePerPackCont.text,
                    numberOfPackageInsideTheCartonCont.text,
                    singleProductCount.value.toString(),
                    cartonsCount.value.toString(),
                    averagePurchasePriceCont.text);
                if (totalProfit >= 0) {
                  //profit can't be negative
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

  //this function checks if all form fields and entered amounts are correct, if so it adds the product to the users inventory
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
        onPressed: () async {
          //intiates the adding process
          if (_formKey.currentState!.validate()) {
            //if all fields and amounts are valid
            displaySnackBar(text: "جاري التسجيل");
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: ((context) => const Center(
                      child: CircularProgressIndicator(),
                    )));
            String res =
                await addToInvVM.creatingAndAddNewProductToUserInventory(
              context: context,
              existInGenInv: true,
              numberOfCartonsInInventory:
                  incDecNoOfCartons.getCount().toString(),
              productName: productNameCont.text,
              barcode: barcodeCont.text,
              averagePurchasePrice: averagePurchasePriceCont.text,
              sellingPricePerPack: sellingPricePerPackCont.text,
              numberOfPackageInsideTheCarton:
                  numberOfPackageInsideTheCartonCont.text,
              numberOfPackagesOutsideCarton:
                  incDecNoOfSingleProduct.getCount().toString(),
              productPhoto: productPhotoCont.text,
              section: sectionCont.text,
              date: getNowDate(),
            );
            if (res == "done") {
              displaySnackBar(text: "تم الاضافة");
              Navigator.of(context)
                ..pop(context)
                ..pop(context);
            } else {
              displaySnackBar(text: " اعد المحاولة ... خطأ في حفظ البيانات");
              Navigator.pop(context);
            }
          }
        },
      );
    });
  }

  //////////////////////////////
  ///utility functions

  ///used to display error message if one of the form fields has an invalid value in it
  displayValidatorResult(bool isValid, String message) {
    if (isValid == true) {
      return null;
    } else {
      displaySnackBar(text: "خطئ في تعديل $message");
      return "دخل الرقم صح";
    }
  }

  //used to quickly intialize form fields with values fetched from general inventory for this product
  setControllersValues(UserInventory productData) {
    productNameCont.text = productData.productName;
    barcodeCont.text = productData.barCode;
    averagePurchasePriceCont.text =
        ""; //productData.averagePurchasePrice.toString();
    sellingPricePerPackCont.text =
        ""; //productData.sellingPricePerPack.toString();
    // purchaseUnitCont.text = productData.purchaseUnit;
    // saleUnitCont.text = productData.saleUnit;
    numberOfPackageInsideTheCartonCont.text =
        productData.numberOfPackageInsideTheCarton.toString();
    productPhotoCont.text = productData.productPhoto;
    sectionCont.text = productData.section;
  }
}
