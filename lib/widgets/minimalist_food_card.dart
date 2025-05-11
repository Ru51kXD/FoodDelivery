import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/food_item.dart' as food_item;
import '../widgets/safe_image.dart';
import '../models/food_adapter.dart';

class MinimalistFoodCard extends StatelessWidget {
  final dynamic food; // Может быть Food или FoodItem
  final VoidCallback onTap;
  
  const MinimalistFoodCard({
    Key? key,
    required this.food,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Извлекаем безопасные значения независимо от типа
    String name = '';
    String imageUrl = '';
    String description = '';
    double price = 0.0;
    double rating = 0.0;
    int? reviewCount;
    bool isVegetarian = false;
    bool isSpicy = false;
    
    // Определяем тип и безопасно извлекаем данные
    if (food is Food) {
      final foodObj = food as Food;
      name = foodObj.name;
      imageUrl = foodObj.imageUrl;
      description = foodObj.description;
      
      // Безопасное преобразование числовых значений
      price = foodObj.price.isFinite ? foodObj.price : 0.0;
      rating = foodObj.rating != null && foodObj.rating!.isFinite ? foodObj.rating! : 0.0;
      reviewCount = foodObj.reviewCount;
      isVegetarian = foodObj.isVegetarian ?? false;
      isSpicy = foodObj.isSpicy ?? false;
    } else if (food is food_item.FoodItem) {
      final foodItemObj = food as food_item.FoodItem;
      name = foodItemObj.name;
      imageUrl = foodItemObj.imageUrl;
      description = foodItemObj.description;
      
      // Безопасное преобразование числовых значений
      price = foodItemObj.price.isFinite ? foodItemObj.price : 0.0;
      rating = foodItemObj.rating.isFinite ? foodItemObj.rating : 0.0;
      reviewCount = foodItemObj.reviewCount;
      isVegetarian = foodItemObj.isVegetarian;
      isSpicy = foodItemObj.isSpicy ?? false;
    } else {
      // Если тип неизвестен, возвращаем заглушку
      return Card(
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Ошибка загрузки',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение с обработкой ошибок
              AspectRatio(
                aspectRatio: 16 / 9,
                child: SafeImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.restaurant, color: Colors.grey[400], size: 32),
                    ),
                  ),
                ),
              ),
              
              // Контент карточки
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название блюда
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Рейтинг и количество отзывов
                    if (rating > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (reviewCount != null && reviewCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($reviewCount)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Цена и иконки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Иконки особенностей
                        Row(
                          children: [
                            if (isVegetarian)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.eco,
                                  size: 14,
                                  color: Colors.green[600],
                                ),
                              ),
                            if (isSpicy)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.whatshot,
                                  size: 14,
                                  color: Colors.red[600],
                                ),
                              ),
                          ],
                        ),
                        
                        // Цена
                        Text(
                          '${price.toInt()} ₽',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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