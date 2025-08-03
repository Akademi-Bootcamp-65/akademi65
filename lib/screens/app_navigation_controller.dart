import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'onboarding_screen.dart';
import 'user_profile_form_screen.dart';
import 'home_screen.dart';

class AppNavigationController extends StatefulWidget {
  const AppNavigationController({super.key});

  @override
  State<AppNavigationController> createState() => _AppNavigationControllerState();
}

class _AppNavigationControllerState extends State<AppNavigationController> {
  @override
  Widget build(BuildContext context) {
    // Fallback to onboarding for now since Hive has issues
    try {
      // Check the navigation flow
      if (UserService.isFirstLaunch) {
        // First launch - show onboarding
        return const OnboardingScreen();
      } else if (!UserService.hasUserProfile) {
        // Onboarding completed but no user profile - show profile form
        return const UserProfileFormScreen();
      } else {
        // User has completed onboarding and has profile - show home
        return const HomeScreen();
      }
    } catch (e) {
      // If there's any issue with UserService, default to onboarding
      print('Navigation controller error: $e');
      return const OnboardingScreen();
    }
  }
}
