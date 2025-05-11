import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onTap;

  const PromotionCard({
    Key? key,
    required this.promotion,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: promotion.imageUrl != null
                      ? Image.network(
                          promotion.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: promotion.type.getColor().withOpacity(0.1),
                              child: Icon(
                                promotion.type.getIcon(),
                                size: 48,
                                color: promotion.type.getColor(),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: promotion.type.getColor().withOpacity(0.1),
                          child: Icon(
                            promotion.type.getIcon(),
                            size: 48,
                            color: promotion.type.getColor(),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: promotion.type.getColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      promotion.type.getName(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (promotion.minOrderAmount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Минимальная сумма заказа: ${promotion.minOrderAmount} ₽',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: promotion.type.getColor(),
                      ),
                    ),
                  ],
                  if (promotion.promoCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: promotion.type.getColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              promotion.promoCode!,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: promotion.type.getColor(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // TODO: Implement copy to clipboard
                          },
                          tooltip: 'Копировать промокод',
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Действует до ${promotion.endDate.day}.${promotion.endDate.month}.${promotion.endDate.year}',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 