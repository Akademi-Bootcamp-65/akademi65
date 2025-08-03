class SimpleReminder {
  final String id;
  final String medicationName;
  final String dosage;
  final String time;
  final bool isActive;
  final String notes;
  final DateTime createdAt;
  final List<DateTime> reminderTimes;
  final List<bool> weekdays;
  final DateTime? startDate;
  final DateTime? endDate;
  final int frequency;
  final String frequencyType;

  SimpleReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.time,
    this.isActive = true,
    this.notes = '',
    required this.createdAt,
    this.reminderTimes = const [],
    this.weekdays = const [true, true, true, true, true, true, true],
    this.startDate,
    this.endDate,
    this.frequency = 1,
    this.frequencyType = 'daily',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'time': time,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'reminderTimes': reminderTimes.map((t) => t.millisecondsSinceEpoch).toList(),
      'weekdays': weekdays,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'frequency': frequency,
      'frequencyType': frequencyType,
    };
  }

  factory SimpleReminder.fromMap(Map<String, dynamic> map) {
    return SimpleReminder(
      id: map['id'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '08:00',
      isActive: map['isActive'] ?? true,
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      reminderTimes: map['reminderTimes'] != null
          ? (map['reminderTimes'] as List).map((t) => DateTime.fromMillisecondsSinceEpoch(t)).toList()
          : [],
      weekdays: map['weekdays'] != null
          ? List<bool>.from(map['weekdays'])
          : [true, true, true, true, true, true, true],
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'])
          : null,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      frequency: map['frequency'] ?? 1,
      frequencyType: map['frequencyType'] ?? 'daily',
    );
  }

  @override
  String toString() {
    return 'SimpleReminder(id: $id, medicationName: $medicationName, dosage: $dosage, time: $time, isActive: $isActive)';
  }
}
