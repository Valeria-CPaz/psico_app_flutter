import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/agenda_config.dart';

class AgendaConfigModal extends StatefulWidget {
  final AgendaConfig config;

  const AgendaConfigModal({super.key, required this.config});

  @override
  State<AgendaConfigModal> createState() => _AgendaConfigModalState();
}

class _AgendaConfigModalState extends State<AgendaConfigModal> {
  late int _startHour;
  late int _endHour;
  late List<AgendaLegend> _legends;

  // Colors available to pick
  final _palette = [
    Colors.blue,
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _startHour = widget.config.startHour;
    _endHour = widget.config.endHour;
    _legends = List.from(widget.config.legends);
  }

  void _editLegend(int index) {
    final legend = _legends[index];
    final labelController = TextEditingController(text: legend.label);
    Color pickedColor = legend.color;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: const Text('Editar legenda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              const Text('Cor:'),
              const SizedBox(height: 6),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _palette.sublist(0, 4).map((color) {
                      return GestureDetector(
                        onTap: () => setInner(() => pickedColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: pickedColor == color
                                ? Border.all(width: 3, color: Colors.black)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _palette.sublist(4, 8).map((color) {
                      return GestureDetector(
                        onTap: () => setInner(() => pickedColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: pickedColor == color
                                ? Border.all(width: 3, color: Colors.black)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _legends[index] = AgendaLegend(
                    id: legend.id,
                    label: labelController.text.trim().isEmpty
                        ? legend.label
                        : labelController.text.trim(),
                    color: pickedColor,
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }

  void _addLegend() {
    if (_legends.length >= 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Máximo de 6 legendas')));
      return;
    }
    setState(() {
      _legends.add(
        AgendaLegend(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: 'Nova legenda',
          color: _palette[_legends.length % _palette.length],
        ),
      );
    });
  }

  void _removeLegend(int index) {
    if (_legends.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mínimo de 1 legenda')));
      return;
    }
    setState(() => _legends.removeAt(index));
  }

  void _save() {
    Navigator.pop(
      context,
      AgendaConfig(legends: _legends, startHour: _startHour, endHour: _endHour),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações da Agenda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Time
          const Text('Horário', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Das '),
              DropdownButton<int>(
                value: _startHour,
                items: List.generate(17, (i) => i + 5)
                    .map(
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text('$hour:00'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null && value < _endHour) {
                    setState(() => _startHour = value);
                  }
                },
              ),
              const Text(' até '),
              DropdownButton<int>(
                value: _endHour,
                items: List.generate(17, (i) => i + 5)
                    .map(
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text('$hour:00'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null && value > _startHour) {
                    setState(() => _endHour = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Legendas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: _addLegend,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ..._legends.asMap().entries.map((entry) {
            final i = entry.key;
            final legend = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: legend.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(legend.label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editLegend(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => _removeLegend(i),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    );
  }
}
