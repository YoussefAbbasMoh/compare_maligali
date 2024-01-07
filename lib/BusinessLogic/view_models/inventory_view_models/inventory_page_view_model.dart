import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:maligali/BusinessLogic/Services/local_inventory_services/hive_services.dart';

import '../../Services/FireBaseServices/coll_inventory_activity_services.dart';
import '../../Services/local_inventory_services/user_inventory_services.dart';
import 'package:flutter/foundation.dart';

import '../../utils/dropdownLists/groceryDropdowns.dart';

/* this view model is responsible for connecting the existing inventory screen to the user inventory services , this view model handles:
1- sections -> -getting all available sections 
               -getting all products per section
2- general -> -getting the number of all products in inventory, -
              -calculate total profit that will be gained from selling all items in inventory
3-operations on a single user inventory item -> - calculate profit from selling a single product in inventory (all packs and cartons)
                                                - delete a product from user inventory
                                                - return a product to user inventory
                                                - edit the information of a prdocut in user inventory
4- validators for editing product in user inventory operation


 */
class InventoryPageVM extends ChangeNotifier {

refreshInventoryPageVM(){
  notifyListeners();
}

  ///////attributes
  UserInventoryServices userInvServicesObj =
      UserInventoryServices(); //user inventory services instance used to call its functions
  InventoryActivityServices invActivityServicesObj =
      InventoryActivityServices(); //user inventory activity instance used to call its functions

  Map<String, int> sectionsCount =
      {}; //map holding the names of all available sections in user inventory as well as the number of products in each section
  Map<String, int> uniquesSectionsCount = {};
  ////////////////////////////////////sections//////////////////////////////
  ///gets the name of all available sections that the products currently in the inventory belong to, as well as the number of products in each section and stores them in attribute above
  getAvailableSectionsItemsCount() async {
    Map<String, int> tempSectionsCount = {};
    for (final item in grocerySectionsBarCodes.keys) {
      tempSectionsCount[item] = 0;
    }
    //temp variable to store processed sections and their counts
    HiveDatabaseManager.getAllProductFromUserInventory().forEach((product) {
      //get all user inventory items stored in hive db
      //for each product
      String section = product.section; //get its section
      int count = 0; //create a temp variable to store its count
      count = tempSectionsCount.containsKey(section)
          ? tempSectionsCount[section]! + 1
          : 1; //if it has been stored before, use its stored count +1 , else use only 1
      tempSectionsCount[section] =
          count; //store the name and its count in temp variable
    });
    sectionsCount = tempSectionsCount; //set attribute to the temp variable

    // for(String tempKey in tempSectionsCount.keys.toList()){
    //   if(tempSectionsCount[tempKey]! > 0){
    //     sectionsCount[tempKey] = tempSectionsCount[tempKey]!;
    //   }
    // }
  }

  getAvailableSectionsInUserInventory() async{
    Map<String, int> sectionsMap = {};
    HiveDatabaseManager.getAllProductFromUserInventory().forEach((element) {
      String section = element.section;

      if(sectionsMap.keys.contains(section)){
        sectionsMap[section] = sectionsMap[section]! + 1;
      }else{
        sectionsMap[section] = 1;
      }
    });

    uniquesSectionsCount = sectionsMap;
  }

  //returns all products in user inv under a certain section
  Future<List<UserInventory>> getAllProductsForSection(
      String sectionName) async {
    List<UserInventory>? tempList = HiveDatabaseManager
            .getAllProductFromUserInventory() //loop over all products in inventory
        .where((element) {
      return element.section ==
          sectionName; //if product section matches qeueury section, return it in result
    }).toList();
    return (tempList == null) ? [] : tempList;
  }

///////////////////////////general//////////////////////////////////
  ///return the count of all products together stored in user inventory
  int getAllProductsInUserInventoryCount() {
    return HiveDatabaseManager.getAllProductFromUserInventory().length;
  }

//repsonsible for counting the profit that would be gained from selling ALL products in user inventory
  double countTotalProfitAllProducts() {
    double totalProfit = 0;
    for (UserInventory product
        in HiveDatabaseManager.getAllProductFromUserInventory().toList()) {
      //for each item in user inventory
      //add profut gained from selling all individual packages outside carton
      totalProfit += (product.averagePurchasePrice /
              product.numberOfPackageInsideTheCarton) *
          product.numberOfPackagesOutsideCarton;
      //add profit gained from selling all its cartons
      totalProfit +=
          product.averagePurchasePrice * product.numberOfCartonsInInventory;
    }
    return totalProfit;
  }

//////////////////////////operations on a single user inventory item////////////////////////
  ///
  ///
  ///responsbile for getting profit for selling all packages outside carton and all cartons of an individual user inventory item
  double countTotalProfit(
    var pricePerPack,
    var numberOfPackageInsideTheCarton,
    var numberOfPackagesOutsideTheCarton,
    var numberOfCartonsInInventoryCont,
    var averagePurchasePrice,
  ) {
    // validate parameters, if they are invalid then initialize them to zero
    pricePerPack = double.tryParse(pricePerPack) ?? 0.0;
    numberOfPackageInsideTheCarton =
        double.tryParse(numberOfPackageInsideTheCarton) ?? 0;
    numberOfPackagesOutsideTheCarton =
        double.tryParse(numberOfPackagesOutsideTheCarton) ?? 0;
    numberOfCartonsInInventoryCont =
        double.tryParse(numberOfCartonsInInventoryCont) ?? 0;
    averagePurchasePrice = double.tryParse(averagePurchasePrice) ?? 0.0;

    //profit for selling all cartons
    double totalProfitPerCarton =
        ((pricePerPack * numberOfPackageInsideTheCarton) -
                (averagePurchasePrice)) *
            numberOfCartonsInInventoryCont;
    //profit for selling all packages outside carton
    double totalProfitForAllPackagesOutsideCarton = ((pricePerPack -
            (averagePurchasePrice / numberOfPackageInsideTheCarton)) *
        numberOfPackagesOutsideTheCarton);

    //adding the two profits together and returning it
    double totalProfit =
        totalProfitPerCarton + totalProfitForAllPackagesOutsideCarton;
    return totalProfit;
  }

//responsible for deleting an item from user inventory , and storing data about the deletion activity that will be used in the future for analysis
  Future<String> deleteProductOperation(
      String barCode,
      String productName,
      String numberOfCartonsInInventory,
      String numberOfPackagesOutsideCarton,
      String averagePurchasePrice,
      String sellingPricePerPack,
      // String saleUnit,
      String date) async {
    //prepare data about the deletion activity
    Map<String, String> activityData =
        invActivityServicesObj.prepareDataForDeleteActivity(
      productName,
      numberOfCartonsInInventory,
      numberOfPackagesOutsideCarton,
      averagePurchasePrice,
      sellingPricePerPack,
      // saleUnit,
      date,
    );

    String res_1 = await userInvServicesObj.deleteProductFromUserInventoryDB(
        barCode); //delete the product from user inventory , returns done if succesful
    String res_2 = await invActivityServicesObj.createNewActivity(
        activityData); //store data about the deletion activity , returns done if succesful

    if (res_1 == "done" && res_2 == "done") {
      //if both are succseful
      notifyListeners();
      return "done"; //return done
    } else {
      //if one or both fails
      return "fail"; //return faul
    }
  }

//responsible for returning a product that exists in user ineventory to distributer/burning it completely
  Future<String> returnProduct(
    String barCode,
    String typeController,
    String productName,
    String numberOfItemsReturned,
    String averagePurchasePrice,
    String sellingPricePerPack,
    String date,
    String totalReturnPrice,
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
  ) async {
    String res_1 = "fail";

    try {
      await userInvServicesObj.subtractProductsFromUserInventoryDB(
          //attempt to subtract that amount from user inventory
          barCode,
          double.tryParse(numberOfItemsReturned) ?? 0,
          bulkOnly: (typeController ==
              "جمله")); //controls wether to subtract from cartons only or from cartons and packages together
      res_1 = "done";
      notifyListeners();
    } catch (e) {
      res_1 = "fail";
      if (kDebugMode) {
        print(e);
      }
    }

    Map<String, String> activityData =
        invActivityServicesObj.prepareDataForReturnActivity(
      //prepare data about the subtraction activity
      productName,
      numberOfItemsReturned,
      averagePurchasePrice,
      sellingPricePerPack,
      date,
      typeController,
      totalReturnPrice,
      numberOfCartonsInInventory,
      numberOfPackagesOutsideCarton,
    );

    String res_2 = await invActivityServicesObj.createNewActivity(
        activityData); //store data about the subtraction activity , returns done if succesful
    if (res_1 == "done" && res_2 == "done") {
      //if both are succseful
      return "done"; //return done
    } else {
      //if one or both fails
      return "fail"; //return faul
    }
  }

//responsbile for editing the information of a prodcut that already exists in user inventory
/*user is only allowed to edit :-
number of cartons , number of packages outside cartons, average purchase price per cartons, selling price per individal package */
  Future<String> editingProductInfoOperation(
      String barCode,
      String productName,
      String numberOfCartonsInInventory,
      String numberOfPackagesOutsideCarton,
      String averagePurchasePrice,
      String sellingPricePerPack,
      String date) async {
    Map<String, String> updatedInfo = _generateMapForUpdatedInfo(
      //store the information that will be changed in a map
      numberOfCartonsInInventory,
      numberOfPackagesOutsideCarton,
      averagePurchasePrice,
      sellingPricePerPack,
    );
    Map<String, String> activityData =
        invActivityServicesObj.prepareDataForUpdateActivity(
            //prepare data about the editing activity
            productName,
            numberOfCartonsInInventory,
            numberOfPackagesOutsideCarton,
            averagePurchasePrice,
            sellingPricePerPack,
            date);

    String res_1 = await userInvServicesObj.reStackProductInUserInventoryDB(
        //attempt to modify the information of the product, returns done if succesful
        barCode,
        updatedInfo);
    String res_2 = await invActivityServicesObj.createNewActivity(
        activityData); //store data about the activity , returns done if succesful

    if (res_1 == "done" && res_2 == "done") {
      //if both are succseful
      notifyListeners();
      return "done"; //return done
    } else {
      //if one or both fails
      return "fail"; //return faul
    }
  }

  Map<String, String> _generateMapForUpdatedInfo(
    //helper functions used to store the info about a product that will be changed in a map
    String numberOfCartonsInInventory,
    String numberOfPackagesOutsideCarton,
    String averagePurchasePrice,
    String sellingPricePerPack,
  ) {
    return {
      "numberOfCartonsInInventory": numberOfCartonsInInventory,
      "numberOfPackagesOutsideCarton": numberOfPackagesOutsideCarton,
      "averagePurchasePrice": averagePurchasePrice,
      "sellingPricePerPack": sellingPricePerPack,
    };
  }

//////////////////////////////////editing product validation///////////////////////////////////
  ///check if the average purchase price entered is correct
  bool checkForAveragePurchasePrice(String averagePurchasePrice,
      String sellingPricePerPack, String numberOfPackageInsideTheCarton) {
    //check if the average purchase price exceeds profit gained from selling all items in carton (making it incorrect)
    bool operationCondition = ((double.tryParse(averagePurchasePrice) ?? 0.0) >
        ((double.tryParse(sellingPricePerPack) ?? 0.0) *
            (double.tryParse(numberOfPackageInsideTheCarton) ?? 0.0)));

    if (averagePurchasePrice == "" || //if average purchase price is empty
        double.parse(averagePurchasePrice) <=
            0.0 || //or purchase price exceeds profit
        operationCondition) {
      return false; //return false to indicate incorrectness
    }
    return true; //else return true
  }

  //checks if number of cartons or packages have been changed (defaults are 0.0)
  bool checkForNoChangeInQuantity(
      String barCode,
      String numberOfCartonsController,
      String numberOfPackagesOutsideCartonController) {


    print(numberOfCartonsController);
    print(numberOfPackagesOutsideCartonController);
    if (numberOfCartonsController == "0.0" &&
        numberOfPackagesOutsideCartonController == "0.0") {
      return true;
    } else {
      return false;
    }
  }

//checks if selling price per pack is valid
  bool checkForSellingPricePerPack(String sellingPricePerPack,
      String averagePurchasePrice, String numberOfPackageInsideTheCarton) {
    //if profit gained from selling a single package is more than the price used to buy this package(from seller side)
    bool operationCondition = ((double.tryParse(sellingPricePerPack) ?? 0.0) <
        ((double.tryParse(averagePurchasePrice) ?? 0.0) /
            (double.tryParse(numberOfPackageInsideTheCarton) ?? 0.0)));

    if (sellingPricePerPack == "" || //if selling price per pack is empty
        double.parse(sellingPricePerPack) <= 0.0 || //or negative
        operationCondition) {
      //or above condition fails
      return false; //return false for failure
    }
    return true; //else return true for success
  }

//checks if the number of cartons and the number of products outside carton entered are correct
  bool checkForNumbOfCartonsAndProductsInInv(
      //the user must enter a valid number of packages or valid number of cartons or both
      String numberOfCartons,
      String numberOfProducts) {
    if (numberOfCartons == "") {
      //if number of cartons wasn't entered
      if (numberOfProducts == "") {
        //if number of packages also wasn't entered
        return false; //fail
      } else {
        //if number of cartons wasn't entered but number of packages was entered
        if (double.parse(numberOfProducts) < 0.0) return false; //fail
      }
    } else {
      if (numberOfProducts == "") {
        //if number of packages wasn't entered
        if (double.parse(numberOfCartons) < 0.0)
          return false; //if number of cartons wasn't entered
      } else {
        if ((double.parse(numberOfCartons) < 0.0) &&
            (double.parse(numberOfProducts) < 0.0))
          return false; //if number of cartons wasn't entered but number of packages was entered
      }
    }
    return true; //otherwise sucesss
  }
}
