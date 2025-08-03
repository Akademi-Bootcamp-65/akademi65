import 'package:flutter/material.dart';
import '../widgets/pharmatox_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'Hakkında',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Icon and Name
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo bölümü - artık PharmatoxLogo kullanıyor
                  const PharmatoxLogo(
                    width: 100,
                    height: 100,
                    showText: false,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pharmatox',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90A4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kişisel İlaç Asistanınız',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7CB342).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Sürüm 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7CB342),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const Text(
                    'Pharmatox Nedir?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pharmatox, günlük ilaç kullanımınızı kolaylaştırmak ve daha güvenli hale getirmek için tasarlanmış akıllı bir sağlık uygulamasıdır. Yapay zeka teknolojisi ile desteklenen özelliklerle, ilaçlarınızı takip etmenizi, doğru zamanlarda almanızı ve olası etkileşimleri önceden tespit etmenizi sağlar.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Features
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const Text(
                    'Özellikler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFeatureItem(
                    Icons.chat_bubble_outline,
                    'AI Sohbet',
                    'İlaçlarınız hakkında yapay zeka ile sohbet edin',
                  ),
                  _buildFeatureItem(
                    Icons.search,
                    'İlaç Sorgulama',
                    'Hızlı ve güvenilir ilaç bilgilerini alın',
                  ),
                  _buildFeatureItem(
                    Icons.camera_alt,
                    'Reçete Tarayıcı',
                    'Reçetelerinizi fotoğraflayarak ilaç bilgilerini çıkarın',
                  ),
                  _buildFeatureItem(
                    Icons.schedule,
                    'İlaç Takvimi',
                    'Akıllı hatırlatmalarla ilaçlarınızı zamanında alın',
                  ),
                  _buildFeatureItem(
                    Icons.warning_amber,
                    'Etkileşim Kontrolü',
                    'İlaçlar arasındaki etkileşimleri kontrol edin',
                  ),
                  _buildFeatureItem(
                    Icons.report_problem,
                    'Yan Etki Takibi',
                    'Yaşadığınız yan etkileri kaydedin ve analiz edin',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Important Notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Önemli Uyarı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu uygulama bilgilendirme amaçlıdır ve profesyonel tıbbi tavsiye yerine geçmez. İlaç kullanımı konusunda mutlaka doktorunuza danışın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636E72),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contact & Legal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const Text(
                    'İletişim ve Yasal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildContactItem(Icons.email, 'E-posta', 'support@pharmatox.com'),
                  _buildContactItem(Icons.web, 'Web Site', 'www.pharmatox.com'),
                  _buildContactItem(Icons.privacy_tip, 'Gizlilik', 'Gizlilik politikamızı okuyun'),
                  _buildContactItem(Icons.description, 'Koşullar', 'Kullanım şartlarını inceleyin'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Copyright
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '© 2025 Pharmatox',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tüm hakları saklıdır.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90A4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4A90A4), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90A4), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
