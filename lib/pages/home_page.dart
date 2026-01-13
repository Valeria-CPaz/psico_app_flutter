import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/pages/agenda_page.dart';
import 'package:psicoapp/pages/patients_page.dart';
import 'package:psicoapp/pages/reports_page.dart';
import 'package:psicoapp/pages/settings_page.dart';
import 'package:psicoapp/components/add_patient_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _openAddPatientModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddPatientModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PatientsPage(onAddPatient: _openAddPatientModal),
      AgendaPage(),
      ReportsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          ['Pacientes', 'Agenda', 'Relatórios', 'Configurações'][_currentIndex],
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Se não mudar isso, ele não vê o background color
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.onPrimary,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Pacientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
