import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/safe_image.dart';

class MinimalistRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  
  const MinimalistRestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Безопасное получение числовых значений
    final double rating = restaurant.rating != null && restaurant.rating!.isFinite ? restaurant.rating! : 0.0;
    final int deliveryTime = restaurant.deliveryTime != null && restaurant.deliveryTime!.isFinite ? restaurant.deliveryTime!.toInt() : 30;
    final double deliveryFee = restaurant.deliveryFee != null && restaurant.deliveryFee!.isFinite ? restaurant.deliveryFee! : 0.0;
    
    print("DEBUG: Building card for ${restaurant.name}");
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Изображение
              Container(
                width: double.infinity,
                height: 120,
                child: SafeImage(
                  imageUrl: restaurant.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.restaurant, color: Colors.grey[400], size: 48),
                    ),
                  ),
                ),
              ),
              
              // Информация о ресторане
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название и рейтинг
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Категории
                    Text(
                      restaurant.categories.isNotEmpty ? restaurant.categories.join(' • ') : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Время доставки и стоимость
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$deliveryTime мин',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deliveryFee > 0 ? '${deliveryFee.toInt()} ₽' : 'Бесплатно',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: restaurant.isOpen ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            restaurant.isOpen ? 'Открыто' : 'Закрыто',
                            style: TextStyle(
                              fontSize: 12,
                              color: restaurant.isOpen ? Colors.green[800] : Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
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
      ),
    );
  }
} 