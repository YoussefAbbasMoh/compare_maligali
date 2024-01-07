import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:maligali/BusinessLogic/utils/globalSnackBar.dart';
import '../../utils/flutter_secure_storage_functions.dart';
import '../../../Screens/authentication/free_trial/free_trail_Screen.dart';
import '../../../Screens/Receipts/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Models/store_owner_model.dart';
import 'package:flutter/foundation.dart';
import '../../utils/time_and_date_utils.dart';
import '../subscriptions_view_model.dart';

class AuthenticationServices extends ChangeNotifier {
  bool _isSourceSignIn = true;
  String _navigateToPage = HomeScreen.routeName;

  String getNavigateToPage() => _navigateToPage;

  authenticationProviderInit({bool isSourceSignIn = true}) {
    _isSourceSignIn = isSourceSignIn;

    if (_isSourceSignIn == false) {
      _navigateToPage = FreeTrailScreen.routeName;
    } else {
      _navigateToPage = HomeScreen.routeName;
    }
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth auth() => _auth;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  FirebaseFirestore fireStore() => _fireStore;

  static User? _user;
  void setUser(User? currentUser) {
    _user = currentUser;
    notifyListeners();
  }

  get user => _user;
  String _verificationOTPCode = "";
  String _smsCode = "";
  void smsCodeSetter(String pin) => _smsCode = pin;

  bool isAuthenticationVerified = false;

  // User Data for Register
  String _nameHolder = "";
  String _numberHolder = "";
  String _shopNameHolder = "";
  String _deliveryManCountHolder = "";
  String _countryCode = "+2";
  String _shopTypeHolder = "";
  String _shopSizeHolder = "";
  String _shopGPSLocation = "";
  String _promoCode = "";
  String _dateHolder = "";
  bool _legalStatement = false;

  setShopGPSLocation({required String lng, required String lat}) {
    _shopGPSLocation = gatherLogLatForShopGPSLocation(lng: lng, lat: lat);
    notifyListeners();
  }

  List<String> splitLogLatForShopGPSLocation(String shopGPSLocation) {
    return shopGPSLocation.split('-');
  }

  String gatherLogLatForShopGPSLocation(
      {required String lng, required String lat}) {
    return lat + "-" + lng;
  }

  // Setters for the data and their helper functions

  _checkForShopTypeHolder(String shopTypeHolder) {
    return (shopTypeHolder == "") ? 'محل بقالة' : shopTypeHolder;
  }

  _checkForShopSizeHolder(String shopSizeHolder) {
    return (shopSizeHolder == "") ? 'محل صغير/ كشك' : shopSizeHolder;
  }

  setRegisterDataHolders(
      String userName,
      String phoneNumber,
      String shopName,
      String deliveryManCount,
      String shopType,
      String shopSize,
      String countryCode,
      String promocode,
      String legalStatement,
      ) {
    _nameHolder = userName;
    _legalStatement = (legalStatement == "ايوا") ? true : false;
    _promoCode = promocode;
    _numberHolder = _addPhoneNumberToCountryCode(phoneNumber, countryCode);
    _shopNameHolder = shopName;
    _deliveryManCountHolder = deliveryManCount;
    _shopTypeHolder = _checkForShopTypeHolder(shopType);
    _shopSizeHolder = _checkForShopSizeHolder(shopSize);
    _dateHolder = getNowDate();
  }

  setSignInDataHolder(String phoneNumber, String countryCode) {
    _numberHolder = _addPhoneNumberToCountryCode(phoneNumber, countryCode);
  }

  _setCountryCode(String countryCode) {
    _countryCode = countryCode;
  }

  _checkForFirstZero(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return phoneNumber;
    } else {
      return phoneNumber.substring(1);
    }
  }

  String _addPhoneNumberToCountryCode(String phoneNumber, String countryCode) {
    _setCountryCode(countryCode);
    phoneNumber = _checkForFirstZero(phoneNumber);

    return countryCode + phoneNumber;
  }

  _checkForPhoneNumberExistence() async {
    bool phoneNumberExist = false;
    await _fireStore
        .collection('users')
        .where('ownerNumber', isEqualTo: _numberHolder)
        .get()
        .then((result) {
      if (result.docs.isNotEmpty) {
        phoneNumberExist = true;
      }
    });

    return phoneNumberExist;
  }

  Future<bool> checkForCorrectAuthenticationSource() async {
    // this function is responsible for checking if new user has registered
    // before or old user is not re-registering by mistake

    bool isAuthenticationSourceCorrect = true;

    if (_isSourceSignIn == false) {
      bool phoneNumberExist = await _checkForPhoneNumberExistence();
      if (phoneNumberExist == true) {
        //should sign in instead
        isAuthenticationSourceCorrect = false;
      }
    } else {
      bool phoneNumberExist = await _checkForPhoneNumberExistence();
      if (phoneNumberExist == false) {
        // should register instead
        isAuthenticationSourceCorrect = false;
      }
    }
    return isAuthenticationSourceCorrect;
  }

  Future<void> startAuthProcess() async {
    await _authenticateWithPhone();
    setUser(_auth.currentUser);
  }

  Future<void> _authenticateWithPhone() async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: _numberHolder,
          verificationCompleted: _verificationCompleteSelectedFunction,
          verificationFailed: _verificationFailed,
          codeSent: _codeSent,
          codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
          timeout: const Duration(seconds: 55));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    ;
  }

  Future<void> _verificationCompleteSelectedFunction(
      PhoneAuthCredential authCredential) async {
    if (_isSourceSignIn == true) {
      return await _signInVerificationComplete(authCredential);
    } else {
      return await _registerVerificationComplete(authCredential);
    }
  }

  updateUserTokenInDatabase() async {
    print(_auth.currentUser?.uid);
    String? userToken = await FirebaseMessaging.instance.getToken();
    print(userToken);


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

  Future<void> _signInVerificationComplete(
      PhoneAuthCredential authCredential) async {
    await _auth.signInWithCredential(authCredential).then<void>((user) async => {
      if (user.user != null)
        {
          print(1),
          await updateUserTokenInDatabase(),
          print(2),
          await _setStoreOwnerObjByFetchingUserData(),
          await storeTokenAndData(user.user!.uid, _numberHolder),
          await SubscriptionsViewModel().setSubscriptionDataInMemoryOnSignIn(),
        }
    });
    isAuthenticationVerified = true;
    notifyListeners();
  }

  _setStoreOwnerObjByFetchingUserData() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      Future<DocumentSnapshot<Map<String, dynamic>>> _userCollection =
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      var querySnapshot = await _userCollection;

      await StoreOwner().updateOwnerData(
          uidUpdated: currentUser.uid,
          storeNameUpdated: querySnapshot.get("shopName"),
          shopGPSLocationUpdated: querySnapshot.get("shopGPSLocation"),
          storeTypeUpdated: querySnapshot.get("shopType"),
          storeSizeUpdated: querySnapshot.get("shopSize"),
          storeOwnerNameUpdated: querySnapshot.get("ownerName"),
          storeOwnerNumberUpdated: querySnapshot.get("ownerNumber"),
          deliveryManCountUpdated: querySnapshot.get("deliveryManCount"),
          legalStatementUpdated: querySnapshot.get("legalStatement"));
    }
  }

  // Register Verification Complete Function

  Future<void> _registerVerificationComplete(
      PhoneAuthCredential authCredential) async {
    await _auth.signInWithCredential(authCredential).then((user) async => {
      if (user.user != null)
        {
          await _saveUserInfoInDB(),
          await storeTokenAndData(user.user!.uid, _numberHolder),
          await _setStoreOwnerObjData(),
        }
    });
    isAuthenticationVerified = true;
    notifyListeners();
  }

  // RegisterVerificationComplete helper functions
  _saveUserInfoInDB() async {
    String? userToken = await FirebaseMessaging.instance.getToken();
    await _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .set(
      {
        'userToken': userToken,
        'ownerName': _nameHolder.trim(),
        'date': _dateHolder,
        'ownerNumber': _numberHolder.trim(),
        'shopName': _shopNameHolder.trim(),
        'shopType': _shopTypeHolder,
        'deliveryManCount': _deliveryManCountHolder.trim(),
        "shopGPSLocation": _shopGPSLocation,
        'shopSize': _shopSizeHolder,
        "shopRating": "0",
        "subscriptionStatus": "SubscriptionState.FREE_TRIAL",
        "promoCode": _promoCode,
        "legalStatement": _legalStatement,
      },
    ) //SetOptions(merge: true))
        .then((value) => {displaySnackBar(text:"تم حفظ بيانات الحساب بنجاح")})
        .catchError((onError) {
      displaySnackBar(text:"حصل مشكلة في حفظ بيانات الحساب");
      debugPrint('Error saving user to db.' + onError.toString());
    });
  }

  _setStoreOwnerObjData() async {
    // this function is used to create an object for the user account data to
    // handle user data manipulation throughout the app
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {

      await SubscriptionsViewModel().initializeFreeTrialSubscription(); // saves free trial subscription data in phone storage

      await StoreOwner().updateOwnerData(
          legalStatementUpdated: _legalStatement,
          storeOwnerNumberUpdated: _numberHolder,
          storeNameUpdated: _shopNameHolder,
          storeSizeUpdated: _shopSizeHolder,
          shopGPSLocationUpdated: _shopGPSLocation,
          uidUpdated: currentUser.uid,
          storeOwnerNameUpdated: _nameHolder,
          deliveryManCountUpdated: _deliveryManCountHolder,
          storeTypeUpdated: _shopTypeHolder);
      //bundleReceiptsCountUpdated: "100",
      //subscriptionStatusUpdated: SubscriptionState.FREE_TRIAL.toString());
    }
  }

  // Common verification helper functions -----------------------------------------

  void _verificationFailed(FirebaseAuthException error) {
    // to check for error codes and their messages refer to this link: https://cloud.google.com/identity-platform/docs/error-codes
    //TODO: a displaySnackBar lkol error message عشان صحتي لا تسمح عايزة انام
    switch (error.code) {
      case "ERROR_INVALID_PHONE_NUMBER":
        {}
        break;
      case "ERROR_MISSING_PHONE_NUMBER":
        {}
        break;
      case "ERROR_MISSING_VERIFICATION_CODE":
        {}
        break;
      case "ERROR_INVALID_VERIFICATION_CODE":
        {}
        break;
      case "ERROR_MISSING_VERIFICATION_ID":
        {}
        break;
      case "ERROR_INVALID_VERIFICATION_ID":
        {}
        break;
      case "ERROR_SESSION_EXPIRED":
        {}
        break;
      case "ERROR_QUOTA_EXCEEDED":
        {}
        break;
      case "ERROR_APP_NOT_VERIFIED":
        {}
        break;
      case "auth/captcha-check-failed":
        {}
        break;
    }
  }

  _codeSent(String verificationId, int? forceResendingToken) {
    _verificationOTPCode = verificationId;
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _verificationOTPCode = verificationId;
  }

  // Sign out related functions ------------------------------------------------
  Future<void> signOut() async {
    await clearStorageAttributes();
    await _clearUserData();
    await clearTokenAndData();
    //await _fireStore.clearPersistence();
    return await _auth.signOut();
  }

  Future<void> _clearUserData() async {
    await StoreOwner().updateOwnerData(
      uidUpdated: " ",
      storeNameUpdated: " ",
      shopGPSLocationUpdated: " ",
      storeTypeUpdated: " ",
      storeSizeUpdated: " ",
      storeOwnerNameUpdated: " ",
      storeOwnerNumberUpdated: " ",
      //bundleReceiptsCountUpdated: " ",
      //subscriptionStatusUpdated: " ",
      deliveryManCountUpdated: " ",
      legalStatementUpdated: false,
    );
  }

  Future<UserCredential> _verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationOTPCode, smsCode: _smsCode);
    return _auth.signInWithCredential(credential);
  }

  checkForOTPVerificationAndStoreData() async {
    try {
      await _verifyOTP()
          .then((value) async => {
        if (value.user != null)
          {
            if (_isSourceSignIn == true)
              {
                await updateUserTokenInDatabase(), // messaging service
                await _setStoreOwnerObjByFetchingUserData(), // Fetch user data from fb and create the storeOwnerModel
                await storeTokenAndData(value.user!.uid, _numberHolder), // store user uid, phone number in memory
                await SubscriptionsViewModel().setSubscriptionDataInMemoryOnSignIn(), // fetch subscription state

              }
            else
              {
                await _saveUserInfoInDB(),
                await storeTokenAndData(value.user!.uid, _numberHolder),
                await _setStoreOwnerObjData(),

              },
            isAuthenticationVerified = true,
            setUser(value.user),
            notifyListeners(),
          }
      });
      //
    } catch (e) {
      print("l error l tayeh is: ");
      if (kDebugMode) {
        print(e);
      }
    }
  }
}