import 'package:hive/hive.dart';

part 'dose_reminder.g.dart';

@HiveType(typeId: 2)
class DoseReminder extends HiveObject {
  @HiveField(0)
  String drugName;

  @HiveField(1)
  String dosage;

  @HiveField(2)
  DateTime scheduledTime;

  @HiveField(3)
  bool isTaken;

  @HiveField(4)
  DateTime? takenAt;

  @HiveField(5)
  int frequencyCount; // e.g., 2 for "2 times a day"

  @HiveField(6)
  String frequencyUnit; // 'day', 'week', 'month'

  @HiveField(7)
  List<DateTime> reminderTimes; // Multiple times per day if needed

  @HiveField(8)
  int durationDays;

  @HiveField(9)
  DateTime startDate;

  @HiveField(10)
  DateTime endDate;

  @HiveField(11)
  bool isActive;

  @HiveField(12)
  int notificationId;

  @HiveField(13)
  String? notes;

  DoseReminder({
    required this.drugName,
    required this.dosage,
    required this.scheduledTime,
    this.isTaken = false,
    this.takenAt,
    required this.frequencyCount,
    required this.frequencyUnit,
    required this.reminderTimes,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.notificationId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'dosage': dosage,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isTaken': isTaken,
      'takenAt': takenAt?.toIso8601String(),
      'frequencyCount': frequencyCount,
      'frequencyUnit': frequencyUnit,
      'reminderTimes': reminderTimes.map((time) => time.toIso8601String()).toList(),
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'notificationId': notificationId,
      'notes': notes,
    };
  }

  factory DoseReminder.fromJson(Map<String, dynamic> json) {
    return DoseReminder(
      drugName: json['drugName'] ?? '',
      dosage: json['dosage'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isTaken: json['isTaken'] ?? false,
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
      frequencyCount: json['frequencyCount'] ?? 1,
      frequencyUnit: json['frequencyUnit'] ?? 'day',
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
          ?.map((timeStr) => DateTime.parse(timeStr as String))
          .toList() ?? [],
      durationDays: json['durationDays'] ?? 1,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      notificationId: json['notificationId'] ?? 0,
      notes: json['notes'],
    );
  }

  String get frequencyDisplayText {
    switch (frequencyUnit) {
      case 'day':
        return frequencyCount == 1 ? 'Günde 1 kez' : 'Günde $frequencyCount kez';
      case 'week':
        return frequencyCount == 1 ? 'Haftada 1 kez' : 'Haftada $frequencyCount kez';
      case 'month':
        return frequencyCount == 1 ? 'Ayda 1 kez' : 'Ayda $frequencyCount kez';
      default:
        return 'Günde $frequencyCount kez';
    }
  }
}
