import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:suiviexpress_app/config/api_config.dart';
import 'package:suiviexpress_app/data/models/user.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';

class UserService {
  final String baseUrl = "${ApiConfig.baseUrl}/users";

  // ✅ Get single user by ID
  Future<User> getUserById(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to load user: ${response.body}");
    }
  }

  // ✅ Update user info
  Future<User> updateUser(String id, User user) async {
    final token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to update user: ${response.body}");
    }
  }
}
