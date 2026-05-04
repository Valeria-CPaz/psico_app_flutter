import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:psicoapp/pages/home_page.dart';
import 'package:psicoapp/pages/login_page.dart';
import 'package:psicoapp/pages/setup_page.dart';
import 'package:psicoapp/services/auth_service.dart';
import 'package:psicoapp/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await loadTheme();

  final Widget startPage;
  if (!await AuthService.hasAccount) {
    startPage = const SetupPage();
  } else if (!await AuthService.isSessionActive) {
    startPage = const LoginPage();
  } else {
    startPage = const HomePage();
  }

  runApp(MyApp(home: startPage));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
