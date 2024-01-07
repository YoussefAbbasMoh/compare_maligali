import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maligali/BusinessLogic/Models/store_owner_model.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:path_provider/path_provider.dart';
import '../../Models/general_inventory_model.dart';
import '../../Models/user_inventory_model.dart';

//////////////////////////////////Hive database//////////////////////////////////
/* Hive is a fast database (package) that can be used to store data locally on a device , hive is a hierarchical database meanining it stores
data in nested boxes/maps like firestore and not in a table format like Mysql 

Hive is able to store custom classes in it 

Hive stores data (a custom class for example) in a box , each item in the box has a key (used to quickly find the item) and a value(the data or the item itself) 
Hive stores entire boxes in collections 
 */

//all callable functions will be static to make using this class easier and not require an instance first (you can use a function by just writing HiveDatabaseManager.{function name})
class HiveDatabaseManager {
  //constrcutors

  HiveDatabaseManager();

  //attributes

  static late Box
      _generalInventoryBox; // box that stores the general inventory model
  static late Box _userInventoryBox; // box that stores the user inventory model

  static const String _pathToGeneralInventoryJson =
      "assets/generalInventory.json"; //since the general inventory is static (will only change very rarely propabably once a year or less , its data is stored in a json file that will be bundled with the application)

  static const String _backUpUserInventoryJsonName =
      "InventoryBackUp.json"; //name of temporary back up file created to help in the process and deleted afterwards
  static const String _restoredUserInventoryJsonName =
      "InventoryRestore.json"; //name of temporary restore file created to help in the process and deleted afterwards

  ///////////////////////////////////////////////////

  ///////behavior (functions that can be used from outside the class to control hive database)/////

  //must be called when the application first starts in order to initialize the databases
  //this function is responsible for initializing the user inventory and general inventory boxes , also if the general inventory box is empty (ie first time opening the application), it will be populated from the general inventory json
  static Future<void> initializeDataBase() async {
    await _openDb();
    _generalInventoryBox = await Hive.openBox<GeneralInventory>(
        "GeneralInventory"); //initialize general inventory
    _userInventoryBox = await Hive.openBox<UserInventory>(
        "UserInventory"); //initialize user inventory

    await _generalInventoryBox
        .clear(); //if first time opening app or general inventory is empty for any reason
    if (_generalInventoryBox.isEmpty) {
      await _saveGeneralInventoryProductsFromJson(
          _pathToGeneralInventoryJson); // populate general inventory from local json
    }
  }

  //////////////////////////////////////////operations on both user inventory and general inventory

  //save a single product to database , products are saved by their barcode as the key used to retrieve them with directly later
  static Future<void> saveProductToGeneralInventory(
      String barCode, GeneralInventory product) async {
    await _generalInventoryBox.put(barCode, product);
  }

  static Future<void> saveProductToUserInventory(
      String barCode, UserInventory product) async {
    await _userInventoryBox.put(barCode, product);
  }

  //get a single product from database products are retrieved using their barcode as their key
  static Future<GeneralInventory> getProductFromGeneralInventory(
      String barCode) async {
    return await _generalInventoryBox.get(barCode);
  }

  static Future<UserInventory?> getProductFromUserInventory(
      String barCode) async {
    return (await _userInventoryBox.get(barCode));
  }

  //delete item from database , products are found using their barcode as their key
  static Future<void> deleteProductFromGeneralInventory(String barCode) async {
    return await _generalInventoryBox.delete(barCode);
  }

  static Future<void> deleteProductFromuserInventory(String barCode) async {
    return await _userInventoryBox.delete(barCode);
  }

  //get all products from a box in database

  static List<UserInventory> getAllProductFromUserInventory() {
    return (_userInventoryBox.values.cast<UserInventory>().toList());
  }

  static List<GeneralInventory> getAllProductFromGeneralInventory() {
    return (_generalInventoryBox.values.cast<GeneralInventory>().toList());
  }

  ////////////////////////////////////////operations on user inventory only

  //update item in user inventory , this function checks which attributes have been modified in the product and applies these edits to them in the database
  static Future<void> updateProductInuserInventory(String barCode,
      {double? numberOfPackageInsideTheCarton,
      String? productName,
      String? productPhoto,
      // String? purchaseUnit,
      // String? saleUnit,
      String? section,
      double? averagePurchasePrice,
      double? sellingPricePerPack,
      double? numberOfPackagesOutsideCarton,
      double? numberOfCartonsInInventory}) async {
    //if a parameter is passed a value, store that value in the corresponding attribute of the product
    UserInventory? item = await _userInventoryBox.get(barCode);
    if (item != null) {
      if (numberOfPackageInsideTheCarton != null) {
        item.numberOfPackageInsideTheCarton = numberOfPackageInsideTheCarton;
      }
      if (productName != null) item.productName = productName;
      if (productPhoto != null) item.productPhoto = productPhoto;
      // if (purchaseUnit != null) item.purchaseUnit = purchaseUnit;
      // if (saleUnit != null) item.saleUnit = saleUnit;
      if (section != null) item.section = section;
      if (numberOfPackagesOutsideCarton != null) {
        item.numberOfPackagesOutsideCarton += numberOfPackagesOutsideCarton;
      }
      if (averagePurchasePrice != null) {
        item.averagePurchasePrice = averagePurchasePrice;
      }
      if (sellingPricePerPack != null) {
        item.sellingPricePerPack = sellingPricePerPack;
      }
      if (numberOfCartonsInInventory != null) {
        item.numberOfCartonsInInventory += numberOfCartonsInInventory;
      }

      await item
          .save(); //call this on any userinventory or generalinventory model to save changes made to it in the database
    }
  }

  //back up user inventory to firebase
  /* this function creates a temporary json file that it copies the user inventory to ,
   it then checks firestore to see how many user inventory backups are there, it uploads the user inventory json copy to it and 
   deletes the oldest backup if there are more than 7 backups */
  static Future<bool> backUpUserInventoryProducts() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //location where temp copy of use rinventory is created

    var storageFile = File(directory.path +
        '/' +
        _backUpUserInventoryJsonName); //name of the file and its location (applications documents directory)

    // empty the file if it already exists using filemode .write
    await storageFile.writeAsString('[', mode: FileMode.write);

    String dataMap = "";
    //write every item in user inventory to the backup file
    for (var data in _userInventoryBox.values.cast<UserInventory>()) {
      dataMap += (jsonEncode(data.toJson()) + ',');
    }

    dataMap = dataMap.substring(0, dataMap.length - 1);
    await storageFile.writeAsString(dataMap, mode: FileMode.append);

    // add closing bracket when we finish
    await storageFile.writeAsString(']', mode: FileMode.append);

    //uploading file to firebase storage
    final folderDestination = 'UsersInventoryBackUp/${StoreOwner().getUid()}';
    final storage = FirebaseStorage.instance;
    ListResult uploadedFiles = await storage.ref(folderDestination).list();

    if (uploadedFiles.items.length == 7) {
      //if user has 7 backups on firestore
      //check for the oldest file
      var oldestFile = uploadedFiles.items[0];
      for (var f in uploadedFiles.items) {
        if (DateTime.parse(f.name.replaceFirstMapped('.json', (match) => ''))
            .isBefore(DateTime.parse(
                oldestFile.name.replaceFirstMapped('.json', (match) => '')))) {
          oldestFile = f;
        }
      }
      //delete oldest file
      await oldestFile.delete();
    }
    //name of the file on firestore (we name it by the date of upload to be able to determine the oldest file later easily)
    final ref =
        storage.ref('$folderDestination/${DateTime.now().toString()}.json');

    try {
      var task = ref.putFile(storageFile); //attempt upload
      await task.whenComplete(() {});
      if (task.snapshot.state == TaskState.success) {
        await storageFile
            .delete(); //delete the temp local file if upload is succesful

        return true;
      } else {
        if (await storageFile.exists()) {
          await storageFile.delete();
        } //delete the temp file if upload is unsuccesful and return false to indicate failure
        return false;
      }
    } on Exception {
      if (await storageFile.exists()) {
        await storageFile.delete();
      } //delete the temp file if an error happens and return false to indicate failure
      return false;
    }
  }

  //restores latest user inventory upload from firestore to the local userinventory hive box
  /* this function checks for the latest back up present on firestore , downloads the json file locally , then loads it into the hive user inventory box */
  static Future<bool> restoreUserInventoryProducts() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //location that the file will be downloaded to

    var storageFile = File(directory.path +
        '/' +
        _restoredUserInventoryJsonName); //name of the file and its location (applications documents directory)

    final folderDestination = 'UsersInventoryBackUp/${StoreOwner().getUid()}';
    final storage = FirebaseStorage.instance;
    //check if backup exists
    if (storage.ref(folderDestination) == storage.ref(folderDestination).root) {
      return false; // if there is no back up on firestore to restore we terminate immediately
    }
    ListResult uploadedFiles = await storage
        .ref(folderDestination)
        .list(); //another check for existing backups
    if (uploadedFiles.items.isEmpty) {
      return false;
    } // if there is no back up on firestore to restore we terminate immediately

    var newestFile = uploadedFiles.items[0];
    //check for the latest file
    for (var f in uploadedFiles.items) {
      if (DateTime.parse(f.name.replaceFirstMapped('.json', (match) => ''))
          .isAfter(DateTime.parse(
              newestFile.name.replaceFirstMapped('.json', (match) => '')))) {
        newestFile = f;
      }
    }
    try {
      //after latest file has been determined on firestore
      var task = newestFile
          .writeToFile(storageFile); //attempt to download the json file locally
      await task.whenComplete(() {}); //when download task is complete
      if (task.snapshot.state == TaskState.success) {
        //if download was succesful
        await _userInventoryBox.clear(); //clear the existing user inventory box
        await _saveUserInventoryProductsFromJson(
            storageFile); //load products from downloaded json to user inventory box
        await storageFile.delete(); //delete the temproray downloaded file
        return true; //return success
      } else {
        if (await storageFile.exists()) {
          await storageFile.delete();
        } //delete the temp local file if download is usuccesful and return false to indicate failure
        return false;
      }
    } on Exception {
      if (await storageFile.exists()) {
        await storageFile.delete();
      } //delete the temp local file if an error occurs and return false to indicate failure
      return false;
    }
  }

//helper functions

  //this function creates and sets up the collections that will contain the boxes (tables/maps) that hive will use to store data in
  static Future<BoxCollection> _openDb() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //location where the collection will be stored
    final localStorageCollection = await BoxCollection.open(
      //parent collection that will contain the child boxes
      'MaliGaliLocalDataBase',

      {},
      path: directory.path,
    );

    return localStorageCollection;
  }

  //gets the general product items from a json map and stores them in GeneralInventory box
  static Future<void> _saveGeneralInventoryProductsFromJson(
      String jsonPath) async {
    String data = await rootBundle.loadString(jsonPath);
    var jsonMap = jsonDecode(data);

    for (var map in jsonMap) {
      await saveProductToGeneralInventory(
          map['barcode'], GeneralInventory.fromJson(map));
    }
  }

  //get user inventory product items from a file and saves them to the inventory box
  static Future<void> _saveUserInventoryProductsFromJson(File file) async {
    String data = await file.readAsString();
    var jsonMap = jsonDecode(data);

    for (var map in jsonMap) {
      await saveProductToUserInventory(
          map['barcode'], UserInventory.fromJson(map));
    }
  }
}
