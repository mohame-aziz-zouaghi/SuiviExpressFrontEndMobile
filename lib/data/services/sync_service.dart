import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:suiviexpress_app/data/services/auth_service.dart';
import 'package:suiviexpress_app/data/services/product_service.dart';
import 'package:suiviexpress_app/data/services/review_service.dart';
import 'package:suiviexpress_app/database/database_helper.dart';

/// Handles automatic offline → online synchronization.
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final ReviewService _reviewService = ReviewService();

  /// Starts listening to connectivity changes.
  void startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (hasConnection) {
        print("📶 Internet connection detected. Starting synchronization...");
        await syncAll();
      } else {
        print("🚫 No internet connection.");
      }
    });
  }

  /// Stops listening to connectivity changes.
  void stopListening() {
    _subscription?.cancel();
  }

  /// Synchronizes all data types in correct order: Users → Products → Reviews.
  Future<void> syncAll() async {
    try {
      await _syncUsers();
      await _syncProducts();
      await _syncReviews();
      print("✅ All data synchronized successfully!");
    } catch (e) {
      print("❌ Sync failed: $e");
    }
  }

  // ====================== USERS SYNC ======================
  Future<void> _syncUsers() async {
    print("🔁 Syncing unsynced users...");
    final unsyncedUsers = await _dbHelper.getUnsyncedUsers();
    for (final user in unsyncedUsers) {
      try {
        await _authService.register(
          user.username,
          user.email,
          user.password ?? '',
          user.firstName,
          user.lastName,
          user.phone ?? '',
          user.address ?? '',
        );
        await _dbHelper.markUserAsSynced(user.id);
        print("✅ Synced user: ${user.username}");
      } catch (e) {
        print("⚠️ Failed to sync user ${user.username}: $e");
      }
    }
  }

  // ====================== PRODUCTS SYNC ======================
  Future<void> _syncProducts() async {
    print("🔁 Syncing unsynced products...");
    final unsyncedProducts = await _dbHelper.getUnsyncedProducts();
    for (final product in unsyncedProducts) {
      try {
        await _productService.createProduct(product);
        await _dbHelper.markProductAsSynced(product.id!);
        print("✅ Synced product: ${product.name}");
      } catch (e) {
        print("⚠️ Failed to sync product ${product.name}: $e");
      }
    }
  }

  // ====================== REVIEWS SYNC ======================
  Future<void> _syncReviews() async {
    print("🔁 Syncing unsynced reviews...");
    final unsyncedReviews = await _dbHelper.getUnsyncedReviews();
    for (final review in unsyncedReviews) {
      try {
        await _reviewService.createReview(
          review.productId,
          review.userId,
          review,
        );
        await _dbHelper.markReviewAsSynced(review.id!);
        print("✅ Synced review ID: ${review.id}");
      } catch (e) {
        print("⚠️ Failed to sync review ID ${review.id}: $e");
      }
    }
  }
}
