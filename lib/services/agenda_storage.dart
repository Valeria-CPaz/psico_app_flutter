import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psicoapp/models/appointment.dart';
import 'package:psicoapp/models/agenda_config.dart';

class AgendaStorage {
  static const _appointmentsKey = 'appointments';
  static const _configKey = 'agenda_config';

  /* ---------------
  -- Appointments --
  --------------- */
  static Future<List<Appointment>> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_appointmentsKey);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((entry) => Appointment.fromMap(entry)).toList();
  }

  static Future<void> saveAppointments(List<Appointment> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      list.map((appointment) => appointment.toMap()).toList(),
    );
    await prefs.setString(_appointmentsKey, encoded);
  }

  /* ---------------
  ----- Config -----
  --------------- */
  static Future<AgendaConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_configKey);
    if (raw == null) return AgendaConfig.defaults;
    return AgendaConfig.fromJson(raw);
  }

  static Future<void> saveConfig(AgendaConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, config.toJson());
  }
}
