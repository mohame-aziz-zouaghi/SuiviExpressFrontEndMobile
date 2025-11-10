import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:suiviexpress_app/config/api_config.dart';
import '../models/product_model.dart';
import '../services/token_storage.dart'; // make sure this is your correct import

class ProductService {
  final String baseUrl = "${ApiConfig.baseUrl}/products";

  Future<List<Product>> getVisibleProducts() async {
    // Retrieve the stored token
    final token = await TokenStorage.getToken(); // returns the JWT token as String

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final response = await http.get(
      Uri.parse("$baseUrl/visible"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load products: ${response.body}");
    }
  }


   Future<Product> createProduct(Product product) async {
    final token = await TokenStorage.getToken();

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception("Failed to create product: ${response.body}");
    }
  }
}


