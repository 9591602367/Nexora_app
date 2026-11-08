import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  static Future<void> showSosNotification({
    required String locationText,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'nexora_sos_channel',
      'SOS Alerts',
      channelDescription: 'Emergency SOS notifications from Nexora',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFE11D48),
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '🚨 SOS ALERT ACTIVATED',
      'Emergency alert sent! Location: $locationText',
      details,
    );
  }

  static Future<void> showGeneralNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'nexora_general_channel',
      'General Alerts',
      channelDescription: 'General notifications from Nexora',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _plugin.show(1, title, body, details);
  }
}