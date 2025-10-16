import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SuiviExpress")),
      body: Center(
        child: Text("Welcome back, $username!", style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
