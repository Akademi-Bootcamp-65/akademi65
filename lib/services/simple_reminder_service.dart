import 'package:hive_flutter/hive_flutter.dart';
import '../models/simple_reminder.dart';

class SimpleReminderService {
  static const String _boxName = 'simple_reminders';
  static Box? _box;

  // Box'ı başlat
  static Future<void> init() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox(_boxName);
        print('✅ Simple reminder database opened');
      }
    } catch (e) {
      print('❌ Simple reminder database error: $e');
      throw Exception('Simple reminder database could not be initialized: $e');
    }
  }

  // Box'ın açık olduğundan emin ol
  static Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  // Tüm hatırlatmaları getir
  static Future<List<SimpleReminder>> getAllReminders() async {
    try {
      final box = await _getBox();
      final List<SimpleReminder> reminders = [];
      
      for (final value in box.values) {
        try {
          final reminder = SimpleReminder.fromMap(Map<String, dynamic>.from(value));
          reminders.add(reminder);
        } catch (e) {
          print('❌ Simple reminder parse error: $e');
        }
      }
      
      return reminders;
    } catch (e) {
      print('❌ Could not get reminders: $e');
      return [];
    }
  }

  // Yeni hatırlatma ekle
  static Future<void> addReminder(SimpleReminder reminder) async {
    try {
      final box = await _getBox();
      await box.put(reminder.id, reminder.toMap());
      print('✅ Reminder added: ${reminder.medicationName}');
    } catch (e) {
      print('❌ Reminder add error: $e');
      throw Exception('Reminder could not be added: $e');
    }
  }

  // Hatırlatma güncelle
  static Future<void> updateReminder(SimpleReminder reminder) async {
    try {
      final box = await _getBox();
      await box.put(reminder.id, reminder.toMap());
      print('✅ Reminder updated: ${reminder.medicationName}');
    } catch (e) {
      print('❌ Reminder update error: $e');
      throw Exception('Reminder could not be updated: $e');
    }
  }

  // Hatırlatma sil
  static Future<void> deleteReminder(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      print('✅ Reminder deleted: $id');
    } catch (e) {
      print('❌ Reminder delete error: $e');
      throw Exception('Reminder could not be deleted: $e');
    }
  }

  // Test verisi ekle
  static Future<void> addTestData() async {
    try {
      final testReminders = [
        SimpleReminder(
          id: 'test1',
          medicationName: 'Aspirin',
          dosage: '1 tablet',
          time: '08:00',
          isActive: true,
          notes: 'Yemekten sonra al',
          createdAt: DateTime.now(),
        ),
        SimpleReminder(
          id: 'test2',
          medicationName: 'Parol',
          dosage: '500mg',
          time: '20:00',
          isActive: true,
          notes: 'Sabah ve akşam',
          createdAt: DateTime.now(),
        ),
      ];

      for (final reminder in testReminders) {
        await addReminder(reminder);
      }
      print('✅ Test data added');
    } catch (e) {
      print('❌ Test data error: $e');
    }
  }

  // Tüm verileri temizle
  static Future<void> clearAllData() async {
    try {
      final box = await _getBox();
      await box.clear();
      print('✅ All data cleared');
    } catch (e) {
      print('❌ Clear data error: $e');
    }
  }
}
