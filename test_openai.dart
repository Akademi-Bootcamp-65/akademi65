// Test OpenAI API directly
import 'package:dio/dio.dart';

void main() async {
  print('🔍 Testing OpenAI API directly...');
  
  const apiKey = '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';
  
  final dio = Dio();
  
  try {
    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user', 
            'content': 'Aspirin nedir? Kısa bir açıklama yap.'
          }
        ],
        'temperature': 0.1,
        'max_tokens': 100,
      },
    );
    
    if (response.statusCode == 200) {
      print('✅ OpenAI API is working!');
      final content = response.data['choices'][0]['message']['content'];
      print('📝 Response: $content');
    } else {
      print('❌ OpenAI API error: ${response.statusCode}');
      print('Response: ${response.data}');
    }
    
  } catch (e) {
    print('💥 Error: $e');
    if (e is DioException) {
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
    }
  }
}
