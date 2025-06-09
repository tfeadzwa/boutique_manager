import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'stock_channel',
        'Stock Alerts',
        channelDescription: 'Notifications for stock alerts',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'stock_alert',
  );
}

Future<void> sendEmailNotification({
  required String subject,
  required String body,
  required String toEmail,
  required String fromEmail,
  required String appPassword,
}) async {
  final smtpServer = gmail(fromEmail, appPassword);
  final message =
      mailer.Message()
        ..from = mailer.Address(fromEmail, 'Boutique Manager')
        ..recipients.add(toEmail)
        ..subject = subject
        ..text = body;
  try {
    final sendReport = await mailer.send(message, smtpServer);
    debugPrint('Email sent: ' + sendReport.toString());
  } catch (e) {
    debugPrint('Email not sent: $e');
  }
}
