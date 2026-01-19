// lib/services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    // 只在移动端初始化
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('当前平台不支持通知功能');
      return;
    }

    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    // 只在移动端支持定时通知
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('当前平台不支持定时通知');
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '🌟 记录今天的精彩时刻',
      '投下一个锚点,让回忆不再漂流',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '每日提醒',
          channelDescription: '提醒您记录生活点滴',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> showInactivityReminder(int daysInactive) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    await flutterLocalNotificationsPlugin.show(
      1,
      '💭 好久不见',
      '已经${daysInactive}天没有投锚了,要不要记录一下最近的故事?',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'inactivity_reminder',
          '活跃提醒',
          channelDescription: '长时间未使用的温馨提示',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}