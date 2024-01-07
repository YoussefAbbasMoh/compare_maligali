class DaySummary {
  double numberOfProductsSold;
  int numberOfReceiptsMade;
  double totalDayProfit;
  double totalDayRevenue;
  String topSoldProductBarCode;
  List<String> productsFinishedFromInventory;
  String leastProductSoldBarCode;
  double topSoldProductCount;
  double leastSoldProductCount;

  DaySummary({
    required this.numberOfProductsSold,
    required this.numberOfReceiptsMade,
    required this.totalDayProfit,
    required this.totalDayRevenue,
    required this.topSoldProductBarCode,
    required this.leastProductSoldBarCode,
    required this.productsFinishedFromInventory,
    required this.topSoldProductCount,
    required this.leastSoldProductCount,
  });

  static Map<String, dynamic> toMap(String dayStartHour, DaySummary daySummary){
    return {
    "numberOfProductsSold": daySummary.numberOfProductsSold,
    "numberOfReceiptsMade": daySummary.numberOfReceiptsMade,
    "totalDayProfit": daySummary.totalDayProfit,
    "totalDayRevenue": daySummary.totalDayRevenue,
    "topSoldProductBarCode": daySummary.topSoldProductBarCode,
    "leastProductSoldBarCode": daySummary.leastProductSoldBarCode,
    "productsFinishedFromInventory": daySummary.productsFinishedFromInventory, // todo
    "topSoldProductCount": daySummary.topSoldProductCount,
    "leastSoldProductCount": daySummary.leastSoldProductCount,
    "startHour": dayStartHour
    };
  }


}
