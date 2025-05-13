import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/promotion.dart';

class PromotionsScreen extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionsScreen({
    Key? key,
    required this.promotions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPromotions = promotions.where((p) => p.isCurrent).toList();
    final upcomingPromotions = promotions.where((p) => p.isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Акции и предложения',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (currentPromotions.isNotEmpty) ...[
            Text(
              'Текущие акции',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...currentPromotions.map((promotion) {
              return _buildPromotionCard(context, promotion);
            }),
            const SizedBox(height: 24),
          ],
          if (upcomingPromotions.isNotEmpty) ...[
            Text(
              'Скоро',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...upcomingPromotions.map((promotion) {
              return _buildPromotionCard(context, promotion);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, Promotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Навигация к деталям акции
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (promotion.imageUrl != null)
              Image.network(
                promotion.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: promotion.getTypeColor().withOpacity(0.1),
                    child: Icon(
                      promotion.getTypeIcon(),
                      size: 64,
                      color: promotion.getTypeColor(),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: promotion.getTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              promotion.getTypeIcon(),
                              size: 16,
                              color: promotion.getTypeColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              promotion.getTypeName(),
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: promotion.getTypeColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (promotion.discountPercent != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${promotion.discountPercent!.toInt()}%',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    promotion.title,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promotion.description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (promotion.minOrderAmount != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Минимальная сумма заказа: ${promotion.minOrderAmount!.toInt()} ₸',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (promotion.promoCode != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            promotion.promoCode!,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: () {
                              // TODO: Копирование промокода
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Действует до ${_formatDate(promotion.endDate)}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
} 