import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'watering_reminders';
  static const String _channelName = 'Watering Reminders';
  static const String _channelDescription =
      'Reminders to water farm crops';

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
    );

    await _createAndroidChannel();
  }

  // ============================================================
  // ANDROID CHANNEL
  // ============================================================

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  // ============================================================
  // REQUEST PERMISSION
  // ============================================================

  static Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final androidGranted =
        await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? false;
  }

  // ============================================================
  // TEST NOTIFICATION
  // ============================================================

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 999999,
      title: '💧 Watering Reminder',
      body: 'This is a test watering notification.',
      notificationDetails: details,
    );
  }

  // ============================================================
  // SCHEDULE NOTIFICATION
  // ============================================================

  static Future<void> scheduleWateringReminder({
  required int notificationId,
  required String cropName,
  required String fieldName,
  required DateTime scheduledTime,
}) async {
  final scheduledDate = tz.TZDateTime.from(
    scheduledTime,
    tz.local,
  );

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.high,
    priority: Priority.high,
  );

  const iosDetails = DarwinNotificationDetails();

  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _plugin.zonedSchedule(
    id: notificationId,
    title: 'Time to water',
    body: '$cropName — $fieldName',
    scheduledDate: scheduledDate,
    notificationDetails: details,
    androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,
  );
}

  // ============================================================
  // CANCEL ONE REMINDER
  // ============================================================

  static Future<void> cancelReminder(
    int notificationId,
  ) async {
    await _plugin.cancel(id: notificationId);
  }

  // ============================================================
  // CANCEL ALL REMINDERS
  // ============================================================

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  // ============================================================
  // GET PENDING NOTIFICATIONS
  // ============================================================

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }
}