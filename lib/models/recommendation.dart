import 'package:flutter/material.dart';
import 'dish.dart';

enum RecommendationType {
  popular,      // популярные блюда
  similar,      // похожие блюда
  dietary,      // по диетическим предпочтениям
  seasonal,     // сезонные блюда
  personalized, // персонализированные рекомендации
}

class Recommendation {
  final String id;
  final Dish dish;
  final RecommendationType type;
  final double score;
  final String reason;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.dish,
    required this.type,
    required this.score,
    required this.reason,
    required this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
      type: RecommendationType.values.firstWhere(
        (e) => e.toString() == 'RecommendationType.${json['type']}',
      ),
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish': dish.toJson(),
      'type': type.toString().split('.').last,
      'score': score,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Color getTypeColor() {
    switch (type) {
      case RecommendationType.popular:
        return Colors.blue;
      case RecommendationType.similar:
        return Colors.purple;
      case RecommendationType.dietary:
        return Colors.green;
      case RecommendationType.seasonal:
        return Colors.orange;
      case RecommendationType.personalized:
        return Colors.teal;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case RecommendationType.popular:
        return Icons.trending_up;
      case RecommendationType.similar:
        return Icons.compare_arrows;
      case RecommendationType.dietary:
        return Icons.restaurant_menu;
      case RecommendationType.seasonal:
        return Icons.wb_sunny;
      case RecommendationType.personalized:
        return Icons.person;
    }
  }

  String getTypeName() {
    switch (type) {
      case RecommendationType.popular:
        return 'Популярное';
      case RecommendationType.similar:
        return 'Похожее';
      case RecommendationType.dietary:
        return 'Диетическое';
      case RecommendationType.seasonal:
        return 'Сезонное';
      case RecommendationType.personalized:
        return 'Для вас';
    }
  }
} 