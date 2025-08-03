import 'package:flutter/material.dart';
import '../models/simple_reminder.dart';
import '../services/simple_reminder_service.dart';

class SimpleRemindersScreen extends StatefulWidget {
  const SimpleRemindersScreen({super.key});

  @override
  State<SimpleRemindersScreen> createState() => _SimpleRemindersScreenState();
}

class _SimpleRemindersScreenState extends State<SimpleRemindersScreen> {
  List<SimpleReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await SimpleReminderService.getAllReminders();
      
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hatırlatmalar yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'İlaç Hatırlatmaları',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4A8DB8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A8DB8),
              ),
            )
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Test verisi ekle
          await SimpleReminderService.addTestData();
          _loadReminders();
        },
        backgroundColor: const Color(0xFF4A8DB8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hatırlatma yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk hatırlatmanızı eklemek için + butonuna basın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: reminder.isActive ? const Color(0xFF4A8DB8) : Colors.grey,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.medication,
                color: Colors.white,
              ),
            ),
            title: Text(
              reminder.medicationName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Doz: ${reminder.dosage}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: Switch(
              value: reminder.isActive,
              onChanged: (value) {
                // TODO: Implement toggle
              },
              activeColor: const Color(0xFF4A8DB8),
            ),
          ),
        );
      },
    );
  }
}
