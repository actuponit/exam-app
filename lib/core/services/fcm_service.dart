import 'dart:convert';

import 'package:exam_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/notifications/presentation/bloc/notification_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late String fcmToken;

  Future<void> initialize() async {
    // Request notification permissions (iOS-specific)
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Setup iOS foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification if the app is opened from a terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Get the FCM token for the device
    String? token = await FirebaseMessaging.instance.getToken();
    fcmToken = token ?? '';

    // Subscribe to the 'all' topic
    if (token != null) {
      debugPrint("FCM Token: $token");
      await _firebaseMessaging.subscribeToTopic("all");
    }
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _initializeLocalNotifications() async {
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

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
      try {
        // Navigate to notifications page on click
        AppRouter.navigatorKey.currentContext?.push(RoutePaths.notifications);
      } catch (e) {
        // Handle error
      }
    });

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'exam_app_notification_channel',
      'Exam App Notification',
      description: 'Exam App Important Notification',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleMessage(RemoteMessage message) {
    _showNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppRouter.navigatorKey.currentContext?.push(RoutePaths.notifications);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'exam_app_notification_channel',
      'Ethio Exam App Notification',
      channelDescription: 'Ethio Exam App Important Notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      // Refresh notifications list
      context.read<NotificationBloc>().add(GetNotificationsEvent());
    }

    // Generate unique notification ID
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Extract title and body from data if notification payload is missing (common in data messages)
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    if (title == null && message.data.isNotEmpty) {
      title = message.data['title'];
    }
    if (body == null && message.data.isNotEmpty) {
      body = message.data['body'];
    }

    if (title != null || body != null) {
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  String get getToken => fcmToken;
}
