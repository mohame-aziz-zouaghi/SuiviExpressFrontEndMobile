// lib/services/review_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:suiviexpress_app/config/api_config.dart';
import 'package:suiviexpress_app/data/models/review_model.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';

class ReviewService {
  final String baseUrl = "${ApiConfig.baseUrl}/reviews";

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 🔹 Get all reviews
  Future<List<Review>> getAllReviews() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load reviews");
    }
  }

  // 🔹 Get reviews by product
  Future<List<Review>> getReviewsByProduct(int productId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/product/$productId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load product reviews");
    }
  }

  // 🔹 Get reviews by user
  Future<List<Review>> getReviewsByUser(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load user reviews");
    }
  }

  // 🔹 Create a review
  Future<Review> createReview(int productId, int userId, Review review) async {
    final headers = await _getAuthHeaders();
    final body = jsonEncode(review.toJson());
    final response = await http.post(
      Uri.parse('$baseUrl/user/$userId/product/$productId'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create review");
    }
  }

  // 🔹 Update a review
  Future<Review> updateReview(
    int id,
    int productId,
    int userId,
    Review updatedReview,
  ) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/user/$userId/product/$productId'),
      headers: headers,
      body: jsonEncode(updatedReview.toJson()),
    );

    if (response.statusCode == 200) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update review");
    }
  }

  // 🔹 Delete a review
  Future<void> deleteReview(int id,int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id/user/$userId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete review");
    }
  }
}
