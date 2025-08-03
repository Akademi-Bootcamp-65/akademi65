import 'package:flutter/material.dart';
import '../models/drug_info.dart';
import '../services/openai_service.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;

  const SearchResultScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final OpenAIService _openAIService = OpenAIService();
  List<DrugInfo> _searchResults = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _openAIService.searchDrugInformation(
        drugName: widget.query,
      );

      if (results != null && results.isNotEmpty) {
        setState(() {
          _searchResults = results.map((json) => DrugInfo.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'İlaç bulunamadı. Farklı bir isim deneyin.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Arama sırasında bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Arama: ${widget.query}',
          style: const TextStyle(
            color: Color(0xFF2E3192),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E3192)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3192)),
            ),
            SizedBox(height: 16),
            Text(
              'İlaç bilgileri aranıyor...',
              style: TextStyle(
                color: Color(0xFF2E3192),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3192),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final drug = _searchResults[index];
        return _buildDrugCard(drug);
      },
    );
  }

  Widget _buildDrugCard(DrugInfo drug) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    drug.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3192),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3192).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    drug.dosage,
                    style: const TextStyle(
                      color: Color(0xFF2E3192),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            if (drug.activeIngredient.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Etken Madde: ${drug.activeIngredient}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Text(
              'Kullanım: ${drug.usage}',
              style: const TextStyle(fontSize: 14),
            ),
            
            if (drug.dosage.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Doz: ${drug.dosage}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            
            if (drug.contraindications.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Uyarılar:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF44336),
                ),
              ),
              const SizedBox(height: 8),
              ...drug.contraindications.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFFF44336))),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            if (drug.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Yan Etkiler:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: drug.sideEffects.map((sideEffect) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    sideEffect,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                )).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToTracker(drug),
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('Takipçiye Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _checkInteractions(drug),
                    icon: const Icon(Icons.sync_problem),
                    label: const Text('Etkileşim'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E3192),
                      side: const BorderSide(color: Color(0xFF2E3192)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addToTracker(DrugInfo drug) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drug.name} doz takipçisine eklendi'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement add to dose tracker
  }

  void _checkInteractions(DrugInfo drug) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${drug.name} etkileşimleri kontrol ediliyor...'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Implement interaction check
  }
}
