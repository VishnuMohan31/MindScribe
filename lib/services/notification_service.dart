// Notification Service - Handles all local notification logic
//
// Uses:
// - flutter_local_notifications for displaying notifications
// - timezone for correct scheduled times
//
// This service is intentionally focused on reliability and clarity rather than
// aggressive background tricks, to keep Play Store review happy while still
// giving users dependable reminders.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/entry_model.dart';
import '../models/reminder_model.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification plugin and timezone data
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone setup (required for zonedSchedule)
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // You can handle navigation based on payload here in future
        debugPrint('Notification tapped with payload: ${details.payload}');
      },
    );

    _initialized = true;
  }

  // ==================== BASIC OPERATIONS ====================

  /// Show an immediate notification (used for quick tests)
  Future<void> testNotification() async {
    await showInstantNotification(
      id: 999997,
      title: 'MindScribe Test',
      body: 'This is a test notification from MindScribe.',
      payload: 'test_instant',
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = _buildAndroidDetails();

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: details),
      payload: payload,
    );
  }

  /// Generic scheduled notification helper
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final details = _buildAndroidDetails();

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  // ==================== ENTRY / REMINDER INTEGRATION ====================

  /// Schedule a notification for an entry + reminder pair
  ///
  /// - Uses reminder.id as notification ID (auto-increment from DB)
  /// - Falls back to a derived ID if reminder.id is null
  Future<void> scheduleEntryNotification(
    EntryModel entry,
    Reminder reminder,
  ) async {
    if (!reminder.isActive) return;

    final now = DateTime.now();
    DateTime scheduled = reminder.reminderTime;

    // If the time is already in the past and it's recurring, move to next
    if (scheduled.isBefore(now)) {
      final next = reminder.getNextOccurrence();
      if (next == null) {
        // One-time reminder already passed
        return;
      }
      scheduled = next;
    }

    final id = reminder.id ?? _deriveNotificationId(reminder);

    final title =
        reminder.ttsTitle ?? (entry.title.isNotEmpty ? entry.title : 'MindScribe');
    final body = reminder.ttsBody ??
        (entry.content.length > 80
            ? '${entry.content.substring(0, 80)}...'
            : entry.content);

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduled,
      payload: entry.id,
    );
  }

  // ==================== DEBUG HELPERS ====================

  /// More verbose test to help validate scheduling behaviour
  Future<void> debugScheduleTest() async {
    final now = DateTime.now();
    final in15Seconds = now.add(const Duration(seconds: 15));

    debugPrint(
        'Debug test notification scheduled for ${in15Seconds.toIso8601String()}');

    await scheduleNotification(
      id: 999999,
      title: '🔬 MindScribe Debug Test',
      body: 'This notification should fire ~15 seconds after you pressed test.',
      scheduledTime: in15Seconds,
      payload: 'debug_test',
    );
  }

  // ==================== INTERNAL HELPERS ====================

  AndroidNotificationDetails _buildAndroidDetails() {
    return const AndroidNotificationDetails(
      'mindscribe_reminders', // channel ID
      'MindScribe Reminders', // channel name
      channelDescription: 'Reminders and notifications for your MindScribe diary',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );
  }

  /// Simple deterministic ID fallback if DB id is not available
  int _deriveNotificationId(Reminder reminder) {
    // Hash entryId + timestamp into a positive int
    final base = reminder.entryId.hashCode ^ reminder.reminderTime.hashCode;
    return base & 0x7fffffff;
  }
}


