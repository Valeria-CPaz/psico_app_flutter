import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/appointment.dart';
import 'package:psicoapp/models/patient.dart';
import 'package:psicoapp/services/agenda_storage.dart';
import 'package:psicoapp/services/patient_storage.dart';
import 'package:psicoapp/services/settings_storage.dart';

enum _PeriodType { week, month, quarter, semester }

class _ChartBar {
  final String label;
  final double amount;
  _ChartBar(this.label, this.amount);
}

class _SessionEntry {
  final DateTime date;
  final String patientName;
  final bool isSocial;
  final double value;
  _SessionEntry({
    required this.date,
    required this.patientName,
    required this.isSocial,
    required this.value,
  });
}

class _ReportData {
  final double totalRevenue;
  final double integralRevenue;
  final double socialRevenue;
  final int sessionCount;
  final int uniquePatients;
  final double? previousRevenue;
  final List<_ChartBar> chartBars;
  final List<_SessionEntry> sessions;

  _ReportData({
    required this.totalRevenue,
    required this.integralRevenue,
    required this.socialRevenue,
    required this.sessionCount,
    required this.uniquePatients,
    this.previousRevenue,
    required this.chartBars,
    required this.sessions,
  });
}

const _monthNames = [
  '',
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

const _monthShort = [
  '',
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
];

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  _PeriodType _periodType = _PeriodType.month;
  DateTime _referenceDate = DateTime.now();
  DateTime? _comparisonRef;
  bool _showPlanBreakdown = true;
  bool _showUniquePatients = false;
  bool _showComparison = false;
  bool _generating = false;
  _ReportData? _report;

  // ── Period helpers ────────────────────────────────────────────────────────

  DateTimeRange _computeRange(DateTime ref, _PeriodType type) {
    switch (type) {
      case _PeriodType.week:
        final monday = ref.subtract(Duration(days: ref.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        return DateTimeRange(
          start: start,
          end: DateTime(start.year, start.month, start.day + 7)
              .subtract(const Duration(seconds: 1)),
        );
      case _PeriodType.month:
        return DateTimeRange(
          start: DateTime(ref.year, ref.month, 1),
          end: DateTime(ref.year, ref.month + 1, 1)
              .subtract(const Duration(seconds: 1)),
        );
      case _PeriodType.quarter:
        final startMonth = ((ref.month - 1) ~/ 3) * 3 + 1;
        return DateTimeRange(
          start: DateTime(ref.year, startMonth, 1),
          end: DateTime(ref.year, startMonth + 3, 1)
              .subtract(const Duration(seconds: 1)),
        );
      case _PeriodType.semester:
        final startMonth = ref.month <= 6 ? 1 : 7;
        return DateTimeRange(
          start: DateTime(ref.year, startMonth, 1),
          end: DateTime(ref.year, startMonth + 6, 1)
              .subtract(const Duration(seconds: 1)),
        );
    }
  }

  DateTime _previousRef(DateTime ref, _PeriodType type) {
    switch (type) {
      case _PeriodType.week:
        return ref.subtract(const Duration(days: 7));
      case _PeriodType.month:
        return DateTime(ref.year, ref.month - 1, 1);
      case _PeriodType.quarter:
        return DateTime(ref.year, ref.month - 3, 1);
      case _PeriodType.semester:
        return DateTime(ref.year, ref.month - 6, 1);
    }
  }

  String _periodLabel(DateTime ref, _PeriodType type) {
    final range = _computeRange(ref, type);
    switch (type) {
      case _PeriodType.week:
        final s = range.start;
        final e = range.end;
        return '${s.day}/${s.month} a ${e.day}/${e.month}/${e.year}';
      case _PeriodType.month:
        return '${_monthNames[ref.month]} ${ref.year}';
      case _PeriodType.quarter:
        return '${(ref.month - 1) ~/ 3 + 1}º Trimestre ${ref.year}';
      case _PeriodType.semester:
        return '${ref.month <= 6 ? 1 : 2}º Semestre ${ref.year}';
    }
  }

  // ── Data computation ──────────────────────────────────────────────────────

  double _valueFor(Appointment a, Map<String, Patient> byId, double integralValue) {
    if (a.patientId == null) return 0.0;
    final p = byId[a.patientId];
    if (p == null) return 0.0;
    return p.isSocial
        ? (p.socialValue ?? 0.0) * a.durationHours
        : integralValue * a.durationHours;
  }

  List<_ChartBar> _buildBars(
    List<Appointment> appts,
    Map<String, Patient> byId,
    double integralValue,
    DateTimeRange range,
    _PeriodType type,
  ) {
    double revenue(Appointment a) => _valueFor(a, byId, integralValue);

    switch (type) {
      case _PeriodType.week:
        const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
        return List.generate(7, (i) {
          final day = range.start.add(Duration(days: i));
          final total = appts
              .where((a) =>
                  a.dateTime.year == day.year &&
                  a.dateTime.month == day.month &&
                  a.dateTime.day == day.day)
              .fold(0.0, (s, a) => s + revenue(a));
          return _ChartBar(labels[i], total);
        });

      case _PeriodType.month:
        final weeks = List.filled(4, 0.0);
        for (final a in appts) {
          weeks[math.min((a.dateTime.day - 1) ~/ 7, 3)] += revenue(a);
        }
        return List.generate(4, (i) => _ChartBar('Sem ${i + 1}', weeks[i]));

      case _PeriodType.quarter:
      case _PeriodType.semester:
        final count = type == _PeriodType.quarter ? 3 : 6;
        final amounts = List.filled(count, 0.0);
        for (final a in appts) {
          final idx = (a.dateTime.year - range.start.year) * 12 +
              (a.dateTime.month - range.start.month);
          if (idx >= 0 && idx < count) amounts[idx] += revenue(a);
        }
        return List.generate(count, (i) {
          final m = DateTime(range.start.year, range.start.month + i, 1);
          return _ChartBar(_monthShort[m.month], amounts[i]);
        });
    }
  }

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _report = null;
    });

    final allAppts = await AgendaStorage.loadAppointments();
    final patients = await PatientStorage.loadPatients();
    final integralValue = await SettingsStorage.getIntegralValue();

    final byId = {for (final p in patients) p.id: p};
    final range = _computeRange(_referenceDate, _periodType);

    final filtered = allAppts
        .where((a) =>
            !a.dateTime.isBefore(range.start) &&
            !a.dateTime.isAfter(range.end))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    double totalRevenue = 0, integralRevenue = 0, socialRevenue = 0;
    final uniqueIds = <String>{};
    final sessions = <_SessionEntry>[];

    for (final a in filtered) {
      if (a.patientId == null) continue;
      final p = byId[a.patientId];
      if (p == null) continue;
      final v = _valueFor(a, byId, integralValue);
      totalRevenue += v;
      uniqueIds.add(a.patientId!);
      if (p.isSocial) {
        socialRevenue += v;
      } else {
        integralRevenue += v;
      }
      sessions.add(_SessionEntry(
        date: a.dateTime,
        patientName: p.name,
        isSocial: p.isSocial,
        value: v,
      ));
    }

    double? previousRevenue;
    if (_showComparison) {
      final prevRef = _comparisonRef ?? _previousRef(_referenceDate, _periodType);
      final prevRange = _computeRange(prevRef, _periodType);
      previousRevenue = allAppts
          .where((a) =>
              !a.dateTime.isBefore(prevRange.start) &&
              !a.dateTime.isAfter(prevRange.end))
          .fold<double>(0.0, (s, a) => s + _valueFor(a, byId, integralValue));
    }

    setState(() {
      _report = _ReportData(
        totalRevenue: totalRevenue,
        integralRevenue: integralRevenue,
        socialRevenue: socialRevenue,
        sessionCount: filtered.length,
        uniquePatients: uniqueIds.length,
        previousRevenue: previousRevenue,
        chartBars: _buildBars(filtered, byId, integralValue, range, _periodType),
        sessions: sessions,
      );
      _generating = false;
    });
  }

  // ── Currency helper ───────────────────────────────────────────────────────

  String _currency(double v) {
    final isNeg = v < 0;
    final s = v.abs().toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write('.');
      buf.write(parts[0][i]);
    }
    return '${isNeg ? '-' : ''}R\$ $buf,${parts[1]}';
  }

  // ── PDF export ────────────────────────────────────────────────────────────

  Future<void> _exportPdf() async {
    final r = _report!;
    final label = _periodLabel(_referenceDate, _periodType);
    final now = DateTime.now();

    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Relatório — PsicoApp',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Período: $label',
              style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
          pw.Text(
              'Gerado em ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          pw.Divider(height: 24),
          pw.Text('Resumo',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _pdfRow('Total recebido', _currency(r.totalRevenue), header: true),
              _pdfRow('Sessões realizadas', '${r.sessionCount}'),
              if (_showPlanBreakdown) ...[
                _pdfRow('↳ Plano Integral', _currency(r.integralRevenue)),
                _pdfRow('↳ Plano Social', _currency(r.socialRevenue)),
              ],
              if (_showUniquePatients)
                _pdfRow('Pacientes únicos', '${r.uniquePatients}'),
              if (_showComparison && r.previousRevenue != null)
                _pdfRow('Período anterior', _currency(r.previousRevenue!)),
            ],
          ),
          if (r.sessions.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text('Sessões',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(80),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: ['Data', 'Paciente', 'Plano', 'Valor']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10)),
                          ))
                      .toList(),
                ),
                ...r.sessions.map((s) => pw.TableRow(children: [
                      '${s.date.day.toString().padLeft(2, '0')}/${s.date.month.toString().padLeft(2, '0')}',
                      s.patientName,
                      s.isSocial ? 'Social' : 'Integral',
                      _currency(s.value),
                    ]
                        .map((t) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(t,
                                  style: const pw.TextStyle(fontSize: 10)),
                            ))
                        .toList())),
              ],
            ),
          ],
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'relatorio_psicoapp_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf',
    );
  }

  pw.TableRow _pdfRow(String label, String value, {bool header = false}) =>
      pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                      header ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(7),
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ),
      ]);

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _referenceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecione uma data dentro do período',
    );
    if (picked != null) setState(() { _referenceDate = picked; _comparisonRef = null; _report = null; });
  }

  Future<void> _pickComparisonDate() async {
    final defaultRef = _previousRef(_referenceDate, _periodType);
    final picked = await showDatePicker(
      context: context,
      initialDate: _comparisonRef ?? defaultRef,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecione uma data dentro do período de comparação',
    );
    if (picked != null) setState(() { _comparisonRef = picked; _report = null; });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCard(),
          if (_report != null) ...[
            const SizedBox(height: 24),
            _buildReport(_report!),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    const periodLabels = {
      _PeriodType.week: 'Semana',
      _PeriodType.month: 'Mês',
      _PeriodType.quarter: 'Trimestre',
      _PeriodType.semester: 'Semestre',
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Período',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _PeriodType.values.map((type) {
                  final selected = _periodType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(periodLabels[type]!),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.onPrimary : null,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                      onSelected: (_) => setState(() {
                        _periodType = type;
                        _report = null;
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 10),
                    Text(
                      _periodLabel(_referenceDate, _periodType),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            const Text('Incluir no relatório',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Breakdown por plano', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Integral vs Social', style: TextStyle(fontSize: 12)),
              value: _showPlanBreakdown,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() { _showPlanBreakdown = v; _report = null; }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pacientes únicos', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Quantos pacientes distintos atendidos', style: TextStyle(fontSize: 12)),
              value: _showUniquePatients,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() { _showUniquePatients = v; _report = null; }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Comparativo com outro período', style: TextStyle(fontSize: 14)),
              value: _showComparison,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() {
                _showComparison = v;
                if (v) _comparisonRef ??= _previousRef(_referenceDate, _periodType);
                _report = null;
              }),
            ),
            if (_showComparison) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: InkWell(
                  onTap: _pickComparisonDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows_outlined,
                            size: 15, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Comparar com: ${_periodLabel(_comparisonRef ?? _previousRef(_referenceDate, _periodType), _periodType)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined, size: 13, color: Colors.grey.shade500),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _generating ? null : _generate,
                child: _generating
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Gerar Relatório',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReport(_ReportData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Destaques',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _highlightCard(
              icon: Icons.payments_outlined,
              label: 'Total recebido',
              value: _currency(r.totalRevenue),
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _highlightCard(
              icon: Icons.event_available_outlined,
              label: 'Sessões realizadas',
              value: '${r.sessionCount}',
              color: const Color(0xFF4A7A68),
            ),
          ),
        ]),
        if (_showUniquePatients) ...[
          const SizedBox(height: 12),
          _highlightCard(
            icon: Icons.people_outline,
            label: 'Pacientes únicos no período',
            value: '${r.uniquePatients}',
            color: const Color(0xFF6D6080),
            fullWidth: true,
          ),
        ],
        if (_showComparison && r.previousRevenue != null) ...[
          const SizedBox(height: 12),
          _comparisonCard(r.totalRevenue, r.previousRevenue!),
        ],
        if (_showPlanBreakdown && (r.integralRevenue > 0 || r.socialRevenue > 0)) ...[
          const SizedBox(height: 12),
          _planBreakdownCard(r),
        ],
        const SizedBox(height: 28),
        const Text('Receita por período',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildChart(r.chartBars),
        const SizedBox(height: 28),
        Row(children: [
          const Text('Sessões',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${r.sessions.length}',
                style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        _buildSessionsList(r.sessions),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: BorderSide(color: AppColors.primaryDark),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Salvar como PDF',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _highlightCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _comparisonCard(double current, double previous) {
    final delta = current - previous;
    final pct = previous > 0 ? (delta / previous * 100) : 0.0;
    final isPositive = delta >= 0;
    final tone = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bg = isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withAlpha(60)),
      ),
      child: Row(children: [
        Icon(isPositive ? Icons.trending_up : Icons.trending_down,
            color: tone, size: 30),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '${isPositive ? '+' : '-'}${_currency(delta.abs())} '
            '(${pct.abs().toStringAsFixed(1)}%)',
            style: TextStyle(
                color: tone, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text('vs período anterior · ${_currency(previous)}',
              style: TextStyle(color: tone.withAlpha(160), fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _planBreakdownCard(_ReportData r) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Por plano',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black54)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Integral',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
                const SizedBox(height: 5),
                Text(_currency(r.integralRevenue),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
            Container(width: 1, height: 44, color: Colors.grey.shade200),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                            color: Color(0xFF4A7A68),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Social',
                        style:
                            TextStyle(fontSize: 12, color: Colors.black54)),
                  ]),
                  const SizedBox(height: 5),
                  Text(_currency(r.socialRevenue),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildChart(List<_ChartBar> bars) {
    final maxY = bars.fold(0.0, (m, b) => math.max(m, b.amount));
    final effectiveMax = maxY > 0 ? maxY * 1.3 : 100.0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 16, 8),
        child: SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              maxY: effectiveMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (_, _, rod, _) => BarTooltipItem(
                    _currency(rod.toY),
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              barGroups: bars.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.amount,
                        color: AppColors.primary,
                        width: bars.length <= 4 ? 28 : 18,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(5)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: effectiveMax,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  )).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= bars.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(bars[idx].label,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value < 0) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          value >= 1000
                              ? 'R\$${(value / 1000).toStringAsFixed(1)}k'
                              : 'R\$${value.toInt()}',
                          style: const TextStyle(
                              fontSize: 9, color: Colors.black38),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList(List<_SessionEntry> sessions) {
    if (sessions.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Nenhuma sessão com paciente vinculado neste período.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: sessions.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final dateStr =
              '${s.date.day.toString().padLeft(2, '0')}/${s.date.month.toString().padLeft(2, '0')} · ${s.date.hour}:00';
          return Column(children: [
            ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor:
                    s.isSocial ? const Color(0xFF4A7A68) : AppColors.primary,
                child: Text(
                  s.patientName.isNotEmpty
                      ? s.patientName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(s.patientName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                '$dateStr · ${s.isSocial ? 'Social' : 'Integral'}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Text(_currency(s.value),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (i < sessions.length - 1)
              Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.shade100),
          ]);
        }).toList(),
      ),
    );
  }
}
