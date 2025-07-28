import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ai_notes_taker/app/app.bottomsheets.dart';
import 'package:ai_notes_taker/app/app.dialogs.dart';
import 'package:ai_notes_taker/app/app.locator.dart';
import 'package:ai_notes_taker/app/app.router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked_services/stacked_services.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Add this if using flutterfire
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupLocator();
  await _initializeLocalNotifications();

  _setupFirebaseMessaging();

  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitSettings =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      debugPrint("Notification clicked: ${response.payload}");
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.authScreen,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
      debugShowCheckedModeBanner: false,
    );
  }
}

void _setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('onMessage: ${message.data}');
    debugPrint('onMessage NOTIFICATION TITLE: ${message.notification?.title}');
    debugPrint('onMessage NOTIFICATION BODY: ${message.notification?.body}');
    // locator<RefreshService>().triggerRefresh(message!.notification!.body!);
    if (message.notification != null) {
      _showLocalNotification(message.notification!);
    }
  });

  // When notification is opened
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('onMessageOpenedApp: ${message.messageId}');
  });

  // Request permissions (for iOS)
  FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

void _showLocalNotification(RemoteNotification notification) async {
  const AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'android_channel_id',
    'android_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    // iOS settings can be added here
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    platformDetails,
    payload: notification.title,
  );
}
