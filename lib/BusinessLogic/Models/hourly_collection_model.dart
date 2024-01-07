import 'dart:convert';

class HourlyReceiptCollection {
  double hourTotalProfit = 0.0;
  double hourTotalRevenue = 0.0;
  int hourItemsSoldCount = 0;
  int hourReceiptsCount = 0;
  String date;
  String time;
  String amPm;
  String topSoldProductBarCode;
  double topSoldProductCount;
  String leastProductSoldBarCode;
  double leastProductSoldCount;
  List<String> productsFinishedFromInventory;

  HourlyReceiptCollection({
    required this.date,
    required this.time,
    required this.amPm,
    required this.hourTotalProfit,
    required this.hourTotalRevenue,
    required this.hourItemsSoldCount,
    required this.hourReceiptsCount,
    required this.topSoldProductBarCode,
    required this.leastProductSoldBarCode,
    required this.productsFinishedFromInventory,
    required this.topSoldProductCount,
    required this.leastProductSoldCount,
  });

  factory HourlyReceiptCollection.fromJson(
      String date, Map<String, dynamic> jsonData) {

    return HourlyReceiptCollection(
      hourTotalProfit: jsonData['hourTotalProfit'],
      hourTotalRevenue: jsonData['hourTotalRevenue'],
      hourItemsSoldCount: jsonData['hourItemsSoldCount'],
      hourReceiptsCount: jsonData['hourReceiptsCount'],
      date: date,
      time: jsonData['time'],
      amPm: jsonData['amPm'],
      topSoldProductBarCode: jsonData['topSoldProductBarCode'],
      leastProductSoldBarCode: jsonData['leastProductSoldBarCode'],
      productsFinishedFromInventory:
          jsonData['productsFinishedFromInventory'].cast<String>(),
      topSoldProductCount: jsonData['topSoldProductCount'],
      leastProductSoldCount: jsonData['leastProductSoldCount'],
    );
  }

  static Map<String, dynamic> toMap(HourlyReceiptCollection model) => {
        'hourTotalProfit': model.hourTotalProfit,
        'hourTotalRevenue': model.hourTotalRevenue,
        'hourItemsSoldCount': model.hourItemsSoldCount,
        'hourReceiptsCount': model.hourReceiptsCount,
        'time': model.time,
        'amPm': model.amPm,
        'topSoldProductBarCode': model.topSoldProductBarCode,
        'leastProductSoldBarCode': model.leastProductSoldBarCode,
        'topSoldProductCount': model.topSoldProductCount,
        'leastProductSoldCount': model.leastProductSoldCount,
        'productsFinishedFromInventory': model.productsFinishedFromInventory
      };

  static String serialize(HourlyReceiptCollection model) =>
      json.encode(HourlyReceiptCollection.toMap(model));

  static HourlyReceiptCollection deserialize(
          String date, Map<String, dynamic> json) =>
      HourlyReceiptCollection.fromJson(date, json);
}
