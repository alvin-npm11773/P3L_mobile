import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math' as math;
import '../models/delivery.dart';
import '../widgets/delivery_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        print('Notification clicked: ${details.payload}');
      },
    );
  }

  Future<void> showDeliveryCompletedNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'delivery_completed_channel',
      'Pengiriman Selesai',
      channelDescription: 'Notifikasi ketika pengiriman selesai',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Pengiriman selesai',
      color: Color(0xFF6CB41C),
      enableLights: true,
      ledColor: Color(0xFF6CB41C),
      ledOnMs: 1000,
      ledOffMs: 500,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      math.Random().nextInt(1000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void showDeliveryCompletedOverlay(BuildContext context, Delivery delivery) {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => DeliveryNotification(
        delivery: delivery,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );
    
    overlayState.insert(overlayEntry);
  }
}