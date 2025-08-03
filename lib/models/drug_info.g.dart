// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrugInfoAdapter extends TypeAdapter<DrugInfo> {
  @override
  final int typeId = 1;

  @override
  DrugInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrugInfo(
      name: fields[0] as String,
      activeIngredient: fields[1] as String,
      usage: fields[2] as String,
      dosage: fields[3] as String,
      sideEffects: (fields[4] as List).cast<String>(),
      contraindications: (fields[5] as List).cast<String>(),
      interactions: (fields[6] as List).cast<String>(),
      pregnancyWarning: fields[7] as String,
      storageInfo: fields[8] as String,
      overdoseInfo: fields[9] as String,
      createdAt: fields[10] as DateTime?,
      prospectusUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DrugInfo obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.activeIngredient)
      ..writeByte(2)
      ..write(obj.usage)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.sideEffects)
      ..writeByte(5)
      ..write(obj.contraindications)
      ..writeByte(6)
      ..write(obj.interactions)
      ..writeByte(7)
      ..write(obj.pregnancyWarning)
      ..writeByte(8)
      ..write(obj.storageInfo)
      ..writeByte(9)
      ..write(obj.overdoseInfo)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.prospectusUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
