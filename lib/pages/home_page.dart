import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/patient.dart';
import 'package:psicoapp/pages/agenda_page.dart';
import 'package:psicoapp/pages/patients_page.dart';
import 'package:psicoapp/pages/reports_page.dart';
import 'package:psicoapp/pages/settings_page.dart';
import 'package:psicoapp/components/add_patient_modal.dart';
import 'package:psicoapp/services/patient_storage.dart';
import 'package:psicoapp/services/theme_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    primaryColorNotifier.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    primaryColorNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  Future<void> _loadPatients() async {
    final patients = await PatientStorage.loadPatients();
    setState(() => _patients = patients);
  }

  void _openAddPatientModal({Patient? patient}) async {
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddPatientModal(patient: patient),
    );

    if (result == null) return;

    if (result == 'delete') {
      setState(() => _patients.removeWhere((p) => p.id == patient!.id));
      await PatientStorage.deletePatient(patient!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente excluído!')),
      );
    } else if (result is Patient) {
      setState(() {
        final index = _patients.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _patients[index] = result;
        } else {
          _patients.add(result);
        }
      });
      await PatientStorage.savePatient(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.name} ${patient != null ? 'editado' : 'adicionado'}!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PatientsPage(
        onAddPatient: _openAddPatientModal,
        onEditPatient: (patient) => _openAddPatientModal(patient: patient),
        patients: _patients,
      ),
      AgendaPage(patients: _patients),
      const ReportsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          ['.Pacientes', '.Agenda', '.Relatórios', '.Configurações'][_currentIndex],
          style: const TextStyle(fontSize: 25),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.onPrimary,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Relatórios'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }
}
