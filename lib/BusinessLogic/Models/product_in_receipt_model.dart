class ProductInReceipt {
  String productName;
  String barcode;
  double userBuyingPrice;
  double productSellingPrice;
  double? productPriceWithSale;
  double productBoughtCount = 0.0;
  double numbItemsInCarton = 1.0;
  bool productOnSale; //TODO: Set final when bottom todo is performed

  ProductInReceipt({
    this.productName = "منتج غير معروف",
    this.barcode = "-",
    this.userBuyingPrice = 0.0,
    this.productSellingPrice = 0.0,
    this.productPriceWithSale,
    this.productOnSale = false,
    this.productBoughtCount = 0.0,
    this.numbItemsInCarton = 0.0,
  });
}
