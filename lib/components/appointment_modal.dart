import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/appointment.dart';
import 'package:psicoapp/models/agenda_config.dart';
import 'package:psicoapp/models/patient.dart';

class AppointmentModal extends StatefulWidget {
  final DateTime dateTime;
  final AgendaConfig config;
  final List<Patient> patients;
  final Appointment? existing;

  const AppointmentModal({
    super.key,
    required this.dateTime,
    required this.config,
    required this.patients,
    this.existing,
  });

  @override
  State<AppointmentModal> createState() => _AppointmentModalState();
}

class _AppointmentModalState extends State<AppointmentModal> {
  late String _selectedLegendId;
  String? _selectedPatientId;
  final _noteController = TextEditingController();
  int _durationHours = 1;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _selectedLegendId = ex.legendId;
      _selectedPatientId = ex.patientId;
      _noteController.text = ex.note ?? '';
      _durationHours = ex.durationHours;
    } else {
      _selectedLegendId = widget.config.legends.first.id;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final appointment = Appointment(
      id:
          widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      dateTime: widget.dateTime,
      durationHours: _durationHours,
      legendId: _selectedLegendId,
      patientId: _selectedLegendId,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    Navigator.pop(context, appointment);
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir compromisso?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) Navigator.pop(context, 'delete');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final day = widget.dateTime;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isEditing ? 'Editar' : 'Novo'} compromisso',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _delete,
                ),
            ],
          ),
          Text(
            '${day.day}/${day.month}/${day.year} às ${day.hour}:00',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Legend
          const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: widget.config.legends.map((legend) {
              final selected = legend.id == _selectedLegendId;
              return ChoiceChip(
                label: Text(legend.label),
                selected: selected,
                selectedColor: legend.color.withAlpha(180),
                avatar: CircleAvatar(backgroundColor: legend.color, radius: 6),
                onSelected: (_) =>
                    setState(() => _selectedLegendId = legend.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          //Patient
          if (widget.patients.isNotEmpty) ...[
            const Text(
              'Paciente',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedPatientId,
              hint: const Text('Nenhum (opcional)'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nenhum')),
                ...widget.patients.map(
                  (patient) => DropdownMenuItem(
                    value: patient.id,
                    child: Text(patient.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedPatientId = value),
            ),
            const SizedBox(height: 12),
          ],

          // Duration
          const Text('Duração', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [1, 2, 3].map((hour) {
              final selected = _durationHours == hour;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${hour}h'),
                  selected: selected,
                  selectedColor: AppColors.primary.withAlpha(180),
                  onSelected: (_) => setState(() => _durationHours = hour),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Observation
          const Text(
            'Observação',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Anotações sobre o compromisso...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              onPressed: _submit,
              child: Text(isEditing ? 'Salvar alterações' : 'Agendar'),
            ),
          ),
        ],
      ),
    );
  }
}
