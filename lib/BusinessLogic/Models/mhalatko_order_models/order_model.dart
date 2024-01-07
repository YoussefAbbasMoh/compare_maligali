import 'package:maligali/BusinessLogic/Services/FireBaseServices/create_and_delete_db_services.dart';

class Order {
  String orderNumber;
  String clientAddress;
  String clientName;
  String clientPhone;
  String distanceByTime;
  String orderDate;
  double orderDeliveryPrice;
  Map<String, String> orderItems;
  String orderRequestTime;
  String orderStatus;
  String customerUid;

  Order(
      {
        required this.orderNumber,
      required this.clientAddress,
      required this.clientName,
      required this.clientPhone,
      required this.distanceByTime,
      required this.orderDate,
      required this.orderDeliveryPrice,
      required this.orderItems,
      required this.orderRequestTime,
      required this.orderStatus,
      required this.customerUid,
      });

  static Map<String, String> convertOrderItemsToMap(
      Map<String, dynamic> orderDocMap) {
    Map<String, String> stringMap = Map<String, String>.from(orderDocMap.map(
      (key, value) => MapEntry<String, String>(key, value.toString()),
    ));
    return stringMap;
  }

  setOrderStatusToSeen() async {
    orderStatus = "seen";
    await CreateAndDeleteDBServices().customersDBReference(customerUid).collection("newOrders").doc(orderNumber).update({
      "orderStatus": orderStatus
    });
  }
  setOrderStatusToOnTheWay() async {
    orderStatus = "onTheWay";
    await CreateAndDeleteDBServices().customersDBReference(customerUid).collection("newOrders").doc(orderNumber).update({
      "orderStatus": orderStatus
    });
  }

  toMap(){
    return {
      "orderNumber": orderNumber,
      "clientAddress": clientAddress,
      "clientName": clientName,
      "clientPhone": clientPhone,
      "distanceByTime": distanceByTime,
      "orderDate": orderDate,
      "orderDeliveryPrice": orderDeliveryPrice,
      "orderItems": orderItems,
      "orderRequestTime": orderRequestTime,
      "orderStatus": orderStatus,
      "customerUid": customerUid
    };
  }

  checkForOrderValidity(){

  }

  convertCPurchasesToJSON() {}
}
