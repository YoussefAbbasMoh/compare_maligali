import 'product_in_receipt_model.dart';

class Receipt {
  final String receiptNumber;
  final String receiptDate;
  final String receiptTime;
  double receiptBeforeSaleProfit;
  double receiptAfterSaleProfit;
  double receiptRevenue;
  int totalProductsSold;
  List<ProductInReceipt> itemsList;

  Receipt(
      {required this.receiptNumber,
      required this.receiptDate,
      required this.receiptTime,
      required this.receiptBeforeSaleProfit,
      required this.receiptAfterSaleProfit,
      required this.receiptRevenue,
      required this.totalProductsSold,
      required this.itemsList});
}
