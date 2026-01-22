import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/patient.dart';
import 'package:psicoapp/utils/phone_formatter.dart';

class PatientsPage extends StatefulWidget {
  final VoidCallback onAddPatient;
  final Function(Patient) onEditPatient;
  final List<Patient> patients;

  const PatientsPage({
    super.key,
    required this.onAddPatient,
    required this.onEditPatient,
    required this.patients,
  });

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filtro
    List<Patient> filteredPatients = widget.patients
        .where(
          (patient) =>
              patient.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar por nome',
              hintStyle: TextStyle(color: AppColors.primaryDark),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryDark,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.primaryDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onAddPatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1_sharp, size: 25),
                SizedBox(width: 8),
                Text('Adicionar Paciente', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.primary.withAlpha(40),
                  elevation: 0,
                  child: ListTile(
                    title: Text(patient.name),
                    subtitle: Text(
                      patient.isSocial
                          ? 'Social 💸: R\$${patient.socialValue?.toStringAsFixed(2) ?? '0'}'
                          : 'Integral 💰',
                    ),
                    trailing: patient.phone != null
                        ? Text(formatPhoneNumber(patient.phone!))
                        : null,
                    onTap: () => widget.onEditPatient(patient),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
