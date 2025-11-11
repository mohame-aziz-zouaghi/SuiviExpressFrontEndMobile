import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';
import '../../../data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String usernameOrEmail = '';
  String password = '';
  bool rememberMe = false;
  bool loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);


  try {
    final response = await _authService.login(usernameOrEmail, password, rememberMe);

    final token = response.token;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    // Example payload: {sub: "123", username: "lucifer", role: "ADMIN"}
    final userId = decodedToken['userId']?.toString() ?? '';
    final username = decodedToken['sub'] ?? '';
    final role = decodedToken['role'] ?? '';
    print( "userId :" + userId +"\n" + " " + "username :" + username + "\n" + " " + "role :" +role  + rememberMe.toString());

    // ✅ Store token and decoded info
    await TokenStorage.saveAuthData(token, username, role, userId);

    // Navigate to home
Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Login failed: $e")));
  } finally {
    setState(() => loading = false);
  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("SuiviExpress Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Username or Email"),
                  onChanged: (v) => usernameOrEmail = v,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  onChanged: (v) => password = v,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                Row(
                  children: [
                    Checkbox(value: rememberMe, onChanged: (v) => setState(() => rememberMe = v!)),
                    const Text("Remember me"),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : _login,
                  child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login"),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Don’t have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
