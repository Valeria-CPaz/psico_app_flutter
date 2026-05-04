import 'package:flutter/material.dart';

class AgendaLegend {
  final String id;
  final String label;
  final Color color;

  AgendaLegend({required this.id, required this.label, required this.color});

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'color': color.toARGB32(),
  };

  factory AgendaLegend.fromMap(Map<String, dynamic> map) => AgendaLegend(
    id: map['id'] as String,
    label: map['label'] as String,
    color: Color(map['color'] as int),
  );
}

class AgendaConfig {
  final List<AgendaLegend> legends;
  final int startHour;
  final int endHour;

  AgendaConfig({
    required this.legends,
    required this.startHour,
    required this.endHour,
  });

  static AgendaConfig get defaults => AgendaConfig(
    startHour: 7,
    endHour: 20,
    legends: [
      AgendaLegend(id: '1', label: 'Paciente', color: Colors.blue),
      AgendaLegend(id: '2', label: 'Problema', color: Colors.amber),
      AgendaLegend(id: '3', label: 'Pessoal', color: Colors.green),
    ],
  );
}
