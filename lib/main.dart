import 'package:flutter/material.dart';
import 'package:suiviexpress_app/presentation/pages/auth/login_page.dart';
import 'package:suiviexpress_app/presentation/pages/auth/register_page.dart';
void main() {
  runApp(const SuiviExpressApp());
}

class SuiviExpressApp extends StatelessWidget {
  const SuiviExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiviExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
