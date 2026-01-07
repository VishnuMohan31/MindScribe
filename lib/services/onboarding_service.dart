// Onboarding Service - Manages first-time user experience

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyAppVersion = 'app_version';
  static const String _keyTutorialShown = 'tutorial_shown';

  // Check if this is the first time user opens the app
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  // Mark that user has launched the app
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // Check if user completed onboarding
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Mark onboarding as completed
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  // Check if tutorial was shown for current version
  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = '2.2.4';
    final lastShownVersion = prefs.getString(_keyAppVersion);
    
    // Show tutorial if version changed or never shown
    return lastShownVersion != currentVersion;
  }

  // Mark tutorial as shown for current version
  static Future<void> setTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppVersion, '2.2.4');
    await prefs.setBool(_keyTutorialShown, true);
  }

  // Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstLaunch);
    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyAppVersion);
    await prefs.remove(_keyTutorialShown);
  }

  // Get user progress metrics
  static Future<Map<String, dynamic>> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'isFirstTime': await isFirstLaunch(),
      'onboardingCompleted': await isOnboardingCompleted(),
      'tutorialShown': prefs.getBool(_keyTutorialShown) ?? false,
      'appVersion': prefs.getString(_keyAppVersion) ?? 'unknown',
    };
  }
}