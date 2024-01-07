import 'dart:math';
import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';
import 'package:fawry_sdk/model/launch_customer_model.dart';
import 'package:fawry_sdk/model/launch_merchant_model.dart';
import 'package:fawry_sdk/model/fawry_launch_model.dart';
import 'package:fawry_sdk/model/bill_item.dart';
import 'package:fawry_sdk/fawry_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:maligali/BusinessLogic/utils/globalSnackBar.dart';
import '../Services/FireBaseServices/create_and_delete_db_services.dart';
import '../utils/enums.dart';
import '../utils/flutter_secure_storage_functions.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class PaymentModel {
  // final String _merchantCode = "770000014175";
  // final String _secureKey = "de9b8780-6572-4b62-b68a-475c04e06960";
  final String _merchantCode = "400000012451";
  final String _secureKey = "50aefa5e-d8a2-4cf5-aca7-c1e3d94bbb0d";

  BuildContext? context;

  PaymentModel(BuildContext? ctx){
    context = ctx;
  }

  String generateSignatureSHA255Key(String merchantRefNumber) {
    // Concatenate the merchantCode, merchantRefNumber, and secureKey
    final String signatureContent = '$_merchantCode$merchantRefNumber$_secureKey';

    // Compute the SHA-256 hash of the signature content
    final List<int> signatureBytes = utf8.encode(signatureContent);
    final List<int> hashBytes = sha256.convert(signatureBytes).bytes;
    final String hashHex = hex.encode(hashBytes);

// URL-encode the hash using percent encoding
    final String signature = Uri.encodeFull(hashHex);

    return signature;
  }

  Future<FawryPayCheckPaymentResults> updateSubscriptionDataInDatabase( Map<String, dynamic> responseData) async {
    if(responseData["orderStatus"] == "PAID"){
      await setSubscriptionStatusToSubscribed(); // todo delete the free trial data
      String itemCode = responseData["orderItems"][0]["itemCode"];
      String subscriptionStatus = "SubscriptionState.SUBSCRIBED_"+itemCode;//convertBundleIDToStatus(itemCode).toString();

      String subEndDate;
      if(responseData.containsKey("paymentTime")){
        DateTime subscriptionDate = DateTime.fromMillisecondsSinceEpoch(responseData["paymentTime"]);
        subEndDate = DateFormat('yyyy-MM-dd').format(subscriptionDate.add(Duration(days: int.parse(itemCode)*30)));
      }
      else{
        DateTime today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        subEndDate = DateFormat('yyyy-MM-dd').format(today.add(Duration(days: int.parse(itemCode)*30)));
      }
      await CreateAndDeleteDBServices().userDBReference().update({"subscriptionStatus": subscriptionStatus, "subEndDate":subEndDate}).then((value){
        displaySnackBar(text:"تم تجديد الاشتراك");
      });
      await resetMerchantRefNumb();
      return FawryPayCheckPaymentResults.SUBSCRIBED;
    }
    else{

      String orderStatus = responseData["orderStatus"];
      switch(orderStatus) {
        case 'New':
          showPopupDialog(context!, text: 'لسة مسددش قيمة الاشتراك');
          break;
        case 'CANCELED':
          showPopupDialog(context!, text: 'تم الغاء عملية الاشتراك خلال الدفع ... اعد طلب كود الدف',);
          break;
        case 'EXPIRED':
          showPopupDialog(context!, text: 'انتهت صلاحية الكود... اعد طلب كود الدفع',);
          break;
        case 'FAILED':
          showPopupDialog(context!, text: 'فشلت عملية الإشتراك ... اعد المحاولة',);
          break;
        case 'UNPAID':
          showPopupDialog(context!, text: 'لم يتم الدفع ... تأكد من العملية',);
      }
      return FawryPayCheckPaymentResults.UNSUBSCRIBED;
    }
  }

  Future<FawryPayCheckPaymentResults> checkPayment() async {
    String fawryLink =
        "https://atfawry.com/ECommerceWeb/Fawry/payments/status/v2";
    String? merchantRefNumber = await fetchMerchantRefNumb();

    if (merchantRefNumber != null) {
      String signature = generateSignatureSHA255Key(merchantRefNumber);
      String fullLink = fawryLink +
          "?" +
          "merchantCode=" +
          _merchantCode +
          "&" +
          "merchantRefNumber=" +
          merchantRefNumber +
          "&" +
          "signature=" +
          signature;

      final response = await http.get(
        Uri.parse(fullLink),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode < 300) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return await updateSubscriptionDataInDatabase(responseData);

      } else {
        if (kDebugMode) {
          print('Failed to get transaction response data: ${response.statusCode}');
        }
        return FawryPayCheckPaymentResults.CONNECTION_FAILURE;
      }
    }
    else{
      if (kDebugMode) {
        print("No merchantRefNumber stored in memory :)");
      }
      return FawryPayCheckPaymentResults.NO_MERCHANT_REF_NUMBER;
    }
  }





  List<BillItem> createBillItem(Map<String, String> bundleMap) {
    BillItem billItem = BillItem(
        itemId: bundleMap["bundleName"]![bundleMap["bundleName"]!.length-1].toString() ?? "1",
        quantity: 1,
        price: double.tryParse(bundleMap["bundleCost"]!.split(" ")[0]) ?? 180.0,
        description:
        'للاستمتاع بخدمات التطبيق توجه لاقرب ماكينة فوري لدفع قيمة الاشتراك'); //TODO: add description
    List<BillItem> chargeItems = [billItem];
    return chargeItems;
  }

  LaunchCustomerModel createLaunchCustomerModel() {
    String customerName =
        StoreOwner.storeOwnerName + " عن صاحبه " + StoreOwner.storeName;
    LaunchCustomerModel customerModel = LaunchCustomerModel(
        customerName: customerName,
        customerMobile: StoreOwner.storeOwnerNumber);
    return customerModel;
  }
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random.secure();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<LaunchMerchantModel> createLaunchMerchantModel() async {
    String customerRequestNumber = getRandomString(10);

    await setMerchantRefNumb(customerRequestNumber);

    LaunchMerchantModel merchantModel = LaunchMerchantModel(
        merchantCode: _merchantCode, //
        merchantRefNum: customerRequestNumber,
        secureKey: _secureKey); //
    return merchantModel;
  }

  Future<FawryLaunchModel> createFawryLaunchModel(
      Map<String, String> bundleMap) async {
    FawryLaunchModel model = FawryLaunchModel(
        allow3DPayment: true,
        paymentMethods: PaymentMethods.FAWRY_PAY,
        chargeItems: createBillItem(bundleMap),
        launchCustomerModel: createLaunchCustomerModel(),
        launchMerchantModel: await createLaunchMerchantModel(),
        skipLogin: true,
        skipReceipt: false);
    return model;
  }

  Future<bool> urlDeclaration(Map<String, String> bundleMap) async {
    return await FawrySdk.instance.init(
        launchModel: await createFawryLaunchModel(bundleMap),
        baseURL: "https://atfawry.com/",
        lang: FawrySdk.LANGUAGE_ARABIC);
  }
}