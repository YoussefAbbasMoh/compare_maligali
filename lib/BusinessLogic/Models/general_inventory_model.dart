import 'package:hive/hive.dart';
part 'general_inventory_model.g.dart';

@HiveType(typeId: 0)
class GeneralInventory extends HiveObject {
  //attributes
  @HiveField(0)
  String numberOfPackageInsideTheCarton;

  @HiveField(1)
  String productName;

  @HiveField(2)
  String productPhoto;

  // @HiveField(3)
  // String purchaseUnit;
  //
  // @HiveField(4)
  // String saleUnit;

  @HiveField(3)
  String section;

  @HiveField(4)
  String barCode;

  //constructors

  GeneralInventory({
    required this.numberOfPackageInsideTheCarton,
    required this.productName,
    required this.productPhoto,
    // required this.purchaseUnit,
    // required this.saleUnit,
    required this.section,
    required this.barCode,
  });
  factory GeneralInventory.fromJson(jsonMap) {
    return GeneralInventory(
        numberOfPackageInsideTheCarton:
            jsonMap['numberOfPackageInsideTheCarton'],
        productName: jsonMap['productName'],
        productPhoto: jsonMap['productPhoto'],
        // purchaseUnit: jsonMap['purchaseUnit'],
        // saleUnit: jsonMap['saleUnit'],
        section: jsonMap['section'],
        barCode: jsonMap['barcode']);
  }

  @override
  String toString() {
    // TODO: implement toString
    return super.toString() +
        "  numberOfPackageInsideTheCarton:$numberOfPackageInsideTheCarton productName: $productName,productPhoto: $productPhoto,"
            // "purchaseUnit: $purchaseUnit,saleUnit: $saleUnit"
            "section: $section";
  }

  @override
  bool operator ==(Object other) =>
      other is GeneralInventory &&
      other.runtimeType == runtimeType &&
      other.barCode == this.barCode;

  @override
  int get hashCode => barCode.hashCode;
}
