import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/nutrition_profile.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelMeals = 'forge_meals';
  static const _channelWater = 'forge_water';
  static const _groupMeals = 'meals';
  static const _groupWater = 'water';

  static const _mealBaseId = 100;
  static const _waterBaseId = 200;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
    debugPrint('[Notifications] initialized');
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleMealReminders(List<MealSlot> meals) async {
    if (!_initialized) await init();
    await _cancelGroup(_groupMeals, _mealBaseId, 10);

    for (var i = 0; i < meals.length; i++) {
      final meal = meals[i];
      final id = _mealBaseId + i;
      final body =
          '${meal.calories.toStringAsFixed(0)} kcal · ${meal.proteinG.toStringAsFixed(0)}g protein';

      await _scheduleDailyAt(
        id: id,
        title: '🍽 Time for ${meal.name}',
        body: body,
        hour: meal.hour,
        minute: meal.minute,
        channelId: _channelMeals,
        channelName: 'Meal Reminders',
        group: _groupMeals,
      );
    }
    debugPrint('[Notifications] scheduled ${meals.length} meal reminders');
  }

  Future<void> cancelMealReminders() async {
    await _cancelGroup(_groupMeals, _mealBaseId, 10);
  }

  Future<void> scheduleWaterReminders(int intervalMinutes) async {
    if (!_initialized) await init();
    await _cancelGroup(_groupWater, _waterBaseId, 20);

    const startHour = 8;
    const endHour = 22;
    int id = _waterBaseId;

    var currentMinute = startHour * 60;
    final endMinute = endHour * 60;

    while (currentMinute <= endMinute) {
      final hour = currentMinute ~/ 60;
      final minute = currentMinute % 60;

      await _scheduleDailyAt(
        id: id++,
        title: '💧 Time to drink water',
        body: 'Stay hydrated — your body will thank you!',
        hour: hour,
        minute: minute,
        channelId: _channelWater,
        channelName: 'Water Reminders',
        group: _groupWater,
      );

      currentMinute += intervalMinutes;
    }
    debugPrint(
        '[Notifications] scheduled water reminders every $intervalMinutes min');
  }

  Future<void> cancelWaterReminders() async {
    await _cancelGroup(_groupWater, _waterBaseId, 20);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[Notifications] all cancelled');
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
    required String group,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          groupKey: group,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelGroup(String group, int baseId, int count) async {
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(baseId + i);
    }
  }
}
