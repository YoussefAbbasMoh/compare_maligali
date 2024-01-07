import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../BusinessLogic/view_models/subscriptions_view_model.dart';
import '../../components/noInternetPopup.dart';
import '../../scaffoldComponents/GeneralScaffold.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'previous/previousDaysSummaryBody.dart';
import 'common_components/custom_app_bar.dart';
import 'today/today_body.dart';

/* entry point for application
contains a tab bar that allows the user to switch between two main bodies which are
today_body and previous_body
 */
class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen"; //route name for navigator
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController; //controller for tab bar  used to switch between bodies
  late StreamSubscription subscription; //used to track internent connection
  var isDeviceConnected = false; //used to track internent connection
  bool isAlertSet =
      false; //used to decide if we should alert the user about internent connection change

  @override
  void initState() {
    getConnectivity(); //used to track and check internet connection
    _tabController = TabController(length: 2, vsync: this); //create tab bar
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GeneralScaffold(
        curentPage: HomeScreen.routeName,
        backGroundColor: white2BG,
        appBar: CustomAppBar(
          key: null,
          pageTitle: "مالي جالي",
          bottom: DefaultTabController(
            length: 2,
            //////////////////tab bar used to switch between bodies//////////////
            child: TabBar(
              controller: _tabController,
              unselectedLabelColor: purplePrimaryColor,
              labelColor: purplePrimaryColor,
              indicatorColor: purplePrimaryColor,
              labelStyle: TextStyle(
                  fontSize: commonTextSize.sp,
                  fontWeight: commonTextWeight), //For Selected tab
              unselectedLabelStyle: TextStyle(
                  fontSize: commonTextSize.sp, fontWeight: commonTextWeight),
              indicatorSize: TabBarIndicatorSize.label,

              tabs: [
                SizedBox(
                    height: 40.h,
                    child:
                        const Tab(text: 'النهاردة')), ///////////first tab title
                SizedBox(
                    height: 40.h,
                    child: const Tab(
                        text: 'ملخص الشهر')), /////////////second tab title
              ],
            ),
          ),
          preferredSize: Size.fromHeight(65.h),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            SingleChildScrollView(
                child: TodayBody()), ///////////first tab actual code body
            SingleChildScrollView(
                child:
                    PreviousDaysSummaryBody()), ///////////second tab actual code body
          ],
        ),
      ),
    ]);
  }

  /////////////////////////////////////
  //used to check for and notify the user that internet connection has been lost
  getConnectivity() => subscription =
          Connectivity() //create a singleton instance (meaning no other instance of this class can exist in the app) that listens to changes in internet connection
              .onConnectivityChanged
              .listen((ConnectivityResult result) async {
        //if a change in internet connection is detected
        isDeviceConnected = await InternetConnectionChecker()
            .hasConnection; //check if the app can access the internet after the change
        if (!isDeviceConnected && isAlertSet == false) {
          //notify the user if internet is lost and we want to alert him
          showDialogBox(context);

          setState(() => isAlertSet = true);
        }
      });
}

Future<String?> getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? tokenRes = "";
// Listen for token refresh events
  messaging.onTokenRefresh.listen((String? token) {
    print('FCM token refreshed: $token');
    tokenRes = token!;
    // Update the token in your app's storage or server
  });
  tokenRes = await messaging.getToken();
  return tokenRes;
}
