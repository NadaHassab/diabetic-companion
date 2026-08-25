import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/medication.dart';

class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
  }) async {
    if (kIsWeb) return;
    await _plugin.periodicallyShow(
      id,
      'Medication reminder',
      'Time to take $medicationName',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Reminders to take your medication',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  static Future<void> scheduleReminders({
    required List<Medication> medications,
    required List<MedIntake> intakes,
  }) async {
    if (kIsWeb) return;
    await cancelAll();

    int notifId = 0;

    for (final med in medications) {
      final alreadyTaken = intakes.any((i) => i.medicationId == med.id);

      if (!alreadyTaken) {
        await scheduleMedicationReminder(
          id: notifId++,
          medicationName: med.name,
        );
      }
    }
  }
}
