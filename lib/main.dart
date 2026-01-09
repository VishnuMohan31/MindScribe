// Main entry point for MindScribe app
// Wires up theme, providers, onboarding, and notifications

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/entry_provider.dart';
import 'providers/category_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/onboarding_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification system before running the app
  await NotificationService.instance.initialize();

  runApp(const MindScribeApp());
}

class MindScribeApp extends StatelessWidget {
  const MindScribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MindScribe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const _RootScreen(),
          );
        },
      ),
    );
  }
}

/// Decides whether to show onboarding or the main home screen
class _RootScreen extends StatefulWidget {
  const _RootScreen();

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  bool _loading = true;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final completed = await OnboardingService.isOnboardingCompleted();
    setState(() {
      _showWelcome = !completed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _showWelcome ? const WelcomeScreen() : const HomeScreen();
  }
}



