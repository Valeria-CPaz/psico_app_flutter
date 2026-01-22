import 'package:flutter/material.dart';

List<DateTime> _daysInWeek(DateTime monday) {
  return List.generate(7, (index) => monday.add(Duration(days: index)));
}

DateTime _mondayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime _currentMonday;
  int _startHour = 7; // ajuste conforme quiser
  int _endHour = 20;

  @override
  void initState() {
    super.initState();
    _currentMonday = _mondayOfWeek(DateTime.now());
  }

  String _formatWeekRange(List<DateTime> days) {
    final start = days[0];
    final end = days[6];

    String monthName(int month) {
      const months = [
        'de Janeiro',
        'de Fevereiro',
        'de Março',
        'de Abril',
        'de Maio',
        'de Junho',
        'de Julho',
        'de Agosto',
        'de Setembro',
        'de Outubro',
        'de Novembro',
        'de Dezembro',
      ];
      return months[month - 1];
    }

    if (start.month == end.month) {
      return '${start.day} – ${end.day} ${monthName(start.month)}';
    } else {
      return '${start.day} ${monthName(start.month)} – ${end.day} ${monthName(end.month)}';
    }
  }

  void _openAppointmentModal(DateTime date, int hour) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendar em ${date.day}/${date.month} às $hour:00'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInWeek(_currentMonday);
    final dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      children: [
        // Cabeçalho com navegação
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _currentMonday = _currentMonday.subtract(
                    const Duration(days: 7),
                  );
                });
              },
            ),
            Text(_formatWeekRange(days)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _currentMonday = _currentMonday.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Linha de cabeçalho: "Hora" + dias da semana
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Center(
                  child: Text(
                    'Hora',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
              ...List.generate(7, (i) {
                return Expanded(child: Center(child: Text(dayNames[i])));
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Grade horária
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(60), // coluna fixa para horas
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
                6: FlexColumnWidth(),
                7: FlexColumnWidth(),
              },
              children: List.generate(_endHour - _startHour + 1, (hourIndex) {
                final hour = _startHour + hourIndex;
                return TableRow(
                  children: [
                    // Coluna de hora
                    Container(
                      alignment: Alignment.center,
                      child: Text('$hour h', style: TextStyle(color: Colors.grey.shade500),),
                    ),
                    // Slots dos dias (Seg a Dom)
                    ...List.generate(7, (dayIndex) {
                      return GestureDetector(
                        onTap: () => _openAppointmentModal(days[dayIndex], hour),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(child: Text('')),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
