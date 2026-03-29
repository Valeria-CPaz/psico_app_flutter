import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/appointment.dart';
import 'package:psicoapp/models/agenda_config.dart';
import 'package:psicoapp/models/patient.dart';
import 'package:psicoapp/services/agenda_storage.dart';
import 'package:psicoapp/services/patient_storage.dart';
import 'package:psicoapp/components/appointment_modal.dart';
import 'package:psicoapp/components/agenda_config_modal.dart';

List<DateTime> _daysInWeek(DateTime monday) =>
    List.generate(7, (i) => monday.add(Duration(days: i)));

DateTime _mondayOfWeek(DateTime date) =>
    date.subtract(Duration(days: date.weekday - 1));

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _currentMonday;
  AgendaConfig _config = AgendaConfig.defaults;
  List<Appointment> _appointments = [];
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _currentMonday = _mondayOfWeek(DateTime.now());
    _loadData();
  }

  Future<void> _loadData() async {
    final config = await AgendaStorage.loadConfig();
    final appointments = await AgendaStorage.loadAppointments();
    final patients = await PatientStorage.loadPatients();
    setState(() {
      _config = config;
      _appointments = appointments;
      _patients = patients;
    });
  }

  // Return appointment (or null)
  Appointment? _appointmentAt(DateTime day, int hour) {
    try {
      return _appointments.firstWhere(
        (a) =>
            a.dateTime.year == day.year &&
            a.dateTime.month == day.month &&
            a.dateTime.day == day.day &&
            a.dateTime.hour == hour,
      );
    } catch (_) {
      return null;
    }
  }

  // Return legend of an appointment
  AgendaLegend? _legendOf(Appointment a) {
    try {
      return _config.legends.firstWhere((legend) => legend.id == a.legendId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openSlot(DateTime day, int hour) async {
    final dt = DateTime(day.year, day.month, day.day, hour);
    final existing = _appointmentAt(day, hour);

    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AppointmentModal(
        dateTime: dt,
        config: _config,
        patients: _patients,
        existing: existing,
      ),
    );

    if (result == null) return;

    setState(() {
      // Remove existing (if true)
      _appointments.removeWhere(
        (appointment) =>
            appointment.dateTime.year == dt.year &&
            appointment.dateTime.month == dt.month &&
            appointment.dateTime.day == dt.day &&
            appointment.dateTime.hour == dt.hour,
      );

      if (result is Appointment) {
        _appointments.add(result);
      }
    });

    await AgendaStorage.saveAppointments(_appointments);
  }

  Future<void> _openConfig() async {
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AgendaConfigModal(config: _config),
    );

    if (result is AgendaConfig) {
      setState(() => _config = result);
      await AgendaStorage.saveConfig(result);
    }
  }

  String _formatWeekRange(List<DateTime> days) {
    final startDay = days[0];
    final endDay = days[6];
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    if (startDay.month == endDay.month) {
      return '${startDay.day} – ${endDay.day} de ${months[startDay.month - 1]}';
    }
    return '${startDay.day} ${months[startDay.month - 1]} – ${endDay.day} ${months[endDay.month - 1]}';
  }

  Widget _buildLegendChip(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInWeek(_currentMonday);
    const dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      children: [
        // Week navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                () => _currentMonday = _currentMonday.subtract(
                  const Duration(days: 7),
                ),
              ),
            ),
            Text(_formatWeekRange(days)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(
                () => _currentMonday = _currentMonday.add(
                  const Duration(days: 7),
                ),
              ),
            ),
          ],
        ),

        // Days
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    'Hora',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ),
              ),
              ...List.generate(
                7,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      dayNames[i],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Grid
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(44),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FlexColumnWidth(),
                  6: FlexColumnWidth(),
                  7: FlexColumnWidth(),
                },
                children: List.generate(
                  _config.endHour - _config.startHour + 1,
                  (hourIndex) {
                    final hour = _config.startHour + hourIndex;
                    return TableRow(
                      children: [
                        Container(
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            '$hour h',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        ...List.generate(7, (dayIndex) {
                          final appointment = _appointmentAt(
                            days[dayIndex],
                            hour,
                          );
                          final legend = appointment != null
                              ? _legendOf(appointment)
                              : null;

                          return GestureDetector(
                            onTap: () => _openSlot(days[dayIndex], hour),
                            child: Container(
                              height: 32,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: legend?.color.withAlpha(200),
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Legends footer
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: _config.legends
                      .map(
                        (legend) =>
                            _buildLegendChip(legend.color, legend.label),
                      )
                      .toList(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
                onPressed: _openConfig,
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
