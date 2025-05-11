import 'package:flutter/material.dart';
import '../models/promotion.dart';
import 'promotion_card.dart';

class PromotionsList extends StatelessWidget {
  final List<Promotion> promotions;
  final Function(Promotion) onPromotionTap;

  const PromotionsList({
    Key? key,
    required this.promotions,
    required this.onPromotionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPromotions = promotions.where((p) => p.isCurrent).toList();
    final upcomingPromotions = promotions.where((p) => p.isUpcoming).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (currentPromotions.isNotEmpty) ...[
          _buildSectionTitle(context, 'Текущие акции'),
          const SizedBox(height: 16),
          ...currentPromotions.map((promotion) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PromotionCard(
                  promotion: promotion,
                  onTap: () => onPromotionTap(promotion),
                ),
              )),
        ],
        if (upcomingPromotions.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Скоро'),
          const SizedBox(height: 16),
          ...upcomingPromotions.map((promotion) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PromotionCard(
                  promotion: promotion,
                  onTap: () => onPromotionTap(promotion),
                ),
              )),
        ],
        if (currentPromotions.isEmpty && upcomingPromotions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет доступных акций',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
} 