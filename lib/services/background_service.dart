import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

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
  DartPluginRegistrant.ensureInitialized();

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

  for (var product in products) {
    if (product.stock <= product.reorderLevel) {
      debugPrint('⚠️ Low Stock Alert: ${product.name}');
    }
  }
}
