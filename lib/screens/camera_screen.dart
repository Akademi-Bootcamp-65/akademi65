import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../models/drug_info.dart';
import '../models/enhanced_drug_analysis.dart';
import 'package:hive/hive.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _capturedImage;
  bool _isAnalyzing = false;
  PrescriptionAnalysisResult? _analysisResult;
  String _analysisStatus = '';
  List<String> _detectedDrugs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8), // Light blue background matching design
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reçete Tarayıcı',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_capturedImage == null) ...[
              // Camera/Upload Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera Icon with gradient background
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(75),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4A90A4), // Teal
                            Color(0xFF7CB342), // Green
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90A4).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Reçete Fotoğrafı Çek',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Reçetenizi fotoğraflayın veya galerinizden\nbir fotoğraf seçin. Yapay zeka\nilaçlarınızı analiz edecek.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF636E72),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _captureImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'Fotoğraf Çek',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90A4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _captureImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, color: Color(0xFF4A90A4)),
                            label: const Text(
                              'Galeriden Seç',
                              style: TextStyle(color: Color(0xFF4A90A4), fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF4A90A4)),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Image Preview and Analysis Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image Preview Card
                      Container(
                        width: double.infinity,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_capturedImage!.path),
                            fit: BoxFit.cover,
                            height: 250,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isAnalyzing ? null : _analyzeImage,
                              icon: _isAnalyzing 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.analytics, color: Colors.white),
                              label: Text(
                                _isAnalyzing ? 'Analiz Ediliyor...' : 'Analiz Et',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7CB342),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _retakePhoto,
                            icon: const Icon(Icons.refresh, color: Color(0xFF4A90A4)),
                            label: const Text(
                              'Yeniden Çek',
                              style: TextStyle(color: Color(0xFF4A90A4), fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF4A90A4)),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Analysis Status Indicator
                      if (_isAnalyzing) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90A4)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _analysisStatus,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3436),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_detectedDrugs.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Tespit edilen ilaçlar: ${_detectedDrugs.join(", ")}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF636E72),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Analysis Results
                      if (_analysisResult != null) ...[
                        _buildAnalysisResults(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF7CB342),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analiz Sonuçları',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Enhanced analysis results
          if (_analysisResult!.enhancedAnalyses.isNotEmpty) ...[
            ..._analysisResult!.enhancedAnalyses.map((analysis) => 
              _buildEnhancedDrugAnalysis(analysis)
            ),
          ] else if (_analysisResult!.drugs.isNotEmpty) ...[
            // Fallback to basic drug info display
            ..._analysisResult!.drugs.map((drug) => 
              _buildBasicDrugInfo(drug)
            ),
          ],
          
          // Display any error message if present
          if (_analysisResult!.hasErrors && _analysisResult!.errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _analysisResult!.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Save to Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveDrugsToProfile,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Profilime Kaydet',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90A4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced drug analysis with dynamic cards
  Widget _buildEnhancedDrugAnalysis(EnhancedDrugAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drug Name Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90A4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              analysis.drugName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Dynamic Cards
          Column(
            children: analysis.sortedCards.map((card) => 
              _buildDynamicCard(card)
            ).toList(),
          ),
        ],
      ),
    );
  }

  /// Build dynamic card based on analysis data
  Widget _buildDynamicCard(DrugAnalysisCard card) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _parseColor(card.color).withOpacity(0.1),
        border: Border.all(color: _parseColor(card.color).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _parseIcon(card.icon), 
                color: _parseColor(card.color), 
                size: 20
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _parseColor(card.color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Parse color from hex string
  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF' + hexColor; // Add alpha if missing
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFF4A90A4); // Default blue
    }
  }

  /// Parse icon from string name
  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'medical_services':
        return Icons.medical_services;
      case 'schedule':
        return Icons.schedule;
      case 'warning':
        return Icons.warning;
      case 'error_outline':
        return Icons.error_outline;
      case 'compare_arrows':
        return Icons.compare_arrows;
      case 'block':
        return Icons.block;
      case 'storage':
        return Icons.storage;
      case 'emergency':
        return Icons.emergency;
      case 'info':
        return Icons.info;
      case 'alternative_route':
        return Icons.alt_route;
      default:
        return Icons.info;
    }
  }

  Widget _buildInfoCard(String title, String content, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _analysisResult = null; // Reset previous analysis
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf çekme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisStatus = 'İlaç isimleri tespit ediliyor...';
      _detectedDrugs = [];
    });

    try {
      // Step 1: Drug detection
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _analysisStatus = 'Prospektüsler aranıyor...';
      });

      // Step 2: Prospectus search
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _analysisStatus = 'PDF\'ler indiriliyor ve işleniyor...';
      });

      // Step 3: PDF processing
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _analysisStatus = 'Veriler analiz ediliyor...';
      });

      // Step 4: Analysis
      final result = await CameraService.analyzeImage(
        File(_capturedImage!.path),
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
        _analysisStatus = 'Analiz tamamlandı!';
        _detectedDrugs = result.drugs.map((d) => d.name).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reçete analizi tamamlandı'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisStatus = 'Analiz hatası oluştu';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _analysisResult = null;
      _analysisStatus = '';
      _detectedDrugs = [];
    });
  }

  Future<void> _saveDrugsToProfile() async {
    if (_analysisResult == null || _analysisResult!.drugs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek ilaç bulunamadı'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Save drugs to Hive storage
      final drugBox = Hive.box<DrugInfo>('drugs');
      for (final drug in _analysisResult!.drugs) {
        await drugBox.add(drug);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlaçlar profilinize kaydedildi'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );

      // Navigate back to home
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaydetme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build basic drug info (fallback)
  Widget _buildBasicDrugInfo(DrugInfo drug) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drug Name Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90A4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              drug.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Basic info cards
          if (drug.usage.isNotEmpty)
            _buildInfoCard('Kullanım Amacı', drug.usage, const Color(0xFF74B9FF), Icons.medical_services),
          if (drug.dosage.isNotEmpty)
            _buildInfoCard('Doz Bilgisi', drug.dosage, const Color(0xFF55A3FF), Icons.schedule),
          if (drug.sideEffects.isNotEmpty)
            _buildInfoCard('Yan Etkiler', drug.sideEffects.join(', '), const Color(0xFFE17055), Icons.error_outline),
        ],
      ),
    );
  }
}
