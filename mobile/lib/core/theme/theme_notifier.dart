import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier(this._storage) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final savedTheme = await _storage.read(key: 'theme_mode');
    if (savedTheme != null) {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.write(
      key: 'theme_mode',
      value: mode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
