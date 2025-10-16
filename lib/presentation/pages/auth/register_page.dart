import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String username = '', email = '', password = '', firstName = '', lastName = '',phone='',address='';
  bool loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _authService.register(username, email, password, firstName, lastName,phone,address);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration successful")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
              TextFormField(decoration: const InputDecoration(labelText: "Username"), onChanged: (v) => username = v),
              TextFormField(decoration: const InputDecoration(labelText: "Email"), onChanged: (v) => email = v),
              TextFormField(decoration: const InputDecoration(labelText: "First Name"), onChanged: (v) => firstName = v),
              TextFormField(decoration: const InputDecoration(labelText: "Last Name"), onChanged: (v) => lastName = v),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (v) => password = v,
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
