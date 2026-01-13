import 'package:flutter/material.dart';
import 'package:psicoapp/constants/app_colors.dart';

class PatientsPage extends StatelessWidget {
  final VoidCallback onAddPatient;
  
  const PatientsPage({super.key, required this.onAddPatient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nome',
              prefixIcon: const Icon(Icons.search),
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
            onPressed: onAddPatient,
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
          const Text('Lista de pacientes vai aparecer aqui'),
        ],
      ),
    );
  }
}
