import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/simple_reminder_service.dart';
import '../models/simple_reminder.dart';

class ModernRemindersScreen extends StatefulWidget {
  const ModernRemindersScreen({super.key});

  @override
  State<ModernRemindersScreen> createState() => _ModernRemindersScreenState();
}

class _ModernRemindersScreenState extends State<ModernRemindersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<SimpleReminder> _reminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await SimpleReminderService.getAllReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hatırlatıcılar yüklenirken hata: $e')),
        );
      }
    }
  }

  List<SimpleReminder> _getRemindersForDay(DateTime day) {
    return _reminders.where((reminder) {
      // For simplicity, show all active reminders for any day
      return reminder.isActive;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90A4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'İlaç Hatırlatıcıları',
          style: TextStyle(
            color: Color(0xFF4A90A4),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90A4),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90A4),
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Bugün'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Takvim'),
            Tab(icon: Icon(Icons.medication), text: 'İlaçlarım'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildCalendarView(),
          _buildMedicationsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: const Color(0xFF4A90A4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayView() {
    final todaysReminders = _getRemindersForDay(DateTime.now());
    
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : todaysReminders.isEmpty
            ? _buildEmptyState('Bugün için hatırlatıcı yok')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: todaysReminders.length,
                itemBuilder: (context, index) {
                  final reminder = todaysReminders[index];
                  return _buildReminderCard(reminder, showDate: false);
                },
              );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TableCalendar<SimpleReminder>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getRemindersForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Color(0xFF4A90A4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4A90A4),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF7CC9E5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF4A90A4),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF4A90A4)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF4A90A4)),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
        ),
        Expanded(
          child: _buildSelectedDayReminders(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayReminders() {
    final dayReminders = _getRemindersForDay(_selectedDay);
    
    return dayReminders.isEmpty
        ? _buildEmptyState('Bu günde hatırlatıcı yok')
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dayReminders.length,
            itemBuilder: (context, index) {
              final reminder = dayReminders[index];
              return _buildReminderCard(reminder, showDate: true);
            },
          );
  }

  Widget _buildMedicationsView() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _reminders.isEmpty
            ? _buildEmptyState('Henüz ilaç eklenmemiş')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return _buildMedicationCard(reminder);
                },
              );
  }

  Widget _buildReminderCard(SimpleReminder reminder, {required bool showDate}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A90A4),
            Color(0xFF7CC9E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90A4).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.medicationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showDate)
                Text(
                  reminder.time,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Doz: ${reminder.dosage}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              reminder.time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(SimpleReminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    colors: [
                      Color(0xFF4A90A4),
                      Color(0xFF7CC9E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medication, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicationName,
                      style: const TextStyle(
                        color: Color(0xFF4A90A4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Doz: ${reminder.dosage}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isActive,
                onChanged: (value) {
                  _toggleReminder(reminder);
                },
                activeColor: const Color(0xFF4A90A4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Hatırlatma Saati:',
            style: TextStyle(
              color: Color(0xFF4A90A4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A90A4).withOpacity(0.1),
                  const Color(0xFF7CC9E5).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
            ),
            child: Text(
              reminder.time,
              style: const TextStyle(
                color: Color(0xFF4A90A4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (reminder.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90A4).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reminder.notes,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddReminderDialog,
            icon: const Icon(Icons.add),
            label: const Text('Hatırlatıcı Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: AddReminderForm(
              onSave: (reminder) {
                _saveReminder(reminder);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveReminder(SimpleReminder reminder) async {
    try {
      await SimpleReminderService.addReminder(reminder);
      await _loadReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatırlatıcı başarıyla eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _toggleReminder(SimpleReminder reminder) async {
    try {
      final updatedReminder = SimpleReminder(
        id: reminder.id,
        medicationName: reminder.medicationName,
        dosage: reminder.dosage,
        time: reminder.time,
        isActive: !reminder.isActive,
        notes: reminder.notes,
        createdAt: reminder.createdAt,
      );
      await SimpleReminderService.updateReminder(updatedReminder);
      await _loadReminders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}

class AddReminderForm extends StatefulWidget {
  final Function(SimpleReminder) onSave;

  const AddReminderForm({super.key, required this.onSave});

  @override
  State<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends State<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
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
              'Yeni Hatırlatıcı',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(height: 24),
            
            // Medication name
            TextFormField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: 'İlaç Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                ),
                prefixIcon: const Icon(Icons.medication, color: Color(0xFF4A90A4)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
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
                labelText: 'Doz (örn: 1 tablet, 5ml)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                ),
                prefixIcon: const Icon(Icons.schedule, color: Color(0xFF4A90A4)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Doz bilgisi gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Time picker
            const Text(
              'Hatırlatma Saati',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90A4),
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4A90A4).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time, color: Color(0xFF4A90A4)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notlar (İsteğe bağlı)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90A4)),
                ),
                prefixIcon: const Icon(Icons.note, color: Color(0xFF4A90A4)),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              width: double.infinity,
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
                child: const Text(
                  'Hatırlatıcıyı Kaydet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final reminder = SimpleReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medicationName: _medicationController.text,
        dosage: _dosageController.text,
        time: _selectedTime.format(context),
        isActive: true,
        notes: _notesController.text,
        createdAt: DateTime.now(),
      );
      
      widget.onSave(reminder);
    }
  }
}
