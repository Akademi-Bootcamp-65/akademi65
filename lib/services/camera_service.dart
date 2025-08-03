import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/drug_info.dart';
import '../models/enhanced_drug_analysis.dart';
import '../services/openai_service.dart';
import '../services/prospectus_service.dart';

class PrescriptionAnalysisResult {
  final List<DrugInfo> drugs;
  final List<EnhancedDrugAnalysis> enhancedAnalyses;
  final String extractedText;
  final bool hasErrors;
  final String? errorMessage;

  PrescriptionAnalysisResult({
    required this.drugs,
    required this.enhancedAnalyses,
    required this.extractedText,
    this.hasErrors = false,
    this.errorMessage,
  });

  factory PrescriptionAnalysisResult.error(String errorMessage) {
    return PrescriptionAnalysisResult(
      drugs: [],
      enhancedAnalyses: [],
      extractedText: '',
      hasErrors: true,
      errorMessage: errorMessage,
    );
  }
}

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Takes a photo from camera
  static Future<XFile?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return photo;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Picks an image from gallery
  static Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking from gallery: $e');
      return null;
    }
  }

  /// Analyzes a prescription image and extracts drug information
  static Future<PrescriptionAnalysisResult> analyzeImage(File imageFile) async {
    try {
      print('🔍 Starting prescription analysis...');
      
      // Create OpenAI service instance
      final openAIService = OpenAIService();
      
      // Extract text from image using OpenAI
      final extractedText = await openAIService.extractTextFromImage(imageFile);
      if (extractedText == null || extractedText.isEmpty) {
        return PrescriptionAnalysisResult.error('No text could be extracted from the image');
      }

      print('📝 Extracted text: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');

      // Extract drug names from the text
      final drugNames = await _extractDrugNames(extractedText);
      if (drugNames.isEmpty) {
        return PrescriptionAnalysisResult.error('No drug names could be identified in the prescription');
      }

      print('💊 Found ${drugNames.length} drugs: ${drugNames.join(', ')}');

      // Get basic drug information
      final drugs = <DrugInfo>[];
      final enhancedAnalyses = <EnhancedDrugAnalysis>[];

      for (String drugName in drugNames) {
        try {
          // Create basic drug info (accepting all extracted names)
          final drugInfo = DrugInfo(
            name: drugName,
            activeIngredient: '', // Will be filled by prospectus if available
            usage: 'Consult your healthcare provider for proper usage instructions',
            dosage: 'As prescribed by healthcare provider',
            sideEffects: [],
            contraindications: [],
            interactions: [],
            pregnancyWarning: 'Consult your healthcare provider before use during pregnancy',
            storageInfo: 'Store according to package instructions',
            overdoseInfo: 'Contact emergency services immediately if overdose is suspected',
          );
          drugs.add(drugInfo);

          // Try to get enhanced analysis from prospectus service
          try {
            final enhancedData = await ProspectusService.getEnhancedDrugAnalysis(drugName);
            if (enhancedData != null) {
              // Create EnhancedDrugAnalysis from the data
              final enhancedAnalysis = EnhancedDrugAnalysis.fromJson({
                'drugName': drugName,
                'cards': enhancedData['cards'] ?? [],
              });
              enhancedAnalyses.add(enhancedAnalysis);
              print('✅ Enhanced analysis obtained for $drugName');
            }
          } catch (e) {
            print('⚠️ Could not get enhanced analysis for $drugName: $e');
          }
        } catch (e) {
          print('⚠️ Error processing drug $drugName: $e');
        }
      }

      return PrescriptionAnalysisResult(
        drugs: drugs,
        enhancedAnalyses: enhancedAnalyses,
        extractedText: extractedText,
      );

    } catch (e) {
      print('❌ Error during prescription analysis: $e');
      return PrescriptionAnalysisResult.error('Analysis failed: ${e.toString()}');
    }
  }

  /// Extract drug names from text using AI - accepts all AI results
  static Future<List<String>> _extractDrugNames(String text) async {
    try {
      print('🤖 Using AI to extract drug names...');
      
      // Create OpenAI service instance
      final openAIService = OpenAIService();
      
      // Use OpenAI to extract drug names
      final aiDrugNames = await openAIService.extractDrugNamesFromText(text);
      if (aiDrugNames != null && aiDrugNames.isNotEmpty) {
        print('✅ AI extracted ${aiDrugNames.length} drug names: ${aiDrugNames.join(', ')}');
        // Accept all AI results without validation
        return aiDrugNames;
      }
      
      print('⚠️ AI extraction returned no results, trying basic extraction...');
      return _extractDrugNamesBasic(text);
      
    } catch (e) {
      print('⚠️ AI extraction error: $e, falling back to basic extraction');
      return _extractDrugNamesBasic(text);
    }
  }

  /// Basic drug name extraction as fallback - very permissive
  static List<String> _extractDrugNamesBasic(String text) {
    final drugNames = <String>[];
    final words = text.split(RegExp(r'[\s\n\r,;.]+'));
    
    for (String word in words) {
      final cleanWord = word.trim();
      if (cleanWord.length >= 3 && _looksLikeDrugName(cleanWord)) {
        drugNames.add(cleanWord);
      }
    }
    
    // Remove duplicates
    final uniqueDrugNames = drugNames.toSet().toList();
    print('📋 Basic extraction found ${uniqueDrugNames.length} potential drugs: ${uniqueDrugNames.join(', ')}');
    
    return uniqueDrugNames;
  }

  /// Very permissive check for drug-like names
  static bool _looksLikeDrugName(String word) {
    // Clean the word
    final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    
    // Must have minimum length
    if (clean.length < 3) return false;
    
    // Skip very common words that are clearly not drugs
    final skipWords = {
      'the', 'and', 'for', 'with', 'this', 'that', 'from', 'they', 'have', 'been',
      'will', 'can', 'may', 'should', 'would', 'could', 'must', 'need', 'want',
      'get', 'got', 'has', 'had', 'was', 'were', 'are', 'is', 'am', 'be', 'being',
      'do', 'does', 'did', 'done', 'go', 'going', 'went', 'gone', 'come', 'came',
      'see', 'saw', 'seen', 'look', 'looking', 'take', 'taking', 'took', 'taken',
      'use', 'using', 'used', 'make', 'making', 'made', 'put', 'putting',
      'per', 'day', 'days', 'week', 'weeks', 'month', 'months', 'year', 'years',
      'time', 'times', 'once', 'twice', 'daily', 'weekly', 'monthly',
      'morning', 'afternoon', 'evening', 'night', 'before', 'after', 'during',
      'tablet', 'tablets', 'capsule', 'capsules', 'pill', 'pills', 'dose', 'doses'
    };
    
    if (skipWords.contains(clean)) return false;
    
    // Skip pure numbers
    if (RegExp(r'^\d+$').hasMatch(clean)) return false;
    
    // Skip very short common words
    if (clean.length <= 3 && RegExp(r'^[a-z]{1,3}$').hasMatch(clean)) {
      final shortSkip = {'mg', 'ml', 'gr', 'tb', 'cp', 'tab', 'cap', 'iu', 'mcg'};
      if (shortSkip.contains(clean)) return false;
    }
    
    // Accept everything else as potentially being a drug name
    return true;
  }

  /// Get analysis summary for display
  static String getAnalysisSummary(PrescriptionAnalysisResult result) {
    if (result.hasErrors) {
      return result.errorMessage ?? 'Analysis failed';
    }
    
    if (result.drugs.isEmpty) {
      return 'No medications detected in the prescription';
    }
    
    final drugCount = result.drugs.length;
    final drugNames = result.drugs.map((d) => d.name).join(', ');
    
    return 'Found $drugCount medication${drugCount > 1 ? 's' : ''}: $drugNames';
  }

  /// Check if image file is valid
  static bool isValidImageFile(File file) {
    if (!file.existsSync()) return false;
    
    final extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'bmp', 'gif'].contains(extension);
  }

  /// Get file size in MB
  static double getFileSizeMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }
}
