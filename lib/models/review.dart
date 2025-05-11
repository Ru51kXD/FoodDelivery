import 'package:flutter/material.dart';

enum ReviewType {
  restaurant,
  dish,
}

class Review {
  final String id;
  final String userId;
  final String itemId;
  final ReviewType type;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
  final String? userName;
  final String? userAvatarUrl;
  final bool isVerified;
  final int likes;
  final bool isLiked;

  Review({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
    this.userName,
    this.userAvatarUrl,
    this.isVerified = false,
    this.likes = 0,
    this.isLiked = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      itemId: json['itemId'],
      type: ReviewType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => ReviewType.restaurant,
      ),
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      isVerified: json['isVerified'] ?? false,
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'type': type.toString().split('.').last,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'isVerified': isVerified,
      'likes': likes,
      'isLiked': isLiked,
    };
  }

  // Получение текста рейтинга
  String get ratingText {
    if (rating >= 4.5) return 'Отлично';
    if (rating >= 4.0) return 'Очень хорошо';
    if (rating >= 3.5) return 'Хорошо';
    if (rating >= 3.0) return 'Нормально';
    if (rating >= 2.0) return 'Плохо';
    return 'Очень плохо';
  }

  // Получение цвета рейтинга
  Color get ratingColor {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.amber;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }
} 