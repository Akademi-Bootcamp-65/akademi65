import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/side_effect_log.dart';

class SideEffectLogScreen extends StatefulWidget {
  const SideEffectLogScreen({super.key});

  @override
  State<SideEffectLogScreen> createState() => _SideEffectLogScreenState();
}

class _SideEffectLogScreenState extends State<SideEffectLogScreen> {
  List<SideEffectLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logsBox = Hive.box<SideEffectLog>('sideEffectLogs');
      setState(() {
        _logs = logsBox.values.toList()
          ..sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Yan Etki Kaydı',
          style: TextStyle(
            color: Color(0xFF2E3192),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E3192)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddLogDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: const Color(0xFFF44336),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3192)),
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.warning,
                size: 50,
                color: Color(0xFFF44336),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz yan etki kaydınız yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Yan etki yaşadığınızda kayıt eklemek için + butonuna dokunun',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddLogDialog,
              icon: const Icon(Icons.add),
              label: const Text('İlk Kaydı Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(SideEffectLog log) {
    final Color severityColor = _getSeverityColor(log.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    log.severity,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(log.reportedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              log.drugName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yan Etki:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.sideEffect,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (log.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notlar:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2E3192),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.notes!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editLog(log),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E3192),
                      side: const BorderSide(color: Color(0xFF2E3192)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _deleteLog(log),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'hafif':
        return Colors.orange;
      case 'orta':
        return Colors.red;
      case 'şiddetli':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAddLogDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddSideEffectDialog(),
    ).then((log) {
      if (log != null) {
        _addLog(log);
      }
    });
  }

  Future<void> _addLog(SideEffectLog log) async {
    try {
      final logsBox = Hive.box<SideEffectLog>('sideEffectLogs');
      await logsBox.add(log);
      await _loadLogs();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yan etki kaydı eklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt eklenirken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editLog(SideEffectLog log) {
    showDialog(
      context: context,
      builder: (context) => AddSideEffectDialog(log: log),
    ).then((updatedLog) {
      if (updatedLog != null) {
        _loadLogs();
      }
    });
  }

  Future<void> _deleteLog(SideEffectLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: Text('${log.drugName} yan etki kaydını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await log.delete();
        await _loadLogs();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt silindi'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silme işleminde bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AddSideEffectDialog extends StatefulWidget {
  final SideEffectLog? log;

  const AddSideEffectDialog({super.key, this.log});

  @override
  State<AddSideEffectDialog> createState() => _AddSideEffectDialogState();
}

class _AddSideEffectDialogState extends State<AddSideEffectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _drugNameController = TextEditingController();
  final _sideEffectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSeverity = 'Hafif';
  DateTime _selectedDate = DateTime.now();

  final List<String> _severityOptions = ['Hafif', 'Orta', 'Şiddetli'];

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _drugNameController.text = widget.log!.drugName;
      _sideEffectController.text = widget.log!.sideEffect;
      _descriptionController.text = widget.log!.notes ?? '';
      _selectedSeverity = widget.log!.severity;
      _selectedDate = widget.log!.reportedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.log == null ? 'Yan Etki Kaydı Ekle' : 'Kaydı Düzenle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _drugNameController,
                decoration: const InputDecoration(
                  labelText: 'İlaç Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'İlaç adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sideEffectController,
                decoration: const InputDecoration(
                  labelText: 'Yan Etki',
                  hintText: 'Ör: Baş ağrısı, Mide bulantısı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Yan etki gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: const InputDecoration(
                  labelText: 'Şiddet',
                  border: OutlineInputBorder(),
                ),
                items: _severityOptions.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Text(severity),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Yan etkinin detayları, ne zaman başladı vs.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveLog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.log == null ? 'Ekle' : 'Güncelle'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveLog() {
    if (_formKey.currentState?.validate() == true) {
      final log = SideEffectLog(
        drugName: _drugNameController.text.trim(),
        sideEffect: _sideEffectController.text.trim(),
        severity: _selectedSeverity,
        reportedAt: _selectedDate,
        notes: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        isKnownSideEffect: false,
        requiresAttention: _selectedSeverity == 'Şiddetli',
      );

      Navigator.pop(context, log);
    }
  }
}
