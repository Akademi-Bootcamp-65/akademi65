import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileService {
  // Firebase removed - using local storage instead
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required DateTime birthDate,
    required String gender,
    required double height,
    required double weight,
    required String medicalConditions,
    required String emergencyContact,
  }) async {
    try {
      // Save to local storage instead of Firebase
      await _secureStorage.write(key: 'firstName', value: firstName);
      await _secureStorage.write(key: 'lastName', value: lastName);
      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'birthDate', value: birthDate.toIso8601String());
      await _secureStorage.write(key: 'gender', value: gender);
      await _secureStorage.write(key: 'height', value: height.toString());
      await _secureStorage.write(key: 'weight', value: weight.toString());
      await _secureStorage.write(key: 'medicalConditions', value: medicalConditions);
      await _secureStorage.write(key: 'emergencyContact', value: emergencyContact);
      
      debugPrint('User profile saved locally');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final firstName = await _secureStorage.read(key: 'firstName');
      if (firstName == null) return null;

      return {
        'firstName': firstName,
        'lastName': await _secureStorage.read(key: 'lastName'),
        'email': await _secureStorage.read(key: 'email'),
        'birthDate': await _secureStorage.read(key: 'birthDate'),
        'gender': await _secureStorage.read(key: 'gender'),
        'height': await _secureStorage.read(key: 'height'),
        'weight': await _secureStorage.read(key: 'weight'),
        'medicalConditions': await _secureStorage.read(key: 'medicalConditions'),
        'emergencyContact': await _secureStorage.read(key: 'emergencyContact'),
      };
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }
}
