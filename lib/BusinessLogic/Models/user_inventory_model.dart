import 'package:hive/hive.dart';

part 'user_inventory_model.g.dart';

@HiveType(typeId: 7)
class UserInventory extends HiveObject {
  @HiveField(0)
  double numberOfPackageInsideTheCarton;
  @HiveField(1)
  String productName;
  @HiveField(2)
  String productPhoto;
  // @HiveField(3)
  // String purchaseUnit;
  // @HiveField(4)
  // String saleUnit;
  @HiveField(3)
  String section;
  @HiveField(4)
  double averagePurchasePrice;
  @HiveField(5)
  double sellingPricePerPack;
  @HiveField(6)
  double numberOfCartonsInInventory;
  @HiveField(7)
  String barCode;
  @HiveField(8)
  double numberOfPackagesOutsideCarton;

  UserInventory(
      {required this.numberOfPackageInsideTheCarton,
      required this.productName,
      required this.barCode,
      required this.productPhoto,
      // required this.purchaseUnit,
      // required this.saleUnit,
      required this.section,
      required this.averagePurchasePrice,
      required this.sellingPricePerPack,
      required this.numberOfCartonsInInventory,
      required this.numberOfPackagesOutsideCarton}) {
    if (productPhoto == null || productPhoto == "") {
      productPhoto =
          "https://drive.google.com/uc?export=view&id=1P9lRgQR8WjmfoCOHUXhIup-uXC1bab-X";
    }
  }

  factory UserInventory.fromJson(jsonMap) {
    return UserInventory(
        numberOfPackageInsideTheCarton:
            jsonMap['numberOfPackageInsideTheCarton'],
        productName: jsonMap['productName'],
        productPhoto: jsonMap['productPhoto'],
        // purchaseUnit: jsonMap['purchaseUnit'],
        // saleUnit: jsonMap['saleUnit'],
        section: jsonMap['section'],
        barCode: jsonMap['barcode'],
        averagePurchasePrice: jsonMap['averagePurchasePrice'],
        sellingPricePerPack: jsonMap['sellingPricePerPack'],
        numberOfCartonsInInventory: jsonMap['numberOfCartonsInInventory'],
        numberOfPackagesOutsideCarton:
            jsonMap['numberOfPackagesOutsideCarton']);
  }
  Map<String, dynamic> toJson() {
    return {
      'numberOfPackageInsideTheCarton': numberOfPackageInsideTheCarton,
      'productName': productName,
      'productPhoto': productPhoto,
      // 'purchaseUnit': purchaseUnit,
      // 'saleUnit': saleUnit,
      'section': section,
      'barcode': barCode,
      'averagePurchasePrice': averagePurchasePrice,
      'sellingPricePerPack': sellingPricePerPack,
      'numberOfCartonsInInventory': numberOfCartonsInInventory,
      'numberOfPackagesOutsideCarton': numberOfPackagesOutsideCarton,
    };
  }

  @override
  String toString() {
    return super.toString() +
        "  numberOfPackageInsideTheCarton:$numberOfPackageInsideTheCarton productName: $productName,productPhoto: $productPhoto"
            //",purchaseUnit: $purchaseUnit,saleUnit: $saleUnit"
            ",section: $section,averagePurchasePrice: $averagePurchasePrice,sellingPricePerPack: $sellingPricePerPack,numberOfCartonsInInventory: $numberOfCartonsInInventory";
  }

  @override
  bool operator ==(Object other) =>
      other is UserInventory &&
      other.runtimeType == runtimeType &&
      other.barCode == this.barCode;

  @override
  int get hashCode => barCode.hashCode;

  static UserInventory createEmptyProductInInventory() {
    return UserInventory(
      productName: "",
      barCode: "",
      averagePurchasePrice: 0.0,
      sellingPricePerPack: 0.0,
      numberOfCartonsInInventory: 0.0,
      // purchaseUnit: "",
      // saleUnit: "",
      numberOfPackageInsideTheCarton: 0.0,
      numberOfPackagesOutsideCarton: 0.0,
      productPhoto: "",
      section: "",
    );
  }
}
