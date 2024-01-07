import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';

import '../../../BusinessLogic/utils/dropdownLists/registerDropDownItems.dart';
import '../../../BusinessLogic/view_models/update_user_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/customTextField.dart';
import '../../../components/dropDownBox.dart';
import '../../../components/orDivider.dart';
import '../../../components/buttons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

/*this screen is repsonsible for allowing the user to update some of the information he signed up with 
this screen allows him to change :

1- store name
2- number of delivery workers
3- store location
4- store size */
class UpdateInfoBody extends StatefulWidget {
  const UpdateInfoBody({Key? key}) : super(key: key);

  @override
  State<UpdateInfoBody> createState() => _UpdateInfoBodyState();
}

class _UpdateInfoBodyState extends State<UpdateInfoBody> {
  final _formKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  //dropdown box for selecting store size out of predetermined options, stored as an attribute for ease of access to selection inside it
  DropdownBox shopSizeDropdownBox = DropdownBox(
    options: shopSizeList,
    titleImageUrl: "assets/images/food-stand.png",
    title: StoreOwner.storeSize,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20).r,
        child: SingleChildScrollView(child: Consumer<UpdateUserInfoViewModel>(
            //this viewmodel is repsonsible for editing the users information, new information is passed to it to attempt a change
            builder: (context, updateProviderInternal, child) {
          return Column(children: [
            SizedBox(height: emptyScreensPadding.h, width: double.infinity.w),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const OrDivider(text: "بيانات\nالمستخدم"),
                  ////////////user name////////////////////////
                  CustomTextField(
                    fontStyle: TextStyle(
                        color: lightGreyReceiptBG,
                        fontSize: commonTextSize.sp,
                        fontWeight: subFontWeight),
                    enabled: false,
                    controller: updateProviderInternal.nameController,
                    labelText: 'اسم المستخدم',
                    hintText: updateProviderInternal.nameController.value.text,
                    topPadding: 10.r,
                  ),
                  //////////////user number//////////////////
                  CustomTextField(
                    fontStyle: TextStyle(
                        color: lightGreyReceiptBG,
                        fontSize: commonTextSize.sp,
                        fontWeight: subFontWeight),
                    enabled: false,
                    labelText: 'رقم المستخدم',
                    topPadding: 5.r,
                    controller: updateProviderInternal.numberController,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      "* لتعديل بيانات المستخدم برجاء الاتصال بخدمة العملاء",
                      style: TextStyle(
                          fontSize: tinyTextSize.sp,
                          fontWeight: tinyTextWeight,
                          color: darkRed),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0).r,
                    child: const OrDivider(text: "معلومات\nالمحل"),
                  ),
                  //////////store name//////////////////
                  CustomTextField(
                    labelText: 'اسم المحل',
                    hintText: 'مثال :  محلات الامل',
                    topPadding: 10.r,
                    controller: updateProviderInternal.shopNameController,
                  ),
                  /////////////number of delivery workers//////////////////
                  CustomTextField(
                    labelText: 'عدد عمال توصيل الطلبات (الدليفري)',
                    topPadding: 10.r,
                    controller:
                        updateProviderInternal.deliveryManCountController,
                  ),
                  ////////////////store address//////////////////
                  CustomTextField(
                    fontStyle: TextStyle(
                        color: lightGreyReceiptBG,
                        fontSize: commonTextSize.sp,
                        fontWeight: subFontWeight),
                    enabled: false,
                    controller: updateProviderInternal.shopLocationController,
                    labelText: 'عنوان المحل',
                    hintText: updateProviderInternal.shopLocationController.value.text,
                    topPadding: 10.r,
                  ),
                  ///




                  Padding(
                    padding: const EdgeInsets.only(top: 3).r,
                    child: shopSizeDropdownBox,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h, width: double.infinity.w),
            //////////////////confirmation button//////////////////
            DefaultButton(
              width: 220.w,
              text: "تعديل البيانات  ",
              fontWeight: mainFontWeight,
              onPressed: () async {
                setState(() {
                  //make sure store size has been selected, if not then give it a default value
                  (shopSizeDropdownBox.controllerNameGetter() == "")
                      ? updateProviderInternal
                          .shopSizeControllerSetter('محل صغير/ كشك')
                      : updateProviderInternal.shopSizeControllerSetter(
                          shopSizeDropdownBox.controllerNameGetter());
                });

                await updateProviderInternal
                    .updateUserInfo(); //attempt to save the changes made to the user information
                Navigator.pop(context);
              },
            ),
          ]);
        })),
      ),
    );
  }
}
