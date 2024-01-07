import '../../../BusinessLogic/view_models/authentication_view_models/authentication_view_model.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../BusinessLogic/utils/globalSnackBar.dart';
import '../../../components/buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../sign_up/sign_up_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../otp/otp_screen.dart';

/*this screen is responsible for taking a phone number from the user and attempt to sign in with that number
 if the number exists as a registered account then navigate the user to otp screen to confirm ownership of the number
 or navigate the user to sign up screen if he clicks on the sign up button or if the number doesn't exist  */

class LogInBody extends StatelessWidget {
  LogInBody({Key? key}) : super(key: key);

  final TextEditingController _numberController =
      TextEditingController(); //controller for textfield holding the phone number
  String _countryCode =
      "+20"; //variable holding the selected country code , defaults to +20
  final _formKey = GlobalKey<FormState>(); //form key for validating textfields

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Container(
              width: 340.w,
              height: 270.h,
              decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/video/loginVid2.gif"), //animation playing at the top of the log in screen
                    fit: BoxFit.fill,
                  ))),
          SizedBox(width: double.infinity.w, height: 40.h),
          Form(
            key: _formKey,
            child: Column(
              children: [
                ////////////////////row where phone number is entered and country code is selected
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0).r,
                      child: SizedBox(
                        width: 220.w,
                        height: 90.h,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          /////////////////phone number textfield
                          child: TextFormField(
                            onFieldSubmitted: (value) async {
                              FocusScope.of(context)
                                  .unfocus(); //automtically unfocus (remove keyboard) when user finishes typing
                            },

                            validator: (value) {
                              //validation of phone number
                              if ((value!).isEmpty) {
                                //field must not be empty
                                displaySnackBar(text:
                                    "دخل رقم التليفون عشان تعرف تسجل");

                                return "empty";
                              }
                              return null;
                            },
                            cursorColor: textBlack,

                            style: TextStyle(fontSize: subFontSize.sp),
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            maxLength:
                                11, //the maximum number of characters the user can enter is 11
                            keyboardType: TextInputType.phone,
                            controller: _numberController,
                            decoration: InputDecoration(
                              counterStyle: const TextStyle(color: textBlack, fontWeight: commonTextWeight),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: textBlack),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: textBlack),
                              ),
                              icon: const Icon(
                                Icons.phone_enabled,
                                color: textBlack,
                              ),
                              labelText: "رقم تليفونك",
                              hintText: "0000 000 100 0",
                              labelStyle: TextStyle(
                                  color: textBlack,
                                  fontSize: mainFontSize.sp,
                                  fontWeight: mainFontWeight),
                              hintStyle: TextStyle(
                                  color: lightGreyReceiptBG, fontSize: subFontSize.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //////////////country code picker//////////////////
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0).r,
                      child: StatefulBuilder(
                        builder: (context, setInnerState) {
                          return GestureDetector(
                            onTap: () async {
                              //if a user clicks on it
                              final code = await const FlCountryCodePicker(
                                      //show country code list
                                      showSearchBar: true)
                                  .showPicker(context: context);
                              if (code != null) {
                                //if a country code is picked then set it
                                setInnerState(() {
                                  _countryCode = code.dialCode;
                                });
                              }
                            },
                            child: Container(
                              width: 70.w,
                              height: 35.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  border: Border.all(width: 2.w),
                                  color: textWhite,
                                  borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0))
                                      .w),
                              child: Text(_countryCode,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: commonTextSize.sp,
                                      fontWeight: commonTextWeight,
                                      color: textBlack)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                /////////////////confirmation button/////////////////////
                SizedBox(height: 30.h, width: double.infinity.w),
                DefaultButton(
                    text: "تسجيل الدخول",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await startAuthProcess(context);
                      }
                    }),
                SizedBox(height: 20.h, width: double.infinity.w),
                Text(
                  "معندكش حساب ؟",
                  style:
                      (TextStyle(color: textWhite, fontSize: tinyTextSize.sp)),
                ),

                ///sign up button navigating the user to sign in screen if he clicks it
                InkWell(
                  child: Text(
                    'سجل حساب جديد',
                    style: TextStyle(
                        color: textWhite,
                        fontSize: tinyTextSize.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, SignUpScreen.routeName);
                  },
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  /////////////////////////////////
  ///
  //responsible for showing an error message for the user if sign in fails
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مشكلة في تسجيل الدخول'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('تمام'),
          )
        ],
      ),
    );
  }

//responsible for authenticating a phone number
  startAuthProcess(BuildContext context) async {
    //authentication services provider instance
    AuthenticationServices provider =
        Provider.of<AuthenticationServices>(context, listen: false);
    provider
        .authenticationProviderInit(); //making sure authentication services have been initialized
    provider.setSignInDataHolder(_numberController.text,
        _countryCode); //passing the phone number to authentication services

    bool isAuthenticationSourceCorrect = await provider
        .checkForCorrectAuthenticationSource(); //check if the phone number is an already registered account number
    if (isAuthenticationSourceCorrect == false) {
      //if the phone number is not already registered
      displaySnackBar(text:
          "رقمك مش موجود عندنا .. سجل حساب جديد"); //show error message
      Navigator.pushNamed(
          context, SignUpScreen.routeName); //navigate to sign up screen
    } else {
      try {
        //if the phone number is registered
        await provider.startAuthProcess().then((value) {
          //start the authentication process , throws exceptions when it fails
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpScreen()), //then navigate the user to the otp screen
          );
        }).catchError((e) {
          if (kDebugMode) {
            print(e);
          }
          String errorMsg =
              'في حاجة غلط اتأكد من اتصال النت او سجل في وقت تاني'; //default error message to show the user if an exception is thrown
          if (e.toString().contains(
              'We have blocked all requests from this device due to unusual activity. Try again later.')) {
            errorMsg =
                'حاولت تسجل حسابك كتير في وقت قصير ... جرب تاني بعد ساعة'; //error message to show if the user attempted multiple sign ins in a short period of time
          }
          _showErrorDialog(context, errorMsg);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }
}
