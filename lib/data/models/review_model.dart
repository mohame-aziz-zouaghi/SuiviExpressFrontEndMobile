// lib/models/review_model.dart

class Review {
  final int? id;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final int productId;
  final int userId;

  Review({
    this.id,
    required this.rating,
    required this.comment,
    required this.productId,
    required this.userId,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      productId: json['productId'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rating': rating,
      'comment': comment,
      'productId': productId,
      'userId': userId,
    };
  }
}
