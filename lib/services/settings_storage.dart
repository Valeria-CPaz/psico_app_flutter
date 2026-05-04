import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _keyIntegralValue = 'integral_value';
  static const _keyPrimaryColor = 'primary_color';

  static Future<double> getIntegralValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyIntegralValue) ?? 0.0;
  }

  static Future<void> setIntegralValue(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyIntegralValue, value);
  }

  static Future<Color> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyPrimaryColor);
    return Color(value ?? 0xFFA3961E);
  }

  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrimaryColor, color.toARGB32());
  }
}
