import 'dart:convert';

class Appointment {
  final String id;
  final DateTime dateTime;
  final int durationHours;
  final String legendId;
  final String? patientId;
  final String? note;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.durationHours,
    required this.legendId,
    this.patientId,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'durationHours': durationHours,
    'legendId': legendId,
    'patientId': patientId,
    'note': note,
  };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'],
    dateTime: DateTime.parse(map['dateTime']),
    durationHours: map['durationHours'] ?? 1,
    legendId: map['legendId'],
    patientId: map['patientId'],
    note: map['note'],
  );

  String toJson() => jsonEncode(toMap());
  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(jsonDecode(source));
}
