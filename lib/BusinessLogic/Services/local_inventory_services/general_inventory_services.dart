import 'package:maligali/BusinessLogic/Models/product_in_receipt_model.dart';

import '../../Models/general_inventory_model.dart';
import 'hive_services.dart';

/* contains functions that operate on general inventory that can be called throghout the application outside of the hive database class */

//searches accross the entire general inventory using a name or barcode as a filter
class GeneralInventoryServices {
  List<GeneralInventory> searchGeneralInventoryByProductNameOrBarCode(
      String? filter) {
    if (filter != null && filter.isNotEmpty) {
      //if the passed filter is valid

      var result = HiveDatabaseManager
              .getAllProductFromGeneralInventory() //search the list containing all general inventory products for a matching name or barcode
          .where((element) =>
              element.productName.contains(filter) ||
              element.barCode.startsWith(filter))
          .toList();

      return result; //return list containing results
    } else {
      return []; //return an empty list if nothing was found
    }
  }

  Future<ProductInReceipt> getProductDataFromGenInvForReceipt(
      {required String barCode,
      required double countBought,
      // required double unitPurchasePrice,
      // required double unitSellingPrice
      }) async {
    GeneralInventory? product =
        await HiveDatabaseManager.getProductFromGeneralInventory(barCode);

    return ProductInReceipt(
      productName: product.productName,
      barcode: barCode,
      // userBuyingPrice: unitPurchasePrice,
      // productSellingPrice: unitSellingPrice,
      productPriceWithSale: null,
      productOnSale: false,
      productBoughtCount: countBought,
      numbItemsInCarton: double.parse(product.numberOfPackageInsideTheCarton),
    );
  }
}
