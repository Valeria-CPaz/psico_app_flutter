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
    'date_time': dateTime.toIso8601String(),
    'duration_hours': durationHours,
    'legend_id': legendId,
    'patient_id': patientId,
    'note': note,
  };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
    id: map['id'] as String,
    dateTime: DateTime.parse(map['date_time'] as String),
    durationHours: map['duration_hours'] as int? ?? 1,
    legendId: map['legend_id'] as String,
    patientId: map['patient_id'] as String?,
    note: map['note'] as String?,
  );
}
