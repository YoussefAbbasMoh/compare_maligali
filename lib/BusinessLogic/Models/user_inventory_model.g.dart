// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInventoryAdapter extends TypeAdapter<UserInventory> {
  @override
  final int typeId = 7;

  @override
  UserInventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInventory(
      numberOfPackageInsideTheCarton: fields[0] as double,
      productName: fields[1] as String,
      barCode: fields[7] as String,
      productPhoto: fields[2] as String,
      section: fields[3] as String,
      averagePurchasePrice: fields[4] as double,
      sellingPricePerPack: fields[5] as double,
      numberOfCartonsInInventory: fields[6] as double,
      numberOfPackagesOutsideCarton: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserInventory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.numberOfPackageInsideTheCarton)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productPhoto)
      ..writeByte(3)
      ..write(obj.section)
      ..writeByte(4)
      ..write(obj.averagePurchasePrice)
      ..writeByte(5)
      ..write(obj.sellingPricePerPack)
      ..writeByte(6)
      ..write(obj.numberOfCartonsInInventory)
      ..writeByte(7)
      ..write(obj.barCode)
      ..writeByte(8)
      ..write(obj.numberOfPackagesOutsideCarton);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
