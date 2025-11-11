import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../models/auth_response.dart';

class AuthService {
  final String baseUrl = "${ApiConfig.baseUrl}/auth";

Future<AuthResponse> login(String usernameOrEmail, String password, bool rememberMe) async {
  final uri = Uri.parse("$baseUrl/login").replace(
    queryParameters: {
      'rememberMe': rememberMe.toString(), // send as query parameter
    },
  );

  final response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "usernameOrEmail": usernameOrEmail,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return AuthResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to login: ${response.body}");
  }
}


  Future<void> register(String username, String email, String password, String firstName, String lastName, String phone, String address) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "phone":phone,
        "address":address,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to register: ${response.body}");
    }
  }
}
