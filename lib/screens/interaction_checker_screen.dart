import 'package:flutter/material.dart';
import '../models/drug_interaction.dart';
import '../services/ai_interaction_service.dart';
import '../services/user_service.dart';
import 'drug_validation_error_screen.dart';

class InteractionCheckerScreen extends StatefulWidget {
  const InteractionCheckerScreen({super.key});

  @override
  State<InteractionCheckerScreen> createState() => _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState extends State<InteractionCheckerScreen> 
    with TickerProviderStateMixin {
  final List<DrugInfo> _selectedDrugs = [];
  final TextEditingController _drugController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isChecking = false;
  InteractionResult? _interactionResult;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _drugController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _drugController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _drugController.text;
    if (query.isNotEmpty) {
      setState(() {
        _suggestions = AIInteractionService.getSuggestions(query);
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: _buildModernAppBar(),
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeaderSection(),
                Expanded(
                  child: _interactionResult == null 
                    ? _buildInputSection() 
                    : _buildResultsSection(),
                ),
              ],
            ),
          ),
          if (_showSuggestions) _buildSuggestionOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI İlaç Etkileşim Analizi',
              style: TextStyle(
                color: Color(0xFF4A90A4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF8FAFB),
            Color(0xFFE8F5E8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90A4).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yapay Zeka Destekli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'İlaç Etkileşim Kontrol Sistemi',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'AI v2.0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'İlaçlarınızı ekleyin ve güvenlik açısından detaylı AI analizi alın',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDrugInputCard(),
          if (_selectedDrugs.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSelectedDrugsCard(),
          ],
          const SizedBox(height: 20),
          _buildQuickAddSection(),
        ],
      ),
    );
  }

  Widget _buildDrugInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'İlaç Ekle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _drugController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'İlaç adını yazın... (örn: Aspirin, Paracetamol)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90A4), width: 2),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4A90A4)),
              suffixIcon: _drugController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _drugController.clear();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onSubmitted: (_) => _addDrug(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _drugController.text.isNotEmpty ? _addDrug : null,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'İlacı Ekle',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90A4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionOverlay() {
    return Positioned(
      top: 280, // AppBar + Header + Input field yaklaşık konumu
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.medication, color: Color(0xFF4A90A4), size: 20),
                title: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 14),
                ),
                onTap: () {
                  _drugController.text = suggestion;
                  setState(() {
                    _showSuggestions = false;
                  });
                  _addDrug();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDrugsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Seçilen İlaçlar (${_selectedDrugs.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_selectedDrugs.map((drug) => _buildDrugChip(drug)).toList()),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedDrugs.length >= 2 ? _checkInteractions : null,
              icon: _isChecking 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.psychology, color: Colors.white),
              label: Text(
                _isChecking ? 'AI Analiz Ediyor...' : 'AI ile Etkileşim Analizi Yap',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedDrugs.length >= 2 
                  ? const Color(0xFF7CB342) 
                  : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _selectedDrugs.length >= 2 ? 4 : 0,
              ),
            ),
          ),
          if (_selectedDrugs.length < 2)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'En az 2 ilaç seçmelisiniz',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrugChip(DrugInfo drug) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90A4).withOpacity(0.1),
            const Color(0xFF7CB342).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.medication, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drug.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                if (drug.category != null)
                  Text(
                    drug.category!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRiskColor(drug.riskLevel).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Risk ${drug.riskLevel}/5',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getRiskColor(drug.riskLevel),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeDrug(drug),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection() {
    final commonDrugs = [
      'Aspirin', 'Paracetamol', 'İbuprofen', 'Warfarin', 'Metformin'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hızlı Ekle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sık kullanılan ilaçlar:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonDrugs.map((drug) {
              final isSelected = _selectedDrugs.any((d) => d.name == drug);
              return GestureDetector(
                onTap: isSelected ? null : () => _addQuickDrug(drug),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                      ? const LinearGradient(
                          colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                        )
                      : null,
                    color: isSelected ? null : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.transparent 
                        : const Color(0xFF4A90A4).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check : Icons.add,
                        size: 16,
                        color: isSelected ? Colors.white : const Color(0xFF4A90A4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        drug,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF4A90A4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResultHeader(),
            const SizedBox(height: 16),
            _buildRiskOverview(),
            const SizedBox(height: 16),
            if (_interactionResult!.interactions.isNotEmpty) ...[
              _buildInteractionsSection(),
              const SizedBox(height: 16),
            ],
            _buildDetailedAnalysis(),
            const SizedBox(height: 16),
            _buildRecommendations(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _interactionResult!.riskColor.withOpacity(0.1),
            _interactionResult!.riskColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _interactionResult!.riskColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _interactionResult!.riskColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _interactionResult!.riskIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Analiz Tamamlandı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _interactionResult!.riskColor,
                      ),
                    ),
                    Text(
                      'Risk Seviyesi: ${_interactionResult!.riskLevel}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _interactionResult!.riskColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_interactionResult!.overallRisk}/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _interactionResult!.summary,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF4A90A4)),
              SizedBox(width: 8),
              Text(
                'Risk Analizi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRiskMeter('Genel Risk', _interactionResult!.overallRisk),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Etkileşim', '${_interactionResult!.interactions.length}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('İlaç Sayısı', '${_interactionResult!.drugs.length}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Analiz Süresi', '2.1s'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMeter(String title, int risk) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: risk / 5,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_getRiskColor(risk)),
              ),
            ),
            Text(
              '$risk/5',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getRiskColor(risk),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text(
                'Tespit Edilen Etkileşimler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_interactionResult!.interactions.map((interaction) => _buildInteractionCard(interaction)).toList()),
        ],
      ),
    );
  }

  Widget _buildInteractionCard(InteractionPair interaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            interaction.severityColor.withOpacity(0.1),
            interaction.severityColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: interaction.severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: interaction.severityColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${interaction.drug1.name} ↔ ${interaction.drug2.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: interaction.severityColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interaction.severityText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            interaction.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: interaction.severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öneri: ${interaction.recommendation}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: interaction.severityColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90A4), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detaylı AI Analizi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _interactionResult!.detailedAnalysis,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3436),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFFFFB74D)),
              SizedBox(width: 8),
              Text(
                'AI Önerileri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_interactionResult!.recommendations.map((recommendation) => _buildRecommendationItem(recommendation)).toList()),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E8), Color(0xFFF0F8FF)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF4A90A4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3436),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _interactionResult = null;
                _selectedDrugs.clear();
                _drugController.clear();
              });
              _animationController.reset();
            },
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90A4)),
            label: const Text(
              'Yeni Analiz',
              style: TextStyle(color: Color(0xFF4A90A4)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF4A90A4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Paylaş veya kaydet fonksiyonu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analiz sonuçları kaydedildi'),
                  backgroundColor: Color(0xFF4A90A4),
                ),
              );
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7CB342),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _addDrug() {
    final drugName = _drugController.text.trim();
    if (drugName.isEmpty) return;

    final drugInfo = AIInteractionService.findDrug(drugName);
    if (drugInfo != null) {
      if (!_selectedDrugs.any((d) => d.name == drugInfo.name)) {
        setState(() {
          _selectedDrugs.add(drugInfo);
          _drugController.clear();
          _showSuggestions = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu ilaç zaten eklenmiş')),
        );
      }
    } else {
      // Bilinmeyen ilaç için genel bir entry oluştur
      final newDrug = DrugInfo(
        name: drugName,
        category: 'Bilinmeyen Kategori',
        riskLevel: 2,
      );
      setState(() {
        _selectedDrugs.add(newDrug);
        _drugController.clear();
        _showSuggestions = false;
      });
    }
  }

  void _addQuickDrug(String drugName) {
    final drugInfo = AIInteractionService.findDrug(drugName);
    if (drugInfo != null && !_selectedDrugs.any((d) => d.name == drugInfo.name)) {
      setState(() {
        _selectedDrugs.add(drugInfo);
      });
    }
  }

  void _removeDrug(DrugInfo drug) {
    setState(() {
      _selectedDrugs.remove(drug);
    });
  }

  Future<void> _checkInteractions() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final userProfile = UserService.currentUser;
      final result = await AIInteractionService.analyzeInteractions(_selectedDrugs, userProfile: userProfile);
      setState(() {
        _interactionResult = result;
        _isChecking = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isChecking = false;
      });
      
      // Check if this is a drug validation error (AI said NO)
      final errorMessage = e.toString();
      if (errorMessage.contains('AI bu öğelerin ilaç olmadığını doğruladı') || 
          errorMessage.contains('gerçek bir ilaç adı değil')) {
        // Navigate to dedicated error screen for invalid drugs
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrugValidationErrorScreen(
              rejectedItems: _selectedDrugs.map((drug) => drug.name).toList(),
              onRetry: () {
                Navigator.pop(context); // Go back to interaction checker
                setState(() {
                  _selectedDrugs.clear(); // Clear invalid drugs
                  _interactionResult = null; // Clear results
                });
              },
            ),
          ),
        );
      } else {
        // Show regular error for other issues
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analiz sırasında hata: $e')),
        );
      }
    }
  }

  Color _getRiskColor(int risk) {
    switch (risk) {
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFFF5722);
      case 5:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
