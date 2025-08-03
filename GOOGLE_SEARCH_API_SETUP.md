# Google Custom Search API Setup for PharmaBox

## Why Google Custom Search API?

The app uses Google Custom Search API to find official pharmaceutical prospectus PDFs because:
- Direct Google scraping is blocked by anti-bot measures
- Custom Search API provides reliable, structured results
- Better filtering and targeting of pharmaceutical sources
- Respect for Google's terms of service

## Setup Instructions

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 2. Enable Custom Search API
1. In the Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Custom Search API"
3. Click on it and press "Enable"

### 3. Create API Key
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API key"
3. Copy the API key (keep it secure!)
4. Optionally, restrict the key to only Custom Search API

### 4. Create Custom Search Engine
1. Go to [Google Custom Search Engine](https://cse.google.com/cse/all)
2. Click "Add" to create a new search engine
3. In "Sites to search", enter `*.com` (or leave empty to search entire web)
4. Give it a name like "Pharmaceutical Prospectus Search"
5. Create the search engine
6. In the control panel, note the "Search engine ID"

### 5. Configure Search Engine (Optional but Recommended)
1. In your CSE control panel, go to "Setup"
2. Under "Basics", you can:
   - Enable "Search the entire web"
   - Add specific pharmaceutical sites to prioritize
3. Under "Advanced", you can:
   - Set language preferences
   - Configure result layout

### 6. Update API Configuration

#### Option A: Direct Configuration (Not Recommended for Production)
Update `lib/config/api_config.dart`:
```dart
static const String googleApiKey = 'your_actual_api_key_here';
static const String googleSearchEngineId = 'your_search_engine_id_here';
```

#### Option B: Environment Variables (Recommended)
Add to your environment or IDE run configuration:
```
GOOGLE_API_KEY=your_actual_api_key_here
GOOGLE_SEARCH_ENGINE_ID=your_search_engine_id_here
```

### 7. Test the Setup
Run the app and try analyzing a drug. You should see logs like:
```
🔍 Starting Google Custom Search for: [drug_name]
🔎 Trying Google API query: [query]
✅ Found prospectus via Google Custom Search API
```

## API Limits and Costs

### Free Tier
- 100 search queries per day
- $5 per 1000 additional queries

### Rate Limits
- 10 queries per second per IP
- The app includes delays to respect these limits

## Troubleshooting

### Common Errors

#### "quotaExceeded"
- You've exceeded the daily free limit
- Either wait until the next day or enable billing

#### "keyInvalid"
- Check that your API key is correct
- Ensure the Custom Search API is enabled
- Verify API key restrictions

#### "accessNotConfigured"
- The Custom Search API is not enabled for your project
- Go back to step 2

### Fallback Methods
If Google API fails, the app automatically falls back to:
1. Direct pharmaceutical company website searches
2. Simple drug database searches
3. AI-only analysis

## Security Notes

1. Never commit API keys to version control
2. Use environment variables in production
3. Restrict API keys to specific APIs and referrers
4. Monitor usage in Google Cloud Console

## Alternative Approaches

If you prefer not to use Google API, you can:
1. Remove the Google search method
2. Rely on the fallback pharmaceutical site searches
3. Use only AI analysis with OpenAI
4. Implement other search APIs (Bing, DuckDuckGo, etc.)
