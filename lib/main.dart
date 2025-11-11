import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/services/sync_service.dart';
import 'package:suiviexpress_app/presentation/pages/auth/login_page.dart';
import 'package:suiviexpress_app/presentation/pages/auth/register_page.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/home/main_home_page.dart';
import 'package:suiviexpress_app/presentation/pages/auth/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Start listening to connectivity and auto-sync changes
  SyncManager().startListening();

  runApp(const SuiviExpressApp());
}

class SuiviExpressApp extends StatelessWidget {
  const SuiviExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiviExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainHomePage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
