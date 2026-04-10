import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Your Theme and Screens
import 'theme/app_theme.dart';
import 'features/shared/screens/loginscreen.dart';
import 'features/shared/services/authWrapper.dart';

// Your Logic/Providers
import 'features/shared/services/cartProvider.dart';
import 'features/shared/services/order_provider.dart'; // NEW
import 'features/shared/services/order_status_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await OrderStatusNotificationService.instance.initialize();
  
  runApp(
    // Wrap the entire app so all screens can access data
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()), // NEW - Load orders on app start
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}