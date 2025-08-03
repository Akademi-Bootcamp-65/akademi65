// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_effect_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SideEffectLogAdapter extends TypeAdapter<SideEffectLog> {
  @override
  final int typeId = 3;

  @override
  SideEffectLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideEffectLog(
      drugName: fields[0] as String,
      sideEffect: fields[1] as String,
      severity: fields[2] as String,
      reportedAt: fields[3] as DateTime?,
      notes: fields[4] as String?,
      isKnownSideEffect: fields[5] as bool,
      requiresAttention: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SideEffectLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.drugName)
      ..writeByte(1)
      ..write(obj.sideEffect)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.reportedAt)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.isKnownSideEffect)
      ..writeByte(6)
      ..write(obj.requiresAttention);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideEffectLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
