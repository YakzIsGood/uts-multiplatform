import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  static const String _themeKey = 'isDarkMode';

  // Asynchronous: Menyimpan status tema (true/false)
  static Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Asynchronous: Membaca status tema, default-nya false (Light Mode)
  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}