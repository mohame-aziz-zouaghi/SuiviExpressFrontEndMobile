// lib/models/review_model.dart

class Review {
  final int? id; // Local SQLite id or backend id
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final int productId;
  final int userId;
  bool synced; // <-- track if synced with backend

  Review({
    this.id,
    required this.rating,
    required this.comment,
    required this.productId,
    required this.userId,
    this.createdAt,
    this.synced = false, // default false for new offline reviews
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      productId: json['productId'] as int,
      userId: json['userId'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      synced: (json['is_synced'] as int? ?? 0) == 1, // handle local DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'productId': productId,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'is_synced': synced ? 1 : 0,
    };
  }
}
