import 'package:flutter/material.dart';

enum LoyaltyTier {
  bronze,   // бронзовый
  silver,   // серебряный
  gold,     // золотой
  platinum, // платиновый
}

class LoyaltyProgram {
  final String userId;
  final int points;
  final LoyaltyTier tier;
  final List<LoyaltyReward> availableRewards;
  final List<LoyaltyReward> usedRewards;
  final DateTime lastPointsUpdate;
  final int totalPointsEarned;
  final int totalPointsSpent;

  LoyaltyProgram({
    required this.userId,
    required this.points,
    required this.tier,
    required this.availableRewards,
    required this.usedRewards,
    required this.lastPointsUpdate,
    required this.totalPointsEarned,
    required this.totalPointsSpent,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      userId: json['userId'],
      points: json['points'],
      tier: LoyaltyTier.values.firstWhere(
        (tier) => tier.toString().split('.').last == json['tier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      availableRewards: (json['availableRewards'] as List)
          .map((reward) => LoyaltyReward.fromJson(reward))
          .toList(),
      usedRewards: (json['usedRewards'] as List)
          .map((reward) => LoyaltyReward.fromJson(reward))
          .toList(),
      lastPointsUpdate: DateTime.parse(json['lastPointsUpdate']),
      totalPointsEarned: json['totalPointsEarned'],
      totalPointsSpent: json['totalPointsSpent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'points': points,
      'tier': tier.toString().split('.').last,
      'availableRewards': availableRewards.map((reward) => reward.toJson()).toList(),
      'usedRewards': usedRewards.map((reward) => reward.toJson()).toList(),
      'lastPointsUpdate': lastPointsUpdate.toIso8601String(),
      'totalPointsEarned': totalPointsEarned,
      'totalPointsSpent': totalPointsSpent,
    };
  }

  // Получение следующего уровня
  LoyaltyTier? get nextTier {
    switch (tier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null;
    }
  }

  // Получение необходимых очков для следующего уровня
  int get pointsToNextTier {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 1000 - points;
      case LoyaltyTier.silver:
        return 5000 - points;
      case LoyaltyTier.gold:
        return 10000 - points;
      case LoyaltyTier.platinum:
        return 0;
    }
  }

  // Получение процента прогресса к следующему уровню
  double get progressToNextTier {
    if (nextTier == null) return 1.0;
    
    int currentTierPoints = 0;
    int nextTierPoints = 0;
    
    switch (tier) {
      case LoyaltyTier.bronze:
        currentTierPoints = 0;
        nextTierPoints = 1000;
        break;
      case LoyaltyTier.silver:
        currentTierPoints = 1000;
        nextTierPoints = 5000;
        break;
      case LoyaltyTier.gold:
        currentTierPoints = 5000;
        nextTierPoints = 10000;
        break;
      case LoyaltyTier.platinum:
        return 1.0;
    }
    
    return (points - currentTierPoints) / (nextTierPoints - currentTierPoints);
  }

  // Получение текста уровня
  String get tierText {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Бронзовый';
      case LoyaltyTier.silver:
        return 'Серебряный';
      case LoyaltyTier.gold:
        return 'Золотой';
      case LoyaltyTier.platinum:
        return 'Платиновый';
    }
  }

  // Получение преимуществ текущего уровня
  List<String> get tierBenefits {
    switch (tier) {
      case LoyaltyTier.bronze:
        return [
          '1% кэшбэк бонусами',
          'Базовая поддержка',
        ];
      case LoyaltyTier.silver:
        return [
          '2% кэшбэк бонусами',
          'Приоритетная поддержка',
          'Бесплатная доставка от 2000₽',
        ];
      case LoyaltyTier.gold:
        return [
          '3% кэшбэк бонусами',
          'VIP поддержка',
          'Бесплатная доставка от 1500₽',
          'Персональные предложения',
        ];
      case LoyaltyTier.platinum:
        return [
          '5% кэшбэк бонусами',
          'Персональный менеджер',
          'Бесплатная доставка всегда',
          'Эксклюзивные предложения',
          'Приоритетная доставка',
        ];
    }
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isUsed;
  final DateTime? usedAt;
  final String? usedInOrderId;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.validFrom,
    required this.validUntil,
    this.isUsed = false,
    this.usedAt,
    this.usedInOrderId,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pointsCost: json['pointsCost'],
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      isUsed: json['isUsed'] ?? false,
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      usedInOrderId: json['usedInOrderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'isUsed': isUsed,
      'usedAt': usedAt?.toIso8601String(),
      'usedInOrderId': usedInOrderId,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return !isUsed && now.isAfter(validFrom) && now.isBefore(validUntil);
  }
} 