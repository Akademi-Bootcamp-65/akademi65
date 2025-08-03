import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  int age;

  @HiveField(1)
  String gender;

  @HiveField(2)
  bool isPregnant;

  @HiveField(4)
  String infoLevel; // 'Sade', 'Orta', 'Detaylı'

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  String name; // Added user's name field

  UserProfile({
    required this.age,
    required this.gender,
    this.isPregnant = false,
    this.infoLevel = 'Orta',
    this.name = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'isPregnant': isPregnant,
      'infoLevel': infoLevel,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      isPregnant: json['isPregnant'] ?? false,
      infoLevel: json['infoLevel'] ?? 'Orta',
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
