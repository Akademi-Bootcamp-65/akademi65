import 'package:flutter/material.dart';
import '../services/side_effect_analysis_service.dart';
import '../widgets/pharmatox_logo.dart';

class SideEffectAnalysisScreen extends StatefulWidget {
  const SideEffectAnalysisScreen({super.key});

  @override
  State<SideEffectAnalysisScreen> createState() => _SideEffectAnalysisScreenState();
}

class _SideEffectAnalysisScreenState extends State<SideEffectAnalysisScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _drugController = TextEditingController();
  final _sideEffectController = TextEditingController();
  
  bool _isAnalyzing = false;
  SideEffectAnalysisResult? _analysisResult;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _drugController.dispose();
    _sideEffectController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSideEffect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final result = await SideEffectAnalysisService.analyzeSideEffect(
        drugName: _drugController.text.trim(),
        reportedSideEffect: _sideEffectController.text.trim(),
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analiz hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetAnalysis() {
    setState(() {
      _analysisResult = null;
      _drugController.clear();
      _sideEffectController.clear();
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const PharmatoxIcon(size: 24),
            const SizedBox(width: 8),
            const Text(
              'Yan Etki Analizi',
              style: TextStyle(
                color: Color(0xFF4A90A4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '🔍 Yan Etki Analizi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yaşadığınız yan etkinin ilacınızla ilgili olup olmadığını analiz edelim.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Analysis Form
              if (_analysisResult == null) ...[
                _buildAnalysisForm(),
              ] else ...[
                _buildAnalysisResult(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drug Name Input
          const Text(
            'İlaç Adı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _drugController,
            decoration: InputDecoration(
              hintText: 'Örn: Aspirin, Parol, Nurofen...',
              prefixIcon: const Icon(Icons.medication, color: Color(0xFF4A90A4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen ilaç adını girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Side Effect Input
          const Text(
            'Yaşadığınız Yan Etki',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sideEffectController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Örn: Baş ağrısı, mide bulantısı, cilt döküntüsü...\nBelirtilerinizi detaylı yazın',
              prefixIcon: const Icon(Icons.warning_amber, color: Color(0xFFF59E0B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen yaşadığınız yan etkiyi açıklayın';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Analyze Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeSideEffect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: _isAnalyzing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Analiz Ediliyor...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '🔍 Yan Etki Analizini Başlat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Warning Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu analiz sadece bilgilendirme amaçlıdır. Ciddi belirtileriniz varsa mutlaka doktorunuza başvurun.',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result Header
            Row(
              children: [
                Icon(
                  _analysisResult!.isLikelyRelated ? Icons.warning : Icons.check_circle,
                  color: _analysisResult!.isLikelyRelated ? Colors.orange : Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Analiz Tamamlandı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Drug and Side Effect Info
            _buildInfoCard(
              title: 'Analiz Edilen Bilgiler',
              content: Column(
                children: [
                  _buildInfoRow('İlaç', _analysisResult!.drugName),
                  const SizedBox(height: 8),
                  _buildInfoRow('Yan Etki', _analysisResult!.reportedSideEffect),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Probability and Severity
            _buildInfoCard(
              title: 'Analiz Sonucu',
              content: Column(
                children: [
                  _buildInfoRow(
                    'İlişki Durumu', 
                    _analysisResult!.isLikelyRelated ? 'Muhtemelen İlgili' : 'Muhtemelen İlgisiz'
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Olasılık', '${_analysisResult!.probabilityPercentage}%'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Ciddiyet', _analysisResult!.severity),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recommendation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _analysisResult!.shouldStopMedication ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _analysisResult!.shouldStopMedication ? Colors.red[200]! : Colors.green[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _analysisResult!.shouldStopMedication ? Icons.stop_circle : Icons.check_circle,
                        color: _analysisResult!.shouldStopMedication ? Colors.red[600] : Colors.green[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tavsiye',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _analysisResult!.shouldStopMedication ? Colors.red[800] : Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _analysisResult!.recommendation,
                    style: TextStyle(
                      fontSize: 16,
                      color: _analysisResult!.shouldStopMedication ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Explanation
            _buildInfoCard(
              title: 'Açıklama',
              content: Text(
                _analysisResult!.explanation,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetAnalysis,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A90A4),
                      side: const BorderSide(color: Color(0xFF4A90A4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Yeni Analiz',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90A4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Ana Sayfaya Dön',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
