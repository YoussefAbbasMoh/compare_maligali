import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../Models/mhalatko_order_models/order_model.dart';
import '../../Models/product_in_receipt_model.dart';
import '../../Models/user_inventory_model.dart';
import '../../Services/FireBaseServices/coll_receipt_services.dart';
import '../../Services/FireBaseServices/create_and_delete_db_services.dart';
import '../../Services/local_inventory_services/hive_services.dart';
import '../../Services/local_inventory_services/user_inventory_services.dart';
import '../../utils/flutter_secure_storage_functions.dart';
import '../../utils/time_and_date_utils.dart';
import '../receipts_view_models/common_receipt_view_models/hour_view_model.dart';

class OrdersViewModel extends ChangeNotifier {

  Order? orderSelected;
  List<Order> newOrdersList = [];
  List<Order> oldOrdersList = [];
  static bool _badgeNotifier = false;
  CollectionReference userOrdersCollectionReference =
  CreateAndDeleteDBServices().userDBReference().collection('orders');

  String date = "";
  String time = "";
  String orderNumber = "";
  List<ProductInReceipt> productsInOrder = [];

  initOrderVM(){

  }
  Future<List<Order>> fetchOrdersFromFireBase() async {
    QuerySnapshot orderQuerySnapshot =
    await userOrdersCollectionReference.get();
    List<Order> orders = [];
    // Iterate over the documents and print their data
    for (var doc in orderQuerySnapshot.docs) {
      String orderNumber = doc.id;
      String customerUid = doc.get("customerUid");

      try {
        DocumentReference customerDocRef =
        CreateAndDeleteDBServices().customersDBReference(customerUid);

        DocumentSnapshot customerDocSnapshot = await customerDocRef.get();

        String clientName = customerDocSnapshot.get("c_name");
        String clientPhone = customerDocSnapshot.get("c_phone");
        await customerDocRef
            .collection("newOrders")
            .doc(orderNumber)
            .get()
            .then((value) {
          Order orderData = Order(
            clientAddress: value.get("clientAddress"),
            clientName: clientName,
            clientPhone: clientPhone,
            distanceByTime: value.get("timeToReach"),
            orderDate: value.get("orderDate"),
            orderDeliveryPrice: value.get("orderDeliveryPrice"),
            orderItems: Order.convertOrderItemsToMap(value.get("orderItems")),
            orderRequestTime: value.get("orderRequestTime"),
            orderStatus: value.get("orderStatus"),
            orderNumber: orderNumber,
            customerUid: customerUid,
          );
          orders.add(orderData);
        });
      } catch (e) {
        if (kDebugMode) {
          print("error getting order data");
        }
      }
    }
    return orders;
  }
  Future<bool> confirmDelivery(Order order) async {
    // ordersList.remove(order);
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print(order.orderStatus);
    CreateAndDeleteDBServices().customersDBReference(order.customerUid).collection("newOrders")
        .doc(order.orderNumber)
        .update({"orderStatus":"Delivered"});
    order.orderStatus = "Delivered";
    return true;
  }



Future<bool> rejectOrder(Order order) async {
    // ordersList.remove(order);
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print(order.orderStatus);
    CreateAndDeleteDBServices().customersDBReference(order.customerUid).collection("newOrders")
        .doc(order.orderNumber)
        .update({"orderStatus":"rejected"});
    order.orderStatus = "rejected";
    userOrdersCollectionReference.doc(order.orderNumber).delete();
    try {
      // await userOrdersCollectionReference.doc(order.customerUid).collection(
      //     "rejectedOrders").doc(order.orderNumber).set(
      //     order.toMap()
      // );
      // await userOrdersCollectionReference.doc(order.customerUid).collection(
      //     "newOrders").doc(order.orderNumber).delete();
      return true;
    }catch (e){
      if (kDebugMode) {
        print("error in rejectOrder + $e");
      }
      return false;
    }
  }


  Future<bool> loadAllOrders() async {
    // main operation
    bool isLoadedSuccessfully = true;
    List<Order> currentOrdersList = [];
    List<Order> confirmedOrdersList = [];

    try{

      newOrdersList = await fetchOrdersFromFireBase();
      print(newOrdersList);
      int i=0;
      for(Order order in newOrdersList){
        i=i+1;
        print("counter:"+i.toString());
        bool isOrderExpired = checkForOrderExpireDate(order);

        if(!isOrderExpired){
          if (order.orderStatus == "Seen" || order.orderStatus == "Placed"){
            currentOrdersList.add(order);}
          else if (order.orderStatus == "OnDelivery" || order.orderStatus == "Delivered"){
            confirmedOrdersList.add(order);
          }
        }
        else if(isOrderExpired && (order.orderStatus == "OnDelivery" || order.orderStatus == "Delivered")){
          userOrdersCollectionReference.doc(order.orderNumber).delete();
        }
        else{
          CreateAndDeleteDBServices().customersDBReference(order.customerUid).collection("newOrders")
              .doc(order.orderNumber)
              .update({"orderStatus":"rejected"});
          userOrdersCollectionReference.doc(order.orderNumber).delete();
        }
      }
      newOrdersList = currentOrdersList;
      oldOrdersList = confirmedOrdersList;
    }catch(e){
      if (kDebugMode) {
        print("error in loadingAllOrders + $e");
      }
    }
    return isLoadedSuccessfully;
  }

  bool checkForOrderExpireDate(Order order){
    int daysRemaining = 0;
    List<String> date = order.orderDate.split("/");
    int year = int.parse(date[2]);
    int month = int.parse(date[1]);
    int day = int.parse(date[0]);
    daysRemaining = DateTime.now().difference(DateTime(year, month, day)).inDays;
    if(daysRemaining > 2){
      // if order exceeded 2 days and not served, delete order
      return true;
    }
    else{
      return false;
    }
  }


  expireOrder(Order order) async {
    // todo move order to expired orders in db
    // notify client
  }


  bool badgeNotifier() => _badgeNotifier;
  //Main function to get the product data from user json file
  Future<List<ProductInReceipt>> getOrderItemsList(Order? order) async {
    order = order ?? orderSelected;
    this.productsInOrder = [];

    Map<String, String> orderItems = order!.orderItems;
    List<ProductInReceipt> products = [];

    for (String itemBarCode in orderItems.keys.toList()) {
      UserInventory? product =
      await HiveDatabaseManager.getProductFromUserInventory(itemBarCode);
      print(product?.productName);
      ProductInReceipt productData = ProductInReceipt(
        productName: product!.productName,
        barcode: itemBarCode,
        userBuyingPrice: product.averagePurchasePrice,
        productSellingPrice: product.sellingPricePerPack,
        productPriceWithSale: null,
        productOnSale: false,
        productBoughtCount: double.tryParse(orderItems[itemBarCode]!)!,
        numbItemsInCarton: product.numberOfPackageInsideTheCarton,
      );
      productsInOrder.add(productData);
    }
    print("----------------------------------->>>>>>>>>>>");
    print("products in order:");
    print(productsInOrder);
    return products;
  }

  void setBadgeNotifier(bool notificationState) {
    _badgeNotifier = notificationState;
  }


  void listenToStorage() async {
    userOrdersCollectionReference.snapshots().listen((event) async {
      print("there is a change in firebase");
    notifyListeners();
    });

  }

  setOrderStatusToDelivered(String orderStatus){
    if(orderStatus == "sent"){

    }
    else{

    }
  }

  setOrderDataInHand(Order order) async {
    orderSelected = order;
    date = getNowDate();
    time = getNowTime();
    orderNumber = orderSelected!.orderNumber;
    await getOrderItemsList(null);
    notifyListeners();
  }

  double getTotalOrderCost() {
    double totalProfit = 0.0;
    for (ProductInReceipt product in productsInOrder) {
      double productPrice =
          product.productPriceWithSale ?? product.productSellingPrice;

      totalProfit += product.productBoughtCount * productPrice;
    }
    return totalProfit;
  }

  clearOrderDataInHand() {
    orderSelected = null;
    date = "";
    time = "";
    orderNumber = "";
    productsInOrder = [];
    //notifyListeners();
  }

  addReceiptToDB(context) async {
    ReceiptCollectionServices receiptDBServiceObj = ReceiptCollectionServices();

    receiptDBServiceObj.addReceiptToDB(orderNumber,
        preparingReceiptProductsForStoringInDB(date, time), null, null);

    String subscriptionStatus =
        await fetchSubscriptionStatus() ?? "UNSUBSCRIBED";

    if (subscriptionStatus == "FREE_TRIAL") {
      await updateRemainingFreeTrialReceipts();
    }
  }

  Map<String, dynamic> preparingReceiptProductsForStoringInDB(
      String receiptDate, String receiptTime) {
    Map<String, Map<String, String>> itemsList = {};

    for (ProductInReceipt product in productsInOrder) {
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
      "ReceiptNumber": orderNumber,
      "itemsList": itemsList,
      "receiptDate": receiptDate,
      "receiptTime": receiptTime,
      "receiptAfterSaleProfit": calculateAfterSaleProfit().toStringAsFixed(2),
      "receiptBeforeSaleProfit": calculateBeforeSaleProfit().toString(),
      "receiptRevenue": calculateReceiptAfterSaleRevenue().toStringAsFixed(2),
      "totalProductsSold": calculateTotalProductsSold().toString(),
    };
  }

  double calculateAfterSaleProfit() {
    double totalProfit = 0.0;
    for (ProductInReceipt product in productsInOrder) {
      double productPrice =
          product.productPriceWithSale ?? product.productSellingPrice;

      totalProfit += product.productBoughtCount * productPrice;
    }
    print("______________________________>>>>");
    print("totalProfit"+totalProfit.toString());
    return totalProfit;
  }

  calculateReceiptAfterSaleRevenue() {
    double totalRevenue = 0.0;
    for (ProductInReceipt product in productsInOrder) {
      double productSellingPrice =
          product.productPriceWithSale ?? product.productSellingPrice;
      double productBuyingPrice =
          product.productSellingPrice / product.numbItemsInCarton;
      totalRevenue += product.productBoughtCount *
          (productSellingPrice - productBuyingPrice);
    }
    return totalRevenue;
  }

  int calculateTotalProductsSold() {
    List<double> itemsOrderedList = orderSelected!.orderItems.values
        .toList()
        .map((data) => double.parse(data))
        .toList();
    double overallItemsCount =
    itemsOrderedList.fold(0, (previous, current) => previous + current);
    return overallItemsCount.round();
  }

  double calculateBeforeSaleProfit() {
    double totalProfit = 0.0;
    for (ProductInReceipt product in productsInOrder) {
      totalProfit += product.productBoughtCount * product.productSellingPrice;
    }
    return totalProfit;
  }

  completeSale() async {
    UserInventoryServices userInvServicesObj = UserInventoryServices();
    if (productsInOrder.isNotEmpty) {
      for (ProductInReceipt product in productsInOrder) {
        await userInvServicesObj.subtractProductsFromUserInventoryDB(
          product.barcode,
          double.parse(product.productBoughtCount.toStringAsFixed(2)),
        );
      }
    }
  }

  Future<void> endReceiptVM(BuildContext context,Order order) async {
    await storeReceiptsCountOfDay();
    await updateOrderStateInFirebase(order);
    clearOrderDataInHand();
    await Provider.of<HourReceiptViewModel>(context, listen: false)
        .updateHourAndDaySummariesAfterReceiptEdit(context);
  }

  updateOrderStateInFirebase(Order order) async {
    CreateAndDeleteDBServices().customersDBReference(order.customerUid)
        .collection("newOrders")
        .doc(order.orderNumber)
        .update({"orderStatus": "OnDelivery"});
    // await CreateAndDeleteDBServices()
    //     .userDBReference()
    //     .collection('orders')
    //     .doc(orderNumber)
    //     .update({"orderState":
  }
}
