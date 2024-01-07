import '../../../BusinessLogic/view_models/authentication_view_models/authentication_view_model.dart';
import '../../../BusinessLogic/utils/time_and_date_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:otp_text_field/otp_field.dart';
import '../../../components/buttons.dart';
import 'package:otp_text_field/style.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

/*this function is responsbile for confirming that the user who is attempting to sign actually owns the phone number 
attached with the account , if he does then he is navigated to the Today receipt screen  */
class OtpBody extends StatelessWidget {
  OtpBody({Key? key}) : super(key: key);

  OtpFieldController otpController =
      OtpFieldController(); //controller for the field the user will enter the sent otp in
  final CountdownController _controller = CountdownController(
      autoStart:
          true); //controller for the countdown timer that determines wether a new otp can be sent or not

  bool disableResendBtn =
      true; //controls whether a new otp could be sent to the user or not

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: WillPopScope(
        onWillPop: () =>
            onWillPopHelper(), // this function determines whether the user is allowed to back from the screen or not
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity.w,
                height: 50.h,
              ),
              Text(
                "دخل الكود المبعوت في الرسايل",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: redTextAlert,
                ),
              ),
              SizedBox(
                width: double.infinity.w,
                height: 30.h,
              ),
              //////////////////otp text field//////////////////
              Consumer<AuthenticationServices>(
                  builder: (context, authProviderInternal, child) {
                return OTPTextField(
                  controller: otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 50.w,
                  style: TextStyle(fontSize: extraLargeTextSize.sp),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.underline,
                  onChanged: (pin) {
                    authProviderInternal.smsCodeSetter(
                        pin); //if a user enters something, attempts to confirm the sent otp
                  },
                  onCompleted: (_) {},
                );
              }),

              Padding(
                padding: const EdgeInsets.only(top: 15, right: 20).r,
                child: StatefulBuilder(builder: (context, setState) {
                  ///////////////resend otp button and timer/////////////////////
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ////////countdown timer/////////////////
                      Countdown(
                        controller: _controller,
                        seconds: 60, //amount of time the counter wil count down
                        build: (BuildContext context, double time) {
                          ////text displaying the time in the counter, it changes color based on whether the user is allowed to resend oto now or not
                          return Text(
                            getTimeStringFromDouble(time),
                            style: TextStyle(
                                color: disableResendBtn
                                    ? darkRed
                                    : lightGreyReceiptBG,
                                fontSize: commonTextSize.sp,
                                fontWeight: commonTextWeight),
                          );
                        },
                        //refresh interval of the text of the counter
                        interval: const Duration(milliseconds: 60),
                        onFinished: () {
                          setState(() {
                            disableResendBtn =
                                false; //when the counter finishes counting, the user is then allowed to press the resend otp button
                          });
                        },
                      ),
                      SizedBox(width: 20.w),
                      //resend otp button
                      IgnorePointer(
                          ignoring: disableResendBtn,
                          child: InkWell(
                              onTap: () async {
                                //if resend otp button is pressed, then disable it again and restart the counter and authentication service
                                setState(() {
                                  disableResendBtn = true;
                                });
                                Provider.of<AuthenticationServices>(context,
                                        listen: false)
                                    .startAuthProcess();
                                //verifyOTP(context);
                                _controller.restart();
                              },
                              child: Text(
                                "عيد الارسال",
                                style: TextStyle(
                                    color: disableResendBtn
                                        ? lightGreyReceiptBG
                                        : darkRed,
                                    fontSize: commonTextSize.sp),
                              ))),
                    ],
                  );
                }),
              ),
              SizedBox(
                width: double.infinity.w,
                height: 30.h,
              ),
              /////////////////confirm button//////////
              DefaultButton(
                  text: "تأكيد",
                  onPressed: () async {
                    verifyOTP(
                        context); //responsible for verifying that the otp the user entered is the one sent to him
                  }),
            ],
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  ///shows an error message to the user if sign in fails
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

  //resposbile for verifying the otp the user has entered
  verifyOTP(BuildContext context) async {
    //authentication servces provider is responsible for this
    AuthenticationServices provider =
        Provider.of<AuthenticationServices>(context, listen: false);

    if (provider.isAuthenticationVerified == false) {
      //if the user is not already authenticated
      try {
        await provider.checkForOTPVerificationAndStoreData().then((_) {
          //check the otp sent to the user and attempt to verify it
          if (provider.isAuthenticationVerified == true) {
            // if otp is verified successfully
            _controller.pause();
            Navigator.of(context).pushNamedAndRemoveUntil(
                provider.getNavigateToPage(), (Route<dynamic> route) => false); //navigates to today page
          } else {
            String errorMsg =
                'حاولت تسجل حسابك كتير في وقت قصير ... جرب تاني بعد ساعة'; // default error message to display if sign in fails
            _showErrorDialog(context, errorMsg);
          }
        }).catchError((e) {
          String errorMsg =
              'في حاجة غلط اتأكد من اتصال النت او سجل في وقت تاني'; //default error message to dislay if an exception is thrown by authentication
          if (e.toString().contains(
              'We have blocked all requests from this device due to unusual activity. Try again later.')) {
            errorMsg =
                'حاولت تسجل حسابك كتير في وقت قصير ... جرب تاني بعد ساعة'; //special error message to display if authentication throws an exception for attempting to sign in multiple times
          }
          _showErrorDialog(context, errorMsg);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          provider.getNavigateToPage(), (Route<dynamic> route) => false); //if the user is already authenticated then navigate to today page
    }
  }

  Future<bool> onWillPopHelper() async {
    //used to prevent the user from backing out from the screen if the counter is counting down
    return !disableResendBtn;
  }
}
