import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants.dart';
import '../../BusinessLogic/view_models/contactUs_view_model.dart';
import '../../components/returnAppBar.dart';

/*this screen is responsible for showing the user how to contact us , it shows the user our company's :
1- email
2- first phone number
3- second phone number
4- facebook account link through a button
5- whatsapp chat through a button

 */
class ContactUsScreen extends StatefulWidget {
  ContactUsScreen({Key? key}) : super(key: key);
  //route name for navigator
  static String routeName = "/ContactUs";
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String whatsappURlAndroidLeading = "whatsapp://send?phone=";
  //first part of url used to launch in whatsapp app
  final String phoneUrlAndroidLeading = 'tel:';
  final String facebookLink = 'https://www.facebook.com/maligaliapp';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: purplePrimaryColor,
        appBar: ReturnAppBar(
          key: null,
          pageTitle: "تواصل معنا",
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
        body: FutureBuilder<Map<String, String>>(
            future: ContactUsViewModel().getContactDataFromFirebase(),
            builder: (context, contactUsDataSnapshot) {
              if (contactUsDataSnapshot.connectionState ==
                  ConnectionState.done) {
                if (contactUsDataSnapshot.hasError) {
                  if (kDebugMode) {
                    print(contactUsDataSnapshot.error);
                  }
                  return Center(
                    child: Text(
                      "حصل مشكلة في تحميل الصفحة \n عيد فتح البرنامج",
                      style: TextStyle(
                          fontSize: commonTextSize.sp,
                          fontWeight: commonTextWeight),
                    ),
                  );
                } else if (contactUsDataSnapshot.hasData) {
                  Map<String, String> ContactUsData =
                      contactUsDataSnapshot.data!;
                  String? email = ContactUsData["email"];
                  String? phone1 = ContactUsData["phoneNo1"];
                  String? phone2 = ContactUsData["phoneNo2"];
                  String? whatsapp = ContactUsData["whatsapp"];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12).r,
                          child: Text(
                            " : للتواصل",
                            style: TextStyle(
                                fontSize: mainFontSize.sp, color: textWhite),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        ////////////////////////////email button////////////////////////
                        Padding(
                          padding: const EdgeInsets.only(right: 55).r,
                          child: SizedBox(
                            width: 300.w,
                            child: Column(
                              children: [
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        email!,
                                        style: TextStyle(
                                            fontSize: subFontSize.sp,
                                            color: textWhite),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                        height: 5.h,
                                      ),
                                      Icon(
                                        Icons.mail,
                                        color: white2BG,
                                        size: 35.w,
                                      ),
                                    ],
                                  ),
                                  onTap: () => launchPath(
                                      "mailto:$email"), //opening an email client with the company mail
                                ),
                                ///////////////////////////first phone number button//////////////////////////////
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        phone1!,
                                        style: TextStyle(
                                            fontSize: subFontSize.sp,
                                            color: textWhite),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                        height: 5.h,
                                      ),
                                      Icon(
                                        Icons.phone,
                                        color: white2BG,
                                        size: 35.w,
                                      ),
                                    ],
                                  ),
                                  onTap: () => launchPath(phoneUrlAndroidLeading +
                                      phone1), //opening phone dialar with companies phone
                                ),
                                ////////////////second phone number button//////////////////////////////////
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        phone2!,
                                        style: TextStyle(
                                            fontSize: subFontSize.sp,
                                            color: textWhite),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                        height: 5.h,
                                      ),
                                      Icon(
                                        Icons.phone,
                                        color: white2BG,
                                        size: 35.w,
                                      ),
                                    ],
                                  ),
                                  onTap: () => launchPath(phoneUrlAndroidLeading +
                                      phone2), //opening phone dialar with companies phone
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50).r,
                          child: Divider(
                            color: textWhite,
                            thickness: 1.w,
                            height: 80.h,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///////////////////////////facebook button///////////////////////////
                            IconButton(
                              icon: Icon(
                                Icons.facebook,
                                color: white2BG,
                                size: 50.w,
                              ),
                              onPressed: () => launchPath(
                                  facebookLink), //opening facebook app to our facebook page
                            ),
                            SizedBox(
                              width: 50.w,
                              height: 50.h,
                            ),
                            //////////////////////////////whatsapp button//////////////////////////////
                            IconButton(
                              icon: FaIcon(FontAwesomeIcons.whatsapp,
                                  color: white2BG, size: 50.w),
                              onPressed: () => launchPath(
                                  whatsappURlAndroidLeading +
                                      whatsapp!), //opening whatsapp app with a chat with our whatsapp
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}

/*this function takes in a link, it then checks if that link can be openned using any app on our device , for example a facebook reference should be opened with facebook
, a whatsapp reference with whatsapp, a phone number with the mobile's dialar, etc

so depending on which option the user clicks on as a way of contacting us, we pass something different to this function */
Future<void> launchPath(String path) async {
  if (await canLaunchUrl(Uri.parse(path))) {
    await launchUrl(Uri.parse(path));
  } //launch it if we can
}
