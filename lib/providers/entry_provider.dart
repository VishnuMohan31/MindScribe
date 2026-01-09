// Entry Provider - Manages state for all entries
// This is the bridge between UI and Database

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/entry_model.dart';
import '../models/reminder_model.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class EntryProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notifications = NotificationService.instance;
  
  // Logger for production-ready logging
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  List<EntryModel> _entries = [];
  List<EntryModel> _filteredEntries = [];
  String _searchQuery = '';
  int? _selectedCategoryId;
  String? _selectedType;
  String? _selectedPriority;
  String? _selectedStatus;

  // Getters
  List<EntryModel> get entries => _filteredEntries;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get selectedType => _selectedType;

  // Initialize - load all entries
  Future<void> initialize() async {
    await loadEntries();
  }

  // Load all entries from database
  Future<void> loadEntries() async {
    _entries = await _db.getAllEntries();
    _applyFilters();
    notifyListeners();
  }

  // Add new entry
  Future<void> addEntry(EntryModel entry, List<Reminder>? reminders) async {
    try {
      await _db.createEntry(entry);
      _logger.i('✅ Entry created: ${entry.title}');
      
      // Schedule notifications for reminders
      if (reminders != null && reminders.isNotEmpty) {
        _logger.i('📅 Scheduling ${reminders.length} reminder(s) for entry: ${entry.title}');
        
        for (var reminder in reminders) {
          // Create reminder in database first
          await _db.createReminder(reminder);
          
          // Schedule notification if reminder is active and in the future
          if (reminder.isActive && reminder.reminderTime.isAfter(DateTime.now())) {
            try {
              await _notifications.scheduleEntryNotification(entry, reminder);
              _logger.d('   ✅ Reminder scheduled for: ${reminder.reminderTime}');
            } catch (e) {
              _logger.e('   ❌ Failed to schedule reminder ${reminder.id}: $e');
            }
          }
        }
        
        _logger.i('✅ Finished scheduling reminders');
      }
      
      await loadEntries();
    } catch (e) {
      _logger.e('❌ Error adding entry: $e');
      rethrow;
    }
  }

  // Update entry
  Future<void> updateEntry(EntryModel entry, List<Reminder>? reminders) async {
    try {
      await _db.updateEntry(entry);
      _logger.i('✅ Entry updated: ${entry.title}');
      
      // Update reminders and reschedule notifications
      if (reminders != null) {
        _logger.i('🔄 Updating reminders for entry: ${entry.title}');
        
        // Get existing reminders to cancel their notifications
        final existingReminders = await _db.getRemindersForEntry(entry.id);
        
        // Cancel existing notifications
        for (var existingReminder in existingReminders) {
          if (existingReminder.id != null) {
            await _notifications.cancelNotification(existingReminder.id!);
          }
        }
        
        // Delete old reminders and create new ones
        await _db.deleteRemindersForEntry(entry.id);
        
        // Create and schedule new reminders
        for (var reminder in reminders) {
          await _db.createReminder(reminder);
          
          // Schedule notification if reminder is active and in the future
          if (reminder.isActive && reminder.reminderTime.isAfter(DateTime.now())) {
            try {
              await _notifications.scheduleEntryNotification(entry, reminder);
              _logger.d('   ✅ Reminder rescheduled for: ${reminder.reminderTime}');
            } catch (e) {
              _logger.e('   ❌ Failed to reschedule reminder ${reminder.id}: $e');
            }
          }
        }
        
        _logger.i('✅ Finished updating reminders');
      }
      
      await loadEntries();
    } catch (e) {
      _logger.e('❌ Error updating entry: $e');
      rethrow;
    }
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    try {
      _logger.i('🗑️ Deleting entry: $id');
      
      // Cancel notifications for reminders before deleting
      final reminders = await _db.getRemindersForEntry(id);
      for (var reminder in reminders) {
        if (reminder.id != null) {
          await _notifications.cancelNotification(reminder.id!);
          _logger.d('   ✅ Cancelled notification for reminder ${reminder.id}');
        }
      }
      
      // Delete the entry and its reminders from database
      await _db.deleteEntry(id);
      _logger.i('✅ Entry deleted successfully');
      
      await loadEntries();
    } catch (e) {
      _logger.e('❌ Error deleting entry: $e');
      rethrow;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(EntryModel entry) async {
    final updated = entry.copyWith(isFavorite: !entry.isFavorite);
    await updateEntry(updated, null);
  }

  // Mark task as complete
  Future<void> markAsComplete(EntryModel entry) async {
    final updated = entry.copyWith(
      status: 'completed',
      progress: 100,
    );
    await updateEntry(updated, null);
  }

  // Search entries
  void searchEntries(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  // Filter by type
  void filterByType(String? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  // Filter by priority
  void filterByPriority(String? priority) {
    _selectedPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedType = null;
    _selectedPriority = null;
    _selectedStatus = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredEntries = _entries.where((entry) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = entry.title.toLowerCase().contains(_searchQuery) ||
            entry.content.toLowerCase().contains(_searchQuery) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategoryId != null && entry.categoryId != _selectedCategoryId) {
        return false;
      }

      // Type filter
      if (_selectedType != null && entry.type != _selectedType) {
        return false;
      }

      // Priority filter
      if (_selectedPriority != null && entry.priority != _selectedPriority) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && entry.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get entries for specific date (for calendar)
  List<EntryModel> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      if (entry.eventDate == null) return false;
      return entry.eventDate!.year == date.year &&
          entry.eventDate!.month == date.month &&
          entry.eventDate!.day == date.day;
    }).toList();
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    return await _db.getStatistics();
  }

  // Get reminders for entry
  Future<List<Reminder>> getRemindersForEntry(String entryId) async {
    return await _db.getRemindersForEntry(entryId);
  }

  // Test notification system
  Future<void> testNotifications() async {
    try {
      await _notifications.testNotification();
    } catch (e) {
      rethrow;
    }
  }

  // Reset notification system (if notifications are broken)
  Future<void> resetNotificationSystem() async {
    try {
      await _notifications.initialize();
    } catch (e) {
      rethrow;
    }
  }

  // Debug: Schedule a test reminder in 10 seconds
  Future<void> scheduleTestReminder() async {
    try {
      _logger.i('Scheduling test notification for 10 seconds from now...');
      
      final testTime = DateTime.now().add(const Duration(seconds: 10));
      
      await _notifications.scheduleNotification(
        id: 999998,
        title: '🧪 10-Second Test',
        body: 'This notification was scheduled 10 seconds ago!',
        scheduledTime: testTime,
        payload: 'test_notification',
      );
      
      _logger.i('Test notification scheduled for: $testTime');
    } catch (e) {
      _logger.e('Failed to schedule test notification: $e');
      rethrow;
    }
  }

  // Debug: Advanced scheduling test
  Future<void> debugAdvancedTest() async {
    try {
      await _notifications.debugScheduleTest();
    } catch (e) {
      _logger.e('Advanced debug test failed: $e');
      rethrow;
    }
  }
}
