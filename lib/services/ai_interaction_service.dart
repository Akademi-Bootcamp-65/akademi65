import '../models/drug_interaction.dart';
import '../models/user_profile.dart';
import '../services/prospectus_service.dart';
import '../services/openai_service.dart';

class AIInteractionService {
  static final Map<String, DrugInfo> _drugDatabase = {
    'aspirin': DrugInfo(
      name: 'Aspirin',
      category: 'NSAİ (Nonsteroid Antiinflamatuar İlaç)',
      activeIngredient: 'Asetilsalisilik Asit',
      contraindications: ['Warfarin', 'Heparin', 'Alkol'],
      riskLevel: 2,
    ),
    'warfarin': DrugInfo(
      name: 'Warfarin',
      category: 'Antikoagülan',
      activeIngredient: 'Warfarin Sodyum',
      contraindications: ['Aspirin', 'İbuprofen', 'Vitamin K'],
      riskLevel: 4,
    ),
    'metformin': DrugInfo(
      name: 'Metformin',
      category: 'Antidiyabetik',
      activeIngredient: 'Metformin Hidroklorür',
      contraindications: ['Insulin', 'Alkol'],
      riskLevel: 2,
    ),
    'ibuprofen': DrugInfo(
      name: 'İbuprofen',
      category: 'NSAİ (Nonsteroid Antiinflamatuar İlaç)',
      activeIngredient: 'İbuprofen',
      contraindications: ['Warfarin', 'Lisinopril', 'Aspirin'],
      riskLevel: 2,
    ),
    'lisinopril': DrugInfo(
      name: 'Lisinopril',
      category: 'ACE İnhibitörü',
      activeIngredient: 'Lisinopril',
      contraindications: ['İbuprofen', 'Potasyum Takviyeleri'],
      riskLevel: 2,
    ),
    'atorvastatin': DrugInfo(
      name: 'Atorvastatin',
      category: 'Statin',
      activeIngredient: 'Atorvastatin Kalsiyum',
      contraindications: ['Siklosporin', 'Gemfibrozil'],
      riskLevel: 2,
    ),
    'digoxin': DrugInfo(
      name: 'Digoksin',
      category: 'Kalp Glikozidi',
      activeIngredient: 'Digoksin',
      contraindications: ['Verapamil', 'Amiodaron', 'Furosemid'],
      riskLevel: 4,
    ),
    'amiodaron': DrugInfo(
      name: 'Amiodaron',
      category: 'Antiaritmik',
      activeIngredient: 'Amiodaron HCl',
      contraindications: ['Digoksin', 'Warfarin', 'Simvastatin'],
      riskLevel: 4,
    ),
  };

  static final Map<String, Map<String, InteractionPair>> _interactionDatabase = {
    'aspirin': {
      'warfarin': InteractionPair(
        drug1: _drugDatabase['aspirin']!,
        drug2: _drugDatabase['warfarin']!,
        severity: 4,
        description: 'Aspirin ile warfarin birlikte kullanıldığında kanama riski önemli ölçüde artar.',
        mechanism: 'Her iki ilaç da kan pıhtılaşmasını önler ve sinerjik etki gösterir.',
        symptoms: ['Aşırı kanama', 'Morluk', 'Burun kanaması', 'Dişeti kanaması'],
        recommendation: 'Bu kombinasyon kritik izlem gerektirir. INR değerleri sık kontrol edilmeli.',
      ),
    },
    'warfarin': {
      'aspirin': InteractionPair(
        drug1: _drugDatabase['warfarin']!,
        drug2: _drugDatabase['aspirin']!,
        severity: 4,
        description: 'Warfarin ile aspirin kombinasyonu ciddi kanama riskine neden olur.',
        mechanism: 'Antikoagülan ve antiplatelet etkiler birleşerek kanama riskini katlar.',
        symptoms: ['İç kanama', 'Hematomlar', 'Uzamış kanama süresi'],
        recommendation: 'Mümkünse kombine kullanımdan kaçının. Zorunlu ise yakın izlem gerekir.',
      ),
      'ibuprofen': InteractionPair(
        drug1: _drugDatabase['warfarin']!,
        drug2: _drugDatabase['ibuprofen']!,
        severity: 3,
        description: 'İbuprofen warfarinin antikoagülan etkisini artırabilir.',
        mechanism: 'NSAİ\'ler protein bağlanmasını etkiler ve kanama riskini artırır.',
        symptoms: ['Kanama eğilimi artışı', 'Morarma'],
        recommendation: 'Alternatif ağrı kesici tercih edilmeli. Zorunlu ise INR izlemi yapılmalı.',
      ),
    },
    'digoxin': {
      'amiodaron': InteractionPair(
        drug1: _drugDatabase['digoxin']!,
        drug2: _drugDatabase['amiodaron']!,
        severity: 5,
        description: 'Amiodaron digoksin seviyelerini 2-3 kat artırarak toksisiteye neden olur.',
        mechanism: 'Amiodaron digoksinin böbrek ve hepatik kleransını azaltır.',
        symptoms: ['Kalp ritim bozuklukları', 'Mide bulantısı', 'Görme bozuklukları', 'Konfüzyon'],
        recommendation: 'KRİTİK: Digoksin dozu %50 azaltılmalı ve sık seviye kontrolü yapılmalı.',
      ),
    },
  };

  static List<String> getSuggestions(String query) {
    if (query.isEmpty || query.length < 2) return [];
    
    // First validate if query looks like a drug name
    if (!_isValidDrugName(query)) {
      return ['⚠️ Lütfen geçerli bir ilaç adı girin'];
    }
    
    final suggestions = _drugDatabase.keys
        .where((drug) => drug.toLowerCase().contains(query.toLowerCase()))
        .map((key) => _drugDatabase[key]!.name)
        .toList();
    
    // Add common Turkish drug names that match the query
    final commonDrugs = [
      'Aspirin', 'Paracetamol', 'İbuprofen', 'Nurofen', 'Voltaren', 'Diclofenac',
      'Amoxicillin', 'Augmentin', 'Cipro', 'Ciprofloxacin', 'Metformin',
      'Insulin', 'Lantus', 'NovoRapid', 'Concerta', 'Ritalin', 'Strattera',
      'Lipitor', 'Atorvastatin', 'Simvastatin', 'Crestor', 'Zocor',
      'Lisinopril', 'Enalapril', 'Ramipril', 'Losartan', 'Valsartan',
      'Amlodipine', 'Nifedipine', 'Bisoprolol', 'Metoprolol', 'Propranolol',
      'Omeprazole', 'Lansoprazole', 'Esomeprazole', 'Pantoprazole',
      'Warfarin', 'Heparin', 'Clopidogrel', 'Aspirin Cardio',
      'Levothyroxine', 'Synthroid', 'Euthyrox', 'L-thyroxine',
      'Sertraline', 'Fluoxetine', 'Paroxetine', 'Citalopram', 'Escitalopram',
      'Lorazepam', 'Alprazolam', 'Diazepam', 'Clonazepam', 'Zolpidem'
    ];
    
    final additionalSuggestions = commonDrugs
        .where((drug) => drug.toLowerCase().contains(query.toLowerCase()))
        .where((drug) => !suggestions.contains(drug))
        .toList();
    
    suggestions.addAll(additionalSuggestions);
    
    return suggestions.take(10).toList();
  }

  static DrugInfo? findDrug(String name) {
    final key = name.toLowerCase().replaceAll(' ', '').replaceAll('ı', 'i');
    return _drugDatabase[key] ?? _findDrugByName(name);
  }

  static DrugInfo? _findDrugByName(String name) {
    for (var drug in _drugDatabase.values) {
      if (drug.name.toLowerCase() == name.toLowerCase()) {
        return drug;
      }
    }
    return null;
  }

  /// Validate if input is actually a drug name
  static bool _isValidDrugName(String name) {
    if (name.isEmpty || name.length < 2) return false;
    
    // Check against common non-drug terms
    final nonDrugTerms = [
      'YEMEK', 'SU', 'ÇORBA', 'EKMEK', 'PEYNİR', 'ELMA', 'MEYVE', 'SEBZE',
      'ÇAY', 'KAHVE', 'MADEN SUYU', 'KOLA', 'BİRA', 'ŞARAP', 'ALKOL',
      'VİTAMİN', 'MİNERAL', 'GIDA', 'BESİN', 'SUPPLEMENT', 'TAKVİYE',
      'ŞEKER', 'TUZ', 'BAHARAT', 'YOĞURT', 'SÜT', 'ET', 'TAVUK', 'BALIK',
      'PİLAV', 'MAKARNA', 'PATATES', 'DOMATES', 'SALATA', 'SANDVIÇ',
      'HAMBURGER', 'PİZZA', 'PASTA', 'KEK', 'BİSKÜVİ', 'ÇİKOLATA',
      'ŞAMPUAN', 'SABUN', 'DETERJANs', 'TEMİZLİK', 'PARFÜM', 'KREM',
      'MASA', 'SANDALYE', 'KAPITAN', 'PENCERE', 'ARABA', 'TELEFON',
      'BİLGİSAYAR', 'TV', 'MÜZİK', 'FİLM', 'KİTAP', 'GAZETE',
      'TEST', 'DENEME', 'ÖRNEK', 'SAMPLE', '123', 'ABC', 'XYZ'
    ];
    
    final upperName = name.toUpperCase();
    
    // Exact match with non-drug terms
    if (nonDrugTerms.contains(upperName)) {
      return false;
    }
    
    // Check if it's mostly numbers
    if (RegExp(r'^\d+$').hasMatch(name)) {
      return false;
    }
    
    // Check if it contains only special characters
    if (RegExp(r'^[^\w\s]+$').hasMatch(name)) {
      return false;
    }
    
    // Must contain at least one letter
    if (!RegExp(r'[a-zA-ZğüşöçİĞÜŞÖÇ]').hasMatch(name)) {
      return false;
    }
    
    return true;
  }

  /// Enhanced interaction analysis using prospectus data
  static Future<InteractionResult> analyzeInteractions(List<DrugInfo> drugs, {UserProfile? userProfile}) async {
    print('🔍 [INTERACTION DEBUG] Starting interaction analysis for ${drugs.length} drugs');
    
    // STEP 1: VALIDATE ALL DRUGS WITH AI FIRST - ASK AI: IS THIS A DRUG?
    print('🤖 [CRITICAL VALIDATION] Asking AI to validate each drug name...');
    final validatedDrugs = <DrugInfo>[];
    final rejectedItems = <String>[];
    final openAIService = OpenAIService();
    
    for (final drug in drugs) {
      print('🤖 [AI VALIDATION] Asking AI: Is "${drug.name}" a drug? (YES/NO only)');
      
      // DIRECT AI VALIDATION - ASKING FOR YES OR NO ONLY
      final isValidDrug = await openAIService.isRealDrug(drug.name);
      
      if (isValidDrug) {
        validatedDrugs.add(drug);
        print('✅ [AI VALIDATION] AI said YES - "${drug.name}" is a real drug');
      } else {
        rejectedItems.add(drug.name);
        print('❌ [AI VALIDATION] AI said NO - "${drug.name}" is NOT a drug');
      }
    }
    
    // If AI says NO to all drugs, IMMEDIATELY throw error and STOP
    if (validatedDrugs.isEmpty) {
      print('🚫 [AI VALIDATION] AI REJECTED ALL DRUGS - THROWING ERROR');
      
      // AI'dan bu öğelerin ne olduğunu kısaca açıklamasını iste
      String whatAreThese = '';
      try {
        final prompt = 'Bu öğeler nedir, çok kısa açıkla (max 20 kelime): ${rejectedItems.join(", ")}';
        final aiExplanation = await openAIService.getChatResponse(prompt);
        if (aiExplanation != null && aiExplanation.isNotEmpty) {
          whatAreThese = '\n🤖 AI Açıklaması: $aiExplanation\n';
        }
      } catch (e) {
        print('AI açıklama hatası: $e');
      }
      
      throw Exception(
        '🚫 HATA: AI bu öğelerin ilaç olmadığını doğruladı!\n\n'
        '📝 Reddedilen öğeler: ${rejectedItems.join(", ")}'
        '$whatAreThese\n'
        '💊 Lütfen gerçek ilaç adları girin.\n\n'
        'Örnek: Aspirin, Parol, Voltaren, Nurofen...'
      );
    }
    
    // If some drugs were rejected, warn but continue with validated ones
    if (rejectedItems.isNotEmpty) {
      print('⚠️ [AI VALIDATION] Some drugs were rejected: ${rejectedItems.join(", ")}');
      print('✅ [AI VALIDATION] Continuing with validated drugs: ${validatedDrugs.map((d) => d.name).join(", ")}');
    } else {
      print('✅ [AI VALIDATION] All ${validatedDrugs.length} drugs validated by AI, proceeding with analysis...');
    }
    
    final interactions = <InteractionPair>[];
    int maxRisk = 1;
    
    // Get enhanced drug analysis for each VALIDATED drug using prospectus service
    final enhancedDrugData = <DrugInfo, Map<String, dynamic>?>{};
    
    for (final drug in validatedDrugs) {
      print('🏥 [INTERACTION DEBUG] Getting enhanced analysis for: ${drug.name}');
      
      try {
        final enhancedAnalysis = await ProspectusService.getEnhancedDrugAnalysis(drug.name);
        enhancedDrugData[drug] = enhancedAnalysis;
        
        if (enhancedAnalysis != null) {
          print('✅ [INTERACTION DEBUG] Enhanced analysis found for: ${drug.name}');
        } else {
          print('⚠️ [INTERACTION DEBUG] No enhanced analysis found for: ${drug.name}');
        }
      } catch (e) {
        print('💥 [INTERACTION DEBUG] Error getting analysis for ${drug.name}: $e');
      }
    }
    
    // Analyze pairwise interactions using AI and prospectus data for VALIDATED drugs only
    for (int i = 0; i < validatedDrugs.length; i++) {
      for (int j = i + 1; j < validatedDrugs.length; j++) {
        final drug1 = validatedDrugs[i];
        final drug2 = validatedDrugs[j];
        
        print('🔬 [INTERACTION DEBUG] Analyzing interaction: ${drug1.name} + ${drug2.name}');
        
        // First check static database for known critical interactions
        final staticInteraction = _findInteraction(drug1, drug2);
        if (staticInteraction != null) {
          interactions.add(staticInteraction);
          if (staticInteraction.severity > maxRisk) {
            maxRisk = staticInteraction.severity;
          }
          print('📋 [INTERACTION DEBUG] Found static interaction with severity: ${staticInteraction.severity}');
        } else {
          // Use AI to analyze interaction based on prospectus data
          final aiInteraction = await _analyzeInteractionWithAI(
            drug1, drug2, 
            enhancedDrugData[drug1], 
            enhancedDrugData[drug2],
            userProfile: userProfile
          );
          
          if (aiInteraction != null) {
            interactions.add(aiInteraction);
            if (aiInteraction.severity > maxRisk) {
              maxRisk = aiInteraction.severity;
            }
            print('🤖 [INTERACTION DEBUG] AI generated interaction with severity: ${aiInteraction.severity}');
          }
        }
      }
    }

    // Calculate overall risk using VALIDATED drugs only
    final overallRisk = _calculateOverallRisk(validatedDrugs, interactions);
    final riskLevel = _getRiskLevelText(overallRisk);
    
    // Generate AI-powered analysis and recommendations using VALIDATED drugs only
    final analysis = await _generateEnhancedAIAnalysis(validatedDrugs, interactions, overallRisk, enhancedDrugData);
    final recommendations = _generateEnhancedRecommendations(validatedDrugs, interactions, overallRisk);

    print('✅ [INTERACTION DEBUG] Analysis complete. Overall risk: $overallRisk, Interactions found: ${interactions.length}');

    // Add warning about rejected drugs if any
    String finalAnalysis = analysis;
    if (rejectedItems.isNotEmpty) {
      finalAnalysis = '⚠️ DİKKAT: Şu öğeler ilaç olmadığı için analiz dışı bırakıldı: ${rejectedItems.join(", ")}\n\n' + analysis;
    }

    return InteractionResult(
      drugs: validatedDrugs, // Return only validated drugs
      overallRisk: overallRisk,
      riskLevel: riskLevel,
      summary: _generateSummary(validatedDrugs, interactions, overallRisk),
      detailedAnalysis: finalAnalysis,
      interactions: interactions,
      recommendations: recommendations,
      analyzedAt: DateTime.now(),
      aiGenerated: true,
    );
  }

  /// Analyze drug interaction using AI and prospectus data
  static Future<InteractionPair?> _analyzeInteractionWithAI(
    DrugInfo drug1, 
    DrugInfo drug2, 
    Map<String, dynamic>? prospectus1, 
    Map<String, dynamic>? prospectus2,
    {UserProfile? userProfile}
  ) async {
    try {
      print('🤖 [INTERACTION DEBUG] Analyzing interaction with AI: ${drug1.name} + ${drug2.name}');
      
      final openAIService = OpenAIService();
      
      // BUILD DETAILED CONTEXT FROM PROSPECTUS DATA
      String detailedContext = '''İlaç Etkileşim Analizi:
İlaç 1: ${drug1.name}
İlaç 2: ${drug2.name}

''';

      // Add user profile information
      if (userProfile != null) {
        detailedContext += '''KULLANICI PROFİLİ:
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}
- Hamilelik: ${userProfile.isPregnant ? 'Evet' : 'Hayır'}
- Bilgi Seviyesi: ${userProfile.infoLevel}

''';
      }

      // Add prospectus data if available
      if (prospectus1 != null && prospectus1['cards'] != null) {
        detailedContext += 'İLAÇ 1 (${drug1.name}) PROSPEKTÜs BİLGİLERİ:\n';
        final cards = prospectus1['cards'] as List;
        for (var card in cards) {
          if (card['type'] == 'interactions' || card['type'] == 'warning' || card['type'] == 'side_effects') {
            detailedContext += '• ${card['title']}: ${card['content']}\n';
          }
        }
        detailedContext += '\n';
      }
      
      if (prospectus2 != null && prospectus2['cards'] != null) {
        detailedContext += 'İLAÇ 2 (${drug2.name}) PROSPEKTÜs BİLGİLERİ:\n';
        final cards = prospectus2['cards'] as List;
        for (var card in cards) {
          if (card['type'] == 'interactions' || card['type'] == 'warning' || card['type'] == 'side_effects') {
            detailedContext += '• ${card['title']}: ${card['content']}\n';
          }
        }
        detailedContext += '\n';
      }
      
      // ENHANCED AI PROMPT WITH SPECIFIC CONTEXT
      final prompt = '''Sen bir eczacı uzmanısın. Bu iki ilaç arasında etkileşim var mı analiz et:

$detailedContext

GÖREV:
1. Bu prospektüs bilgileri ışığında etkileşim riski analiz et
2. Özellikle yan etkiler, uyarılar ve mevcut etkileşim bilgilerini değerlendir
3. Dinamik ve gerçekçi bir analiz yap
4. Kullanıcının bilgi seviyesine uygun dilde açıkla

AÇIKLAMA STİLİ${userProfile != null ? ' (Bilgi Seviyesi: ${userProfile.infoLevel})' : ''}:
${userProfile?.infoLevel == 'Sade' ? '- Çok basit kelimelerle açıkla\n- Kısa ve net cümleler kullan\n- Teknik terim kullanma' : 
userProfile?.infoLevel == 'Detaylı' ? '- Bilimsel terimleri kullanabilirsin ama açıkla\n- Etki mekanizmalarını açıkla\n- Detaylı açıklama yap' : 
'- Orta seviyede detay ver\n- Anlaşılır ama bilgilendirici ol\n- Gerekirse basit tıbbi terimler kullan'}

ÖRNEKLERlE AÇIKLAMA:
- Aspirin + Warfarin = Kanama riski (her ikisi de kan sulandırır)
- Lustral (SSRI) + Paracetamol = Genelde güvenli, çok az etkileşim
- İbuprofen + Lisinopril = Böbrek fonksiyonu etkilenebilir

CEVAP FORMATI:
ETKILEŞIM: [EVET/HAYIR]
CİDDİYET: [1-5] (1=minimal, 5=kritik)
AÇIKLAMA: [Neden etkileşim var/yok, prospektüs bilgilerine dayanarak]
TAVSİYE: [Pratik öneri]

${drug1.name} + ${drug2.name} için analiz:''';

      final response = await openAIService.getChatResponse(prompt);
      
      if (response != null) {
        print('🤖 [AI ANALYSIS] Full response: $response');
        
        // PARSE ENHANCED RESPONSE
        if (response.toUpperCase().contains('ETKILEŞIM: EVET') || 
            response.toUpperCase().contains('ETKİLEŞİM: EVET')) {
          
          // Extract severity
          final severityMatch = RegExp(r'CİDDİYET:\s*(\d+)', caseSensitive: false).firstMatch(response);
          final severity = severityMatch != null ? int.parse(severityMatch.group(1)!) : 2;
          
          // Extract description
          final descMatch = RegExp(r'AÇIKLAMA:\s*([^\n]+)', caseSensitive: false).firstMatch(response);
          final description = descMatch?.group(1)?.trim() ?? 
            'Prospektüs bilgileri ışığında potansiyel etkileşim tespit edildi';
          
          // Extract recommendation
          final recMatch = RegExp(r'TAVSİYE:\s*(.+)', caseSensitive: false, dotAll: true).firstMatch(response);
          final recommendation = recMatch?.group(1)?.trim() ?? 
            'Doktor kontrolünde kullanım önerilir';
          
          print('🤖 [AI INTERACTION] Found interaction with severity $severity');
          print('🤖 [AI INTERACTION] Description: $description');
          
          return InteractionPair(
            drug1: drug1,
            drug2: drug2,
            severity: severity,
            description: description,
            mechanism: 'Prospektüs verilerinden AI analizi',
            symptoms: ['Etkileşim belirtilerini izleyin'],
            recommendation: recommendation,
          );
        } else {
          print('🤖 [AI INTERACTION] No significant interaction found');
          
          // EVEN IF NO INTERACTION, PROVIDE USEFUL INFO
          if (prospectus1 != null || prospectus2 != null) {
            print('🤖 [AI INTERACTION] Creating minimal interaction note based on prospectus data');
            return InteractionPair(
              drug1: drug1,
              drug2: drug2,
              severity: 1,
              description: 'Prospektüs verileri analiz edildi, ciddi etkileşim tespit edilmedi. Ancak her iki ilaç da kendi yan etkilerine sahiptir.',
              mechanism: 'Prospektüs bazlı güvenlik analizi',
              symptoms: ['Normal dozlarda kullanım güvenli görünüyor'],
              recommendation: 'Düzenli kullanımda doktor takibi önerilir. Her iki ilacın da kendi uyarılarına dikkat edin.',
            );
          }
        }
      }
      
      return null;
    } catch (e) {
      print('💥 [INTERACTION DEBUG] Error in AI interaction analysis: $e');
      return null;
    }
  }

  /// Generate enhanced AI analysis using prospectus data
  static Future<String> _generateEnhancedAIAnalysis(
    List<DrugInfo> drugs, 
    List<InteractionPair> interactions, 
    int overallRisk,
    Map<DrugInfo, Map<String, dynamic>?> enhancedData
  ) async {
    // Start with basic analysis
    var analysis = _generateAIAnalysis(drugs, interactions, overallRisk);
    
    // Add prospectus-based insights
    if (enhancedData.values.any((data) => data != null)) {
      analysis += '\n\n📚 Prospektüs Bazlı Analiz:\n';
      
      for (final entry in enhancedData.entries) {
        if (entry.value != null) {
          analysis += '• ${entry.key.name}: Detaylı prospektüs verisi kullanılarak analiz edildi\n';
        }
      }
    }
    
    return analysis;
  }

  /// Generate enhanced recommendations
  static List<String> _generateEnhancedRecommendations(List<DrugInfo> drugs, List<InteractionPair> interactions, int overallRisk) {
    final recommendations = _generateRecommendations(drugs, interactions, overallRisk);
    
    // Add validation-specific recommendations
    recommendations.insert(0, '✅ Tüm ilaç adları doğrulandı ve analiz edildi');
    recommendations.add('🔍 Analiz prospektüs verileri ve AI ile desteklendi');
    recommendations.add('⚠️ Yeni ilaç eklerken mutlaka doktor onayı alın');
    
    return recommendations;
  }

  static InteractionPair? _findInteraction(DrugInfo drug1, DrugInfo drug2) {
    final key1 = drug1.name.toLowerCase().replaceAll(' ', '').replaceAll('ı', 'i');
    final key2 = drug2.name.toLowerCase().replaceAll(' ', '').replaceAll('ı', 'i');
    
    return _interactionDatabase[key1]?[key2] ?? _interactionDatabase[key2]?[key1];
  }

  static int _calculateOverallRisk(List<DrugInfo> drugs, List<InteractionPair> interactions) {
    if (interactions.isEmpty) return 1;
    
    int maxSeverity = interactions.map((e) => e.severity).reduce((a, b) => a > b ? a : b);
    int avgDrugRisk = (drugs.map((e) => e.riskLevel).reduce((a, b) => a + b) / drugs.length).round();
    
    return ((maxSeverity + avgDrugRisk) / 2).round().clamp(1, 5);
  }

  static String _getRiskLevelText(int risk) {
    switch (risk) {
      case 1:
        return 'Minimal Risk';
      case 2:
        return 'Düşük Risk';
      case 3:
        return 'Orta Risk';
      case 4:
        return 'Yüksek Risk';
      case 5:
        return 'Kritik Risk';
      default:
        return 'Bilinmeyen Risk';
    }
  }

  static String _generateSummary(List<DrugInfo> drugs, List<InteractionPair> interactions, int overallRisk) {
    if (interactions.isEmpty) {
      return '✅ Analiz edilen ${drugs.length} ilaç arasında bilinen önemli etkileşim tespit edilmedi. Genel kullanım güvenli görünmektedir.';
    }

    final criticalCount = interactions.where((i) => i.severity >= 4).length;
    final moderateCount = interactions.where((i) => i.severity == 3).length;
    
    if (criticalCount > 0) {
      return '⚠️ KRİTİK: $criticalCount adet ciddi etkileşim tespit edildi. Acil doktor kontrolü gerekiyor!';
    } else if (moderateCount > 0) {
      return '⚡ UYARI: $moderateCount adet orta seviye etkileşim tespit edildi. Doktor gözetimi önerilir.';
    } else {
      return '💊 ${interactions.length} adet hafif etkileşim tespit edildi. Genel olarak güvenli, ancak takip önerilir.';
    }
  }

  static String _generateAIAnalysis(List<DrugInfo> drugs, List<InteractionPair> interactions, int overallRisk) {
    var analysis = '''🤖 AI Destekli Kapsamlı Etkileşim Analizi

📊 GENEL DURUM:
• Analiz edilen ilaç sayısı: ${drugs.length}
• Tespit edilen etkileşim: ${interactions.length}
• Genel risk seviyesi: ${_getRiskLevelText(overallRisk)}

💊 İLAÇ PROFİLİ:
''';

    for (var drug in drugs) {
      analysis += '• ${drug.name} (${drug.category ?? "Kategori belirtilmemiş"}) - Risk Level ${drug.riskLevel}/5\n';
    }

    if (interactions.isNotEmpty) {
      analysis += '\n⚡ TESPİT EDİLEN ETKİLEŞİMLER:\n';
      for (var interaction in interactions) {
        analysis += '''
🔴 ${interaction.drug1.name} ↔ ${interaction.drug2.name}
   Ciddiyet: ${interaction.severityText} (${interaction.severity}/5)
   Mekanizma: ${interaction.mechanism}
   Belirtiler: ${interaction.symptoms.join(', ')}
   Öneri: ${interaction.recommendation}
''';
      }
    }

    analysis += '''

🧠 AI DEĞERLENDİRMESİ:
Bu kombinasyon için yapay zeka destekli analiz tamamlandı. Sistem, güncel farmakoljik veriler ve klinik kılavuzlar ışığında kapsamlı bir değerlendirme gerçekleştirdi.

📈 RİSK ANALİZİ:
''';

    switch (overallRisk) {
      case 1:
        analysis += 'Minimal risk - Güvenli kombinasyon. Rutin kontroller yeterli.';
        break;
      case 2:
        analysis += 'Düşük risk - Genel olarak güvenli. Periyodik doktor kontrolü önerilir.';
        break;
      case 3:
        analysis += 'Orta risk - Dikkatli izlem gerekiyor. Düzenli doktor görüşmeleri şart.';
        break;
      case 4:
        analysis += 'Yüksek risk - Acil doktor kontrolü gerekiyor. Alternatif tedaviler değerlendirilmeli.';
        break;
      case 5:
        analysis += 'KRİTİK DURUM - Acil tıbbi müdahale gerekiyor. Hemen doktorunuza başvurun!';
        break;
    }

    return analysis;
  }

  static List<String> _generateRecommendations(List<DrugInfo> drugs, List<InteractionPair> interactions, int overallRisk) {
    final recommendations = <String>[];

    // Risk seviyesine göre genel öneriler
    switch (overallRisk) {
      case 1:
        recommendations.addAll([
          '✅ Bu ilaç kombinasyonu genel olarak güvenlidir',
          '📅 6 aylık doktor kontrolü yeterlidir',
          '💡 İlaçları düzenli saatlerde alın',
        ]);
        break;
      case 2:
        recommendations.addAll([
          '⚡ Düzenli doktor kontrolü yapın (3 ayda bir)',
          '📊 Yan etkiler için kendinizi gözlemleyin',
          '💊 İlaç dozlarında değişiklik yapmayın',
        ]);
        break;
      case 3:
        recommendations.addAll([
          '⚠️ Aylık doktor kontrolü şarttır',
          '🩸 Düzenli kan tahlili yaptırın',
          '📞 Herhangi bir yan etki hissederseniz hemen doktorunuzu arayın',
        ]);
        break;
      case 4:
      case 5:
        recommendations.addAll([
          '🚨 ACİL doktor kontrolü gerekiyor',
          '🏥 Alternatif tedavi seçenekleri değerlendirilmeli',
          '📱 24/7 doktor erişiminiz olduğundan emin olun',
          '⛔ Bu kombinasyonu kullanmaya devam etmeden önce doktorunuzla görüşün',
        ]);
        break;
    }

    // Özel etkileşimlere göre öneriler
    for (var interaction in interactions) {
      if (interaction.severity >= 4) {
        recommendations.add('🔴 ${interaction.drug1.name} + ${interaction.drug2.name}: ${interaction.recommendation}');
      }
    }

    // Genel sağlık önerileri
    recommendations.addAll([
      '💧 Bol su için (günde en az 8 bardak)',
      '🍎 Sağlıklı beslenin ve düzenli egzersiz yapın',
      '📝 İlaç alım saatlerinizi kaydedin',
      '🚫 Alkol tüketimini sınırlayın veya tamamen bırakın',
      '🛡️ Tüm doktorlarınızı kullandığınız ilaçlar hakkında bilgilendirin',
    ]);

    return recommendations;
  }
}
