import 'dart:io';
import 'package:suiviexpress_app/database/database_helper.dart';
import 'package:suiviexpress_app/data/models/review_model.dart';
import 'package:suiviexpress_app/data/services/review_service.dart';

class ReviewSyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ReviewService _reviewService = ReviewService();

  /// Try to sync unsynced reviews to the remote server
  Future<void> syncReviews() async {
    try {
      // Check network first
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        print('⚠️ No internet connection. Skipping sync.');
        return;
      }

      // Get all local reviews not yet synced
      final unsyncedReviews = await _dbHelper.getUnsyncedReviews();

      if (unsyncedReviews.isEmpty) {
        print('✅ No unsynced reviews found.');
        return;
      }

      print('🔁 Syncing ${unsyncedReviews.length} reviews...');

      for (var review in unsyncedReviews) {
        try {
          // Send to backend
          final created = await _reviewService.createReview(
            review.productId,
            review.userId,
            review,
          );

          // Mark as synced locally if successful
          await _dbHelper.markReviewAsSynced(review.id!);

          print('✅ Synced review ID ${created.id}');
        } catch (e) {
          print('❌ Failed to sync review (product: ${review.productId}): $e');
        }
      }
    } catch (e) {
      print('❌ Error during sync: $e');
    }
  }

  /// Simple connectivity check (optional: replace with `connectivity_plus`)
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
