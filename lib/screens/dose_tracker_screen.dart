import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/dose_reminder.dart';
import '../services/notification_service.dart';

class DoseTrackerScreen extends StatefulWidget {
  const DoseTrackerScreen({super.key});

  @override
  State<DoseTrackerScreen> createState() => _DoseTrackerScreenState();
}

class _DoseTrackerScreenState extends State<DoseTrackerScreen> {
  List<DoseReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final reminderBox = Hive.box<DoseReminder>('doseReminders');
      setState(() {
        _reminders = reminderBox.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reminders: $e');
      setState(() {
        _isLoading = false;
      });
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
          'İlaç Takvimi',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4A90A4)),
            onPressed: _showAddReminderDialog,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90A4)),
        ),
      );
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A90A4).withOpacity(0.1),
                    const Color(0xFF7CB342).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.medication,
                size: 60,
                color: Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz ilaç hatırlatmanız yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'İlaç alım saatlerinizi takip etmek için\nyeni bir hatırlatma ekleyin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF636E72),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddReminderDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'İlk Hatırlatmayı Ekle',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90A4),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(DoseReminder reminder) {
    final now = DateTime.now();
    final isToday = reminder.scheduledTime.day == now.day &&
        reminder.scheduledTime.month == now.month &&
        reminder.scheduledTime.year == now.year;
    final isOverdue = reminder.scheduledTime.isBefore(now) && !reminder.isTaken;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isOverdue
                ? Colors.red.withOpacity(0.3)
                : reminder.isTaken
                    ? const Color(0xFF7CB342).withOpacity(0.3)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4A90A4).withOpacity(0.1),
                          const Color(0xFF7CB342).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: Color(0xFF4A90A4),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.drugName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.dosage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF636E72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (reminder.isTaken)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CB342).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Alındı',
                        style: TextStyle(
                          color: Color(0xFF7CB342),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                  if (isOverdue && !reminder.isTaken)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Gecikti',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Time and frequency info
              Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF4A90A4), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${reminder.scheduledTime.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.repeat, color: Color(0xFF4A90A4), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    reminder.frequencyDisplayText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
              
              if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, color: Color(0xFF4A90A4), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reminder.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF636E72),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  if (!reminder.isTaken && isToday)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsTaken(reminder),
                        icon: const Icon(Icons.check, color: Colors.white, size: 18),
                        label: const Text(
                          'Alındı',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CB342),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    
                  if (!reminder.isTaken && isToday && _reminders.length > 1)
                    const SizedBox(width: 12),
                    
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editReminder(reminder),
                      icon: const Icon(Icons.edit, color: Color(0xFF4A90A4), size: 18),
                      label: const Text(
                        'Düzenle',
                        style: TextStyle(color: Color(0xFF4A90A4), fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF4A90A4)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  IconButton(
                    onPressed: () => _deleteReminder(reminder),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddReminderDialog(),
    ).then((reminder) {
      if (reminder != null) {
        _addReminder(reminder);
      }
    });
  }

  Future<void> _addReminder(DoseReminder reminder) async {
    try {
      final reminderBox = Hive.box<DoseReminder>('doseReminders');
      await reminderBox.add(reminder);
      
      // Schedule notification
      await NotificationService.scheduleDoseReminder(reminder);
      
      await _loadReminders();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatma eklendi'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatma eklenirken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsTaken(DoseReminder reminder) async {
    try {
      reminder.isTaken = true;
      reminder.takenAt = DateTime.now();
      await reminder.save();
      
      setState(() {
        // Update UI
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminder.drugName} alındı olarak işaretlendi'),
          backgroundColor: const Color(0xFF7CB342),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşaretleme sırasında bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editReminder(DoseReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    ).then((updatedReminder) {
      if (updatedReminder != null) {
        _loadReminders();
      }
    });
  }

  Future<void> _deleteReminder(DoseReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hatırlatmayı Sil'),
        content: Text('${reminder.drugName} hatırlatmasını silmek istediğinizden emin misiniz?'),
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
        await reminder.delete();
        await _loadReminders();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hatırlatma silindi'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silme sırasında bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Enhanced Add Reminder Dialog with Smart Frequency Input
class AddReminderDialog extends StatefulWidget {
  final DoseReminder? reminder;

  const AddReminderDialog({super.key, this.reminder});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _drugNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyCountController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFrequencyUnit = 'day';
  int _durationDays = 7;
  List<TimeOfDay> _reminderTimes = [TimeOfDay.now()];

  final List<String> _frequencyUnits = ['day', 'week', 'month'];
  final Map<String, String> _frequencyLabels = {
    'day': 'gün',
    'week': 'hafta',
    'month': 'ay',
  };

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _drugNameController.text = widget.reminder!.drugName;
      _dosageController.text = widget.reminder!.dosage;
      _frequencyCountController.text = widget.reminder!.frequencyCount.toString();
      _selectedFrequencyUnit = widget.reminder!.frequencyUnit;
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.scheduledTime);
      _durationDays = widget.reminder!.durationDays;
      _notesController.text = widget.reminder!.notes ?? '';
      
      // Convert reminder times from DateTime to TimeOfDay
      _reminderTimes = widget.reminder!.reminderTimes
          .map((dateTime) => TimeOfDay.fromDateTime(dateTime))
          .toList();
    }
    _updateReminderTimes();
  }

  void _updateReminderTimes() {
    final count = int.tryParse(_frequencyCountController.text) ?? 1;
    setState(() {
      if (count > _reminderTimes.length) {
        // Add more times
        while (_reminderTimes.length < count) {
          _reminderTimes.add(TimeOfDay.now());
        }
      } else if (count < _reminderTimes.length) {
        // Remove excess times
        _reminderTimes = _reminderTimes.take(count).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.reminder == null ? 'Yeni Hatırlatma' : 'Hatırlatmayı Düzenle',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Drug Name
                    TextFormField(
                      controller: _drugNameController,
                      decoration: InputDecoration(
                        labelText: 'İlaç Adı',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.medication, color: Color(0xFF4A90A4)),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'İlaç adı gerekli';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Dosage
                    TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: 'Doz (ör: 1 tablet, 5ml)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_pharmacy, color: Color(0xFF4A90A4)),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) {
                          return 'Doz bilgisi gerekli';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Smart Frequency Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sıklık',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A90A4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _frequencyCountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Sayı',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (_) => _updateReminderTimes(),
                                  validator: (value) {
                                    final count = int.tryParse(value ?? '');
                                    if (count == null || count < 1) {
                                      return 'Geçerli sayı';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedFrequencyUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Birim',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  items: _frequencyUnits.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(_frequencyLabels[unit]!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedFrequencyUnit = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            'Örnek: "${_frequencyCountController.text} ${_frequencyLabels[_selectedFrequencyUnit]} başına ${_frequencyCountController.text} kez"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF636E72),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Reminder Times
                    if (_selectedFrequencyUnit == 'day' && _reminderTimes.isNotEmpty) ...[
                      const Text(
                        'Hatırlatma Saatleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A90A4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      ..._reminderTimes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final time = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFE9ECEF)),
                            ),
                            leading: const Icon(Icons.access_time, color: Color(0xFF4A90A4)),
                            title: Text('${index + 1}. Hatırlatma'),
                            subtitle: Text(time.format(context)),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _selectTime(index),
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Duration
                    TextFormField(
                      initialValue: _durationDays.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Süre (gün)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFF4A90A4)),
                      ),
                      onChanged: (value) {
                        _durationDays = int.tryParse(value) ?? 7;
                      },
                      validator: (value) {
                        final days = int.tryParse(value ?? '');
                        if (days == null || days < 1) {
                          return 'Geçerli gün sayısı';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notlar (isteğe bağlı)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.note_alt, color: Color(0xFF4A90A4)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
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
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90A4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.reminder == null ? 'Ekle' : 'Güncelle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );
    
    if (picked != null) {
      setState(() {
        _reminderTimes[index] = picked;
      });
    }
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(Duration(days: _durationDays));
    final frequencyCount = int.parse(_frequencyCountController.text);

    // Convert TimeOfDay to DateTime for the first reminder time
    final selectedDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      _reminderTimes.isNotEmpty ? _reminderTimes.first.hour : _selectedTime.hour,
      _reminderTimes.isNotEmpty ? _reminderTimes.first.minute : _selectedTime.minute,
    );

    // Convert all reminder times to DateTime
    final reminderDateTimes = _reminderTimes.map((timeOfDay) {
      return DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    }).toList();

    final reminder = DoseReminder(
      drugName: _drugNameController.text,
      dosage: _dosageController.text,
      scheduledTime: selectedDateTime,
      frequencyCount: frequencyCount,
      frequencyUnit: _selectedFrequencyUnit,
      reminderTimes: reminderDateTimes,
      durationDays: _durationDays,
      startDate: startDate,
      endDate: endDate,
      notificationId: widget.reminder?.notificationId ?? DateTime.now().millisecondsSinceEpoch,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    Navigator.pop(context, reminder);
  }

  @override
  void dispose() {
    _drugNameController.dispose();
    _dosageController.dispose();
    _frequencyCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
