import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../config/api_config.dart';
import '../models/drug_info.dart';
import '../services/openai_service.dart';

class ProspectusService {
  static final Dio _dio = Dio();

  /// Search for official drug prospectus and extract structured data
  static Future<DrugInfo?> findDrugProspectus(String drugName) async {
    try {
      print('🔍 [FINDPROSPECTUS DEBUG] Searching for prospectus: $drugName');
      
      // Only use Google Custom Search API (most reliable and comprehensive)
      print('📡 [FINDPROSPECTUS DEBUG] Attempting Google Custom Search API...');
      final googleResult = await _deepGoogleSearch(drugName);
      print('📡 [FINDPROSPECTUS DEBUG] Google search result: ${googleResult != null ? 'SUCCESS' : 'NULL'}');
      if (googleResult != null) {
        print('✅ [FINDPROSPECTUS DEBUG] Found via Google Custom Search API');
        return googleResult;
      }
      
      print('❌ [FINDPROSPECTUS DEBUG] No prospectus found for: $drugName via Google Custom Search');
      return null;
    } catch (e) {
      print('💥 [FINDPROSPECTUS DEBUG] Error searching prospectus: $e');
      return null;
    }
  }

  /// Deep Google search using Custom Search API to find official drug prospectus PDFs
  static Future<DrugInfo?> _deepGoogleSearch(String drugName) async {
    try {
      print('🔍 [GOOGLESEARCH DEBUG] Starting Google Custom Search for: $drugName');
      
      // Check if Google API is configured
      if (!ApiConfig.isGoogleApiConfigured) {
        print('⚠️ [GOOGLESEARCH DEBUG] Google API not configured, skipping Google Custom Search');
        return null;
      }
      
      print('✅ [GOOGLESEARCH DEBUG] Google API is configured');
      final apiKey = ApiConfig.googleApiKeyFromEnv;
      final searchEngineId = ApiConfig.googleSearchEngineIdFromEnv;
      print('🔑 [GOOGLESEARCH DEBUG] Using API key: ${apiKey.substring(0, 10)}... and engine: $searchEngineId');
      
      // Optimized search queries - "İlaç Adı Prospektüs" format brings original PDFs first
      final searchQueries = [
        '$drugName prospektüs',                    // Most effective - original PDFs appear first
        '"$drugName" prospektüs PDF',              // Exact match with PDF specification
        '$drugName kullanma talimatı',             // Alternative Turkish term
        '$drugName prospectus filetype:pdf',       // Force PDF results
        '$drugName drug information leaflet',      // English alternative
        '$drugName official prescribing information', // Official sources
      ];
      
      for (final query in searchQueries) {
        print('🔎 Trying Google API query: $query');
        
        try {
          // Use Google Custom Search API
          final searchUrl = 'https://www.googleapis.com/customsearch/v1';
          final response = await _dio.get(
            searchUrl,
            queryParameters: {
              'key': apiKey,
              'cx': searchEngineId,
              'q': query,
              'num': 10,
              'fileType': query.contains('filetype:pdf') ? 'pdf' : null,
            }..removeWhere((key, value) => value == null),
          );
          
          if (response.statusCode == 200) {
            final results = await _parseGoogleAPIResults(response.data, drugName);
            if (results != null) {
              print('✅ Found prospectus via Google Custom Search API');
              return results;
            }
          }
          
          // Add delay to respect API rate limits
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          print('⚠️ Google API query failed: $query - $e');
          
          // If quota exceeded or API issues, break out of loop
          if (e.toString().contains('quotaExceeded') || 
              e.toString().contains('keyInvalid') ||
              e.toString().contains('accessNotConfigured')) {
            print('💥 Google API issue detected, switching to fallback methods');
            break;
          }
          continue;
        }
      }
      
      return null;
      
    } catch (e) {
      print('💥 Google Custom Search error: $e');
      return null;
    }
  }

  /// Parse Google Custom Search API results to find pharmaceutical PDFs
  static Future<DrugInfo?> _parseGoogleAPIResults(Map<String, dynamic> apiResponse, String drugName) async {
    try {
      final items = apiResponse['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        print('No search results found');
        return null;
      }
      
      for (final item in items) {
        final url = item['link'] as String?;
        final title = item['title'] as String?;
        final snippet = item['snippet'] as String?;
        
        if (url == null || title == null) continue;
        
        print('🔗 Checking result: $title');
        print('🌐 URL: $url');
        
        // Filter for high-quality prospectus sources
        if (_isRelevantProspectusLink(url, title, snippet ?? '', drugName)) {
          print('🎯 Found relevant prospectus link');
          
          // Try to fetch and parse the prospectus
          final prospectusData = await _fetchAndParseProspectus(url, drugName);
          if (prospectusData != null) {
            prospectusData.prospectusUrl = url; // Store source URL
            return prospectusData;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error parsing Google API results: $e');
      return null;
    }
  }

  /// Check if a link is relevant for drug prospectus
  static bool _isRelevantProspectusLink(String url, String title, String snippet, String drugName) {
    final urlLower = url.toLowerCase();
    final titleLower = title.toLowerCase();
    final snippetLower = snippet.toLowerCase();
    final drugNameLower = drugName.toLowerCase();
    
    print('🔍 Evaluating link relevance:');
    print('   📋 Title: $title');
    print('   🌐 URL: $url');
    print('   💊 Drug: $drugName');
    
    // FIRST: Check blacklisted sites and reject immediately
    final blacklistedSites = [
      'ilacabak.com',
      'ilacprospektusu.com',
      'eczanede.com',
      'drugs.com',
      'webmd.com',
      'medlineplus.gov',
      'rxlist.com'
    ];
    
    for (final blacklisted in blacklistedSites) {
      if (urlLower.contains(blacklisted)) {
        print('   ❌ Rejected: Third-party aggregator site ($blacklisted) - seeking original source');
        return false;
      }
    }
    
    // Must contain drug name
    final containsDrugName = titleLower.contains(drugNameLower) || snippetLower.contains(drugNameLower);
    print('   ✅ Contains drug name: $containsDrugName');
    
    if (!containsDrugName) {
      print('   ❌ Rejected: Does not contain drug name');
      return false;
    }
    
    // Priority 1: Direct PDF links (most likely original sources)
    if (urlLower.endsWith('.pdf')) {
      print('   📄 Found PDF link!');
      final hasProspectusKeywords = _containsProspectusKeywords(titleLower, snippetLower);
      print('   📝 Contains prospectus keywords: $hasProspectusKeywords');
      print('   🎯 PDF link accepted as likely original source');
      return true; // Accept all PDFs that contain drug name
    }
    
    // Priority 2: Official pharmaceutical company websites (ORIGINAL SOURCES ONLY)
    final pharmaCompanies = [
      'berkoilac.com.tr',      // Berko İlaç (İburamin üreticisi)
      'eczacibasi.com.tr',     // Eczacıbaşı İlaç
      'novartis.com.tr',       // Novartis Türkiye
      'pfizer.com.tr',         // Pfizer Türkiye
      'roche.com.tr',          // Roche Türkiye
      'bayer.com.tr',          // Bayer Türkiye
      'sanofi.com.tr',         // Sanofi Türkiye
      'abbott.com.tr',         // Abbott Türkiye
      'gsk.com.tr',            // GSK Türkiye
      'merck.com.tr',          // Merck Türkiye
      'jnj.com',               // Johnson & Johnson
      'astrazeneca.com.tr',    // AstraZeneca Türkiye
      'boehringer-ingelheim.com.tr', // Boehringer Ingelheim
      'takeda.com.tr',         // Takeda Türkiye
      'lilly.com.tr',          // Lilly Türkiye
      'zentiva.com.tr',        // Zentiva Türkiye
      'abdi-ibrahim.com.tr',   // Abdi İbrahim İlaç
      'deva.com.tr',           // Deva Holding
      'bilim-ilac.com.tr',     // Bilim İlaç
      'gen-ilac.com.tr',       // Gen İlaç
      'sandoz.com.tr',         // Sandoz Türkiye
      'teva.com.tr',           // Teva Türkiye
      'polifarma.com.tr',      // Polifarma
      'mustafanev.com.tr'      // Mustafa Nevzat İlaç
    ];
    
    for (final company in pharmaCompanies) {
      if (urlLower.contains(company)) {
        print('   🏭 Found official pharmaceutical company website: $company');
        return _containsProspectusKeywords(titleLower, snippetLower);
      }
    }
    
    // Priority 3: Official medical regulatory databases ONLY
    final officialSites = [
      'titck.gov.tr',         // Turkish Medicines Agency (Official)
      'ema.europa.eu',        // European Medicines Agency (Official)
      'fda.gov',              // US FDA (Official)
      'medicines.org.uk',     // UK Medicines Agency (Official)
      'hc-sc.gc.ca',          // Health Canada (Official)
      'tga.gov.au',           // Australian TGA (Official)
      'medsafe.govt.nz'       // New Zealand Medsafe (Official)
    ];
    
    for (final site in officialSites) {
      if (urlLower.contains(site)) {
        print('   🏛️ Found official regulatory database: $site');
        return _containsProspectusKeywords(titleLower, snippetLower);
      }
    }
    
    print('   ❌ Rejected: Not a recognized pharmaceutical or medical site');
    return false;
  }

  /// Check if title or snippet contains prospectus-related keywords
  static bool _containsProspectusKeywords(String titleLower, String snippetLower) {
    final keywords = [
      'prospektüs', 'kullanma talimatı', 'prospectus', 'patient information',
      'leaflet', 'package insert', 'medication guide', 'drug information',
      'prescribing information', 'summary of product characteristics',
      'spc', 'pil', 'ilaç bilgisi', 'hasta bilgi', 'kullanım kılavuzu'
    ];
    
    final combinedText = '$titleLower $snippetLower';
    
    for (final keyword in keywords) {
      if (combinedText.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }

  /// Fetch and parse prospectus from URL (handles both PDF and HTML)
  static Future<DrugInfo?> _fetchAndParseProspectus(String url, String drugName) async {
    try {
      print('📄 Fetching prospectus from: $url');
      
      // Handle PDF files differently
      if (url.toLowerCase().endsWith('.pdf')) {
        return await _processPDFProspectus(url, drugName);
      }
      
      // Handle HTML pages
      print('🌐 Fetching HTML prospectus page...');
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      
      print('📊 HTML response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('📄 HTML content received, length: ${response.data.toString().length} characters');
        
        // Extract all text from HTML page for AI analysis
        final document = html.parse(response.data);
        final pageText = document.body?.text ?? document.outerHtml;
        
        print('📝 Extracted HTML text length: ${pageText.length} characters');
        print('📖 First 500 characters: ${pageText.substring(0, pageText.length > 500 ? 500 : pageText.length)}...');
        
        // Use AI to analyze the HTML text content
        try {
          print('🤖 Starting AI analysis of HTML prospectus content...');
          final openAIService = OpenAIService();
          final aiAnalysis = await openAIService.analyzeProspectusText(
            drugName: drugName,
            pdfText: pageText, // Use extracted HTML text
            sourceUrl: url,
          );
          
          if (aiAnalysis != null) {
            print('🤖 ✅ AI successfully analyzed HTML prospectus');
            return aiAnalysis;
          } else {
            print('❌ AI analysis of HTML failed, using fallback...');
          }
        } catch (e) {
          print('💥 AI analysis of HTML failed: $e');
        }
        
        // Fallback to keyword-based HTML parsing
        print('🔄 Using keyword-based HTML parsing as fallback...');
        return _parseHTMLProspectus(document, drugName);
      }
      
      return null;
    } catch (e) {
      print('Error fetching prospectus: $e');
      return null;
    }
  }

  /// Process PDF prospectus (extract text and analyze)
  static Future<DrugInfo?> _processPDFProspectus(String pdfUrl, String drugName) async {
    try {
      print('📑 Processing PDF prospectus: $pdfUrl');
      print('🔍 Drug name: $drugName');
      
      // Download PDF file
      print('⬇️ Starting PDF download...');
      final response = await _dio.get(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );
      
      print('📊 Download response status: ${response.statusCode}');
      print('📦 Downloaded bytes: ${response.data?.length ?? 0}');
      
      if (response.statusCode == 200 && response.data != null) {
        final pdfBytes = response.data as List<int>;
        print('✅ PDF downloaded successfully: ${pdfBytes.length} bytes');
        
        // Extract text from PDF
        print('🔤 Attempting to extract text from PDF...');
        final pdfText = await _extractTextFromPDF(pdfBytes);
        
        if (pdfText != null && pdfText.isNotEmpty) {
          print('✅ Successfully extracted ${pdfText.length} characters from PDF');
          print('📖 First 500 characters: ${pdfText.substring(0, pdfText.length > 500 ? 500 : pdfText.length)}...');
          
          // Use AI to analyze the PDF text intelligently
          try {
            print('🤖 Starting AI analysis of PDF content...');
            print('🔗 Source URL: $pdfUrl');
            print('💊 Drug Name: $drugName');
            print('📄 Text Length: ${pdfText.length} characters');
            
            final openAIService = OpenAIService();
            print('🚀 Calling OpenAI analyzeProspectusText method...');
            
            final aiAnalysis = await openAIService.analyzeProspectusText(
              drugName: drugName,
              pdfText: pdfText,
              sourceUrl: pdfUrl,
            );
            
            print('📬 AI analysis response received');
            
            if (aiAnalysis != null) {
              print('🤖 ✅ AI successfully analyzed prospectus PDF');
              print('📋 AI extracted usage: ${aiAnalysis.usage}');
              print('💊 AI extracted dosage: ${aiAnalysis.dosage}');
              print('🧪 AI extracted active ingredient: ${aiAnalysis.activeIngredient}');
              print('⚠️ AI extracted side effects count: ${aiAnalysis.sideEffects.length}');
              return aiAnalysis;
            } else {
              print('❌ AI analysis returned null, using fallback...');
            }
          } catch (e) {
            print('💥 AI analysis failed with error: $e');
            print('🔄 Falling back to keyword extraction...');
          }
          
          // Fallback: Parse the extracted text using keyword-based extraction
          print('📝 Using keyword-based extraction as fallback...');
          return _parsePDFProspectusText(pdfText, drugName, pdfUrl);
        } else {
          print('⚠️ No text could be extracted from PDF');
          print('🔍 PDF might be image-based or corrupted');
        }
      } else {
        print('❌ PDF download failed with status: ${response.statusCode}');
      }
      
      // Fallback: Create placeholder with PDF reference
      print('🔄 Creating fallback DrugInfo with PDF reference...');
      return DrugInfo(
        name: drugName,
        activeIngredient: 'PDF kaynak: $pdfUrl',
        usage: 'Resmi prospektüs PDF dosyasından alınacak',
        dosage: 'PDF analizi gerekiyor',
        sideEffects: ['PDF kaynak mevcut'],
        contraindications: ['Detaylar PDF dosyasında'],
        interactions: ['PDF analizi gerekli'],
        pregnancyWarning: 'Resmi prospektüse bakınız',
        storageInfo: 'PDF dosyasında belirtilmiştir',
        overdoseInfo: 'Acil durumda doktora başvurun',
        prospectusUrl: pdfUrl,
      );
    } catch (e) {
      print('💥 Error processing PDF: $e');
      print('🔍 URL: $pdfUrl');
      print('🏷️ Drug: $drugName');
      return null;
    }
  }

  /// Extract text from PDF bytes using Syncfusion PDF
  static Future<String?> _extractTextFromPDF(List<int> pdfBytes) async {
    try {
      print('📄 Loading PDF document from ${pdfBytes.length} bytes...');
      
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      print('📖 PDF document loaded successfully');
      print('📃 Number of pages: ${document.pages.count}');
      
      // Extract text from the entire document
      final PdfTextExtractor textExtractor = PdfTextExtractor(document);
      final String extractedText = textExtractor.extractText();
      
      // Dispose the document
      document.dispose();
      
      print('📄 Extracted ${extractedText.length} characters from PDF');
      
      if (extractedText.isNotEmpty) {
        print('✅ PDF text extraction successful');
        // Print a sample of the extracted text
        final sampleLength = extractedText.length > 500 ? 500 : extractedText.length;
        print('📝 Sample text: ${extractedText.substring(0, sampleLength)}...');
        return extractedText;
      } else {
        print('⚠️ PDF text extraction returned empty string');
        return null;
      }
    } catch (e) {
      print('💥 PDF text extraction error: $e');
      return null;
    }
  }

  /// Parse HTML prospectus page
  static DrugInfo? _parseHTMLProspectus(Document document, String drugName) {
    try {
      // Enhanced selectors for common prospectus page structures
      final selectors = {
        'name': ['.drug-name', '.product-name', '.medication-name', 'h1', '.title', '[data-drug-name]'],
        'activeIngredient': ['.active-ingredient', '.etken-madde', '.composition', '.ingredients', '[data-active-ingredient]'],
        'usage': ['.indication', '.kullanim-alani', '.usage', '.therapeutic-indication', '[data-indication]'],
        'dosage': ['.dosage', '.doz', '.posology', '.dose', '[data-dosage]'],
        'sideEffects': ['.side-effects li', '.yan-etkiler li', '.adverse-effects li', '.undesirable-effects li'],
        'contraindications': ['.contraindications li', '.kontrendikasyonlar li', '.contraindication li'],
        'interactions': ['.interactions li', '.etkilesimler li', '.drug-interactions li'],
        'pregnancy': ['.pregnancy', '.hamilelik', '.gebelik', '.pregnancy-warning'],
        'storage': ['.storage', '.saklama-kosullari', '.storage-conditions'],
        'overdose': ['.overdose', '.asiri-doz', '.overdosage']
      };
      
      return DrugInfo(
        name: _extractText(document, selectors['name']!) ?? drugName,
        activeIngredient: _extractText(document, selectors['activeIngredient']!) ?? '',
        usage: _extractText(document, selectors['usage']!) ?? '',
        dosage: _extractText(document, selectors['dosage']!) ?? '',
        sideEffects: _extractList(document, selectors['sideEffects']!),
        contraindications: _extractList(document, selectors['contraindications']!),
        interactions: _extractList(document, selectors['interactions']!),
        pregnancyWarning: _extractText(document, selectors['pregnancy']!) ?? '',
        storageInfo: _extractText(document, selectors['storage']!) ?? '',
        overdoseInfo: _extractText(document, selectors['overdose']!) ?? '',
      );
    } catch (e) {
      print('Error parsing HTML prospectus: $e');
      return null;
    }
  }

  /// Extract text from HTML document using multiple selectors
  static String? _extractText(Document document, List<String> selectors) {
    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null && element.text.trim().isNotEmpty) {
        return element.text.trim();
      }
    }
    return null;
  }

  /// Extract list from HTML document using multiple selectors
  static List<String> _extractList(Document document, List<String> selectors) {
    for (final selector in selectors) {
      final elements = document.querySelectorAll(selector);
      if (elements.isNotEmpty) {
        return elements
            .map((e) => e.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  /// Parse PDF text content using keyword-based extraction
  static DrugInfo _parsePDFProspectusText(String pdfText, String drugName, String sourceUrl) {
    // Keyword-based extraction logic
    final lines = pdfText.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    
    String activeIngredient = '';
    String usage = '';
    String dosage = '';
    List<String> sideEffects = [];
    List<String> contraindications = [];
    List<String> interactions = [];
    String pregnancyWarning = '';
    String storageInfo = '';
    String overdoseInfo = '';
    
    // Enhanced keyword-based extraction
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      
      // Active ingredient extraction
      if ((line.contains('etken madde') || line.contains('active ingredient') || line.contains('composition')) && activeIngredient.isEmpty) {
        activeIngredient = _extractSectionContent(lines, i, 3);
      }
      
      // Usage extraction
      if ((line.contains('endikasyon') || line.contains('kullanım alanı') || line.contains('indication') || line.contains('ne için kullanılır')) && usage.isEmpty) {
        usage = _extractSectionContent(lines, i, 5);
      }
      
      // Dosage extraction
      if ((line.contains('doz') || line.contains('posolog') || line.contains('dosage') || line.contains('nasıl kullanılır')) && dosage.isEmpty) {
        dosage = _extractSectionContent(lines, i, 5);
      }
      
      // Side effects extraction
      if ((line.contains('yan etki') || line.contains('side effect') || line.contains('adverse')) && sideEffects.isEmpty) {
        final effectsText = _extractSectionContent(lines, i, 10);
        sideEffects = _extractListItems(effectsText);
      }
      
      // Contraindications extraction
      if ((line.contains('kontrendikasyon') || line.contains('contraindication') || line.contains('kullanılmamalı')) && contraindications.isEmpty) {
        final contraindicationsText = _extractSectionContent(lines, i, 8);
        contraindications = _extractListItems(contraindicationsText);
      }
      
      // Interactions extraction
      if ((line.contains('etkileşim') || line.contains('interaction') || line.contains('diğer ilaçlar')) && interactions.isEmpty) {
        final interactionsText = _extractSectionContent(lines, i, 8);
        interactions = _extractListItems(interactionsText);
      }
      
      // Pregnancy warning extraction
      if ((line.contains('hamilelik') || line.contains('gebelik') || line.contains('pregnancy')) && pregnancyWarning.isEmpty) {
        pregnancyWarning = _extractSectionContent(lines, i, 3);
      }
      
      // Storage info extraction
      if ((line.contains('saklama') || line.contains('storage') || line.contains('muhafaza')) && storageInfo.isEmpty) {
        storageInfo = _extractSectionContent(lines, i, 3);
      }
      
      // Overdose info extraction
      if ((line.contains('aşırı doz') || line.contains('overdose') || line.contains('zehirlenme')) && overdoseInfo.isEmpty) {
        overdoseInfo = _extractSectionContent(lines, i, 3);
      }
    }
    
    return DrugInfo(
      name: drugName,
      activeIngredient: activeIngredient.isNotEmpty ? activeIngredient : 'Prospektüsten çıkarılacak',
      usage: usage.isNotEmpty ? usage : 'Doktor tavsiyesi gerekir',
      dosage: dosage.isNotEmpty ? dosage : 'Doktor tavsiyesi gerekir',
      sideEffects: sideEffects.isNotEmpty ? sideEffects : ['Prospektüse bakınız'],
      contraindications: contraindications.isNotEmpty ? contraindications : ['Doktor danışmanlığı gerekir'],
      interactions: interactions.isNotEmpty ? interactions : ['Diğer ilaçlarla etkileşim için doktora danışın'],
      pregnancyWarning: pregnancyWarning.isNotEmpty ? pregnancyWarning : 'Hamilelikte doktor tavsiyesi gerekir',
      storageInfo: storageInfo.isNotEmpty ? storageInfo : 'Oda sıcaklığında saklayın',
      overdoseInfo: overdoseInfo.isNotEmpty ? overdoseInfo : 'Aşırı doz durumunda acil servise başvurun',
      prospectusUrl: sourceUrl,
    );
  }

  /// Extract content from a section starting at given line index
  static String _extractSectionContent(List<String> lines, int startIndex, int maxLines) {
    final content = <String>[];
    int currentIndex = startIndex + 1;
    int linesRead = 0;
    
    while (currentIndex < lines.length && linesRead < maxLines) {
      final line = lines[currentIndex].trim();
      
      // Stop if we hit a new section header
      if (_isSectionHeader(line)) {
        break;
      }
      
      if (line.isNotEmpty) {
        content.add(line);
        linesRead++;
      }
      
      currentIndex++;
    }
    
    return content.join(' ').trim();
  }

  /// Extract list items from text content
  static List<String> _extractListItems(String text) {
    final items = <String>[];
    
    // Split by common list separators
    final separators = [',', ';', '\n', '•', '-', '*'];
    
    List<String> parts = [text];
    for (final separator in separators) {
      final newParts = <String>[];
      for (final part in parts) {
        newParts.addAll(part.split(separator));
      }
      parts = newParts;
    }
    
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed.length > 3) {
        items.add(trimmed);
      }
    }
    
    return items.take(10).toList(); // Limit to 10 items
  }

  /// Check if a line is a section header
  static bool _isSectionHeader(String line) {
    final upperLine = line.toUpperCase();
    return upperLine.length < 50 && 
           (upperLine.contains('BÖLÜM') || 
            upperLine.contains('SECTION') ||
            RegExp(r'^\d+\.').hasMatch(line));
  }

  /// Get comprehensive drug analysis with AI enhancement
  static Future<Map<String, dynamic>?> getEnhancedDrugAnalysis(String drugName, {String? userAge, String? userGender, bool? isPregnant}) async {
    try {
      print('🔍 [PROSPECTUS DEBUG] Starting enhanced analysis for: $drugName');
      print('🔍 [PROSPECTUS DEBUG] Parameters - Age: $userAge, Gender: $userGender, Pregnant: $isPregnant');
      
      // Step 1: Get official prospectus data using deep search
      print('🔍 [PROSPECTUS DEBUG] Calling findDrugProspectus...');
      final prospectusData = await findDrugProspectus(drugName);
      print('🔍 [PROSPECTUS DEBUG] findDrugProspectus result: ${prospectusData != null ? 'SUCCESS' : 'NULL'}');
      
      // Step 2: Use AI to analyze and enhance the prospectus data
      final openAIService = OpenAIService();
      
      String prospectusText = '';
      String sourceInfo = '';
      
      if (prospectusData != null) {
        prospectusText = _convertDrugInfoToText(prospectusData);
        sourceInfo = prospectusData.prospectusUrl != null 
            ? 'Kaynak: ${prospectusData.prospectusUrl}'
            : 'Kaynak: Resmi prospektüs veritabanı';
        print('✅ Found official prospectus data');
      } else {
        print('⚠️ No official prospectus found, using AI-only analysis');
        sourceInfo = 'Kaynak: AI analizi (resmi prospektüs bulunamadı)';
      }
      
      // Step 3: Create comprehensive analysis prompt
      print('🔍 Creating analysis prompt...');
      final analysisPrompt = _buildEnhancedAnalysisPrompt(drugName, prospectusText, sourceInfo, userAge, userGender, isPregnant);
      print('✅ Analysis prompt created, length: ${analysisPrompt.length} characters');
      
      // Step 4: Get AI analysis and structuring
      print('🤖 [PROSPECTUS DEBUG] Starting structured drug analysis...');
      print('🤖 [PROSPECTUS DEBUG] Analysis prompt length: ${analysisPrompt.length} characters');
      print('🤖 [PROSPECTUS DEBUG] Analysis prompt preview: ${analysisPrompt.substring(0, 200)}...');
      
      final aiAnalysis = await openAIService.getStructuredDrugAnalysis(analysisPrompt);
      print('📬 [PROSPECTUS DEBUG] Structured analysis completed, result: ${aiAnalysis != null ? 'SUCCESS' : 'FAILED'}');
      print('📬 [PROSPECTUS DEBUG] AI Analysis result type: ${aiAnalysis?.runtimeType}');
      if (aiAnalysis != null) {
        print('📬 [PROSPECTUS DEBUG] AI Analysis keys: ${aiAnalysis.keys.toList()}');
      }
      
      if (aiAnalysis == null) {
        print('❌ AI analysis failed');
        return null;
      }
      
      // Step 5: Add source attribution card to the analysis
      final analysis = Map<String, dynamic>.from(aiAnalysis);
      _addSourceAttributionCard(analysis, sourceInfo, prospectusData?.prospectusUrl);
      
      print('✅ Enhanced analysis completed');
      return analysis;
      
    } catch (e) {
      print('💥 Error in enhanced analysis: $e');
      return null;
    }
  }

  /// Convert DrugInfo to readable text for AI analysis
  static String _convertDrugInfoToText(DrugInfo drugInfo) {
    final buffer = StringBuffer();
    
    buffer.writeln('İlaç Adı: ${drugInfo.name}');
    if (drugInfo.activeIngredient.isNotEmpty) {
      buffer.writeln('Etken Madde: ${drugInfo.activeIngredient}');
    }
    if (drugInfo.usage.isNotEmpty) {
      buffer.writeln('Kullanım Alanı: ${drugInfo.usage}');
    }
    if (drugInfo.dosage.isNotEmpty) {
      buffer.writeln('Doz Bilgisi: ${drugInfo.dosage}');
    }
    if (drugInfo.sideEffects.isNotEmpty) {
      buffer.writeln('Yan Etkiler: ${drugInfo.sideEffects.join(', ')}');
    }
    if (drugInfo.contraindications.isNotEmpty) {
      buffer.writeln('Kontrendikasyonlar: ${drugInfo.contraindications.join(', ')}');
    }
    if (drugInfo.interactions.isNotEmpty) {
      buffer.writeln('İlaç Etkileşimleri: ${drugInfo.interactions.join(', ')}');
    }
    if (drugInfo.pregnancyWarning.isNotEmpty) {
      buffer.writeln('Hamilelik Uyarısı: ${drugInfo.pregnancyWarning}');
    }
    if (drugInfo.storageInfo.isNotEmpty) {
      buffer.writeln('Saklama Koşulları: ${drugInfo.storageInfo}');
    }
    if (drugInfo.overdoseInfo.isNotEmpty) {
      buffer.writeln('Aşırı Doz Bilgisi: ${drugInfo.overdoseInfo}');
    }
    
    return buffer.toString();
  }

  /// Build enhanced analysis prompt for AI
  static String _buildEnhancedAnalysisPrompt(String drugName, String prospectusText, String sourceInfo, String? userAge, String? userGender, bool? isPregnant) {
    final userContext = _buildUserContext(userAge, userGender, isPregnant);
    final personalizedWarnings = _buildPersonalizedWarnings(userAge, userGender, isPregnant);
    
    return '''
İlaç Analizi ve Kişiselleştirilmiş Hasta Danışmanlığı

İlaç: $drugName
$sourceInfo

${prospectusText.isNotEmpty ? 'Resmi Prospektüs Bilgileri:\n$prospectusText\n' : ''}

Hasta Profili:
$userContext

$personalizedWarnings

Lütfen aşağıdaki yapıda hasta profiline özel kapsamlı bir analiz hazırla:

1. GENEL BİLGİLER
- İlaç adı ve etken madde
- Ne için kullanılır  
- Nasıl çalışır
- Bu hasta için uygunluk değerlendirmesi

2. KULLANIM BİLGİLERİ  
- Doktor önerisi önemli
- Bu yaş grubu için özel doz bilgileri
- Kullanım şekli
- Hasta profiline göre kullanım önerileri

3. ÖNEMLİ UYARILAR
- Bu hasta profili için kritik özel uyarılar
- Yaş grupuna özgü riskler
- Cinsiyet bazlı dikkat edilecek durumlar
- Hamilelik/emzirme durumu için özel uyarılar
- Kontrendikasyonlar

4. YAN ETKİLER
- Bu yaş grubunda görülen yaygın yan etkiler
- Cinsiyet bazlı yan etki riskleri
- Hamilelik durumunda dikkat edilecek yan etkiler
- Ciddi yan etkiler ve belirtileri
- Ne zaman acil doktora başvurulmalı

5. İLAÇ ETKİLEŞİMLERİ
- Diğer ilaçlarla etkileşimler
- Besin etkileşimleri
- Bu hasta grubu için özel lifestyle uyarıları
- Alkol, kahve gibi madde etkileşimleri

6. SAKLAMA VE DİĞER BİLGİLER
- Saklama koşulları
- Son kullanma tarihi önemi
- Aşırı doz durumu ve belirtileri
- Hasta profiline göre özel saklama önerileri

NOT: Kişiselleştirilmiş uyarıları ve önerileri hasta profiline göre özelleştir.
Her bölümü kart formatında, açık ve anlaşılır şekilde hazırla.
Tıbbi tavsiye veremeyeceğini ve doktor danışmanlığının önemli olduğunu vurgula.
Özellikle yaş, cinsiyet ve hamilelik durumuna göre spesifik öneriler sun.
''';
  }

  /// Build personalized warnings based on user profile
  static String _buildPersonalizedWarnings(String? userAge, String? userGender, bool? isPregnant) {
    final warnings = <String>[];
    
    // Age-based warnings
    if (userAge != null && userAge.isNotEmpty) {
      final age = int.tryParse(userAge) ?? 0;
      if (age < 18) {
        warnings.add('• YAŞA ÖZEL UYARI: Çocuk hasta - özel dozaj ve güvenlik önlemleri gerekli');
      } else if (age >= 65) {
        warnings.add('• YAŞA ÖZEL UYARI: Yaşlı hasta - organ fonksiyonları ve yan etki riskleri değerlendirilmeli');
      }
    }
    
    // Gender-based warnings
    if (userGender == 'Kadın') {
      warnings.add('• CİNSİYET BAZLI UYARI: Kadın hasta - hormonal etkileşimler ve özel durumlar değerlendirilmeli');
    }
    
    // Pregnancy warnings
    if (isPregnant == true) {
      warnings.add('• KRİTİK UYARI: HAMİLE HASTA - İlaç güvenliği ve teratojen riskler mutlaka değerlendirilmeli');
      warnings.add('• Hamilelik kategorisi kontrol edilmeli');
      warnings.add('• Anne ve bebek sağlığı için özel öneriler sunulmalı');
    }
    
    if (warnings.isEmpty) {
      return 'ÖNEMLİ: Bu hasta için kişiselleştirilmiş değerlendirme yapılacak.';
    }
    
    return 'KİŞİSELLEŞTİRİLMİŞ UYARILAR:\n${warnings.join('\n')}';
  }

  /// Build user context string
  static String _buildUserContext(String? userAge, String? userGender, bool? isPregnant) {
    final context = <String>[];
    
    if (userAge != null && userAge.isNotEmpty) {
      context.add('Yaş: $userAge');
    }
    
    if (userGender != null && userGender.isNotEmpty) {
      context.add('Cinsiyet: $userGender');
    }
    
    if (isPregnant == true) {
      context.add('Durum: Hamile');
    }
    
    return context.isNotEmpty ? context.join(', ') : 'Genel profil';
  }

  /// Add source attribution card to analysis
  static void _addSourceAttributionCard(Map<String, dynamic> analysis, String sourceInfo, String? prospectusUrl) {
    final sourceCard = {
      'title': '📚 Kaynak Bilgisi',
      'content': sourceInfo,
      'type': 'info',
      'priority': 10, // Use int instead of string
      'icon': 'source',
      'color': '#6C757D'
    };
    
    if (prospectusUrl != null) {
      sourceCard['url'] = prospectusUrl;
      sourceCard['action'] = 'Prospektüsü Görüntüle';
    }
    
    // Add source card to the end
    if (analysis['cards'] is List) {
      (analysis['cards'] as List).add(sourceCard);
    }
  }

  /// AI ile genel analiz yapma (etkileşim kontrolü için)
  static Future<String?> analyzeWithAI(String prompt) async {
    try {
      print('🤖 Starting AI analysis with prompt length: ${prompt.length}');
      
      final openAIService = OpenAIService();
      
      // Use the getChatResponse method with a comprehensive system prompt
      final fullPrompt = '''Sen uzman bir eczacısın ama halkın anlayacağı basit bir dille konuşuyorsun. İlaç etkileşimleri konusunda derin bilgin var.

GÖREVIN: Verilen ilaçlar arasında tehlikeli durum olup olmadığını basit dille açıklamak.

NASIL ANALİZ ET:
1. İlaçların beraber kullanımı güvenli mi?
2. Hangi yan etkiler artabilir?
3. Vücutta nasıl etkileşiyorlar?
4. Risk ne kadar büyük?
5. Ne yapması gerekiyor?

CEVAP FORMATI:
- Risk seviyesi söyle (Çok Tehlikeli/Orta Tehlikeli/Az Tehlikeli)
- Neden tehlikeli olduğunu basit kelimelerle açıkla
- Ne yapması gerektiğini söyle
- Doktora gitmesi gerekiyorsa belirt

ÖNEMLİ KURALLAR:
- Tıp jargonu kullanma
- Herkesin anlayacağı basit kelimeler kullan
- "Hepatotoksisite" yerine "karaciğere zarar" de
- "Kardiyovasküler" yerine "kalp ve damar" de
- "Sinerjistik etki" yerine "etkinin artması" de
- Günlük konuşma dilinde açıkla
- Hasta güvenliğini ön planda tut

---

$prompt''';

      final response = await openAIService.getChatResponse(fullPrompt);
      
      if (response != null && response.isNotEmpty) {
        print('✅ AI analysis completed successfully');
        return response;
      } else {
        print('❌ AI analysis returned empty response');
        return null;
      }
      
    } catch (e) {
      print('❌ AI analysis failed: $e');
      return null;
    }
  }
}
