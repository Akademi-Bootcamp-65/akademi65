import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/drug_info.dart';
import '../models/user_profile.dart';
import 'dart:io';
import 'dart:convert';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  // TEMPORARY: Direct API key for testing
  static const String _apiKey = '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';
  
  final Dio _dio = Dio();

  OpenAIService() {
    print('🔑 OpenAI API Key configured: ${_apiKey.substring(0, 10)}...');
    
    _dio.options.headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
  }

  /// Analyze drug prospectus PDF text and extract structured information
  Future<DrugInfo?> analyzeDrugProspectus({
    required String drugName,
    required String prospectusText,
    required UserProfile userProfile,
  }) async {
    try {
      final prompt = _buildProspectusAnalysisPrompt(drugName, prospectusText, userProfile);
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Adın Pharmatox. Sen bir ilaç uzmanısın ama halkın anlayacağı basit bir dille konuşuyorsun. Prospektüs bilgilerini analiz edip tıp jargonu kullanmadan açıklıyorsun.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseDrugInfoFromResponse(content, drugName);
    } catch (e) {
      debugPrint('OpenAI API Error: $e');
      return null;
    }
  }

  /// Analyze prospectus PDF text intelligently using AI
  Future<DrugInfo?> analyzeProspectusText({
    required String drugName,
    required String pdfText,
    required String sourceUrl,
  }) async {
    try {
      print('🤖 🚀 Starting OpenAI prospectus analysis');
      print('🤖 💊 Drug Name: $drugName');
      print('🤖 📄 PDF Text Length: ${pdfText.length} characters');
      print('🤖 🔗 Source URL: $sourceUrl');
      
      final prompt = '''
Bir ilaç prospektüsünden bilgileri basit ve anlaşılır bir dille çıkar:

İlaç Adı: $drugName
Kaynak URL: $sourceUrl

Prospektüs Metni:
${pdfText.length > 8000 ? pdfText.substring(0, 8000) + "..." : pdfText}

Aşağıdaki formatında yanıt ver:
{
  "name": "İlaç adı",
  "activeIngredient": "İlacın içindeki etken madde",
  "usage": "Hangi hastalık için kullanılır",
  "dosage": "Nasıl ve ne kadar kullanılır",
  "sideEffects": ["olabilecek yan etkiler - basit dille"],
  "contraindications": ["kimler kullanmamalı - basit dille"],
  "interactions": ["hangi ilaçlarla beraber kullanılmamalı"],
  "pregnancyWarning": "Hamile ve emziren anneler için uyarı",
  "storageInfo": "Nasıl saklanır",
  "overdoseInfo": "Fazla alınırsa ne olur"
}

ÖNEMLİ KURALLAR:
- Tıp jargonu kullanma
- Herkesin anlayacağı basit kelimeler kullan
- Günlük konuşma dilinde açıkla
- Karmaşık tıbbi terimler yerine basit açıklamalar yap
''';

      print('🤖 📝 Prompt prepared, length: ${prompt.length} characters');
      print('🤖 📤 Sending request to OpenAI API...');
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'Sen uzman bir eczacısın ama halkın anlayacağı basit bir dille konuşuyorsun. İlaç prospektüslerini analiz edip tıp jargonu kullanmadan açıklıyorsun.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
          'max_tokens': 2000,
        },
      );

      print('🤖 📬 Response received from OpenAI');
      print('🤖 📊 Response status: ${response.statusCode}');
      
      final content = response.data['choices'][0]['message']['content'];
      print('🤖 💬 AI Analysis Response: $content');
      
      final parsedResult = _parseAIProspectusResponse(content, drugName, sourceUrl);
      print('🤖 ✅ AI Analysis completed successfully');
      
      return parsedResult;
    } catch (e) {
      print('🤖 💥 OpenAI prospectus analysis error: $e');
      print('🤖 🔍 Error details:');
      print('🤖   - Drug Name: $drugName');
      print('🤖   - PDF Text Length: ${pdfText.length}');
      print('🤖   - Source URL: $sourceUrl');
      return null;
    }
  }

  /// Analyze prescription photo using GPT-4 Vision
  Future<List<Map<String, dynamic>>?> analyzePrescriptionPhoto({
    required String base64Image,
    required UserProfile userProfile,
  }) async {
    try {
      final prompt = _buildPrescriptionAnalysisPrompt(userProfile);
      
      print('🚀 Sending request to OpenAI...');
      print('📝 Prompt: $prompt');
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': 'Adın Pharmatox. Sen bir reçete analiz uzmanısın ama halkın anlayacağı basit bir dille konuşuyorsun. Fotoğraflardan ilaç bilgilerini çıkarıp tıp jargonu kullanmadan açıklıyorsun.'},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      print('🤖 OpenAI response: $content');
      
      final parsedResult = _parsePrescriptionFromResponse(content);
      print('📊 Parsed result: $parsedResult');
      
      return parsedResult;
    } catch (e) {
      debugPrint('OpenAI Vision API Error: $e');
      return null;
    }
  }

  /// Check drug interactions
  Future<String?> checkDrugInteractions({
    required List<String> drugNames,
    required UserProfile userProfile,
  }) async {
    try {
      // İlk önce gerçek ilaç isimlerini filtrele
      final realDrugs = <String>[];
      final suspiciousNames = <String>[];
      
      for (final drug in drugNames) {
        final drugLower = drug.toLowerCase();
        // Şüpheli isimler (süper kahramanlar, film karakterleri vs.)
        if (drugLower.contains('spider') || drugLower.contains('batman') || 
            drugLower.contains('hulk') || drugLower.contains('superman') ||
            drugLower.contains('iron') || drugLower.contains('thor') ||
            drugLower.contains('wonder')) {
          suspiciousNames.add(drug);
        } else {
          realDrugs.add(drug);
        }
      }
      
      // Eğer hiç gerçek ilaç yoksa uyarı ver
      if (realDrugs.isEmpty) {
        return "❌ Girdiğiniz isimler gerçek ilaç isimleri gibi görünmüyor. Lütfen ilaç kutusunda yazan tam ismi yazın.\n\n" +
               "Örnek: Aspirin, Parol, Voltaren, Nurofen gibi...\n\n" +
               "Not: ${suspiciousNames.isNotEmpty ? 'Film karakteri isimleri ilaç değildir.' : 'Lütfen doğru ilaç isimlerini girin.'}";
      }
      
      final prompt = _buildInteractionCheckPrompt(realDrugs, userProfile);
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'system', 'content': 'Sen uzman bir eczacısın. SADECE gerçek ilaç isimleri için etkileşim analizi yaparsın. Film karakterleri veya hayali isimler ilaç değildir. Halkın anlayacağı basit bir dille konuş, tıp jargonu kullanma.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
          'max_tokens': 1000,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Drug interaction check error: $e');
      return null;
    }
  }

  /// Analyze side effect reports
  Future<Map<String, dynamic>?> analyzeSideEffect({
    required String drugName,
    required String sideEffect,
    required UserProfile userProfile,
  }) async {
    try {
      final prompt = _buildSideEffectAnalysisPrompt(drugName, sideEffect, userProfile);
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4.1-mini',
          'messages': [
            {'role': 'system', 'content': 'Sen bir yan etki analiz uzmanısın. Bildirilen yan etkileri değerlendirip risk seviyesi belirliyorsun.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.2,
          'max_tokens': 800,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseSideEffectAnalysis(content);
    } catch (e) {
      debugPrint('Side effect analysis error: $e');
      return null;
    }
  }

  /// Extract text from image using OCR
  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': 'Bu görüntüdeki tüm metni çıkar. Sadece metin içeriğini döndür, başka bir şey ekleme.'
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'max_tokens': 1000,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Text extraction error: $e');
      return null;
    }
  }

  /// Search for drug information
  Future<List<Map<String, dynamic>>?> searchDrugInformation({
    required String drugName,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4.1-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''Sen bir ilaç bilgi uzmanısın. İlaç ismi verildiğinde JSON formatında detaylı bilgi döndürüyorsun.
              Şu JSON formatını kullan:
              [
                {
                  "name": "İlaç Adı",
                  "activeIngredient": "Etken madde",
                  "usage": "Kullanım alanı",
                  "dosage": "Doz bilgisi",
                  "sideEffects": ["Yan etki 1", "Yan etki 2"],
                  "contraindications": ["Uyarı 1", "Uyarı 2"],
                  "interactions": ["Etkileşim 1", "Etkileşim 2"],
                  "pregnancyWarning": "Hamilelik uyarısı"
                }
              ]'''
            },
            {
              'role': 'user',
              'content': 'Bu ilaç hakkında bilgi ver: $drugName'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final decoded = jsonDecode(content);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      debugPrint('Drug search error: $e');
      return null;
    }
  }

  /// Get chat response for general drug consultation
  Future<String?> getChatResponse(String userMessage) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4.1-mini',
          'messages': [
            {
              'role': 'system', 
              'content': '''Senin adın pharmatoxSen uzman bir eczacısın ama halkın anlayacağı basit bir dille konuşuyorsun. Türkçe olarak kullanıcıların ilaç sorularına güvenilir, net ve anlaşılır şekilde cevap veriyorsun. 
              
              Kurallar:
              - Tıp jargonu kullanma, herkesin anlayacağı basit kelimeler kullan
              - Her zaman güvenli ve doğru bilgi ver
              - Ciddi durumlar için doktora yönlendir
              - Doz önerileri verme, sadece genel bilgi ver
              - Tanı koyma
              - Nazik ve yardımsever ol
              - Kısa ve öz cevaplar ver
              - Günlük konuşma dilinde açıkla
              - Karmaşık tıbbi terimleri basit açıklamalarla değiştir'''
            },
            {'role': 'user', 'content': userMessage}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Chat API Error: $e');
      return null;
    }
  }

  /// Get structured drug analysis using enhanced prompt
  Future<Map<String, dynamic>?> getStructuredDrugAnalysis(String prompt) async {
    try {
      print('🤖 [OPENAI DEBUG] Starting structured drug analysis...');
      print('🤖 [OPENAI DEBUG] Prompt length: ${prompt.length} characters');
      print('🤖 [OPENAI DEBUG] Prompt preview: ${prompt.substring(0, 300)}...');
      print('🤖 [OPENAI DEBUG] Making API call to OpenAI...');
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': 'Sen bir eczacı ve ilaç uzmanısın. Verilen ilaç bilgilerini analiz edip yapılandırılmış JSON bilgi kartları oluşturuyorsun. SADECE JSON formatında yanıt ver, başka hiçbir açıklama, markdown veya metin ekleme. Her kart şu formatta olmalı: {"title":"string","content":"string","type":"string","priority":integer,"icon":"string","color":"hex"}'},
            {'role': 'user', 'content': '$prompt\n\nÇOK ÖNEMLİ: Sadece JSON formatında yanıt ver. Hiçbir açıklama, markdown (```json veya ```), veya başka metin ekleme. Her kartın priority değeri integer (1-10) olmalı. Direkt JSON başlat:\n\n{"cards":[{"title":"🔍 Genel Bilgiler","content":"...","type":"info","priority":1,"icon":"info","color":"#4A90A4"},...]}'}
          ],
          'temperature': 0.1,
          'max_tokens': 2000,
        },
      );

      print('🤖 [OPENAI DEBUG] Response received for structured analysis');
      print('🤖 [OPENAI DEBUG] Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('🤖 [OPENAI DEBUG] ❌ API returned error status: ${response.statusCode}');
        print('🤖 [OPENAI DEBUG] Error response: ${response.data}');
        return null;
      }
      
      final content = response.data['choices'][0]['message']['content'];
      print('🤖 [OPENAI DEBUG] Structured analysis response length: ${content?.length ?? 0}');
      print('🤖 [OPENAI DEBUG] Structured analysis response preview: ${content?.substring(0, 200) ?? 'NULL'}...');
      
      final parsedResult = _parseStructuredAnalysis(content);
      print('🤖 [OPENAI DEBUG] Structured analysis parsing result: ${parsedResult != null ? 'SUCCESS' : 'FAILED'}');
      if (parsedResult != null) {
        print('🤖 [OPENAI DEBUG] Parsed result keys: ${parsedResult.keys.toList()}');
      }
      
      return parsedResult;
    } catch (e) {
      print('🤖 [OPENAI DEBUG] ❌ Structured analysis error: $e');
      print('🤖 [OPENAI DEBUG] Error type: ${e.runtimeType}');
      if (e is DioException) {
        print('🤖 [OPENAI DEBUG] Dio error type: ${e.type}');
        print('🤖 [OPENAI DEBUG] Dio error message: ${e.message}');
        if (e.response != null) {
          print('🤖 [OPENAI DEBUG] Dio response status: ${e.response?.statusCode}');
          print('🤖 [OPENAI DEBUG] Dio response data: ${e.response?.data}');
        }
      }
      return null;
    }
  }

  /// Parse structured analysis response
  Map<String, dynamic>? _parseStructuredAnalysis(String response) {
    try {
      print('🤖 🔧 Parsing structured analysis response...');
      print('🤖 📝 Response length: ${response.length} characters');
      
      // Clean the response to extract JSON
      String cleanedResponse = response.trim();
      
      // Remove markdown code blocks if present
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
        print('🤖 🧹 Removed ```json prefix');
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
        print('🤖 🧹 Removed ``` prefix');
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        print('🤖 🧹 Removed ``` suffix');
      }
      
      cleanedResponse = cleanedResponse.trim();
      print('🤖 📋 Cleaned response length: ${cleanedResponse.length} characters');
      
      // Find JSON object start and end
      int jsonStart = cleanedResponse.indexOf('{');
      int jsonEnd = cleanedResponse.lastIndexOf('}');
      
      print('🤖 🔍 JSON boundaries: start=$jsonStart, end=$jsonEnd');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        String jsonString = cleanedResponse.substring(jsonStart, jsonEnd + 1);
        print('🤖 📄 Extracted JSON string: $jsonString');
        
        final Map<String, dynamic> result = jsonDecode(jsonString);
        print('🤖 ✅ JSON parsed successfully');
        return result;
      } else {
        print('🤖 ❌ No valid JSON boundaries found');
        print('🤖 📄 Full response: $response');
        return null;
      }
    } catch (e) {
      print('🤖 💥 Error parsing structured analysis: $e');
      print('🤖 📄 Response was: $response');
      return null;
    }
  }

  String _buildProspectusAnalysisPrompt(String drugName, String prospectusText, UserProfile userProfile) {
    return '''
İlaç adı: $drugName

Kişi bilgileri:
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}
- Hamilelik: ${userProfile.isPregnant ? 'Evet' : 'Hayır'}
- Bilgi seviyesi: ${userProfile.infoLevel}

Prospektüs metni:
$prospectusText

Bu ilaç bilgilerini analiz edip aşağıdaki formatında basit ve anlaşılır bir dille ver:

{
  "activeIngredient": "ilacın içindeki etken madde",
  "usage": "hangi hastalık veya rahatsızlık için kullanılır",
  "dosage": "nasıl ve ne kadar kullanılır",
  "sideEffects": ["olabilecek yan etkiler - basit dille"],
  "contraindications": ["kimler kullanmamalı - basit dille"],
  "interactions": ["hangi ilaçlarla beraber kullanılmamalı - basit dille"],
  "pregnancyWarning": "hamile ve emziren anneler için uyarı",
  "storageInfo": "nasıl saklanır",
  "overdoseInfo": "fazla alınırsa ne olur ve ne yapılır"
}

ÖNEMLİ KURALLAR (Bilgi Seviyesi: ${userProfile.infoLevel}):
- Tıp jargonu kullanma
- Herkesин anlayacağı basit kelimeler kullan
- "kontrendikasyon" yerine "kimler kullanmamalı" de
- "hepatotoksisite" yerine "karaciğere zarar" de
- "nefrotoksisite" yerine "böbreklere zarar" de
- Karmaşık tıbbi terimler kullanma
- Günlük konuşma dilinde açıkla
''';
  }

  String _buildPrescriptionAnalysisPrompt(UserProfile userProfile) {
    return '''
Bu reçete fotoğrafından ilaç bilgilerini çıkar ve basit bir dille açıkla.

Kişi bilgileri:
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}
- Hamilelik: ${userProfile.isPregnant ? 'Evet' : 'Hayır'}

Aşağıdaki formatında yanıt ver:
[
  {
    "name": "ilaç adı",
    "activeIngredient": "ilacın içindeki etken madde",
    "usage": "hangi hastalık için kullanılır",
    "dosage": "nasıl ve ne kadar kullanılır",
    "sideEffects": ["olabilecek yan etkiler - basit dille"],
    "contraindications": ["kimler kullanmamalı - basit dille"],
    "interactions": ["hangi ilaçlarla beraber kullanılmamalı"],
    "pregnancyWarning": "hamile ve emziren anneler için uyarı",
    "storageInfo": "nasıl saklanır",
    "overdoseInfo": "fazla alınırsa ne olur"
  }
]

ÖNEMLİ: Tıp jargonu kullanma! Herkesin anlayacağı basit kelimelerle açıkla. Günlük konuşma dilinde yaz.
''';
  }

  String _buildInteractionCheckPrompt(List<String> drugNames, UserProfile userProfile) {
    return '''
SADECE bu gerçek ilaçları analiz et (süper kahraman isimleri değil!):
${drugNames.join(', ')}

Kişi bilgileri:
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}
- Hamilelik: ${userProfile.isPregnant ? 'Evet' : 'Hayır'}

Bu ilaçlar gerçek mi kontrol et. Eğer gerçek ilaçlarsa:

Eğer beraber kullanmak tehlikeliyse:
- Ne kadar tehlikeli olduğunu söyle (Az Tehlikeli/Orta Tehlikeli/Çok Tehlikeli)
- Neden tehlikeli olduğunu basit bir dille açıkla
- Ne yapması gerektiğini söyle

Eğer beraber kullanmak güvenliyse "Bu ilaçları beraber kullanmakta sakınca yok" de.

ÖNEMLİ: 
- SADECE gerçek ilaç isimleri analiz et
- Film karakteri isimleri (Spiderman, Batman vs.) ilaç değildir
- Tıp jargonu kullanma, sade ve anlaşılır bir dille yaz
- Halk tarafından anlaşılacak kelimeler kullan
''';
  }

  String _buildSideEffectAnalysisPrompt(String drugName, String sideEffect, UserProfile userProfile) {
    return '''
İlaç: $drugName
Yaşanan durum: $sideEffect

Kişi bilgileri:
- Yaş: ${userProfile.age}
- Cinsiyet: ${userProfile.gender}

Bu durum hakkında basit bir dille bilgi ver:
1. Bu ilacın bilinen bir yan etkisi mi?
2. Ne kadar ciddi? (Hafif/Orta/Ciddi)
3. Doktora gitmek gerekiyor mu?
4. Ne yapması önerirsin?

JSON formatında yanıt ver:
{
  "isKnownSideEffect": true/false,
  "severity": "Hafif/Orta/Ciddi",
  "requiresAttention": true/false,
  "recommendation": "basit ve anlaşılır öneri"
}

ÖNEMLİ: Tıp jargonu kullanma, herkesin anlayacağı basit kelimelerle açıkla.
''';
  }

  DrugInfo? _parseDrugInfoFromResponse(String response, String drugName) {
    try {
      // JSON parsing logic here
      // This is a simplified version - implement proper JSON parsing
      return DrugInfo(
        name: drugName,
        activeIngredient: '',
        usage: '',
        dosage: '',
        sideEffects: [],
        contraindications: [],
        interactions: [],
        pregnancyWarning: '',
        storageInfo: '',
        overdoseInfo: '',
      );
    } catch (e) {
      debugPrint('Error parsing drug info: $e');
      return null;
    }
  }

  List<Map<String, dynamic>>? _parsePrescriptionFromResponse(String response) {
    try {
      // Clean the response to extract JSON
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      
      cleanedResponse = cleanedResponse.trim();
      
      // Find JSON array start and end
      int jsonStart = cleanedResponse.indexOf('[');
      int jsonEnd = cleanedResponse.lastIndexOf(']');
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        String jsonString = cleanedResponse.substring(jsonStart, jsonEnd + 1);
        
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error parsing prescription: $e');
      debugPrint('Response was: $response');
      return null;
    }
  }

  Map<String, dynamic>? _parseSideEffectAnalysis(String response) {
    try {
      // JSON parsing logic here
      return {};
    } catch (e) {
      debugPrint('Error parsing side effect analysis: $e');
      return null;
    }
  }

  /// Extract drug names from text using AI to understand context
  Future<List<String>?> extractDrugNamesFromText(String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''Sen bir Türkiye eczacısısın. Verilen metinden SADECE gerçek, TİTCK onaylı ilaç isimlerini çıkar.

KESİN KURALLAR:
1. SADECE gerçek ilaç marka isimleri (Aspirin, Parol, Voltaren, Concerta, Prozac gibi)
2. Film/çizgi roman karakterleri DEĞİL (Spiderman, Batman, Hulk, Superman DEĞİL!)
3. Etken madde isimleri DEĞİL (Parasetamol, Ibuprofen DEĞİL!)
4. Firma isimleri DEĞİL (Bayer, Pfizer DEĞİL!)
5. Dozaj bilgileri DEĞİL (20mg, 500ml DEĞİL!)
6. Eğer hiç gerçek ilaç yoksa boş liste döndür: {"drug_names": []}

GERÇEK İLAÇ ÖRNEKLERİ:
✅ Aspirin, Parol, Voltaren, Nurofen, Majezik, Cataflam, Advil, Tylenol
❌ Spiderman, Batman, Hulk, Superman, Iron Man (bunlar ilaç değil!)

JSON formatında döndür:
{"drug_names": ["sadece_gerçek_ilaçlar"]}'''
            },
            {
              'role': 'user',
              'content': 'Bu metindeki ilaç isimlerini çıkar:\n\n$text'
            }
          ],
          'max_tokens': 500,
          'temperature': 0.1,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      print('🤖 AI response for drug extraction: $content');
      
      // Parse JSON response
      try {
        final jsonResponse = jsonDecode(content);
        final drugNames = List<String>.from(jsonResponse['drug_names'] ?? []);
        return drugNames.where((name) => name.isNotEmpty).toList();
      } catch (e) {
        print('⚠️ Failed to parse AI JSON response: $e');
        // Try to extract drug names from plain text response
        return _extractDrugNamesFromPlainText(content);
      }
    } catch (e) {
      print('💥 AI drug extraction error: $e');
      return null;
    }
  }

  /// Validate with AI if the detected text is actually a pharmaceutical drug.
  /// Returns true if the AI confirms it's a drug, false otherwise.
  Future<bool> isRealDrug(String drugName) async {
    try {
      print('🤖 [AI VALIDATION] Asking AI if "$drugName" is a real drug...');
      
      // SMART AI-POWERED VALIDATION - No more manual lists!
      final prompt = '''You are a world-class pharmaceutical expert with access to global drug databases.

TASK: Determine if "$drugName" is a real pharmaceutical medication.

ANALYSIS CRITERIA:
✅ REAL DRUGS include:
- Prescription medications (any country)
- Over-the-counter medicines 
- Brand names (Tylenol, Advil, Tylol Hot, İburamİn, etc.)
- Generic names (ibuprofen, paracetamol, aspirin, etc.)
- Active ingredients (acetaminophen, acetylsalicylic acid, etc.)
- Medical formulations (tablets, syrups, gels, etc.)
- International variations and misspellings
- Cold/flu medicines with modifiers (Hot, Cold, Extra, Plus, Forte)
- Pain relievers, antibiotics, vitamins, supplements

❌ NOT DRUGS:
- Fictional characters (Spider-Man, Batman, Hulk)
- Food items (pizza, apple, bread)  
- Objects (car, phone, table)
- Places (cities, countries)
- Random words or nonsense

SMART RECOGNITION PATTERNS:
- Names ending in medical suffixes: -in, -ol, -ine, -ate, -ium
- Names containing medical prefixes: anti-, pro-, meta-, para-
- Brand names that sound pharmaceutical
- Turkish, English, and international drug names
- Common pharmaceutical naming conventions

EXAMPLES:
✅ "Tylol Hot" → REAL (Turkish cold medicine)
✅ "İburamİn" → REAL (Turkish ibuprofen brand)
✅ "Tylenol" → REAL (acetaminophen brand)
✅ "aspirin" → REAL (generic pain reliever)
❌ "Spider-Man" → NOT REAL (fictional character)
❌ "pizza" → NOT REAL (food)

Question: Is "$drugName" a real pharmaceutical medication?

Think about:
1. Does it sound like a drug name?
2. Does it follow pharmaceutical naming patterns?
3. Could it be a brand or generic medication?
4. Is it clearly NOT a drug (food, person, object)?

Answer with ONLY: YES or NO''';

      final response = await getChatResponse(prompt);
      
      if (response != null) {
        final cleanResponse = response.trim().toUpperCase();
        print('🤖 [AI VALIDATION] AI response for "$drugName": "$cleanResponse"');
        
        // Simple YES/NO detection
        if (cleanResponse.contains('YES') || 
            (cleanResponse.contains('REAL') && !cleanResponse.contains('NOT'))) {
          print('✅ [AI VALIDATION] "$drugName" confirmed as real drug');
          return true;
        } else {
          print('❌ [AI VALIDATION] "$drugName" rejected as non-drug. Response was: "$cleanResponse"');
          return false;
        }
      }
      
      print('⚠️ [AI VALIDATION] No response from AI, defaulting to false');
      return false;
    } catch (e) {
      print('💥 [AI VALIDATION] Error validating "$drugName": $e');
      return false; // Default to false for safety
    }
  }

  /// Extract drug names from plain text AI response as fallback
  List<String> _extractDrugNamesFromPlainText(String text) {
    final drugNames = <String>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      final cleaned = line.trim();
      // Look for lines that might contain drug names
      if (cleaned.isNotEmpty && 
          !cleaned.toLowerCase().contains('etken') &&
          !cleaned.toLowerCase().contains('madde') &&
          !cleaned.toLowerCase().contains('firma') &&
          !cleaned.toLowerCase().contains('tescil') &&
          cleaned.length > 2 &&
          cleaned.length < 30) {
        
        // Remove common prefixes and suffixes
        final drugName = cleaned
            .replaceAll(RegExp(r'^[-•*\d\.\s]+'), '')
            .replaceAll(RegExp(r'\s*\d+\s*(mg|ml|g).*$'), '')
            .trim();
            
        if (drugName.isNotEmpty && RegExp(r'^[A-ZŞĞÜÖÇİ]').hasMatch(drugName)) {
          drugNames.add(drugName);
        }
      }
    }
    
    return drugNames;
  }

  // ...existing code...

  /// Test method to verify JSON parsing - for development only
  List<Map<String, dynamic>>? testParsing() {
    // This method is for testing purposes only
    return null;
  }

  /// Parse AI prospectus analysis response
  DrugInfo? _parseAIProspectusResponse(String content, String drugName, String sourceUrl) {
    try {
      print('🤖 🔧 Parsing AI response...');
      print('🤖 📝 Response content length: ${content.length} characters');
      
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        print('🤖 ❌ No JSON found in AI response');
        print('🤖 📄 Full response: $content');
        return null;
      }

      final jsonStr = jsonMatch.group(0)!;
      print('🤖 📋 Extracted JSON: $jsonStr');
      
      final jsonData = jsonDecode(jsonStr);
      print('🤖 ✅ JSON parsed successfully');

      final drugInfo = DrugInfo(
        name: jsonData['name']?.toString() ?? drugName,
        activeIngredient: jsonData['activeIngredient']?.toString() ?? '',
        usage: jsonData['usage']?.toString() ?? '',
        dosage: jsonData['dosage']?.toString() ?? '',
        sideEffects: _parseListFromJson(jsonData['sideEffects']),
        contraindications: _parseListFromJson(jsonData['contraindications']),
        interactions: _parseListFromJson(jsonData['interactions']),
        pregnancyWarning: jsonData['pregnancyWarning']?.toString() ?? '',
        storageInfo: jsonData['storageInfo']?.toString() ?? '',
        overdoseInfo: jsonData['overdoseInfo']?.toString() ?? '',
        prospectusUrl: sourceUrl,
      );
      
      print('🤖 🎯 DrugInfo created successfully');
      print('🤖 💊 Name: ${drugInfo.name}');
      print('🤖 🧪 Active Ingredient: ${drugInfo.activeIngredient}');
      print('🤖 📋 Usage: ${drugInfo.usage}');
      
      return drugInfo;
    } catch (e) {
      print('🤖 💥 Error parsing AI prospectus response: $e');
      print('🤖 📄 Content: $content');
      return null;
    }
  }

  /// Parse list from JSON data
  List<String> _parseListFromJson(dynamic data) {
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    } else if (data is String && data.isNotEmpty) {
      return [data];
    }
    return [];
  }
}

