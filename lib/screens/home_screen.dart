import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../widgets/pharmatox_logo.dart';
import 'user_profile_screen.dart';
import 'camera_screen.dart';
import 'chat_screen.dart';
import 'about_screen.dart';
import 'interaction_checker_screen.dart';
import 'settings_screen.dart';
import 'modern_reminders_screen.dart';
import 'side_effect_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await NotificationService.initialize();
    await NotificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white, // Pure white background
      drawer: _buildSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and menu
            _buildHeader(),
            
            // Welcome message
            _buildWelcomeMessage(),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Feature cards in 2x3 grid matching new design
                    _buildFeatureGrid(),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Clickable Logo matching design
          GestureDetector(
            onTap: () {
              try {
                _scaffoldKey.currentState?.openDrawer();
              } catch (e) {
                print('Error opening drawer: $e');
              }
            },
            child: Row(
              children: [
                // Logo icon without gradient background
                const PharmatoxIcon(
                  size: 40,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pharmatox',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90A4),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Removed hamburger menu - now sidebar opens via logo tap
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Merhaba, ${UserService.userName},',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4A90A4), // Solid color instead of gradient
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const PharmatoxIcon(
                    size: 32,
                    color: Color(0xFF4A90A4),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pharmatox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  UserService.userName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Menu Item
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF4A90A4)),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _openProfile(); // Ana sayfadaki profil butonuyla aynı navigasyon
            },
          ),
          
          // Side Effect Analysis Menu Item
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF4A90A4)),
            title: const Text('Yan Etki Analizi'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _openSideEffectAnalysis();
            },
          ),
          
          // About Menu Item
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF4A90A4)),
            title: const Text('Pharmatox Hakkında'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
          
          // Settings Menu Item
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Color(0xFF4A90A4)),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // App Version
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Sürüm 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        // First row - 2 cards
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'Sohbet',
                subtitle: 'Pharmatox AI sohbet servisi',
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF6366F1), // Modern indigo
                onTap: _openChat,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                title: 'Kamera',
                subtitle: 'Fotoğraf çekerek ilaç sorgulayın',
                icon: Icons.camera_alt_outlined,
                color: const Color(0xFF10B981), // Modern emerald
                onTap: _openCamera,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Second row - 2 cards  
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'Takvim',
                subtitle: 'İlaçlarınızı takip edin',
                icon: Icons.calendar_today_outlined,
                color: const Color(0xFFF59E0B), // Modern amber
                onTap: _openReminders,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                title: 'Etkileşimler',
                subtitle: 'İlaçlarınızın etkileşim risklerini analiz edin',
                icon: Icons.sync_alt_outlined,
                color: const Color(0xFFEF4444), // Modern red
                onTap: _openInteractionChecker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Third row - 2 cards
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'Yan Etki Analizi',
                subtitle: 'Yaşadığınız yan etkiyi analiz edin',
                icon: Icons.health_and_safety_outlined,
                color: const Color(0xFF8B5CF6), // Modern violet
                onTap: _openSideEffectAnalysis,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                title: 'Ayarlar',
                subtitle: 'Uygulama ayarlarını düzenleyin',
                icon: Icons.settings_outlined,
                color: const Color(0xFFEC4899), // Modern pink
                onTap: _openSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Increased height to prevent overflow
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16), // Reduced padding slightly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28, // Slightly smaller icon
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15, // Slightly smaller font
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11, // Smaller subtitle
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openInteractionChecker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InteractionCheckerScreen(),
      ),
    );
  }

  void _openReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernRemindersScreen(),
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }

  void _openSideEffectAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SideEffectAnalysisScreen(),
      ),
    );
  }
}
