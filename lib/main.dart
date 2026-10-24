import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/app_models.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/restaurant/restaurant_detail_screen.dart';
import 'screens/filter/deals_filter_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const MealMapApp());
}

typedef MyApp = MealMapApp;

class MealMapApp extends StatelessWidget {
  const MealMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MealMap',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F7F5),
            cardColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F7A5B),
              primary: const Color(0xFF0F7A5B),
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121816),
            cardColor: const Color(0xFF1B2421),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F7A5B),
              primary: const Color(0xFF12A66B),
              brightness: Brightness.dark,
            ),
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const MainShell(initialTab: 0),
            '/map': (context) => const MainShell(initialTab: 1),
            '/deals': (context) => const MainShell(initialTab: 2),
            '/favorites': (context) => const MainShell(initialTab: 3),
            '/profile': (context) => const MainShell(initialTab: 4),
            '/restaurant': (context) => const RestaurantDetailScreen(),
            '/filter': (context) => const DealsFilterScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/orders': (context) => const OrdersScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
