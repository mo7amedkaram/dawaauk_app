// lib/app/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  final _box = GetStorage();
  final _key = 'theme_mode';

  // Current theme mode
  ThemeMode get themeMode => _loadThemeMode();
  // Is dark mode currently enabled
  bool get isDarkMode => themeMode == ThemeMode.dark;

  // Load the theme mode from storage
  ThemeMode _loadThemeMode() {
    String? themeText = _box.read(_key);
    return AppTheme.getThemeMode(themeText ?? 'system');
  }

  // Save the theme mode to storage
  _saveThemeMode(ThemeMode mode) => _box.write(_key, _getModeText(mode));

  // Get string representation of theme mode
  String _getModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }

  // Change the theme
  void changeThemeMode(ThemeMode mode) {
    Get.changeThemeMode(mode);
    _saveThemeMode(mode);
    update();
  }

  // Toggle between light and dark
  void toggleTheme() {
    ThemeMode newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(newMode);
    _saveThemeMode(newMode);
    update();
  }
}
