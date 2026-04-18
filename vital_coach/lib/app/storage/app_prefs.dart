import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kOnboardingDone = 'onboarding_done_v1';

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, value);
  }
}

