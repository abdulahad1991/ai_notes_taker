import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ai_notes_taker/app/app.bottomsheets.dart';
import 'package:ai_notes_taker/app/app.dialogs.dart';
import 'package:ai_notes_taker/app/app.locator.dart';
import 'package:ai_notes_taker/app/app.router.dart';
import 'package:ai_notes_taker/services/sync_service.dart';
import 'package:ai_notes_taker/services/connectivity_service.dart';
import 'package:ai_notes_taker/services/api_service.dart';
import 'package:ai_notes_taker/services/data_service.dart';
import 'package:ai_notes_taker/services/offline_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' hide Priority;
import 'package:stacked_services/stacked_services.dart';
import 'package:alarm/alarm.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'i18n/strings.g.dart';

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
  await Alarm.init();
  
  // Initialize database and sync services
  await _initializeDatabaseServices();

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // Listen to locale changes
    LocaleSettings.getLocaleStream().listen((locale) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Pad',
      initialRoute: Routes.authScreen,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      // Localization support
      locale: LocaleSettings.currentLocale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
  final AndroidNotificationDetails androidDetails =
  AndroidNotificationDetails(
    'android_channel_id',
    'android_channel_name',
    importance: Importance.max,
    // priority: AndroidNotificationPriority.high,
    icon: '@mipmap/ic_launcher',
  );

  final NotificationDetails platformDetails = NotificationDetails(
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

Future<void> _initializeDatabaseServices() async {
  try {
    // Get services from locator
    final syncService = locator<SyncService>();
    final connectivityService = locator<ConnectivityService>();
    final apiService = locator<ApiService>();
    final dataService = locator<DataService>();
    final offlineService = locator<OfflineService>();
    
    // Add a small delay to ensure platform channels are ready
    await Future.delayed(Duration(milliseconds: 100));
    
    // Initialize connectivity monitoring with error handling
    try {
      connectivityService.initialize();
    } catch (e) {
      debugPrint('ConnectivityService initialization failed: $e');
      // Continue without connectivity monitoring
    }
    
    // Initialize offline service
    try {
      offlineService.initialize();
    } catch (e) {
      debugPrint('OfflineService initialization failed: $e');
      // Continue without offline service
    }
    
    // Initialize sync service with API service
    try {
      syncService.initialize(apiService);
    } catch (e) {
      debugPrint('SyncService initialization failed: $e');
      // Continue without sync service
    }
    
    // Initialize data service
    try {
      dataService.initialize(apiService, connectivityService);
    } catch (e) {
      debugPrint('DataService initialization failed: $e');
      // Continue without data service
    }
    
    debugPrint('Database and sync services initialization completed');
  } catch (e) {
    debugPrint('Error initializing database services: $e');
    // Don't throw - let the app continue without these services
  }
}
