// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_profile.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive with minimal setup to avoid corruption issues
    await Hive.initFlutter();
    
    // Register only essential adapters
    Hive.registerAdapter(UserProfileAdapter());
    
    // Only open essential boxes with clean slate approach
    try {
      await Hive.openBox<UserProfile>('userProfiles');
      print('userProfiles box opened successfully');
    } catch (e) {
      print('Error opening userProfiles box: $e');
      try {
        await Hive.deleteBoxFromDisk('userProfiles');
        await Hive.openBox<UserProfile>('userProfiles');
        print('userProfiles box recreated successfully');
      } catch (e2) {
        print('Failed to recreate userProfiles box: $e2');
      }
    }
    
    try {
      await Hive.openBox('settings');
      print('settings box opened successfully');
    } catch (e) {
      print('Error opening settings box: $e');
      try {
        await Hive.deleteBoxFromDisk('settings');
        await Hive.openBox('settings');
        print('settings box recreated successfully');
      } catch (e2) {
        print('Failed to recreate settings box: $e2');
      }
    }
    
    print('Hive initialized successfully with minimal setup');
  } catch (e) {
    print('Error initializing Hive: $e');
  }
  
  runApp(const PharmatoxApp());
}

class PharmatoxApp extends StatelessWidget {
  const PharmatoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmatox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3A1)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const OnboardingScreen(),
    );
  }
}
