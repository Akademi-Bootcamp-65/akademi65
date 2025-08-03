import 'package:hive/hive.dart';

part 'drug_info.g.dart';

@HiveType(typeId: 1)
class DrugInfo extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String activeIngredient;

  @HiveField(2)
  String usage;

  @HiveField(3)
  String dosage;

  @HiveField(4)
  List<String> sideEffects;

  @HiveField(5)
  List<String> contraindications;

  @HiveField(6)
  List<String> interactions;

  @HiveField(7)
  String pregnancyWarning;

  @HiveField(8)
  String storageInfo;

  @HiveField(9)
  String overdoseInfo;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  String? prospectusUrl;

  DrugInfo({
    required this.name,
    required this.activeIngredient,
    required this.usage,
    required this.dosage,
    required this.sideEffects,
    required this.contraindications,
    required this.interactions,
    required this.pregnancyWarning,
    required this.storageInfo,
    required this.overdoseInfo,
    DateTime? createdAt,
    this.prospectusUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activeIngredient': activeIngredient,
      'usage': usage,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'interactions': interactions,
      'pregnancyWarning': pregnancyWarning,
      'storageInfo': storageInfo,
      'overdoseInfo': overdoseInfo,
      'createdAt': createdAt.toIso8601String(),
      'prospectusUrl': prospectusUrl,
    };
  }

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      name: json['name'] ?? '',
      activeIngredient: json['activeIngredient'] ?? '',
      usage: json['usage'] ?? '',
      dosage: json['dosage'] ?? '',
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
      pregnancyWarning: json['pregnancyWarning'] ?? '',
      storageInfo: json['storageInfo'] ?? '',
      overdoseInfo: json['overdoseInfo'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      prospectusUrl: json['prospectusUrl'],
    );
  }
}
