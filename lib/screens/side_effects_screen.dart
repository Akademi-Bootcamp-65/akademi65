import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SideEffect {
  final String id;
  final String drugName;
  final String sideEffect;
  final String severity;
  final DateTime date;
  final String notes;

  SideEffect({
    required this.id,
    required this.drugName,
    required this.sideEffect,
    required this.severity,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugName': drugName,
      'sideEffect': sideEffect,
      'severity': severity,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory SideEffect.fromMap(Map<String, dynamic> map) {
    return SideEffect(
      id: map['id'],
      drugName: map['drugName'],
      sideEffect: map['sideEffect'],
      severity: map['severity'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'] ?? '',
    );
  }
}

class SideEffectsScreen extends StatefulWidget {
  const SideEffectsScreen({super.key});

  @override
  State<SideEffectsScreen> createState() => _SideEffectsScreenState();
}

class _SideEffectsScreenState extends State<SideEffectsScreen> {
  List<SideEffect> sideEffects = [];
  final TextEditingController _drugController = TextEditingController();
  final TextEditingController _sideEffectController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedSeverity = 'Hafif';

  final List<String> severityLevels = ['Hafif', 'Orta', 'Şiddetli'];
  final List<String> commonSideEffects = [
    'Baş ağrısı',
    'Mide bulantısı',
    'Baş dönmesi',
    'Yorgunluk',
    'Diyare',
    'Konstipasyon',
    'Cilt döküntüsü',
    'Uykusuzluk',
    'İştah kaybı',
    'Kuru ağız',
  ];

  @override
  void initState() {
    super.initState();
    _loadSideEffects();
  }

  void _loadSideEffects() async {
    try {
      final box = await Hive.openBox('sideEffects');
      final effectsList = box.get('effects', defaultValue: <Map<String, dynamic>>[]);
      
      setState(() {
        sideEffects = effectsList
            .map<SideEffect>((map) => SideEffect.fromMap(Map<String, dynamic>.from(map)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      });
    } catch (e) {
      // Handle error
    }
  }

  void _saveSideEffects() async {
    try {
      final box = await Hive.openBox('sideEffects');
      await box.put('effects', sideEffects.map((effect) => effect.toMap()).toList());
    } catch (e) {
      // Handle error
    }
  }

  void _addSideEffect() {
    if (_drugController.text.isNotEmpty && _sideEffectController.text.isNotEmpty) {
      final newEffect = SideEffect(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        drugName: _drugController.text,
        sideEffect: _sideEffectController.text,
        severity: _selectedSeverity,
        date: DateTime.now(),
        notes: _notesController.text,
      );

      setState(() {
        sideEffects.insert(0, newEffect);
      });

      _saveSideEffects();

      // Clear form
      _drugController.clear();
      _sideEffectController.clear();
      _notesController.clear();
      _selectedSeverity = 'Hafif';

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yan etki kaydedildi'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );
    }
  }

  void _deleteSideEffect(String id) {
    setState(() {
      sideEffects.removeWhere((effect) => effect.id == id);
    });
    _saveSideEffects();
  }

  void _showAddSideEffectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Yan Etki Ekle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drug name
                    const Text(
                      'İlaç Adı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _drugController,
                      decoration: InputDecoration(
                        hintText: 'İlaç adını girin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Side effect
                    const Text(
                      'Yan Etki',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sideEffectController,
                      decoration: InputDecoration(
                        hintText: 'Yaşadığınız yan etkiyi yazın',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Common side effects
                    const Text(
                      'Yaygın Yan Etkiler',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: commonSideEffects.map((effect) {
                        return GestureDetector(
                          onTap: () {
                            _sideEffectController.text = effect;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90A4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
                            ),
                            child: Text(
                              effect,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A90A4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Severity
                    const Text(
                      'Şiddet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: severityLevels.map((severity) {
                        final isSelected = _selectedSeverity == severity;
                        Color color;
                        switch (severity) {
                          case 'Hafif':
                            color = Colors.green;
                            break;
                          case 'Orta':
                            color = Colors.orange;
                            break;
                          case 'Şiddetli':
                            color = Colors.red;
                            break;
                          default:
                            color = Colors.grey;
                        }
                        
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSeverity = severity;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color),
                              ),
                              child: Text(
                                severity,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : color,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notes
                    const Text(
                      'Notlar (İsteğe bağlı)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ek bilgiler, başlangıç zamanı vb.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFDDD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Color(0xFF636E72)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _addSideEffect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90A4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Hafif':
        return Colors.green;
      case 'Orta':
        return Colors.orange;
      case 'Şiddetli':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yan Etkiler',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yan Etki Takibi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yaşadığınız yan etkileri kaydedin ve doktorunuzla paylaşın',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Side effects list
          Expanded(
            child: sideEffects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz yan etki kaydınız yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yaşadığınız yan etkileri kaydetmeye başlayın',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sideEffects.length,
                    itemBuilder: (context, index) {
                      final effect = sideEffects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(effect.severity).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.warning_amber,
                              color: _getSeverityColor(effect.severity),
                            ),
                          ),
                          title: Text(
                            effect.sideEffect,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                effect.drugName,
                                style: const TextStyle(
                                  color: Color(0xFF4A90A4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getSeverityColor(effect.severity),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      effect.severity,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${effect.date.day}/${effect.date.month}/${effect.date.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (effect.notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  effect.notes,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteSideEffect(effect.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSideEffectDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _drugController.dispose();
    _sideEffectController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
