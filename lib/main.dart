import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/reading_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/mock_api_service.dart';
import 'theme/colors.dart';

void main() {
  final mockApi = MockApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService: mockApi)),
        ChangeNotifierProvider(create: (_) => ReadingProvider(apiService: mockApi)..startPolling()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const SmartWarehouseApp(),
    ),
  );
}

class SmartWarehouseApp extends StatelessWidget {
  const SmartWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Smart Warehouse',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.accent,
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: AppColors.text),
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
