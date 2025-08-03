import 'package:flutter/material.dart';
import '../widgets/pharmatox_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkThemeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification Settings
          _buildSettingsSection(
            'Bildirim Ayarları',
            [
              _buildSwitchTile(
                'Bildirimleri Etkinleştir',
                'İlaç hatırlatmaları ve önemli bildirimleri alın',
                Icons.notifications,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                'Ses',
                'Bildirim seslerini açın/kapatın',
                Icons.volume_up,
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
              ),
              _buildSwitchTile(
                'Titreşim',
                'Bildirim titreşimini açın/kapatın',
                Icons.vibration,
                _vibrationEnabled,
                (value) => setState(() => _vibrationEnabled = value),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // App Settings
          _buildSettingsSection(
            'Uygulama Ayarları',
            [
              _buildSwitchTile(
                'Koyu Tema',
                'Koyu görünüm temasını etkinleştir',
                Icons.dark_mode,
                _darkThemeEnabled,
                (value) => setState(() => _darkThemeEnabled = value),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Support
          _buildSettingsSection(
            'Destek',
            [
              _buildTile(
                'Hakkında',
                'Uygulama bilgileri ve sürüm',
                Icons.info,
                () => _showAbout(),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Reset button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetSettings,
              icon: const Icon(Icons.restore, color: Colors.red),
              label: const Text(
                'Ayarları Sıfırla',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90A4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4A90A4), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4A90A4),
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90A4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF4A90A4), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF636E72))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF636E72)),
      onTap: onTap,
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Pharmatox',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
        ),
        child: const PharmatoxIcon(size: 64),
      ),
      children: [
        const Text(
          'Pharmatox, ilaç takibinizi kolaylaştıran akıllı sağlık asistanınızdır. '
          'Yapay zeka destekli özelliklerle ilaçlarınızı güvenle yönetin.',
          style: TextStyle(height: 1.5),
        ),
      ],
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ayarları Sıfırla'),
        content: const Text('Tüm ayarlar varsayılan değerlere sıfırlanacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notificationsEnabled = true;
                _soundEnabled = true;
                _vibrationEnabled = true;
                _darkThemeEnabled = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ayarlar sıfırlandı'),
                  backgroundColor: Color(0xFF7CB342),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}
