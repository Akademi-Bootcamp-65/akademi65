import '../services/openai_service.dart';
import '../services/prospectus_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class SideEffectAnalysisService {
  static final OpenAIService _openAIService = OpenAIService();

  /// Analyze if reported side effects match drug's known side effects
  static Future<SideEffectAnalysisResult> analyzeSideEffect({
    required String drugName,
    required String reportedSideEffect,
  }) async {
    print('🔍 [SIDE EFFECT] Starting analysis for: $drugName → $reportedSideEffect');
    
    try {
      // Get user profile for personalized analysis
      final userProfile = UserService.currentUser;
      
      // Step 1: Get drug prospectus data
      print('📄 [SIDE EFFECT] Getting prospectus data for: $drugName');
      final prospectusData = await ProspectusService.getEnhancedDrugAnalysis(drugName);
      
      // Step 2: AI analysis with prospectus data
      final analysisResult = await _analyzeWithAI(
        drugName: drugName,
        reportedSideEffect: reportedSideEffect,
        prospectusData: prospectusData,
        userProfile: userProfile,
      );
      
      return analysisResult;
      
    } catch (e) {
      print('❌ [SIDE EFFECT] Analysis error: $e');
      
      return SideEffectAnalysisResult(
        drugName: drugName,
        reportedSideEffect: reportedSideEffect,
        isLikelyRelated: false,
        probabilityPercentage: 0,
        severity: 'Bilinmiyor',
        recommendation: 'HEMEN DOKTORA BAŞVURUN',
        explanation: 'Analiz yapılamadı. Güvenliğiniz için doktorunuza danışın.',
        shouldStopMedication: true,
        emergencyLevel: 'YÜKSEK',
      );
    }
  }

  /// AI-powered side effect analysis
  static Future<SideEffectAnalysisResult> _analyzeWithAI({
    required String drugName,
    required String reportedSideEffect,
    required Map<String, dynamic>? prospectusData,
    required UserProfile? userProfile,
  }) async {
    
    // Build analysis prompt with prospectus data
    String prospectusInfo = '';
    if (prospectusData != null && prospectusData['cards'] != null) {
      final cards = prospectusData['cards'] as List;
      for (var card in cards) {
        if (card['type'] == 'side_effects' || card['type'] == 'warning') {
          prospectusInfo += '• ${card['title']}: ${card['content']}\n';
        }
      }
    }

    // Get explanation style based on user info level
    String explanationStyle = 'basit ve anlaşılır';
    if (userProfile != null) {
      switch (userProfile.infoLevel) {
        case 'Sade':
          explanationStyle = 'çok basit, 12 yaşındaki çocuğa anlatır gibi';
          break;
        case 'Detaylı':
          explanationStyle = 'detaylı ve bilimsel ama anlaşılır';
          break;
        default:
          explanationStyle = 'orta seviyede detaylı ama anlaşılır';
      }
    }

    final prompt = '''
GÖREV: Yan Etki Analizi ve Güvenlik Değerlendirmesi

İLAÇ: $drugName
BİLDİRİLEN YAN ETKİ: $reportedSideEffect

KULLANICI BİLGİLERİ:
${userProfile != null ? '''
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}
- Hamilelik: ${userProfile.isPregnant ? 'Evet' : 'Hayır'}
- Bilgi Seviyesi: ${userProfile.infoLevel}
''' : 'Kullanıcı profili yok'}

PROSPEKTÜs BİLGİLERİ:
$prospectusInfo

GÖREVİN:
1. Bu yan etkinin bu ilaçla bağlantısını değerlendir
2. Aciliyet seviyesini belirle  
3. Net bir tavsiye ver (devam et / bırak / doktora git)
4. $explanationStyle bir dilde açıkla

ZORUNLU CEVAP FORMATI:
İLGİLİ: [EVET/HAYIR]
OLASILIK: [0-100]%
CİDDİYET: [HAFİF/ORTA/AĞIR/KRİTİK]
TAVSİYE: [DEVAM_ET/BIRAK/DOKTOR_ACIL]
ACİLİYET: [DÜŞÜK/ORTA/YÜKSEK/ACİL]
AÇIKLAMA: [Neden bu sonuca vardığını açıkla - prospektüs bilgilerine dayanarak]
YAPILACAKLAR: [Kullanıcının ne yapması gerektiği - adım adım]

KRITIK KURALLAR:
- Prospektüs verilerini öncelikle kullan
- Belirsizlikde güvenliği tercih et (BIRAK/DOKTOR öner)
- Ağır yan etkiler için MUTLAKA DOKTOR öner
- Kullanıcının yaş/durumunu dikkate al
- $explanationStyle açıklama yap

ANALİZ:''';

    try {
      final response = await _openAIService.getChatResponse(prompt);
      
      if (response != null) {
        return _parseAIResponse(response, drugName, reportedSideEffect);
      }
      
    } catch (e) {
      print('❌ [AI ANALYSIS] Error: $e');
    }
    
    // Fallback safe response
    return SideEffectAnalysisResult(
      drugName: drugName,
      reportedSideEffect: reportedSideEffect,
      isLikelyRelated: true, // Güvenlik için true
      probabilityPercentage: 50,
      severity: 'Bilinmiyor',
      recommendation: 'HEMEN DOKTORA BAŞVURUN',
      explanation: 'Analiz tamamlanamadı. Güvenlik için doktorunuza danışmanızı öneriyoruz.',
      shouldStopMedication: true,
      emergencyLevel: 'YÜKSEK',
    );
  }

  /// Parse AI response to structured result
  static SideEffectAnalysisResult _parseAIResponse(
    String response, 
    String drugName, 
    String reportedSideEffect
  ) {
    try {
      // Extract information using regex
      final relatedMatch = RegExp(r'İLGİLİ:\s*(EVET|HAYIR)', caseSensitive: false).firstMatch(response);
      final probabilityMatch = RegExp(r'OLASILIK:\s*(\d+)%?', caseSensitive: false).firstMatch(response);
      final severityMatch = RegExp(r'CİDDİYET:\s*(HAFİF|ORTA|AĞIR|KRİTİK)', caseSensitive: false).firstMatch(response);
      final recommendationMatch = RegExp(r'TAVSİYE:\s*(DEVAM_ET|BIRAK|DOKTOR_ACIL)', caseSensitive: false).firstMatch(response);
      final urgencyMatch = RegExp(r'ACİLİYET:\s*(DÜŞÜK|ORTA|YÜKSEK|ACİL)', caseSensitive: false).firstMatch(response);
      final explanationMatch = RegExp(r'AÇIKLAMA:\s*([^\n]+)', caseSensitive: false).firstMatch(response);
      
      final isRelated = relatedMatch?.group(1)?.toUpperCase() == 'EVET';
      final probability = int.tryParse(probabilityMatch?.group(1) ?? '50') ?? 50;
      final severity = severityMatch?.group(1) ?? 'ORTA';
      final recommendation = recommendationMatch?.group(1) ?? 'DOKTOR_ACIL';
      final urgency = urgencyMatch?.group(1) ?? 'YÜKSEK';
      final explanation = explanationMatch?.group(1)?.trim() ?? 'Analiz tamamlandı';
      
      // Convert recommendation to user-friendly format
      String userRecommendation;
      bool shouldStop;
      
      switch (recommendation) {
        case 'DEVAM_ET':
          userRecommendation = 'İlaç kullanımına devam edebilirsiniz ama belirtileri takip edin';
          shouldStop = false;
          break;
        case 'BIRAK':
          userRecommendation = 'İlaç kullanımını durdurun ve doktorunuza danışın';
          shouldStop = true;
          break;
        default: // DOKTOR_ACIL
          userRecommendation = 'HEMEN doktorunuza başvurun, ilacı kullanmayı durdurun';
          shouldStop = true;
      }
      
      return SideEffectAnalysisResult(
        drugName: drugName,
        reportedSideEffect: reportedSideEffect,
        isLikelyRelated: isRelated,
        probabilityPercentage: probability,
        severity: severity,
        recommendation: userRecommendation,
        explanation: explanation,
        shouldStopMedication: shouldStop,
        emergencyLevel: urgency,
      );
      
    } catch (e) {
      print('❌ [PARSE ERROR] $e');
      
      // Safe fallback
      return SideEffectAnalysisResult(
        drugName: drugName,
        reportedSideEffect: reportedSideEffect,
        isLikelyRelated: true,
        probabilityPercentage: 75,
        severity: 'ORTA',
        recommendation: 'Güvenlik için doktorunuza danışın',
        explanation: 'Yan etki ile ilaç arasında bağlantı olabilir.',
        shouldStopMedication: true,
        emergencyLevel: 'ORTA',
      );
    }
  }
}

/// Side effect analysis result model
class SideEffectAnalysisResult {
  final String drugName;
  final String reportedSideEffect;
  final bool isLikelyRelated;
  final int probabilityPercentage;
  final String severity;
  final String recommendation;
  final String explanation;
  final bool shouldStopMedication;
  final String emergencyLevel;

  SideEffectAnalysisResult({
    required this.drugName,
    required this.reportedSideEffect,
    required this.isLikelyRelated,
    required this.probabilityPercentage,
    required this.severity,
    required this.recommendation,
    required this.explanation,
    required this.shouldStopMedication,
    required this.emergencyLevel,
  });
}
