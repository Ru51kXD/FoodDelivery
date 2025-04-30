import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../services/food_service.dart';
import '../data/mock_data.dart';

class FoodProvider with ChangeNotifier {
  final FoodService _foodService = FoodService();
  
  List<FoodItem> _allFoodItems = [];
  List<Restaurant> _restaurants = [];
  List<String> _categories = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  List<FoodItem> get allFoodItems => _allFoodItems;
  List<Restaurant> get restaurants => _restaurants;
  List<String> get categories => _categories;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Инициализация данных
  Future<void> initData() async {
    _setLoading(true);
    try {
      // Загрузка ресторанов
      _restaurants = await _foodService.getRestaurants();
      
      // Загрузка блюд
      _allFoodItems = await _foodService.getAllFoodItems();
      
      // Извлечение уникальных категорий
      final Set<String> categorySet = {};
      for (var food in _allFoodItems) {
        categorySet.add(food.category);
      }
      _categories = categorySet.toList()..sort();
      
      notifyListeners();
    } catch (error) {
      _setError('Не удалось загрузить данные: $error');
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение блюд по ресторану
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) async {
    _setLoading(true);
    try {
      final restaurantFoods = await _foodService.getRestaurantMenu(restaurantId);
      return restaurantFoods;
    } catch (error) {
      _setError('Не удалось загрузить меню ресторана: $error');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Получение ресторана по ID
  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      _setError('Ресторан с ID $id не найден');
      return null;
    }
  }
  
  // Получение блюда по ID
  FoodItem? getFoodItemById(String id) {
    try {
      return _allFoodItems.firstWhere((food) => food.id == id);
    } catch (e) {
      _setError('Блюдо с ID $id не найдено');
      return null;
    }
  }
  
  // Поиск ресторанов по названию или категории
  List<Restaurant> searchRestaurants(String query) {
    if (query.isEmpty) return _restaurants;
    
    final lowercaseQuery = query.toLowerCase();
    return _restaurants.where((restaurant) {
      final nameMatch = restaurant.name.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch = restaurant.description.toLowerCase().contains(lowercaseQuery);
      final categoryMatch = restaurant.categories.any(
        (category) => category.toLowerCase().contains(lowercaseQuery)
      );
      
      return nameMatch || descriptionMatch || categoryMatch;
    }).toList();
  }
  
  // Поиск блюд по названию или ингредиентам
  List<FoodItem> searchFoodItems(String query) {
    if (query.isEmpty) return _allFoodItems;
    
    final lowercaseQuery = query.toLowerCase();
    return _allFoodItems.where((food) {
      final nameMatch = food.name.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch = food.description.toLowerCase().contains(lowercaseQuery);
      final ingredientsMatch = food.ingredients.any(
        (ingredient) => ingredient.toLowerCase().contains(lowercaseQuery)
      );
      
      return nameMatch || descriptionMatch || ingredientsMatch;
    }).toList();
  }
  
  // Фильтрация блюд по категории
  List<FoodItem> filterFoodItemsByCategory(String category) {
    if (category.isEmpty) return _allFoodItems;
    
    return _allFoodItems.where((food) => food.category == category).toList();
  }
  
  // Фильтрация ресторанов по категории
  List<Restaurant> filterRestaurantsByCategory(String category) {
    if (category.isEmpty) return _restaurants;
    
    return _restaurants.where((restaurant) => 
      restaurant.categories.contains(category)
    ).toList();
  }
  
  // Получение популярных блюд
  List<FoodItem> getPopularFoodItems() {
    return _allFoodItems.where((food) => food.isPopular).toList();
  }
  
  // Вспомогательные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 