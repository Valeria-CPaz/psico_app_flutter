import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyEmail = 'auth_email';
  static const _keyHash = 'auth_hash';
  static const _keySession = 'auth_session';

  static String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  static Future<bool> get hasAccount async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyEmail);
  }

  static Future<String?> get storedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> setup(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email.trim().toLowerCase());
    await prefs.setString(_keyHash, _hashPassword(password));
    await prefs.setBool(_keySession, true);
  }

  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedHash = prefs.getString(_keyHash);
    if (storedEmail != email.trim().toLowerCase()) return false;
    if (storedHash != _hashPassword(password)) return false;
    await prefs.setBool(_keySession, true);
    return true;
  }

  static Future<bool> get isSessionActive async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySession) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
  }
}
