import '../models/food.dart' as FoodModel;
import '../models/food_item.dart' as FoodItemModel;

/// Адаптер для конвертации между моделями Food и FoodItem
class FoodAdapter {
  /// Конвертирует объект Food в FoodItem
  static FoodItemModel.FoodItem toFoodItem(FoodModel.Food food) {
    return FoodItemModel.FoodItem(
      id: food.id,
      name: food.name,
      description: food.description,
      price: food.price,
      imageUrl: food.imageUrl,
      category: food.categories.isNotEmpty ? food.categories[0] : '',
      rating: food.rating ?? 0.0,
      preparationTime: food.preparationTime ?? 30,
      isPopular: food.rating != null && food.rating! >= 4.5,
      isVegetarian: food.isVegetarian ?? false,
      ingredients: food.ingredients ?? [],
      restaurantId: food.restaurantId,
      categories: food.categories,
      reviewCount: food.reviewCount,
      isSpicy: food.isSpicy,
      options: food.options != null 
          ? food.options!.map((option) => 
              FoodItemModel.FoodOption(
                name: option.name,
                choices: option.choices.map((choice) => 
                  FoodItemModel.FoodOptionChoice(
                    name: choice.name,
                    priceAdd: choice.priceAdd,
                  )
                ).toList(),
                required: option.required,
                maxChoices: option.maxChoices,
              )
            ).toList()
          : null,
      isAvailable: food.isAvailable,
    );
  }

  /// Конвертирует объект FoodItem в Food
  static FoodModel.Food toFood(FoodItemModel.FoodItem foodItem) {
    return FoodModel.Food(
      id: foodItem.id,
      name: foodItem.name,
      description: foodItem.description,
      imageUrl: foodItem.imageUrl,
      price: foodItem.price,
      restaurantId: foodItem.restaurantId ?? '',
      categories: foodItem.categories ?? [foodItem.category],
      isAvailable: foodItem.isAvailable ?? true,
      rating: foodItem.rating,
      reviewCount: foodItem.reviewCount,
      isVegetarian: foodItem.isVegetarian,
      isSpicy: foodItem.isSpicy,
      ingredients: foodItem.ingredients,
      options: foodItem.options != null 
          ? foodItem.options!.map((option) => 
              FoodModel.FoodOption(
                name: option.name,
                choices: option.choices.map((choice) => 
                  FoodModel.FoodOptionChoice(
                    name: choice.name,
                    priceAdd: choice.priceAdd,
                  )
                ).toList(),
                required: option.required,
                maxChoices: option.maxChoices,
              )
            ).toList()
          : null,
      preparationTime: foodItem.preparationTime,
    );
  }

  /// Безопасно конвертирует список Food в список FoodItem
  static List<FoodItemModel.FoodItem> convertFoodList(List<FoodModel.Food> foods) {
    return foods.map((food) => toFoodItem(food)).toList();
  }
} 