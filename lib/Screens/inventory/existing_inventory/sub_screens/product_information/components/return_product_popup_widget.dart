import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import '../../../../../../../BusinessLogic/utils/time_and_date_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../BusinessLogic/utils/globalSnackBar.dart';
import 'package:maligali/components/buttons.dart';
import '../../../../../../../components/dataSection.dart';
import 'package:flutter/material.dart';
import '../../../../../../../../constants.dart';
import '../../../../../../BusinessLogic/view_models/inventory_view_models/inventory_page_view_model.dart';

//responsible for returning product to user inventory after it has been sold
/*A user can return a product in bulk "جملة " or as individual products "فرط"
he must also enter the total price of the returned units 
 */

Widget returnProductPopup(UserInventory productData, BuildContext context) {
  bool?
      colorChange; //highlights the selected option, if null both are not selected - if true so فرط is selected - if false جملة is selected
  String typeController =
      ""; //used to determine if the user is trying to return bulk or individual units
  final _formKey = GlobalKey<
      FormState>(); //key for the form used to enter the return variables

  TextEditingController totalReturnPriceCont = TextEditingController();
  TextEditingController numberOfItemsReturnCont = TextEditingController();

  return StatefulBuilder(builder: (context, StateSetter setState) {
    return Dialog(
      backgroundColor: purplePrimaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
        Radius.circular(30),
      ).w),
      child: Stack(
        children: [
          ///Title and back button of the popUp///
          Padding(
            padding: const EdgeInsets.only(top: 10).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Padding(
                  padding: const EdgeInsets.only(left: 70).r,
                  child: Text(
                    "ارجاع/حرق المنتج",
                    style: TextStyle(
                      fontSize: subFontSize.sp,
                      fontWeight: subFontWeight,
                      color: textWhite,
                    ),
                  ),
                ),
               IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 25.w,
                    color: textWhite,
                  ),
                  onPressed: () {
                        Navigator.pop(context);
                      },
                ),

              ],
            ),
          ),

          ///body of the popUp///
          Padding(
            padding: const EdgeInsets.only(top: 60).r,
            child: Container(
                width: 300.w,
                decoration: BoxDecoration(
                    color: textWhite,
                    borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))
                        .w),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15).r,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ///product name///
                            Text(
                              productData.productName,
                              maxLines: 2,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: commonTextSize.sp,
                                fontWeight: commonTextWeight,
                              ),
                            ),

                            ///product barcode///
                            Text(
                              productData.barCode,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: lightGreyReceiptBG,
                                fontSize: tinyTextSize.sp,
                                fontWeight: tinyTextWeight,
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),

                            ///price of the returned products///
                            ///must be set////////////////////////
                            DataSection(
                              type: TextInputType.number,
                              boxWidth: 300.w,
                              validator: (value) {
                                if (totalReturnPriceCont.text.isEmpty) {
                                  displaySnackBar(text:"خطأ في تعديل اجمالي السعر");
                                  return "ادخل الرقم صح";
                                }
                                return null;
                              },
                              onChanged: (value) {},
                              title: " اجمالي سعر الارجاع / الحرق",
                              detailsController: totalReturnPriceCont,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),

                            ///number of the returned products///
                            ///must be set///////////////////
                            DataSection(
                              type: TextInputType.number,
                              boxWidth: 300.w,
                              validator: (value) {
                                if (totalReturnPriceCont.text == "") {
                                  displaySnackBar(text:"خطأ في تعديل اجمالي السعر");
                                  return "ادخل الرقم صح";
                                }
                                return null;
                              },
                              onChanged: (value) {},
                              title: " عدد الوحدات المباعة/ المردودة",
                              detailsController: numberOfItemsReturnCont,
                            ),

                            ///buttons to select whether we are returning bulk or individual units

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20).r,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              (colorChange == null) ||
                                                      (colorChange == true)
                                                  ? Colors.transparent
                                                  : darkRed),
                                    ),
                                    child: Text(
                                      "كرتونة",
                                      style: TextStyle(
                                        fontSize: subFontSize.sp,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        colorChange = false;
                                        typeController = "جمله";
                                      });
                                    },
                                  ),
                                  SizedBox(width: 50.w),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              (colorChange == null) ||
                                                      (colorChange == false)
                                                  ? Colors.transparent
                                                  : darkRed),
                                    ),
                                    child: Text(
                                      "فرط",
                                      style: TextStyle(
                                        fontSize: subFontSize.sp,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        colorChange = true;
                                        typeController = "فرط";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            /// done button
                            Center(
                              child: DefaultButton(
                                  text: "تم",
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      displaySnackBar(text:"جاري التعديل");

                                      //if no form field is empty, we return the product
                                      String res =
                                          await InventoryPageVM().returnProduct(
                                        productData.barCode,
                                        typeController,
                                        productData.productName,
                                        numberOfItemsReturnCont.text,
                                        productData.averagePurchasePrice
                                            .toString(),
                                        productData.sellingPricePerPack
                                            .toString(),
                                        getNowDate(),
                                        totalReturnPriceCont.text,
                                        productData.numberOfCartonsInInventory
                                            .toString(),
                                        productData
                                            .numberOfPackagesOutsideCarton
                                            .toString(),
                                      );

                                      if (res == "done") {
                                        //if return is succesful//
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text("تم الارجاع")));
                                        Navigator.pop(context);
                                      } else {
                                        //if return failed//
                                        displaySnackBar(text:
                                            " اعد المحاولة ... خطأ في حفظ البيانات");
                                      }
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    }
                                  }),
                            ),
                            SizedBox(height: 10.h)
                          ]),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  });
}
