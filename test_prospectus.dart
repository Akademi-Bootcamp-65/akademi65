import 'dart:io';
import 'package:dio/dio.dart';
import 'lib/services/prospectus_service.dart';

void main() async {
  print('🧪 Testing prospectus processing for specific drug...');
  
  try {
    final result = await ProspectusService.getEnhancedDrugAnalysis('Aspirin');
    
    if (result != null) {
      print('✅ Enhanced analysis successful!');
      print('📊 Result type: ${result.runtimeType}');
      print('🔑 Result keys: ${result.keys.toList()}');
      
      if (result.containsKey('cards')) {
        final cards = result['cards'];
        print('📚 Number of cards: ${cards?.length ?? 0}');
      }
    } else {
      print('❌ Enhanced analysis failed - returned null');
    }
    
  } catch (e) {
    print('💥 Test error: $e');
  }
}
