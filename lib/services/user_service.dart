import 'package:hive/hive.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _userBoxName = 'userProfiles';
  static const String _settingsBoxName = 'settings';
  
  static Box<UserProfile>? get _userBox {
    try {
      return Hive.box<UserProfile>(_userBoxName);
    } catch (e) {
      print('UserService: userProfiles box not available: $e');
      return null;
    }
  }
  
  static Box? get _settingsBox {
    try {
      return Hive.box(_settingsBoxName);
    } catch (e) {
      print('UserService: settings box not available: $e');
      return null;
    }
  }
  
  // Check if this is the first launch
  static bool get isFirstLaunch {
    final box = _settingsBox;
    if (box == null) return true; // Default to first launch if box not available
    return !box.containsKey('hasCompletedOnboarding');
  }
  
  // Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final box = _settingsBox;
    if (box != null) {
      await box.put('hasCompletedOnboarding', true);
    }
  }
  
  // Check if user profile exists
  static bool get hasUserProfile {
    final box = _userBox;
    if (box == null) return false;
    return box.isNotEmpty && box.getAt(0)?.name.isNotEmpty == true;
  }
  
  // Get current user profile
  static UserProfile? get currentUser {
    final box = _userBox;
    if (box == null || box.isEmpty) {
      print('⚠️ UserService: No user profile found (box: ${box != null ? 'exists but empty' : 'null'})');
      return null;
    }
    
    final profile = box.getAt(0);
    if (profile != null) {
      print('✅ UserService: User profile retrieved successfully');
      print('   👤 Name: ${profile.name}');
      print('   📊 Age: ${profile.age}');
      print('   👥 Gender: ${profile.gender}');
    } else {
      print('❌ UserService: Profile at index 0 is null');
    }
    
    return profile;
  }

  // Get user profile (async version)
  static Future<UserProfile?> getUserProfile() async {
    return currentUser;
  }
  
  // Get user's name
  static String get userName {
    final user = currentUser;
    return user?.name.isNotEmpty == true ? user!.name : 'Kullanıcı';
  }
  
  // Save user profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final box = _userBox;
    if (box == null) {
      print('⚠️ UserService: Cannot save profile - userProfiles box not available');
      return;
    }
    
    print('💾 UserService: Saving user profile...');
    print('   👤 Name: ${profile.name}');
    print('   📊 Age: ${profile.age}');
    print('   👥 Gender: ${profile.gender}');
    print('   🤱 Pregnant: ${profile.isPregnant}');
    print('    Info Level: ${profile.infoLevel}');
    
    if (box.isEmpty) {
      await box.add(profile);
      print('✅ UserService: New profile saved at index 0');
    } else {
      await box.putAt(0, profile);
      print('✅ UserService: Profile updated at index 0');
    }
    
    // Verify save
    final savedProfile = box.getAt(0);
    if (savedProfile != null) {
      print('✅ UserService: Profile save verified successfully');
    } else {
      print('❌ UserService: Profile save verification failed');
    }
  }
  
  // Update user name
  static Future<void> updateUserName(String name) async {
    final box = _userBox;
    if (box == null) return;
    
    final currentProfile = currentUser;
    if (currentProfile != null) {
      final updatedProfile = UserProfile(
        name: name,
        age: currentProfile.age,
        gender: currentProfile.gender,
        isPregnant: currentProfile.isPregnant,
        infoLevel: currentProfile.infoLevel,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );
      await saveUserProfile(updatedProfile);
    } else {
      // Create new profile with just the name
      final newProfile = UserProfile(
        name: name,
        age: 0,
        gender: '',
      );
      await saveUserProfile(newProfile);
    }
  }
  
  // Clear all user data (for testing/reset)
  static Future<void> clearUserData() async {
    final userBox = _userBox;
    final settingsBox = _settingsBox;
    
    if (userBox != null) await userBox.clear();
    if (settingsBox != null) await settingsBox.clear();
  }
}
