import 'package:flutter/material.dart';
import '../models/loyalty_program.dart';
import '../models/promo_code.dart';
import '../models/order.dart';

class LoyaltyService {
  // Получение информации о программе лояльности пользователя
  Future<LoyaltyProgram> getUserLoyaltyProgram(String userId) async {
    // TODO: Реализовать получение данных из API
    // Временная заглушка для демонстрации
    return LoyaltyProgram(
      userId: userId,
      points: 750,
      tier: LoyaltyTier.bronze,
      availableRewards: [
        LoyaltyReward(
          id: '1',
          title: 'Бесплатная доставка',
          description: 'Бесплатная доставка для следующего заказа',
          pointsCost: 500,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(days: 30)),
        ),
        LoyaltyReward(
          id: '2',
          title: 'Скидка 10%',
          description: 'Скидка 10% на следующий заказ',
          pointsCost: 1000,
          validFrom: DateTime.now(),
          validUntil: DateTime.now().add(const Duration(days: 30)),
        ),
      ],
      usedRewards: [],
      lastPointsUpdate: DateTime.now(),
      totalPointsEarned: 1000,
      totalPointsSpent: 250,
    );
  }

  // Получение доступных промокодов
  Future<List<PromoCode>> getAvailablePromoCodes() async {
    // TODO: Реализовать получение данных из API
    // Временная заглушка для демонстрации
    return [
      PromoCode(
        code: 'WELCOME10',
        description: 'Скидка 10% на первый заказ',
        type: PromoCodeType.percentage,
        value: 10,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 30)),
        minOrderAmount: 1000,
      ),
      PromoCode(
        code: 'FREEDEL',
        description: 'Бесплатная доставка',
        type: PromoCodeType.freeDelivery,
        value: 0,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 7)),
        minOrderAmount: 2000,
      ),
    ];
  }

  // Проверка и применение промокода
  Future<PromoCode?> validateAndApplyPromoCode(String code, double orderAmount) async {
    final promoCodes = await getAvailablePromoCodes();
    final promoCode = promoCodes.firstWhere(
      (promo) => promo.code == code,
      orElse: () => throw Exception('Промокод не найден'),
    );

    if (!promoCode.isValid(DateTime.now(), orderAmount)) {
      throw Exception('Промокод недействителен');
    }

    return promoCode;
  }

  // Начисление бонусных баллов за заказ
  Future<void> addPointsForOrder(String userId, Order order) async {
    final loyaltyProgram = await getUserLoyaltyProgram(userId);
    final pointsToAdd = calculatePointsForOrder(order, loyaltyProgram.tier);
    
    // TODO: Реализовать обновление баллов в API
    print('Начислено $pointsToAdd баллов за заказ ${order.id}');
  }

  // Расчет бонусных баллов за заказ
  int calculatePointsForOrder(Order order, LoyaltyTier tier) {
    double pointsMultiplier;
    switch (tier) {
      case LoyaltyTier.bronze:
        pointsMultiplier = 0.01; // 1%
        break;
      case LoyaltyTier.silver:
        pointsMultiplier = 0.02; // 2%
        break;
      case LoyaltyTier.gold:
        pointsMultiplier = 0.03; // 3%
        break;
      case LoyaltyTier.platinum:
        pointsMultiplier = 0.05; // 5%
        break;
    }

    return (order.totalAmount * pointsMultiplier).round();
  }

  // Использование награды из программы лояльности
  Future<void> useLoyaltyReward(String userId, String rewardId, String orderId) async {
    final loyaltyProgram = await getUserLoyaltyProgram(userId);
    final reward = loyaltyProgram.availableRewards.firstWhere(
      (reward) => reward.id == rewardId,
      orElse: () => throw Exception('Награда не найдена'),
    );

    if (!reward.isValid) {
      throw Exception('Награда недействительна');
    }

    if (loyaltyProgram.points < reward.pointsCost) {
      throw Exception('Недостаточно баллов');
    }

    // TODO: Реализовать использование награды в API
    print('Использована награда ${reward.id} в заказе $orderId');
  }

  // Получение истории наград
  Future<List<LoyaltyReward>> getRewardHistory(String userId) async {
    final loyaltyProgram = await getUserLoyaltyProgram(userId);
    return loyaltyProgram.usedRewards;
  }

  // Получение доступных наград
  Future<List<LoyaltyReward>> getAvailableRewards(String userId) async {
    final loyaltyProgram = await getUserLoyaltyProgram(userId);
    return loyaltyProgram.availableRewards.where((reward) => reward.isValid).toList();
  }
} 