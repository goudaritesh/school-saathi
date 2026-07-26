import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/driver_provider.dart';
import 'features/dashboard/providers/parent_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/connections/providers/connection_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/leave/providers/leave_provider.dart';
import 'features/complaints/providers/complaint_provider.dart';
import 'features/reports/providers/report_provider.dart';

import 'core/services/firebase_messaging_service.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Initialize our custom messaging service for permissions & foreground messages
    final fcmService = FirebaseMessagingService();
    await fcmService.init();
  } catch (e) {
    print("Firebase Initialization Error: Ensure you have added google-services.json/GoogleService-Info.plist!");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
        ChangeNotifierProvider(create: (_) => ParentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const SchoolVanConnectApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SchoolVanConnectApp extends StatelessWidget {
  const SchoolVanConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Van Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      navigatorKey: navigatorKey,
    );
  }
}
