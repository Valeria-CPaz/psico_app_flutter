import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:psicoapp/constants/app_colors.dart';
import 'package:psicoapp/models/patient.dart';
import 'package:psicoapp/utils/phone_formatter.dart';

class AddPatientModal extends StatefulWidget {
  final Patient? patient;

  const AddPatientModal({super.key, this.patient});

  @override
  State<AddPatientModal> createState() => _AddPatientModalState();
}

class _AddPatientModalState extends State<AddPatientModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _socialValueController = TextEditingController();
  bool _isSocial = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name;
      if (widget.patient!.phone != null) {
        _phoneController.text = formatPhoneNumber(widget.patient!.phone!);
      }
      _isSocial = widget.patient!.isSocial;
      if (widget.patient!.socialValue != null) {
        _socialValueController.text = widget.patient!.socialValue.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withAlpha(230),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Novo Paciente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome *',
                  labelStyle: TextStyle(color: AppColors.primaryDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryDark),
                  ),
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
                onChanged: (value) {
                  final raw = value.replaceAll(RegExp(r'\D'), '');
                  final formatted = formatPhoneNumber(raw);
                  if (formatted != value) {
                    _phoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Telefone (opcional)',
                  labelStyle: TextStyle(color: AppColors.primaryDark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Plano Social ?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isSocial,
                    activeThumbColor: AppColors.onPrimary,
                    activeTrackColor: AppColors.primary.withAlpha(240),
                    inactiveThumbColor: AppColors.onPrimary,
                    inactiveTrackColor: AppColors.primary.withAlpha(240),
                    thumbColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.onPrimary;
                      }
                      return AppColors.onPrimary;
                    }),
                    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return AppColors.primaryLight;
                    }),
                    onChanged: (value) {
                      setState(() {
                        _isSocial = value;
                      });
                    },
                  ),
                ],
              ),
              if (_isSocial) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _socialValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    labelStyle: TextStyle(color: AppColors.primaryDark),
                    hintText: 'Ex: 110',
                    hintStyle: TextStyle(color: AppColors.primaryDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primaryDark),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Valor é obrigatório para plano social';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Digite um número válido';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    double? socialValue;
                    if (_isSocial) {
                      socialValue = double.parse(_socialValueController.text);
                    }

                    final patient = Patient(
                      id: const Uuid().v4(),
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim().isNotEmpty
                          ? _phoneController.text.replaceAll(
                              RegExp(r'\D'),
                              '',
                            ) // Só digitos
                          : null,
                      isSocial: _isSocial,
                      socialValue: socialValue,
                    );

                    Navigator.pop(context, patient);
                  }
                },
                child: Text(
                  widget.patient == null ? 'Salvar' : 'Salvar Alterações',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (widget.patient != null) ...[
                const SizedBox(height: 5),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.pop(context, 'delete');
                  },
                  child: const Text(
                    'Deletar Paciente',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
