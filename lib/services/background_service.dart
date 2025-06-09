import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'notification_service.dart';

// Configure these with your admin email and app password
const String adminEmail = 'tfadzwa02@gmail.com';
const String appPassword = 'cozkdjbbtkzxyyem';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'boutique_manager_channel',
      initialNotificationTitle: 'Boutique Manager Service',
      initialNotificationContent: 'Monitoring stock levels...',
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.invoke('setAsForeground');
  service.invoke('setAutoStartOnBoot', {'enabled': true});

  service.on('checkStock').listen((event) async {
    await checkStockAndNotify();
  });

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    await checkStockAndNotify();
  });
}

Future<void> checkStockAndNotify() async {
  final db = DatabaseHelper.instance;
  final products = await db.getAllProducts();
  final now = DateTime.now();

  for (var product in products) {
    // Low stock notification
    if (product.stockQty <= product.restockThreshold) {
      final title = 'Low Stock Alert';
      final body = '${product.name} is low in stock (${product.stockQty} left)';
      await showLocalNotification(title, body);
      await sendEmailNotification(
        subject: title,
        body: body,
        toEmail: adminEmail,
        fromEmail: adminEmail,
        appPassword: appPassword,
      );
    }
    // Stock out notification
    if (product.stockQty == 0) {
      final title = 'Stock Out';
      final body = '${product.name} is out of stock!';
      await showLocalNotification(title, body);
      await sendEmailNotification(
        subject: title,
        body: body,
        toEmail: adminEmail,
        fromEmail: adminEmail,
        appPassword: appPassword,
      );
    }
    // Non-moving goods notification (not sold in 30+ days)
    final lastSoldAt = product.lastSoldAt;
    if (lastSoldAt != null && now.difference(lastSoldAt).inDays > 30) {
      final title = 'Non-moving Product';
      final body = '${product.name} has not sold in over 30 days';
      await showLocalNotification(title, body);
      await sendEmailNotification(
        subject: title,
        body: body,
        toEmail: adminEmail,
        fromEmail: adminEmail,
        appPassword: appPassword,
      );
    }
  }
}
