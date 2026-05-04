import 'package:hive_flutter/hive_flutter.dart';
import 'package:psicoapp/models/patient.dart';

class PatientStorage {
  static Future<Box> _box() => Hive.openBox('patients');

  static Future<List<Patient>> loadPatients() async {
    final box = await _box();
    return box.values
        .map((v) => Patient.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Future<void> savePatient(Patient patient) async {
    final box = await _box();
    await box.put(patient.id, patient.toMap());
  }

  static Future<void> deletePatient(String id) async {
    final box = await _box();
    await box.delete(id);
  }
}
