import 'package:shared_preferences/shared_preferences.dart';
import 'package:psicoapp/models/patient.dart';
import 'dart:convert'; 

class PatientStorage {
  static const String _key = 'patients';

  static Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Converte cada Patient para Map, depois para String JSON
    final List<String> jsonList = patients
        .map((p) => json.encode({
              'id': p.id,
              'name': p.name,
              'phone': p.phone,
              'isSocial': p.isSocial,
              'socialValue': p.socialValue,
            }))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<Patient>> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList
        .map((jsonString) => Patient.fromMap(json.decode(jsonString) as Map<String, dynamic>))
        .toList();
  }
}