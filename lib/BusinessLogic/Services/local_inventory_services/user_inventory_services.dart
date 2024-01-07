import 'package:maligali/BusinessLogic/Models/general_inventory_model.dart';

import '../../Models/product_in_receipt_model.dart';
import '../../Models/user_inventory_model.dart';
import '../../view_models/notifications_view_model.dart';

import 'hive_services.dart';

/* this class is responsilbe for providing the operations needed for manipulating the stored user inventory in hive database and providing a simple interface for the screens to use 

  operations include:- 
  1- adding an item to user inventory
  2- deleting an item from it ( completely removing it from inventory , it can't be even searched for again)
  3- restacking products in already in  inventory (editing their information)
  4- subtracting from products in inventory ( just decresasing the quantity , even if it is 0 it will still remain )
  5- return product to user inventory 
  6- search for an item in user inventory by name or barcode
  7- get product data for displaying product information
  8- get product data for display when creating a user inventory product from a general inventory product
  and two functions for heping receipt operations which are
  1- getting product data for receipt
  2- getting a product name from its barcode

 */

class UserInventoryServices {
  /// adding product to user inventory
  Future<String> addProductToUserInventory(UserInventory product) async {
    try {
      await HiveDatabaseManager.saveProductToUserInventory(
          //uses hive database ready functions
          product.barCode,
          product);
      return "done"; //returns a string containing done if succesful
    } catch (e) {
      return "fail"; //returns a string containing fail if unsuccesful
    }
  }

  /// deleting a product from user inventory
  Future<String> deleteProductFromUserInventoryDB(String barcode) async {
    try {
      HiveDatabaseManager.deleteProductFromuserInventory(
          barcode); //uses hive delete functions
      return "done"; // returns done if succesful
    } catch (e) {
      return "fail"; //reterns fail if unsuccesful
    }
  }

  ///editing product information in user inventory
  Future<String> reStackProductInUserInventoryDB(
      String barCode, Map<String, dynamic> data) async {
    //takes a map containing the new data that should replace the old data of the product
    try {
      await HiveDatabaseManager.updateProductInuserInventory(
        //uses hive update function
        barCode,
        numberOfCartonsInInventory:
            double.parse(data['numberOfCartonsInInventory']),
        numberOfPackagesOutsideCarton:
            double.parse(data["numberOfPackagesOutsideCarton"]),
        averagePurchasePrice: double.parse(data['averagePurchasePrice']),
        sellingPricePerPack: double.parse(data['sellingPricePerPack']),
      );
      return "done"; //returns done if succseful
    } catch (e) {
      return "fail"; //returns fail if unsuccesful
    }
  }

  /// responsible for subtracting the quantity of product items in user inventory for sale/burn operations , also responsible for determining when an alert notification should be sent to the user
  /// regarding items in his inventory (run out / close to running out / inconsistent quantites between sale and stock)
  subtractProductsFromUserInventoryDB(String barCode, double productCount,
      //bulk only will make it so all subtractions happen only to bulk (كراتين)
      {bool bulkOnly = false}) async {
    //use bulk only for the old جملة operation

    ///subtraction logic///
    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(
            barCode); //getting item to subtract from

    //storing current quantitiy of cartons , number of pacakages in a carton, and individual packages (فرط) in temperoary variables
    double numberOfCartonsInInventory = product!.numberOfCartonsInInventory;
    double numberOfPackageInsideTheCarton =
        product.numberOfPackageInsideTheCarton;
    double numberOfPackagesOutsideCartonInInventory =
        product.numberOfPackagesOutsideCarton;

    String prodName = product.productName;

    if (bulkOnly) {
      //if we should only subtract from cartons
      product.numberOfCartonsInInventory -=
          productCount; //decrease from cartons only

      //if we should subtract from all inventory , we first check if the amount we want to subtract can be fully subtracted from individual pacakges outside cartons
      //so that we don't need to open cartons to subtract from
    } else if (numberOfPackagesOutsideCartonInInventory >= productCount) {
      product.numberOfPackagesOutsideCarton -=
          productCount; //decrease from individual packages only

      //if we have to subtract from all and the number we want to subtract will require us to open cartons
    } else {
      //first we remove as much as we can from the individual pacakages outside cartons
      double tempProductCount = productCount;
      tempProductCount -= product.numberOfPackagesOutsideCarton;
      // we then check how many cartons we need to open to be able to provide the remaining products we need to subtract
      var numberOfCartonsToOpen =
          (tempProductCount / numberOfPackageInsideTheCarton).ceil();
      //we then subtract that number of cartons that we opened
      product.numberOfCartonsInInventory -= numberOfCartonsToOpen;
      //we then update the remaining individual packages outside of carton count after opening the necessary cartons and taking from them
      product.numberOfPackagesOutsideCarton =
          ((numberOfCartonsToOpen * numberOfPackageInsideTheCarton) -
              tempProductCount);
    }

    ///alert notification logic///

    if (bulkOnly) {
      if (numberOfCartonsInInventory < productCount) {
        NotificationsViewModel().createInventoryNotificationBody(
            notifBody:
                "منتج $prodName عدد الكراتين اللي في مخزنك $numberOfCartonsInInventory واللي طلع $productCount اكتر من اللي موجود ");
      } else {
        if (product.numberOfCartonsInInventory == 0 &&
            product.numberOfPackagesOutsideCarton == 0) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName خلص من محلك انت محتاج تشتري تاني في اسرع وقت ");
        } else if (product.numberOfCartonsInInventory == 0 &&
            product.numberOfPackagesOutsideCarton > 0) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName خلص كل الكراتين بس فاضل منه ${product.numberOfPackagesOutsideCarton} فرط ");
          //todo
        } else if (product.numberOfCartonsInInventory == 1 &&
            product.numberOfPackagesOutsideCarton == 0) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName قرب يخلص فاضل منة ${product.numberOfCartonsInInventory} كرتونة ");
        } else if (product.numberOfCartonsInInventory == 1 &&
            product.numberOfPackagesOutsideCarton > 0) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName قرب يخلص فاضل منة ${product.numberOfCartonsInInventory} كرتونة و ${product.numberOfPackagesOutsideCarton} فرط ");
        }
      }
    } else {
      // packages only
      if (product.numberOfCartonsInInventory <= 0) {
        if (product.numberOfCartonsInInventory < 0) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName كان عندك عدد $numberOfCartonsInInventory كرتونة وعدد $numberOfPackagesOutsideCartonInInventory فرط ودة اقل من الي طلع ");
        } else if (numberOfPackagesOutsideCartonInInventory < productCount) {
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName عدد الفرط اللي في مخزنك $numberOfPackagesOutsideCartonInInventory واللي طلع $productCount اكتر من اللي موجود ");
        }
        if (product.numberOfPackagesOutsideCarton <= 5 &&
            product.numberOfPackagesOutsideCarton > 0) {
          // notify that l fart 2rb y5ls
          // todo
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName خلص كل الكراتين بس فاضل منه ${product.numberOfPackagesOutsideCarton} فرط ");
        } else if (product.numberOfPackagesOutsideCarton == 0) {
          // notify that product is finished
          NotificationsViewModel().createInventoryNotificationBody(
              notifBody:
                  "منتج $prodName خلص من محلك انت محتاج تشتري تاني في اسرع وقت ");
        }
      }

      /* else if (numberOfPackagesOutsideCartonInInventory < 0 &&
          numberOfCartonsInInventory < 0) {
        // notify with problem
        // todo
        /*      if (productCount > numberOfPackageInsideTheCarton) {
          int fullCartoonsReturned =
              productCount ~/ numberOfPackageInsideTheCarton;
          int packagesReturned = productCount -
              (fullCartoonsReturned * numberOfPackageInsideTheCarton);

          product.numberOfPackagesOutsideCarton -= packagesReturned;
          product.numberOfCartonsInInventory -= fullCartoonsReturned;
        } else {
          product.numberOfPackagesOutsideCarton -= productCount;
        } */
      } else {
        int allProductPackagesCountExisting =
            numberOfCartonsInInventory * numberOfPackageInsideTheCarton +
                numberOfPackagesOutsideCartonInInventory;

        if (allProductPackagesCountExisting < productCount) {
          // todo notify with problem
          // عدد العبوات اللي طلع اكتر من اللي موجود في مخزنك
          int fullCartoonsReturned =
              productCount ~/ numberOfPackageInsideTheCarton;
          int packagesReturned = productCount -
              (fullCartoonsReturned * numberOfPackageInsideTheCarton);

          product.numberOfPackagesOutsideCarton -= packagesReturned;
          product.numberOfCartonsInInventory -= fullCartoonsReturned;
        } else {
          int fullCartoonsReturned =
              productCount ~/ numberOfPackageInsideTheCarton;
          int packagesReturned = productCount -
              (fullCartoonsReturned * numberOfPackageInsideTheCarton);

          product.numberOfPackagesOutsideCarton -= packagesReturned;
          product.numberOfCartonsInInventory -= fullCartoonsReturned;
          // operation slima
          if (product.numberOfCartonsInInventory == 1) {
            // notify remaining only one carton
          } else if (product.numberOfCartonsInInventory == 0 &&
              product.numberOfPackagesOutsideCarton != 0) {
            // notify that cartons finished and number of packages remaining is ...
          } else if (product.numberOfCartonsInInventory == 0 &&
              product.numberOfPackagesOutsideCarton == 0) {
            // notify that product is finished
          } else if (product.numberOfCartonsInInventory != 0 &&
              product.numberOfPackagesOutsideCarton == 0) {
            // notify الفرط عندك خلص و لسة باقي كراتين ....
          }
        }
      } */
    }
    if (product.numberOfCartonsInInventory < 0) {
      double zero = 0.0;
      product.numberOfPackagesOutsideCarton = zero;
      product.numberOfCartonsInInventory = zero;
    }
    await product.save();
  }

  ///returning a sold product to user inventory
  Future<void> returnProductToUserInventoryDB(
      String barCode, double productBoughtCount) async {
    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(barCode);

    product!.numberOfPackagesOutsideCarton +=
        productBoughtCount; //add the number of packages returned to the amount of  individual packages outside carton

    await product.save();
  }

  //search for an item in user inventory by name or barcode
  List<UserInventory> searchUserInventoryByProductNameOrBarCode(
      String? filter) {
    if (filter != null && filter.isNotEmpty) {
      //if the passed filter is valid
      var result = HiveDatabaseManager.getAllProductFromUserInventory()
          .where(
              (element) => //search the list containing all general inventory products for a matching name or barcode
                  element.productName.contains(filter) ||
                  element.barCode.startsWith(filter))
          .toList();

      return result; //return list containing results
    } else {
      return []; //return an empty list if nothing was found
    }
  }

  /// fetch a product to display its information in a necessary screen
  Future<UserInventory> getUserInvProductDataForInventoryDisplay(
    String barCode,
  ) async {
    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(barCode);

    if (product != null) {
      //if products exists return it
      return product;
    } else {
      return UserInventory
          .createEmptyProductInInventory(); //if it doesn'st exist return a newly created empty product
    }
  }

  //return a user inventory product created from a general inventory product
  Future<UserInventory> getGeneralInvProductDataForCreatingNewProduct(
    String barCode,
  ) async {
    GeneralInventory? product =
        await HiveDatabaseManager.getProductFromGeneralInventory(
            barCode); //attempt to get the product that we will copy from from general inventory

    if (product != null) {
      //if products exists return it with the necessary values empty to allow the user to add them himself
      return UserInventory(
        productName: product.productName,
        barCode: product.barCode,
        averagePurchasePrice: 0.0,
        sellingPricePerPack: 0.0,
        numberOfCartonsInInventory: 0.0,
        // purchaseUnit: product.purchaseUnit,
        // saleUnit: product.saleUnit,
        numberOfPackageInsideTheCarton:
            double.parse(product.numberOfPackageInsideTheCarton),
        numberOfPackagesOutsideCarton: 0.0,
        productPhoto: product.productPhoto,
        section: product.section,
      );
    } else {
      return UserInventory
          .createEmptyProductInInventory(); //if it doesn'st exist return a newly created empty product
    }
  }

///////////////////////////////////////////receipt operations
//creating a product in receipt item from a user inventory product
  Future<ProductInReceipt> getProductDataForReceipt(
      String barCode, double countBought) async {
    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(barCode);

    return ProductInReceipt(
      productName: product!.productName,
      barcode: barCode,
      userBuyingPrice: product.averagePurchasePrice,
      productSellingPrice: product.sellingPricePerPack,
      productPriceWithSale: null,
      productOnSale: false,
      productBoughtCount: countBought,
      numbItemsInCarton: product.numberOfPackageInsideTheCarton,
    );
  }

//utility function for receipt operations
  Future<String?> getProductNameFromBarCode(String barcode) async {
    UserInventory? product =
        await HiveDatabaseManager.getProductFromUserInventory(barcode);
    return product!.productName;
  }

  Future<double> getProductCountInCartoonFromBarCode(String barcode) async {
    UserInventory? product =
    await HiveDatabaseManager.getProductFromUserInventory(barcode);
    return product!.numberOfPackageInsideTheCarton;
  }
}
