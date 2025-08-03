import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Starting Pharmatox app...');
  
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
