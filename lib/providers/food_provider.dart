import 'package:flutter/foundation.dart';
import 'dart:async'; // Add this import for timeout functionality
import '../models/food.dart';
import '../models/restaurant.dart';
import '../services/database_service.dart';
import '../data/mock_data.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_item.dart';
import '../models/food_adapter.dart';

// Максимальное количество операций в батче
const int _MAX_BATCH_OPERATIONS = 5;

class FoodProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Restaurant> _restaurants = [];
  List<Food> _allFoods = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  // Кэширование данных
  final Map<String, List<Food>> _foodsByRestaurantCache = {};
  final Map<String, List<Food>> _foodsByCategoryCache = {};
  
  // Пагинация
  bool _hasInitializedData = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  
  // Прогресс заполнения БД
  double _databasePopulationProgress = 0.0;
  bool _isPopulatingDatabase = false;
  
  // Геттеры
  List<Restaurant> get restaurants => _restaurants;
  List<Food> get allFoods => _allFoods;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get hasInitializedData => _hasInitializedData;
  String? get error => _error;
  double get databasePopulationProgress => _databasePopulationProgress;
  bool get isPopulatingDatabase => _isPopulatingDatabase;
  
  // Оптимизированная инициализация данных
  Future<void> initData() async {
    if (_hasInitializedData) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Загружаем категории из мок-данных сразу
    _categories = mockCategories;
    
    // Загружаем мок-данные моментально для быстрого отображения UI
    _loadMockData();
    
    // Сокращаем число обновлений UI
    _isLoading = false;
    _hasInitializedData = true;
    notifyListeners();
    
    // Асинхронно загружаем данные из БД без использования изолята
    _loadInitialDataFromDatabase();
  }
  
  // Загрузка мок-данных
  void _loadMockData() {
    _restaurants = List.from(mockRestaurants);
    _allFoods = List.from(mockFoods);
    print("DEBUG: Loaded ${_restaurants.length} restaurants from mock data");
    print("DEBUG: Loaded ${_allFoods.length} foods from mock data");
  }
  
  // Загрузка первой порции данных из БД
  Future<void> _loadInitialDataFromDatabase() async {
    try {
      // Проверяем БД только один раз
      final db = await _databaseService.database;
      
      // Используем одну транзакцию для всех операций чтения
      await db.transaction((txn) async {
        try {
          // Проверяем данные в БД одним запросом
          final counts = await Future.wait([
            txn.rawQuery('SELECT COUNT(*) FROM restaurants'),
            txn.rawQuery('SELECT COUNT(*) FROM foods')
          ]);
          
          final restaurantCount = Sqflite.firstIntValue(counts[0]) ?? 0;
          final foodCount = Sqflite.firstIntValue(counts[1]) ?? 0;
          
          // Если БД пуста, заполняем ее мок-данными поэтапно
          if (restaurantCount == 0 || foodCount == 0) {
            // Используем поэтапное заполнение БД, чтобы избежать фризов
            _isPopulatingDatabase = true;
            _databasePopulationProgress = 0.0;
            notifyListeners();
            
            // Запускаем заполнение базы в фоне с периодическими обновлениями UI
            await _populateDatabaseInBackground(db);
            return;
          }
        } catch (e) {
          print("Error checking database counts: $e");
        }
      });
      
      // Используем оптимизированные методы для загрузки данных без лишних запросов
      final restaurants = await _databaseService.getRestaurants();
      if (restaurants.isNotEmpty) {
        _restaurants = restaurants;
      }
      
      // Загружаем первую страницу блюд с пагинацией
      final foods = await _databaseService.getFoodsPaginated(limit: _pageSize, offset: 0);
      if (foods.isNotEmpty) {
        _allFoods = foods;
        _currentPage = 1;
        _hasMoreData = foods.length >= _pageSize;
      }
      
      // Обновляем UI только один раз после всех изменений
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      print("Error loading database data: $_error");
      // Используем мок-данные (они уже загружены в initData)
    } finally {
      _isPopulatingDatabase = false;
      _databasePopulationProgress = 1.0;
      notifyListeners();
    }
  }
  
  // Поэтапное заполнение базы данных без блокировки UI
  Future<void> _populateDatabaseInBackground(Database db) async {
    try {
      print("Начинаем заполнение базы данных мок-данными поэтапно");
      
      // Расчетное общее количество операций
      final int totalOperations = mockRestaurants.length + mockFoods.length;
      int completedOperations = 0;
      
      // Заполняем рестораны небольшими группами
      for (int i = 0; i < mockRestaurants.length; i += _MAX_BATCH_OPERATIONS) {
        final batch = db.batch();
        
        // Определяем размер текущей группы
        final int endIdx = (i + _MAX_BATCH_OPERATIONS < mockRestaurants.length) 
            ? i + _MAX_BATCH_OPERATIONS 
            : mockRestaurants.length;
        
        // Вставляем группу ресторанов в одной микротранзакции
        await db.transaction((txn) async {
          for (int j = i; j < endIdx; j++) {
            await _databaseService.insertRestaurantWithTransaction(txn, mockRestaurants[j]);
            completedOperations++;
          }
        });
        
        // Обновляем прогресс и даем время UI для отрисовки
        _databasePopulationProgress = completedOperations / totalOperations;
        notifyListeners();
        
        // Короткая пауза для обновления UI
        await Future.delayed(Duration(milliseconds: 10));
      }
      
      // Заполняем блюда небольшими группами
      for (int i = 0; i < mockFoods.length; i += _MAX_BATCH_OPERATIONS) {
        // Определяем размер текущей группы
        final int endIdx = (i + _MAX_BATCH_OPERATIONS < mockFoods.length) 
            ? i + _MAX_BATCH_OPERATIONS 
            : mockFoods.length;
        
        // Вставляем группу блюд в одной микротранзакции
        await db.transaction((txn) async {
          for (int j = i; j < endIdx; j++) {
            await _databaseService.insertFoodWithTransaction(txn, mockFoods[j]);
            completedOperations++;
          }
        });
        
        // Обновляем прогресс и даем время UI для отрисовки
        _databasePopulationProgress = completedOperations / totalOperations;
        notifyListeners();
        
        // Короткая пауза для обновления UI
        await Future.delayed(Duration(milliseconds: 10));
      }
      
      print("База данных успешно заполнена мок-данными поэтапно");
      
      // Теперь загружаем данные из БД
      final restaurants = await _databaseService.getRestaurants();
      if (restaurants.isNotEmpty) {
        _restaurants = restaurants;
      }
      
      // Загружаем первую страницу блюд
      final foods = await _databaseService.getFoodsPaginated(limit: _pageSize, offset: 0);
      if (foods.isNotEmpty) {
        _allFoods = foods;
        _currentPage = 1;
        _hasMoreData = foods.length >= _pageSize;
      }
      
      _databasePopulationProgress = 1.0;
      _isPopulatingDatabase = false;
      notifyListeners();
    } catch (e) {
      print("Error populating database with mock data: $e");
      _error = "Ошибка заполнения базы данных: $e";
      _isPopulatingDatabase = false;
      notifyListeners();
    }
  }
  
  // Загрузка следующей страницы данных
  Future<void> loadMoreFoods() async {
    if (_isLoadingMore || !_hasMoreData || _isPopulatingDatabase) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      // Используем оптимизированный метод для загрузки следующей страницы
      final foods = await _databaseService.getFoodsPaginated(
        limit: _pageSize, 
        offset: _currentPage * _pageSize
      );
      
      if (foods.isNotEmpty) {
        _allFoods.addAll(foods);
        _currentPage++;
        _hasMoreData = foods.length >= _pageSize;
      } else {
        _hasMoreData = false;
      }
      
    } catch (e) {
      print("Error loading more foods: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  // Вспомогательная функция для обработки карт блюд
  Future<List<Food>> _processFoodMaps(Transaction txn, List<Map<String, dynamic>> foodMaps) async {
    final List<Food> dbFoods = [];
    
    for (var map in foodMaps) {
      final foodId = map['id'] as String;
      
      final categoryMaps = await txn.query(
        'food_categories',
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      
      final categories = categoryMaps.map((m) => m['category'] as String).toList();
      
      final ingredientMaps = await txn.query(
        'ingredients',
        where: 'food_id = ?',
        whereArgs: [foodId],
      );
      
      final ingredients = ingredientMaps.map((m) => m['ingredient'] as String).toList();
      
      dbFoods.add(Food(
        id: foodId,
        name: map['name'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String,
        price: map['price'] as double,
        restaurantId: map['restaurant_id'] as String,
        categories: categories,
        isAvailable: (map['is_available'] as int?) == 1,
        rating: map['rating'] as double?,
        reviewCount: map['review_count'] as int?,
        ingredients: ingredients,
      ));
    }
    
    return dbFoods;
  }
  
  // Метод для заполнения БД мок-данными без изолята - устаревший метод
  @deprecated
  Future<void> _populateDatabaseWithMockData(Transaction txn) async {
    try {
      print("Начинаем заполнение базы данных мок-данными");
      
      // Вставляем рестораны
      for (var restaurant in mockRestaurants) {
        await _databaseService.insertRestaurantWithTransaction(txn, restaurant);
      }
      
      // Вставляем блюда пакетами, но без batch чтобы избежать потенциальных проблем
      for (var food in mockFoods) {
        await _databaseService.insertFoodWithTransaction(txn, food);
      }
      
      print("База данных успешно заполнена мок-данными");
    } catch (e) {
      print("Error populating database with mock data: $e");
    }
  }
  
  // Оптимизированные методы выборки с кэшированием
  
  // Получение блюд по ресторану с кэшированием
  List<Food> getFoodsByRestaurant(String restaurantId) {
    // Проверяем кэш
    if (_foodsByRestaurantCache.containsKey(restaurantId)) {
      return _foodsByRestaurantCache[restaurantId]!;
    }
    
    // Если не в кэше, вычисляем и сохраняем
    final foods = _allFoods.where((food) => food.restaurantId == restaurantId).toList();
    _foodsByRestaurantCache[restaurantId] = foods;
    return foods;
  }
  
  // Получение блюд по категории с кэшированием
  List<Food> getFoodsByCategory(String category) {
    // Проверяем кэш
    if (_foodsByCategoryCache.containsKey(category)) {
      return _foodsByCategoryCache[category]!;
    }
    
    // Если не в кэше, вычисляем и сохраняем
    final foods = _allFoods.where((food) => food.categories.contains(category)).toList();
    _foodsByCategoryCache[category] = foods;
    return foods;
  }
  
  // Поиск блюд с оптимизацией
  List<Food> searchFoods(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _allFoods.where((food) =>
      food.name.toLowerCase().contains(lowercaseQuery) ||
      food.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Получение популярных блюд с кэшированием и безопасным преобразованием типов
  List<Food> getPopularFoods() {
    try {
      return _allFoods.where((food) => food.rating != null && food.rating! >= 4.5).toList();
    } catch (e) {
      print("Ошибка при получении популярных блюд: $e");
      return [];
    }
  }
  
  // Очистка кэша (вызывается при обновлении данных)
  void _clearCache() {
    _foodsByRestaurantCache.clear();
    _foodsByCategoryCache.clear();
  }
  
  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Получение ресторана по ID с использованием firstWhereOrNull
  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      return null;
    }
  }

  // Получение блюда по ID с использованием firstWhereOrNull
  Food? getFoodById(String id) {
    try {
      return _allFoods.firstWhere((food) => food.id == id);
    } catch (e) {
      return null;
    }
  }

  // Оптимизированный поиск ресторанов
  List<Restaurant> searchRestaurants(String query) {
    if (query.isEmpty) return _restaurants;
    
    final lowercaseQuery = query.toLowerCase();
    return _restaurants.where((restaurant) {
      return restaurant.name.toLowerCase().contains(lowercaseQuery) ||
          restaurant.description.toLowerCase().contains(lowercaseQuery) ||
          restaurant.categories.any((category) => category.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Обновление данных - включает очистку кэша
  Future<void> refreshData() async {
    if (_isPopulatingDatabase) return;
    
    _isLoading = true;
    _currentPage = 0;
    _clearCache();
    notifyListeners();
    
    await _loadInitialDataFromDatabase();
    
    _isLoading = false;
    notifyListeners();
  }

  // Алиасы для совместимости - обновлены с безопасным получением данных
  List<Food> getPopularFoodItems() {
    try {
      return getPopularFoods();
    } catch (e) {
      print("Ошибка при получении популярных блюд: $e");
      return [];
    }
  }
  
  // Исправленные методы с безопасной конвертацией типов
  List<FoodItem> getFoodItemsByRestaurant(String restaurantId) {
    try {
      final foods = getFoodsByRestaurant(restaurantId);
      return FoodAdapter.convertFoodList(foods);
    } catch (e) {
      print("Ошибка при получении блюд ресторана: $e");
      return [];
    }
  }
  
  List<FoodItem> searchFoodItems(String query) {
    try {
      final foods = searchFoods(query);
      return FoodAdapter.convertFoodList(foods);
    } catch (e) {
      print("Ошибка при поиске блюд: $e");
      return [];
    }
  }

  // Получение всех категорий блюд
  List<String> getAllCategories() {
    final Set<String> categories = {};
    
    for (final food in mockFoods) {
      if (food.categories.isNotEmpty) {
        categories.addAll(food.categories);
      }
    }
    
    return categories.toList()..sort();
  }
  
  // Получение похожих блюд (той же категории)
  List<Food> getSimilarFoods(String foodId, int limit) {
    try {
      // Находим текущее блюдо
      final currentFood = getFoodById(foodId);
      if (currentFood == null || currentFood.categories.isEmpty) {
        return getRandomFoods(limit);
      }
      
      // Находим блюда той же категории
      final List<Food> similarFoods = mockFoods
        .where((food) => 
          food.id != foodId && 
          food.categories.any((cat) => currentFood.categories.contains(cat))
        )
        .toList();
      
      // Если похожих блюд недостаточно, добавляем случайные
      if (similarFoods.length < limit) {
        final additionalFoods = mockFoods
          .where((food) => 
            food.id != foodId && 
            !similarFoods.any((similar) => similar.id == food.id)
          )
          .take(limit - similarFoods.length)
          .toList();
        
        similarFoods.addAll(additionalFoods);
      }
      
      // Если блюд больше, чем нужно, ограничиваем
      return similarFoods.take(limit).toList();
    } catch (e) {
      print("Ошибка при получении похожих блюд: $e");
      return [];
    }
  }
  
  // Получение случайных блюд
  List<Food> getRandomFoods(int limit) {
    try {
      final List<Food> allFoods = List.from(mockFoods);
      allFoods.shuffle();
      return allFoods.take(limit).toList();
    } catch (e) {
      print("Ошибка при получении случайных блюд: $e");
      return [];
    }
  }
} 