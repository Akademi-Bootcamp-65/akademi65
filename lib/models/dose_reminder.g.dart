// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseReminderAdapter extends TypeAdapter<DoseReminder> {
  @override
  final int typeId = 2;

  @override
  DoseReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseReminder(
      drugName: fields[0] as String,
      dosage: fields[1] as String,
      scheduledTime: fields[2] as DateTime,
      isTaken: fields[3] as bool,
      takenAt: fields[4] as DateTime?,
      frequencyCount: fields[5] as int,
      frequencyUnit: fields[6] as String,
      reminderTimes: (fields[7] as List).cast<DateTime>(),
      durationDays: fields[8] as int,
      startDate: fields[9] as DateTime,
      endDate: fields[10] as DateTime,
      isActive: fields[11] as bool,
      notificationId: fields[12] as int,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DoseReminder obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.drugName)
      ..writeByte(1)
      ..write(obj.dosage)
      ..writeByte(2)
      ..write(obj.scheduledTime)
      ..writeByte(3)
      ..write(obj.isTaken)
      ..writeByte(4)
      ..write(obj.takenAt)
      ..writeByte(5)
      ..write(obj.frequencyCount)
      ..writeByte(6)
      ..write(obj.frequencyUnit)
      ..writeByte(7)
      ..write(obj.reminderTimes)
      ..writeByte(8)
      ..write(obj.durationDays)
      ..writeByte(9)
      ..write(obj.startDate)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.notificationId)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
