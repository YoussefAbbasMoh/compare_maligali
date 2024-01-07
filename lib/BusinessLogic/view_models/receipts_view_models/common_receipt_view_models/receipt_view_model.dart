import 'package:flutter/cupertino.dart';
import 'package:maligali/BusinessLogic/view_models/receipts_view_models/today_view_models/today_page_view_model.dart';
import 'package:provider/provider.dart';
import '../../../Models/product_in_receipt_model.dart';
import '../../../Services/FireBaseServices/coll_receipt_services.dart';
import '../../../Services/local_inventory_services/user_inventory_services.dart';
import '../../../utils/flutter_secure_storage_functions.dart';
import '../../../utils/time_and_date_utils.dart';
import '../../subscriptions_view_model.dart';
import 'hour_view_model.dart';

class ReceiptViewModel extends ChangeNotifier {
  UserInventoryServices userInvServicesObj = UserInventoryServices();
  ReceiptCollectionServices receiptDBServiceObj = ReceiptCollectionServices();

  String day = "0";
  String month = "0";
  String year = "0";
  String hour = "0";
  String min = "0";
  String receiptNumber = "-";
  bool receiptInitialized = false;
  bool receiptReloaded = false;
 // bool subscriptionState = SubscriptionsViewModel.allowReceiptsCreation;
  //double discountOnReceipt = 0.0;

  List<ProductInReceipt> _productsList = [];
  List<ProductInReceipt> getProductsList() => _productsList;

  Map<String, ProductInReceipt> _onSearchingList = {};
  Map<String, ProductInReceipt> getOnSearchingList() => _onSearchingList;

  double totalReceiptCost = 0.0;
  double payedMoney = 0.0;
  double discountValue = 0.0;
  double returnedChange = 0.0;

  setTotalReceiptCostController(String receiptCostValue){
    totalReceiptCost = double.parse(receiptCostValue.isEmpty? "0.0":receiptCostValue);
    changeTotalReceiptCost();
    //notifyListeners();
  }

  setPayedMoneyController(String payedMoneyValue){
    payedMoney = double.parse(payedMoneyValue.isEmpty? "0.0": payedMoneyValue);
    changePayedMoneyValue();
  }


  changeTotalReceiptCost(){
    discountValue = calculateBeforeSaleProfit() - totalReceiptCost;
    returnedChange = payedMoney - totalReceiptCost;
    if(returnedChange <0 && payedMoney == 0){
      returnedChange = 0.0;
    }
    notifyListeners();
  }

  changePayedMoneyValue(){
    returnedChange = payedMoney - totalReceiptCost;
    if(returnedChange<0 && payedMoney==0){
      returnedChange = 0.0;
    }
    notifyListeners();
  }


  //TodayPageVM? _todayPageVM;

  // Handling initializing receipt data: -------------------------------------------------
  initNewReceiptVM(BuildContext ctx) async {
    //_todayPageVM = Provider.of<TodayPageVM>(ctx, listen: false);
    receiptInitialized = true;

    DateTime now = DateTime.now();

    day = now.day.toString();
    month = now.month.toString();
    year = now.year.toString();
    hour = now.hour.toString();
    min = now.minute.toString();

    if (day.length == 1) {
      day = "0" + day;
    }
    if (month.length == 1) {
      month = "0" + month;
    }
    if (hour.length == 1) {
      hour = "0" + hour;
    }
    if (min.length == 1) {
      min = "0" + min;
    }
    await receiptNumberGenerator();
  }

  receiptNumberGenerator() async {
    String receiptCount =
        (await fetchReceiptsCountFromStorage() + 1).toString();
    final int digitsCount = receiptCount.length;

    if (digitsCount < 4) {
      for (int i = 1; i <= 4 - digitsCount; i++) {
        receiptCount = '0' + receiptCount;
      }
    }
    // 12 Digits Code Sequence Generation: MM-DD-HH-yy-XXXX
    // yy is the last 2 digits of the year as in year 2021, yy is 21
    // XXXX is a sequenced number from 0 to 9999
    receiptNumber = month + day + hour + year.split("0")[1] + receiptCount;
  }

  convertReceiptBarCodesToNames() {}

  loadPreviousReceipt(String collHour, String date, String time,
      String receiptNumb, List<ProductInReceipt> productsList) {
    List<String> dateParts = date.split("-");
    day = dateParts[0];
    month = dateParts[1];
    year = dateParts[2];

    List<String> hourParts = time.split(":");
    hour = collHour;
    min = hourParts[1];

    receiptNumber = receiptNumb;
    _productsList = productsList;
    receiptReloaded = true;
    notifyListeners();
  }

  // Handling emptying/ ending receipt data: -----------------------------------------------
  endReceiptVM(BuildContext context) async {
    await storeReceiptsCountOfDay();
    removeReceiptData();
    await Provider.of<HourReceiptViewModel>(context, listen: false).updateHourAndDaySummariesAfterReceiptEdit(context);
  }

  removeReceiptData() {
    receiptInitialized = false;
    receiptReloaded = false;
    emptyProductsList();
    emptyProductsList();
    day = "0";
    month = "0";
    year = "0";
    hour = "0";
    min = "0";
    totalReceiptCost = 0.0;
    payedMoney = 0.0;
    discountValue = 0.0;
    returnedChange = 0.0;
    receiptNumber = "-";
    notifyListeners();
  }

  // Handling Service lists of VM: ---------------------------------------------------------
  void emptyProductsList() {
    _productsList = [];
  }

  void addToProductsList(List<ProductInReceipt> addedProduct) {
    _productsList.addAll(addedProduct);
  }

  void removeProductFromReceipt(String barCode, double? productBoughtCount) {
    if (receiptReloaded == true) {
      userInvServicesObj.returnProductToUserInventoryDB(
          barCode, productBoughtCount!);
    }
    int productInReceiptIndex = _productsList
        .indexWhere((productData) => productData.barcode == barCode);
    _productsList.removeAt(productInReceiptIndex);
  }

  emptyOnSearchingList() {
    _onSearchingList = {};
  }

  addToOnSearchingList(ProductInReceipt product) {
    _onSearchingList[product.productName] = product;
  }

  removeFromOnSearchList(String productName) {
    _onSearchingList.remove(productName);
  }

  // Handling Calculating Total Receipt Values: ----------------------------------------------
  double calculateBeforeSaleProfit() {
    double totalProfit = 0.0;
    for (ProductInReceipt product in _productsList) {
      totalProfit += product.productBoughtCount * product.productSellingPrice;
    }
    return totalProfit;
  }

  updateReceiptAfterSaleProfit(){
    notifyListeners();
  }

  calculateTotalReceiptDiscountValue(String profitAfterDiscount){
    double totalBeforeDiscount = calculateBeforeSaleProfit();
    discountValue = totalBeforeDiscount - double.parse(profitAfterDiscount);
    return discountValue.toStringAsFixed(2);
  }

  double calculateAfterSaleProfit() {
    double totalProfit = calculateBeforeSaleProfit() - discountValue;
    totalReceiptCost = totalProfit;

    return totalProfit;
  }

  calculateReceiptBeforeSaleRevenue() {
    double totalRevenue = 0.0;
    for (ProductInReceipt product in _productsList) {
      totalRevenue += product.productBoughtCount *
          ((product.productPriceWithSale ?? product.productSellingPrice) -
              (product.userBuyingPrice / product.numbItemsInCarton));
    }
    return totalRevenue;
  }

  calculateReceiptAfterSaleRevenue(){
    double totalRevenue = calculateReceiptBeforeSaleRevenue() - discountValue;
    return totalRevenue;
  }

  int calculateTotalProductsSold() {
    double overallItemsCount = 0.0;
    for (ProductInReceipt product in _productsList) {
      overallItemsCount += product.productBoughtCount;
    }
    return overallItemsCount.round();
  }

  // Further Functions Handling adding and editing receipts and products in DB: -------------------
  addReceiptToDB(BuildContext context, String? date, String? time) async {
    String receiptDate =
        date ?? reformatDateSplittedToCombined(day, month, year);
    String receiptTime = time ?? reformatTimeSplittedToCombined(hour, min);

    if (receiptReloaded == true) {
      String changedReceiptHour = reformatHourSplitted(hour.toString());
      receiptDBServiceObj.addReceiptToDB(
          receiptNumber,
          preparingReceiptProductsForStoringInDB(receiptDate, receiptTime),
          changedReceiptHour,
          receiptDate);
      Provider.of<TodayPageViewModel>(context,
          listen: false).setHourToUpdate(changedReceiptHour);
    } else {

      receiptDBServiceObj.addReceiptToDB(
          receiptNumber,
          preparingReceiptProductsForStoringInDB(receiptDate, receiptTime),
          null,
          null);
    }

    String subscriptionStatus = await fetchSubscriptionStatus()??"UNSUBSCRIBED";

    if(subscriptionStatus == "FREE_TRIAL") {
      await updateRemainingFreeTrialReceipts();
    }
    //print(subscriptionState);
    // if (subscriptionState == true) {
    //   print("1");
    //   await SubscriptionsViewModel().subscriptionReceiptsCounter();
    // }
  }


  Map<String, dynamic> preparingReceiptProductsForStoringInDB(
      String receiptDate, String receiptTime) {
    Map<String, Map<String, String>> itemsList = {};

    for (ProductInReceipt product in _productsList) {
      //itemsList[product.productName] = {

      if (itemsList.containsKey(product.barcode)) {
        itemsList[product.barcode]!["count"] =
            (double.parse(itemsList[product.barcode]!["count"]!) +
                    product.productBoughtCount)
                .toString();
      } else {
        itemsList[product.barcode] = {
          "count": product.productBoughtCount.toString(),
          "productSellingPrice": product.productSellingPrice.toString(),
          "userBuyingPrice": product.userBuyingPrice.toString(),
        };
      }
    }

    return {
      "ReceiptNumber": receiptNumber,
      "itemsList": itemsList,
      "receiptDate": receiptDate,
      "receiptTime": receiptTime,
      "receiptAfterSaleProfit": calculateAfterSaleProfit().toStringAsFixed(2),
      "receiptBeforeSaleProfit": calculateBeforeSaleProfit().toString(),
      "receiptRevenue": calculateReceiptAfterSaleRevenue().toStringAsFixed(2),
      "totalProductsSold": calculateTotalProductsSold().toString(),
    };
  }

  completeSale() async {
    if (_productsList.isNotEmpty) {
      for (ProductInReceipt product in _productsList) {
        await userInvServicesObj.subtractProductsFromUserInventoryDB(
          product.barcode,
          double.parse(product.productBoughtCount.toStringAsFixed(2)),
        );
        print(product.barcode);
        print("ooooooooooooooooooooooooooooooooooooooo");
      }
    }
  }
}
