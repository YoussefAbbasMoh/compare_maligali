import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../Models/fawry_payment_model.dart';
import '../Services/FireBaseServices/create_and_delete_db_services.dart';
import '../utils/enums.dart';
import '../utils/flutter_secure_storage_functions.dart';
import '../utils/globalSnackBar.dart';
import 'package:intl/intl.dart';


class SubscriptionsViewModel {

  Future<int> getFreeTrailDataFromFirebase()async{
    String freeTrialCount = "1";
    try{
      freeTrialCount = await FirebaseFirestore.instance
          .collection('appController')
          .doc("freeTrials").get().then((value) => value.get("count"));
    }
    catch(e){
      print(e);
    }
    return int.parse(freeTrialCount);
  }


  Future<List<Map<String, String>>> getSubscriptionDataFromFirebase()async{
    var docSnapshot = await FirebaseFirestore.instance
        .collection('appController')
        .doc("bundles").get();
    Map<String, dynamic> data = docSnapshot.data()!;
    int count = int.parse(data["bundlesCount"]);


    List <Map<String,String>> subscriptionBundlesData = [];

    String bundleName;

    for(int i=1; i<=count;i++){
      bundleName = ("bundle"+i.toString());
      subscriptionBundlesData.add(
          {
            "bundleName": data[bundleName]["bundleName"],
            "bundleCost": data[bundleName]["bundleCost"],
            "numberOfMonths": data[bundleName]["numberOfMonths"],
            "bundleDiscount": data[bundleName]["bundleDiscount"],

          }
      );
    }
    return subscriptionBundlesData;

  }

  // ---------------------------------------------------------------------------

  setSubscriptionDataInMemoryOnSignIn() async {
    DocumentReference<Object?> userRef = CreateAndDeleteDBServices().userDBReference();

    String subscriptionStatus = await userRef
        .get()
        .then((value) => value
        .get("subscriptionStatus"));


    if(subscriptionStatus == "SubscriptionState.UNSUBSCRIBED"){
      await setSubscriptionStatusToUnSubscribed();
    }
    else if (subscriptionStatus == "SubscriptionState.FREE_TRIAL"){
      await setSubscriptionStatusToFreeTrial();
      await setFreeTrialReceiptsCount();
    }
    else{
      String subEndDate = await userRef
          .get()
          .then((value) => value
          .get("subEndDate"));


      // if we have reached this step, then the subEndDate field exists in the
      // database and it holds value

      DateTime dateTime = DateFormat('yyyy-MM-dd').parse(subEndDate);
      DateTime now = DateTime.now();
      bool isEndDayPassed = dateTime.isBefore(now);
      if(isEndDayPassed == true){
        // subEndDay has passed
        await setSubscriptionStatusToUnSubscribed();
        await userRef.update({
          "subscriptionStatus": "SubscriptionState.UNSUBSCRIBED",
          "subEndDate":FieldValue.delete()});
      }
      else{
        await setSubscriptionStatusToSubscribed();
      }
    }
  }

  checkSubscriptionStateOnAppInitialize(BuildContext context) async {
    DocumentReference<Object?> userRef = CreateAndDeleteDBServices().userDBReference();
    String? subscriptionRes = await fetchSubscriptionStatus();

    if(subscriptionRes == "SUBSCRIBED") { // first check for the subscription state in memory
      // if field in memory is subscribed
      try {
        // second step is to check if the subscription end date is found in database
        String subEndDate = await userRef
            .get(const GetOptions(source: Source.cache))
            .then((value) => value
            .get("subEndDate")); // will be checking in cache first

        if (subEndDate.isEmpty) { // then check in firebase if the field is not found in cache
          subEndDate =
          await userRef.get().then((value) => value.get("subEndDate"));
        }

        // if we have reached this step, then the subEndDate field exists in the
        // database and it holds value
        DateTime dateTime = DateFormat('yyyy-MM-dd').parse(subEndDate);
        DateTime now = DateTime.now();

        bool isEndDayPassed = dateTime.isBefore(now);
        if(isEndDayPassed == true){
          // subEndDay has passed
          await setSubscriptionStatusToUnSubscribed();
          await userRef.update({
            "subscriptionStatus": "SubscriptionState.UNSUBSCRIBED",
            "subEndDate":FieldValue.delete()});
        }
        else{
          // subEndDay has not passed yet - no action shall be taken
        }
      } catch (e) {
        // if we entered in the catch, then the subscription end date is not
        // found in the firebase while the subscription state is subscribed
        // so there must be an error in storing the data

        String subStatusFB = await userRef.get().then((value) => value.get("subscriptionStatus"));

        if(subStatusFB == "SubscriptionState.UNSUBSCRIBED"){
          await setSubscriptionStatusToUnSubscribed();
        }
        else if(subStatusFB == "SubscriptionState.FREE_TRIAL"){

          FawryPayCheckPaymentResults paymentCheckResult = await PaymentModel(context).checkPayment();
          if(paymentCheckResult == FawryPayCheckPaymentResults.CONNECTION_FAILURE){
            showPopupDialog(context, title:"خطأ في الاتصال", text:"حصل مشكلة في الاتصال بخدمة فوري. جرب تعيد فتح البرنامج او راجع اتصالك بالانترنت", buttonText: "خروج");
          }
          else if(paymentCheckResult == FawryPayCheckPaymentResults.NO_MERCHANT_REF_NUMBER){
            await setSubscriptionStatusToFreeTrial();

          }

        }
        else{
          FawryPayCheckPaymentResults paymentCheckResult = await PaymentModel(context).checkPayment();

          if(paymentCheckResult == FawryPayCheckPaymentResults.SUBSCRIBED){
            // update the data directly inside the checkPayment function
          }
          else if (paymentCheckResult == FawryPayCheckPaymentResults.UNSUBSCRIBED){
            // update the data and set to unsubscribed
            await setSubscriptionStatusToUnSubscribed();
            await userRef.update({
              "subscriptionStatus": "SubscriptionState.UNSUBSCRIBED"});
          }
          else if(paymentCheckResult == FawryPayCheckPaymentResults.CONNECTION_FAILURE){
            showPopupDialog(context, title:"خطأ في الاتصال", text:"حصل مشكلة في الاتصال بخدمة فوري. جرب تعيد فتح البرنامج او راجع اتصالك بالانترنت", buttonText: "خروج");
          }
          else if(paymentCheckResult == FawryPayCheckPaymentResults.NO_MERCHANT_REF_NUMBER){
            showPopupDialog(context,
                title: "مشكلة في بيانات الإشتراك",
                text: 'في مشكلة في بيانات الاشتراك. تواصل مع خدمة العملاء لحل المشكلة \n رقم خدمة العملاء: '"01033245173",
                buttonText: "خروج",
                exitApp: true) ;
          }
        }
      }
    }
    else if(subscriptionRes == null){
      // if the field is not yet created in memory, it must be created and set to FREE_TRIAL
      await setSubscriptionStatusToFreeTrial();
    }
    else{
      // if field in memory is unsubscribed or free trial
      FawryPayCheckPaymentResults paymentCheckResult = await PaymentModel(context).checkPayment();

      // if(paymentCheckResult == FawryPayCheckPaymentResults.SUBSCRIBED){
      //   // update the data directly inside the checkPayment function
      // }
      // else if (paymentCheckResult == FawryPayCheckPaymentResults.UNSUBSCRIBED){
      //   // update the data and set to unsubscribed
      // }
      if(paymentCheckResult == FawryPayCheckPaymentResults.CONNECTION_FAILURE){
        showPopupDialog(context, title:"خطأ في الاتصال", text:"حصل مشكلة في الاتصال بخدمة فوري. جرب تعيد فتح البرنامج او راجع اتصالك بالانترنت", buttonText: "خروج");
      }
      else if(paymentCheckResult == FawryPayCheckPaymentResults.NO_MERCHANT_REF_NUMBER){

        await setSubscriptionDataInMemoryOnSignIn();

        // showPopupDialog(context,
        //     title: "مشكلة في بيانات الإشتراك",
        //     text: '01033245173في مشكلة في بيانات الاشتراك. تواصل مع خدمة العملاء لحل المشكلة \n رقم خدمة العملاء:',
        //     buttonText: "خروج",
        //     exitApp: true);
      }
    }
  }

  initializeFreeTrialSubscription() async {
    await setFreeTrialReceiptsCount();
    await setSubscriptionStatusToFreeTrial();
  }

  endFreeTrialSubscriptions() async {
    DocumentReference<Object?> userRef = CreateAndDeleteDBServices().userDBReference();

    await clearFreeTrialReceiptsCount();
    await setSubscriptionStatusToUnSubscribed();

    try {
      // performed as 2 steps because in some cases the subEndDate could not be stored in the firebase (deleted)
      await userRef.update({
        "subscriptionStatus": "SubscriptionState.UNSUBSCRIBED"});

      await userRef.update({
        "subEndDate": FieldValue.delete()});
    }
    catch(e){
      print(e);
    }
  }

  Future<bool> allowReceiptUsage() async {
    String subscriptionStorageResult = await fetchSubscriptionStatus()?? "UNSUBSCRIBED";

    if(subscriptionStorageResult == "UNSUBSCRIBED"){
      return false;
    }
    else if(subscriptionStorageResult == "SUBSCRIBED"){
      return true;
    }
    else{
      // result is free trial
      int remainingReceipts = await fetchRemainingFreeTrialReceipts();

      if(remainingReceipts > 0 ){
        return true;
      }
      else{
        await endFreeTrialSubscriptions();
        return false;
      }
    }
  }

  Future<String> getSubscriptionTextToDisplay() async {
    String subscriptionStorageResult = await fetchSubscriptionStatus()?? "UNSUBSCRIBED";

    if(subscriptionStorageResult == "UNSUBSCRIBED"){
      return "انت غير مشترك في باقة";
    }
    else if(subscriptionStorageResult == "SUBSCRIBED"){
      DocumentReference<Object?> ref = CreateAndDeleteDBServices().userDBReference();
      String subEndDate;
      String subscriptionBundle;
      try{
        subEndDate = await ref.get(const GetOptions(source: Source.cache)).then((value) => value.get("subEndDate"));
        subscriptionBundle = await ref.get(const GetOptions(source: Source.cache)).then((value) => value.get("subscriptionStatus"));
        subscriptionBundle = subscriptionBundle.split("_")[1];
      }
      catch(e){
        try{
          subEndDate = await ref.get().then((value) => value.get("subEndDate"));
          subscriptionBundle = await ref.get().then((value) => value.get("subscriptionStatus"));
          subscriptionBundle = subscriptionBundle.split("_")[1];
        }
        catch(e){
          print("not found in firebase");
          print(e);
          subEndDate = "-";
          subscriptionBundle = "??";
        }
      }
      return "انت مشترك في باقة رقم: "+subscriptionBundle+"\n ميعاد التجديد: "+ subEndDate;
      return "انت مشترك في باقة\n ميعاد التجديد: "+subEndDate;
    }
    else{
      // result is free trial
      int remainingReceipts = await fetchRemainingFreeTrialReceipts();

      if(remainingReceipts > 0 ){
        return "باقي من فواتير التجربة: " + remainingReceipts.toString();
      }
      else{
        //await endFreeTrialSubscriptions();
        return "انهيت فواتير التجربة - محتاج تشترك في باقة ";
      }
    }
  }
}