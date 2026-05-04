import 'package:flutter/material.dart';
import 'package:psicoapp/services/settings_storage.dart';

const defaultPrimaryColor = Color(0xFFA3961E);

final primaryColorNotifier = ValueNotifier<Color>(defaultPrimaryColor);

Future<void> loadTheme() async {
  primaryColorNotifier.value = await SettingsStorage.getPrimaryColor();
}
