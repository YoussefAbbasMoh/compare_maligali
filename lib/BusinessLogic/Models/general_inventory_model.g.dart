// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeneralInventoryAdapter extends TypeAdapter<GeneralInventory> {
  @override
  final int typeId = 0;

  @override
  GeneralInventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneralInventory(
      numberOfPackageInsideTheCarton: fields[0] as String,
      productName: fields[1] as String,
      productPhoto: fields[2] as String,
      section: fields[3] as String,
      barCode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GeneralInventory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.numberOfPackageInsideTheCarton)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productPhoto)
      ..writeByte(3)
      ..write(obj.section)
      ..writeByte(4)
      ..write(obj.barCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralInventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
