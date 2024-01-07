import 'package:flutter/cupertino.dart';
import 'package:maligali/BusinessLogic/Models/user_inventory_model.dart';
import 'package:provider/provider.dart';
import '../../Services/FireBaseServices/coll_inventory_activity_services.dart';
import '../../Services/local_inventory_services/user_inventory_services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/dropdownLists/cleaningDropDownItems.dart';
import '../../utils/dropdownLists/groceryDropdowns.dart';
import '../../utils/dropdownLists/roastersDropDownItems.dart';
import '../../utils/dropdownLists/stationaryDropDownItems.dart';
import '../../utils/globalSnackBar.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import '../../utils/enums.dart';
import 'dart:math';
import 'dart:io';

import 'inventory_page_view_model.dart';

/*this view model is responsible for the operations related to adding a new custom product to the users inventory
this view model :
-generates a new barcode for the item
-takes and uploads an image of it to firestore and stores its link
- creates and adds a new item to the users inventory

 */
class AddToUserInvVM extends ChangeNotifier {
  ////////////attributes
  UserInventoryServices userInvServicesObj =
      UserInventoryServices(); //user inventory services instance used to call its functions
  InventoryActivityServices invActivityServicesObj =
      InventoryActivityServices(); //user inventory activity instance used to call its functions
  FirebaseStorage storage = FirebaseStorage
      .instance; //firebase storage instance used when uploading newly taken pictures of new custom products

//////////////////////////functions for preparing the creating of a new item///////////////////
//responsible for generating a new custom barcode for an item if the user doesn't want to enter one manually
  String generateBarCodeFromDropDown(String shopType, String section) {
    String generatedBarCode = "000";
    if(shopType == "grocery"){
      generatedBarCode = grocerySectionsBarCodes[section]!; //uses the products section to assign the start of the newly generated barcode
    }
    else if(shopType == "roasters"){
      generatedBarCode = roastersSectionsBarCodes[section]!;
    }
    else if(shopType == "cleaning"){
      generatedBarCode = cleaningSectionsBarCodes[section]!;
    }
    else if(shopType == "stationary") {
      generatedBarCode = stationarySectionsBarCodes[section]!;
    }

    Random randomNumb = Random();
    String randomNumber = randomNumb
        .nextInt(10000)
        .toString(); //random number used to complete the generated barcode
    generatedBarCode =
    '$generatedBarCode$randomNumber'; //new barcode = section code + randomly generated number
    return generatedBarCode;
  }

  String generateBarCodeNoDropDown(String shopType, String section){
    String firstDigit = shopType.length.toString();
    String secondDigit = (section.length+10).toString();

    Random randomNumb = Random();
    String randomNumber = randomNumb
        .nextInt(10000)
        .toString(); //random number used to complete the generated barcode
    String generatedBarCode = firstDigit+secondDigit+randomNumber;

    return generatedBarCode;
  }



//responsible for capturing an image from users the camera
  Future<XFile?> captureImgFromCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final CameraController _controller = CameraController(
      firstCamera,
      ResolutionPreset.low, ////resolution of the image that will be taken
    );
    final Future<void> _initializeControllerFuture = _controller.initialize();
    try {
      await _initializeControllerFuture;
      final XFile image =
          await _controller.takePicture(); //image that will be taken
      return image; //return the image if it was taken succesfully
    } catch (e) {
      return null; //if taking an image fails, null is returned
    }
  }

//responsible for uploading a newly taken image for a user inventory item to firestore
  Future<String?> uploadImageToStorage(File? itemPhotoCaptured) async {
    String capturedImageDBStoragePath =
        ""; //url that will store a link to the image after uploading it

    // upload image to the storage
    if (itemPhotoCaptured == null) {
      return null; //if the image to upload is null, stop and return null
    }
    final fileName = basename(
        itemPhotoCaptured.path); //name of the file will be name of the image
    final destination =
        'UsersCapturedImages/$fileName'; //path of the image on firebase storage
    try {
      //atempt to upload image and store a link to it
      final ref = storage.ref(destination);
      await ref.putFile(itemPhotoCaptured);
      capturedImageDBStoragePath = await ref.getDownloadURL();
    } catch (e) {
      displaySnackBar(text:"حدث خطأ في التسجيل"); //if upload fails
    }
    return capturedImageDBStoragePath; //if upload is succesful reutrn a link to the image
  }

//repsonsible for adding a new custom product to the user inventory
  Future<String> creatingAndAddNewProductToUserInventory({
    required BuildContext context,
    required bool existInGenInv,
    required String numberOfCartonsInInventory,
    required String productName,
    required String barcode,
    required String averagePurchasePrice,
    required String sellingPricePerPack,
    // String purchaseUnit,
    // String saleUnit,
    required String numberOfPackageInsideTheCarton,
    required String numberOfPackagesOutsideCarton,
    required String productPhoto,
    required String section,
    required String date
  }) async {
    //create a new user inventory instance from the collected data about the new custom product
    UserInventory newProduct = UserInventory(
      numberOfPackagesOutsideCarton:
          double.parse(numberOfPackagesOutsideCarton),
      numberOfCartonsInInventory: double.parse(numberOfCartonsInInventory),
      productName: productName,
      barCode: barcode,
      averagePurchasePrice: double.parse(averagePurchasePrice),
      sellingPricePerPack: double.parse(sellingPricePerPack),
      // purchaseUnit: purchaseUnit,
      // saleUnit: saleUnit,
      numberOfPackageInsideTheCarton:
          double.parse(numberOfPackageInsideTheCarton),
      productPhoto: productPhoto,
      section: section,
    );
    //prepare data to store about the adding operation
    Map<String, String> activityData = existInGenInv
        ? invActivityServicesObj.prepareDataForCreateFromGenInvActivity(
            //if the product existed in general inventory
            productName,
            numberOfCartonsInInventory.toString(),
            numberOfPackagesOutsideCarton,
            averagePurchasePrice,
            sellingPricePerPack,
            date)
        : invActivityServicesObj.prepareDataForCreateNewActivity(
            //if the product is completely new/custom
            productName,
            numberOfCartonsInInventory.toString(),
            numberOfPackagesOutsideCarton,
            averagePurchasePrice,
            sellingPricePerPack,
            date);

    String res_1 = await userInvServicesObj.addProductToUserInventory(
        newProduct); //attempt to add the product instance to the user inventory , retuns done if sucessful
    String res_2 = await invActivityServicesObj.createNewActivity(
        activityData); //attempt to store the data about the adding activity , return done if succesful

    if (res_1 == "done" && res_2 == "done") {
      //if both are sucessful
      Provider.of<InventoryPageVM>(context, listen: false).refreshInventoryPageVM();
      return "done";
    } else {
      //if one or both fail
      return "fail";
    }
  }
}
