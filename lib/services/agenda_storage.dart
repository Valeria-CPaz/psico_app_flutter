import 'package:hive_flutter/hive_flutter.dart';
import 'package:psicoapp/models/appointment.dart';
import 'package:psicoapp/models/agenda_config.dart';

class AgendaStorage {
  static Future<Box> _appointmentsBox() => Hive.openBox('appointments');
  static Future<Box> _configBox() => Hive.openBox('agenda_config');

  // ── Appointments ──────────────────────────────────────────────────────────

  static Future<List<Appointment>> loadAppointments() async {
    final box = await _appointmentsBox();
    return box.values
        .map((v) => Appointment.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList();
  }

  static Future<void> saveAppointment(Appointment appointment) async {
    final box = await _appointmentsBox();
    await box.put(appointment.id, appointment.toMap());
  }

  static Future<void> deleteAppointment(String id) async {
    final box = await _appointmentsBox();
    await box.delete(id);
  }

  // ── Config ────────────────────────────────────────────────────────────────

  static Future<AgendaConfig> loadConfig() async {
    final box = await _configBox();
    final raw = box.get('config');
    if (raw == null) return AgendaConfig.defaults;

    final map = Map<String, dynamic>.from(raw as Map);
    final legendsRaw = (map['legends'] as List?) ?? [];

    return AgendaConfig(
      startHour: map['start_hour'] as int,
      endHour: map['end_hour'] as int,
      legends: legendsRaw
          .map((l) => AgendaLegend.fromMap(Map<String, dynamic>.from(l as Map)))
          .toList(),
    );
  }

  static Future<void> saveConfig(AgendaConfig config) async {
    final box = await _configBox();
    await box.put('config', {
      'start_hour': config.startHour,
      'end_hour': config.endHour,
      'legends': config.legends.map((l) => l.toMap()).toList(),
    });
  }
}
