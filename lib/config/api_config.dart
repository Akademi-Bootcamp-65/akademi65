/// API Configuration for external services
class ApiConfig {
  // Google Custom Search API Configuration
  // To get these values:
  // 1. Go to Google Cloud Console (https://console.cloud.google.com/)
  // 2. Create a new project or select existing one
  // 3. Enable "Custom Search API"
  // 4. Create credentials (API Key)
  // 5. Go to https://cse.google.com/cse/all to create a Custom Search Engine
  // 6. Configure it to search the entire web or specific sites
  // 7. Get the Search Engine ID from the CSE control panel
  
  // TEMPORARY: Direct API keys for testing
  static const String googleApiKey = 'AIzaSyA1hmyYbrGAmEvpL3B0I7-GC2jOzS8e4DE';
  static const String googleSearchEngineId = '82584aac17ba2434c';
  
  // Environment variables with fallback to defaults
  static String get googleApiKeyFromEnv => googleApiKey;
  
  static String get googleSearchEngineIdFromEnv => googleSearchEngineId;
  
  // Check if Google API is properly configured
  static bool get isGoogleApiConfigured => 
      googleApiKeyFromEnv.isNotEmpty && 
      googleSearchEngineIdFromEnv.isNotEmpty;
}
