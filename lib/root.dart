import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:maligali/Screens/authentication/login_or_signup/login_or_signup_screen.dart';
import 'package:maligali/Screens/Receipts/home_screen.dart';
import 'package:provider/provider.dart';
import 'BusinessLogic/view_models/authentication_view_models/authentication_view_model.dart';
import 'BusinessLogic/utils/flutter_secure_storage_functions.dart';
import 'BusinessLogic/view_models/receipts_view_models/today_view_models/start_day_provider.dart';
import 'BusinessLogic/view_models/subscriptions_view_model.dart';

class Root extends StatefulWidget {
  static String routeName = "/Root";

  const Root({Key? key}) : super(key: key);

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  User? user;

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkForUserAuthenticationPersistence();
    return currentPage;
  }

  Widget currentPage =
  const Scaffold(body: Center(child: CircularProgressIndicator()));
  AuthenticationServices? _authClass;

  checkDayState() async {
    bool? res = await StartDayProvider.getCurrentDayState();

    if (res == null) {
      await StartDayProvider.updateDayStateInStorage();
    } else {
      await StartDayProvider.setDayStarted(res);
    }
  }


  void checkLogin() async {
    await checkDayState();

    _authClass = Provider.of<AuthenticationServices>(context, listen: false);
    String? token = await getToken();

    if (token != null) {
      await SubscriptionsViewModel().checkSubscriptionStateOnAppInitialize(context);
      setState(() {
        currentPage = const HomeScreen();

      });


    } else {
      setState(() {
        currentPage = const LogInOrSignUpScreen();
      });
    }
  }

  checkForUserAuthenticationPersistence() async {
    FirebaseAuth.instance
        .authStateChanges().listen((user) async {
          if(user != null){
            await updateUserTokenInDatabase();
          }
    });
  }


  updateUserTokenInDatabase() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

    String? userToken = await FirebaseMessaging.instance.getToken();

    DocumentReference<Map<String, dynamic>> docRef = _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid);
    try {
      String tokenFetched = await docRef.get().then((value) =>
          value.get("userToken"));

      if(tokenFetched != userToken!){
        await
        docRef.update(
            {'userToken':userToken});
      }
    }
    catch(e){
      await
      docRef.update(
          {'userToken':userToken! });
    }
    print("done");
  }

}