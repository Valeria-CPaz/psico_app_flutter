import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/pages/login_page.dart';
import 'package:psicoapp/services/auth_service.dart';
import 'package:psicoapp/services/settings_storage.dart';
import 'package:psicoapp/services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _integralController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  Color _selectedColor = defaultPrimaryColor;

  static const _palette = [
    (Color(0xFFA3961E), 'Oliva'),
    (Color(0xFF1565C0), 'Azul'),
    (Color(0xFF00695C), 'Verde-azulado'),
    (Color(0xFF6A1B9A), 'Roxo'),
    (Color(0xFFC62828), 'Vermelho'),
    (Color(0xFFE65100), 'Laranja'),
    (Color(0xFF2E7D32), 'Verde'),
    (Color(0xFF00838F), 'Ciano'),
    (Color(0xFF4527A0), 'Índigo'),
    (Color(0xFFAD1457), 'Rosa'),
    (Color(0xFF4E342E), 'Marrom'),
    (Color(0xFF455A64), 'Azul-cinza'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _integralController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final value = await SettingsStorage.getIntegralValue();
    final color = await SettingsStorage.getPrimaryColor();
    setState(() {
      _integralController.text = value > 0 ? value.toStringAsFixed(2) : '';
      _selectedColor = color;
      _loading = false;
    });
  }

  Future<void> _saveIntegral() async {
    final raw = _integralController.text.replaceAll(',', '.');
    final value = double.tryParse(raw) ?? 0.0;
    setState(() => _saving = true);
    await SettingsStorage.setIntegralValue(value);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Valor salvo!')),
    );
  }

  Future<void> _selectColor(Color color) async {
    await SettingsStorage.setPrimaryColor(color);
    primaryColorNotifier.value = color;
    setState(() => _selectedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Valor integral ──────────────────────────────────────────────
          const Text(
            'Valor da sessão — Plano Integral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Usado nos relatórios de receita. Alterações valem a partir de agora — não retroativo.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _integralController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            decoration: InputDecoration(
              labelText: 'Valor por sessão (R\$)',
              hintText: 'ex: 200,00',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
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
              onPressed: _saving ? null : _saveIntegral,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Salvar valor'),
            ),
          ),

          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 20),

          // ── Cor do tema ─────────────────────────────────────────────────
          const Text(
            'Cor do tema',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'A cor principal usada em todo o aplicativo.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _palette.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) {
              final (color, label) = _palette[i];
              final selected = _selectedColor.toARGB32() == color.toARGB32();
              return Tooltip(
                message: label,
                child: GestureDetector(
                  onTap: () => _selectColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(width: 3, color: Colors.black87)
                          : Border.all(width: 2, color: Colors.transparent),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 20),

          // ── Sair ───────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sair',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
