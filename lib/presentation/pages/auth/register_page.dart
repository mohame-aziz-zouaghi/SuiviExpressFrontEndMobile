import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/user.dart';
import '../../../database/database_helper.dart';
import '../../../data/services/auth_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String username = '',
      email = '',
      password = '',
      firstName = '',
      lastName = '',
      phone = '',
      address = '';
  bool loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    // Create user object
    final user = User(
      id: 0,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone.isEmpty ? null : phone,
      address: address.isEmpty ? null : address,
      profileImageUrl: null,
      role: "USER",
      enabled: true,
      locked: false,
      password: password,
    );

    try {
  print("🛰 Checking connectivity...");
  final connectivity = await Connectivity().checkConnectivity();
  print("✅ Connectivity result: $connectivity");

  if (connectivity != ConnectivityResult.none) {
    print("📴 Offline mode detected — saving locally...");
    await DatabaseHelper().insertUser(user, synced: false);
    print("✅ User saved locally!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⚠️ No internet. User saved locally.")),
    );
  } else {
    print("🌐 Online mode detected — calling API...");
    await _authService.register(
      username,
      email,
      password,
      firstName,
      lastName,
      phone,
      address,
    );
    print("✅ Registration successful!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Registration successful")),
    );
  }

  Navigator.pop(context);
} catch (e, stacktrace) {
  print("❌ ERROR: $e");
  print("🔍 STACKTRACE:\n$stacktrace");
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("Error: $e")));
} finally {
  setState(() => loading = false);
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                onChanged: (v) => username = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                onChanged: (v) => email = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "First Name"),
                onChanged: (v) => firstName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Last Name"),
                onChanged: (v) => lastName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (v) => password = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Phone"),
                onChanged: (v) => phone = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Address"),
                onChanged: (v) => address = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : _register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
