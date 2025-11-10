import 'dart:convert';

import 'package:dio/dio.dart' as http;
import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/product_model.dart';
import 'package:suiviexpress_app/data/models/review_model.dart';
import 'package:suiviexpress_app/data/services/review_service.dart';
import 'package:suiviexpress_app/data/services/token_storage.dart';
import 'package:suiviexpress_app/data/services/user_service.dart';
import 'package:suiviexpress_app/database/database_helper.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/order/OrderPage.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  const ProductDetailsPage({required this.product, super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ReviewService _reviewService = ReviewService();
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Review> _reviews = [];
  bool _loadingReviews = true;
  int? _currentUserId;
  String? _currentUsername;
  Map<int, String> _reviewUsernames = {}; // review.userId -> username
  Map<int, bool> _editingReview = {}; // reviewId -> isEditing
  Map<int, TextEditingController> _updateControllers =
      {}; // reviewId -> controller

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadReviews();
  }

  Future<void> _loadUserId() async {
    final userIdStr = await TokenStorage.getuserId();
    if (userIdStr != null) {
      final id = int.tryParse(userIdStr);
      if (id != null) {
        setState(() {
          _currentUserId = id;
        });

        // Load current username using UserService
        try {
          final user = await UserService().getUserById(id);
          setState(() {
            _currentUsername = user.username;
          });
        } catch (e) {
          print("Failed to load current username: $e");
        }
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await _reviewService.getReviewsByProduct(
        widget.product.id!,
      );

      // Load username for each review
      for (var r in reviews) {
        if (!_reviewUsernames.containsKey(r.userId)) {
          try {
            final user = await UserService().getUserById(r.userId);
            _reviewUsernames[r.userId] = user.username;
          } catch (e) {
            _reviewUsernames[r.userId] = "User ${r.userId}";
          }
        }
      }

      setState(() {
        _reviews = reviews;
        _loadingReviews = false;
      });
    } catch (e) {
      setState(() => _loadingReviews = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load reviews: $e")));
    }
  }

Future<void> _submitReview() async {
  if (_rating == 0 || _commentController.text.trim().isEmpty) return;
  if (_currentUserId == null) return;

  final review = Review(
    rating: _rating.toInt(),
    comment: _commentController.text.trim(),
    productId: widget.product.id!,
    userId: _currentUserId!,
  );

  try {
    // Try online submission
    final createdReview = await _reviewService.createReview(
      widget.product.id!,
      _currentUserId!,
      review,
    );

    // Online success → update local DB (mark as synced)
    await DatabaseHelper().insertReview(createdReview);
    await DatabaseHelper().markReviewAsSynced(createdReview.id!);

    _commentController.clear();
    setState(() => _rating = 0);
    await _loadReviews();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Review submitted successfully!")),
    );
  } catch (e) {
    // Offline or API error → store review locally
    await DatabaseHelper().insertReview(review);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⚠️ Offline: Review saved locally. Will sync later."),
      ),
    );
  }
}


  Future<void> _updateReview(Review review) async {
    final controller = _updateControllers[review.id]!;
    if (controller.text.trim().isEmpty) return;

    final updatedReview = Review(
      rating: review.rating,
      comment: controller.text.trim(),
      productId: review.productId,
      userId: review.userId,
    );

    try {
      await _reviewService.updateReview(
        review.id!,
        review.productId,
        review.userId,
        updatedReview,
      );
      setState(() => _editingReview[review.id!] = false);
      await _loadReviews(); // reload reviews after update
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update review: $e")));
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _reviewService.deleteReview(review.id!, review.userId);
      await _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete review: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(product.brand),
                  backgroundColor: Colors.indigo.shade50,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(product.category),
                  backgroundColor: Colors.indigo.shade50,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${product.averageRating.toStringAsFixed(1)} (${product.reviewCount} reviews)",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (product.discount > 0)
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (product.discount > 0) const SizedBox(width: 8),
                Text(
                  "\$${(product.price - product.discount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.stockQuantity > 0
                  ? "In Stock: ${product.stockQuantity}"
                  : "Out of Stock",
              style: TextStyle(
                fontSize: 14,
                color: product.stockQuantity > 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Customer Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _loadingReviews
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                ? const Text("No reviews yet")
                : SizedBox(
                    height: 300, // fixed height for scrollable reviews
                    child: ListView.builder(
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final r = _reviews[index];
                        _updateControllers[r.id!] ??= TextEditingController(
                          text: r.comment,
                        );
                        final isEditing = _editingReview[r.id!] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Text(
                              _reviewUsernames[r.userId] ?? "User ${r.userId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < r.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                isEditing
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Update Rating",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                          // ⭐ Editable rating stars
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    final updated = Review(
                                                      id: r.id,
                                                      rating: index + 1,
                                                      comment: r.comment,
                                                      productId: r.productId,
                                                      userId: r.userId,
                                                      createdAt: r.createdAt,
                                                    );
                                                    final reviewIndex = _reviews
                                                        .indexWhere(
                                                          (rev) =>
                                                              rev.id == r.id,
                                                        );
                                                    if (reviewIndex != -1)
                                                      _reviews[reviewIndex] =
                                                          updated;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 2.0,
                                                      ),
                                                  child: Icon(
                                                    index < r.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 8),
                                          TextField(
                                            controller:
                                                _updateControllers[r.id!],
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Update your comment...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 8),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    _updateReview(r),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.indigo,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                label: const Text(
                                                  "Update",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  setState(() {
                                                    _editingReview[r.id!] =
                                                        false;
                                                    _updateControllers[r.id!]!
                                                            .text =
                                                        r.comment;
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                        255,
                                                        212,
                                                        209,
                                                        209,
                                                      ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 8,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.black54,
                                                  size: 18,
                                                ),
                                                label: const Text("Cancel"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Text(r.comment),

                                const SizedBox(height: 4),
                                Text(
                                  r.createdAt != null
                                      ? r.createdAt.toString().split(' ')[0]
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing:
                                _currentUserId != null &&
                                    _currentUserId == r.userId
                                ? PopupMenuButton(
                                    icon: const Icon(Icons.more_horiz),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'update',
                                        child: Text('Update'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'update') {
                                        setState(
                                          () => _editingReview[r.id!] =
                                              !isEditing,
                                        );
                                      } else if (value == 'delete') {
                                        _deleteReview(r);
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),

            const Divider(height: 24),
            const Text(
              "Write a Review",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1.0),
                ),
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Write your comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Submit Review",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: _submitReview,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: product.stockQuantity > 0
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderPage(product: product),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Add to Cart",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
