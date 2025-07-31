// File: lib/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isFahrenheit = false;   // Temperature unit: false = Celsius, true = Fahrenheit
  bool _is24Hour = true;        // Time format: true = 24-hour, false = 12-hour

  bool get isFahrenheit => _isFahrenheit;
  bool get is24Hour => _is24Hour;

  // Loads saved settings from shared preferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    _is24Hour = prefs.getBool('is24Hour') ?? true;
    notifyListeners();
  }

  // Toggles temperature unit and saves it
  Future<void> toggleTemperatureUnit() async {
    _isFahrenheit = !_isFahrenheit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFahrenheit', _isFahrenheit);
    notifyListeners();
  }

  // Toggles time format and saves it
  Future<void> toggleTimeFormat() async {
    _is24Hour = !_is24Hour;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24Hour', _is24Hour);
    notifyListeners();
  }
}
