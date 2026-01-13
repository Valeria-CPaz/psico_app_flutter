import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';

class AddPatientModal extends StatefulWidget {
  const AddPatientModal({super.key});

  @override
  State<AddPatientModal> createState() => _AddPatientModalState();
}

class _AddPatientModalState extends State<AddPatientModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSocial = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            const Text(
              'Novo Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Plano social ?'),
                const SizedBox(width: 8),
                Switch(
                  value: _isSocial,
                  onChanged: (value) {
                    setState(() {
                      _isSocial = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final patient = Patient(
                    id: const Uuid().v4(),
                    name: _nameController.text.trim(),
                    phone: _phoneController.text.trim().isNotEmpty
                        ? _phoneController.text.trim()
                        : null,
                    isSocial: _isSocial,
                  );
                }
              },
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
