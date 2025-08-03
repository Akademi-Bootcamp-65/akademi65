import 'package:hive/hive.dart';

part 'side_effect_log.g.dart';

@HiveType(typeId: 3)
class SideEffectLog extends HiveObject {
  @HiveField(0)
  String drugName;

  @HiveField(1)
  String sideEffect;

  @HiveField(2)
  String severity; // 'Hafif', 'Orta', 'Şiddetli'

  @HiveField(3)
  DateTime reportedAt;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool isKnownSideEffect;

  @HiveField(6)
  bool requiresAttention;

  SideEffectLog({
    required this.drugName,
    required this.sideEffect,
    required this.severity,
    DateTime? reportedAt,
    this.notes,
    this.isKnownSideEffect = false,
    this.requiresAttention = false,
  }) : reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'drugName': drugName,
      'sideEffect': sideEffect,
      'severity': severity,
      'reportedAt': reportedAt.toIso8601String(),
      'notes': notes,
      'isKnownSideEffect': isKnownSideEffect,
      'requiresAttention': requiresAttention,
    };
  }

  factory SideEffectLog.fromJson(Map<String, dynamic> json) {
    return SideEffectLog(
      drugName: json['drugName'] ?? '',
      sideEffect: json['sideEffect'] ?? '',
      severity: json['severity'] ?? 'Hafif',
      reportedAt: DateTime.parse(json['reportedAt']),
      notes: json['notes'],
      isKnownSideEffect: json['isKnownSideEffect'] ?? false,
      requiresAttention: json['requiresAttention'] ?? false,
    );
  }
}
