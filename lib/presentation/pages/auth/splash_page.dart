import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:suiviexpress_app/presentation/pages/auth/login_page.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/home/main_home_page.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
      // Valid token -> go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainHomePage()),
      );
    } else {
      // No token or expired -> go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
