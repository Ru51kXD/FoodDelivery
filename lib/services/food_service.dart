import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../data/mock_data.dart';

class FoodService {
  final String _baseUrl = 'https://your-api-endpoint.com/api'; // Заменить на реальный API при необходимости
  final bool _useMockData = true; // Используем моковые данные вместо реального API
  
  // Получение всех блюд
  Future<List<FoodItem>> getAllFoodItems() async {
    try {
      print("FoodService: Requesting all food items");
      
      if (_useMockData) {
        print("FoodService: Using mock data for all food items");
        await Future.delayed(const Duration(milliseconds: 500)); // Имитация сетевой задержки
        print("FoodService: Mock data loaded successfully: ${mockFoodItems.length} items");
        return mockFoodItems;
      }
      
      // Реальный API запрос
      final response = await http.get(Uri.parse('$_baseUrl/foods'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить блюда: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in getAllFoodItems: $e");
      rethrow;
    }
  }
  
  // Получение списка ресторанов
  Future<List<Restaurant>> getRestaurants() async {
    try {
      print("FoodService: Requesting all restaurants");
      
      if (_useMockData) {
        // Используем моковые данные
        print("FoodService: Using mock data for restaurants");
        await Future.delayed(const Duration(milliseconds: 500)); // Имитация сетевой задержки
        print("FoodService: Mock data loaded successfully: ${mockRestaurants.length} restaurants");
        return mockRestaurants;
      }
      
      // Реальный API запрос
      final response = await http.get(Uri.parse('$_baseUrl/restaurants'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить рестораны: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in getRestaurants: $e");
      rethrow;
    }
  }
  
  // Получение популярных блюд
  Future<List<FoodItem>> getPopularFoods() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mockFoodItems.where((food) => food.isPopular).toList();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/foods/popular'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить популярные блюда');
    }
  }
  
  // Получение рекомендованных блюд для пользователя
  Future<List<FoodItem>> getRecommendedFoods() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Просто возвращаем случайные блюда в качестве рекомендаций
      return mockFoodItems.take(5).toList();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/foods/recommended'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить рекомендованные блюда');
    }
  }
  
  // Получение категорий
  Future<List<String>> getCategories() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Получаем уникальные категории из блюд
      final Set<String> categories = {};
      for (var food in mockFoodItems) {
        categories.add(food.category);
      }
      return categories.toList()..sort();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/categories'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return List<String>.from(data);
    } else {
      throw Exception('Не удалось загрузить категории');
    }
  }
  
  // Получение меню ресторана
  Future<List<FoodItem>> getRestaurantMenu(String restaurantId) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (restaurantMenu.containsKey(restaurantId)) {
        final List<String> foodIds = restaurantMenu[restaurantId] ?? [];
        final List<FoodItem> restaurantFoods = [];
        
        for (var foodId in foodIds) {
          try {
            final foodItem = mockFoodItems.firstWhere(
              (food) => food.id == foodId,
              orElse: () => throw Exception('Блюдо с ID $foodId не найдено'),
            );
            restaurantFoods.add(foodItem);
          } catch (e) {
            print('Ошибка при поиске блюда $foodId: $e');
          }
        }
        
        return restaurantFoods;
      }
      
      return [];
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/restaurants/$restaurantId/menu'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить меню ресторана');
    }
  }
  
  // Поиск блюд по названию
  Future<List<FoodItem>> searchFoods(String query) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Фильтруем блюда по запросу
      final lowercaseQuery = query.toLowerCase();
      return mockFoodItems
          .where((food) => 
            food.name.toLowerCase().contains(lowercaseQuery) ||
            food.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/foods/search?query=$query'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось выполнить поиск блюд');
    }
  }
  
  // Поиск ресторанов по названию
  Future<List<Restaurant>> searchRestaurants(String query) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Фильтруем рестораны по запросу
      final lowercaseQuery = query.toLowerCase();
      return mockRestaurants
          .where((restaurant) => 
            restaurant.name.toLowerCase().contains(lowercaseQuery) ||
            restaurant.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/restaurants/search?query=$query'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось выполнить поиск ресторанов');
    }
  }
  
  // Получение блюд по категории
  Future<List<FoodItem>> getFoodsByCategory(String category) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Фильтруем блюда по категории
      return mockFoodItems
          .where((food) => food.category == category)
          .toList();
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/foods/category/$category'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Не удалось загрузить блюда категории');
    }
  }
  
  // Получение ресторана по ID
  Future<Restaurant?> getRestaurantById(String id) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      try {
        return mockRestaurants.firstWhere((restaurant) => restaurant.id == id);
      } catch (e) {
        return null;
      }
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/restaurants/$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Restaurant.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Не удалось загрузить ресторан');
    }
  }
  
  // Получение блюда по ID
  Future<FoodItem?> getFoodById(String id) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      try {
        return mockFoodItems.firstWhere((food) => food.id == id);
      } catch (e) {
        return null;
      }
    }
    
    final response = await http.get(Uri.parse('$_baseUrl/foods/$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FoodItem.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Не удалось загрузить блюдо');
    }
  }
} 