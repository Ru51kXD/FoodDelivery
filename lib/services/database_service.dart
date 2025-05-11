import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';
import '../models/food.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }
  
  DatabaseService._internal();
  
  Database? _db;
  Completer<Database>? _dbCompleter;
  bool _isDatabaseInitialized = false;
  bool _isWindows = false;

  // Проверка, запущено ли приложение на Windows
  bool get isWindowsPlatform {
    try {
      _isWindows = !kIsWeb && Platform.isWindows;
      return _isWindows;
    } catch (e) {
      // В случае ошибки, при запуске на Windows может не быть доступен Platform
      print("Ошибка определения платформы: $e");
      _isWindows = true;
      return true;
    }
  }

  Future<Database> get database async {
    if (_db != null && _isDatabaseInitialized) {
      return _db!;
    }
    
    if (isWindowsPlatform) {
      print("Запуск на Windows платформе. Используем облегченный режим без базы данных.");
      throw Exception("База данных не доступна на Windows в облегченном режиме");
    }
    
    _db = await _initDatabase();
    _isDatabaseInitialized = true;
    return _db!;
  }

  // Проверяет, доступна ли база данных
  Future<bool> isDatabaseAvailable() async {
    try {
      if (isWindowsPlatform) {
        return false;
      }
      
      // Пробуем выполнить простой запрос с таймаутом
      final db = await _initDatabase();
      await db.rawQuery('SELECT 1').timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException("Timeout initializing database")
      );
      return true;
    } catch (e) {
      print("База данных недоступна: $e");
      return false;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_delivery.db');
    
    // Улучшенный метод инициализации базы данных
    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onConfigure: (db) async {
          // Включаем только внешние ключи, без дополнительных PRAGMA
          await db.execute("PRAGMA foreign_keys = ON");
        },
      );
    } catch (e) {
      print("Error opening database: $e");
      rethrow;
    }
  }

  // Создание базы данных оптимизировано для быстрой инициализации
  Future<void> _createDatabase(Database db, int version) async {
    try {
      // Используем batch для выполнения всех операций в одной транзакции
      Batch batch = db.batch();
      
      // Таблица пользователей
      batch.execute('''
        CREATE TABLE users(
          id TEXT PRIMARY KEY,
          name TEXT,
          email TEXT,
          phone TEXT,
          address TEXT,
          avatar_url TEXT,
          token TEXT,
          favorite_restaurants TEXT,
          favorite_foods TEXT,
          is_email_verified INTEGER,
          is_phone_verified INTEGER
        )
      ''');

      // Таблица ресторанов
      batch.execute('''
        CREATE TABLE restaurants(
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          image_url TEXT,
          cover_image_url TEXT,
          rating REAL,
          review_count INTEGER,
          address TEXT,
          delivery_fee REAL,
          delivery_time INTEGER,
          min_order_amount REAL,
          is_open INTEGER
        )
      ''');

      // Создаем основные индексы для таблицы ресторанов
      batch.execute('CREATE INDEX idx_restaurant_name ON restaurants(name)');

      // Таблица категорий ресторанов
      batch.execute('''
        CREATE TABLE restaurant_categories(
          restaurant_id TEXT,
          category TEXT,
          FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE,
          PRIMARY KEY (restaurant_id, category)
        )
      ''');

      // Добавляем индекс для категорий
      batch.execute('CREATE INDEX idx_restaurant_category ON restaurant_categories(category)');

      // Таблица блюд
      batch.execute('''
        CREATE TABLE foods(
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          image_url TEXT,
          price REAL,
          restaurant_id TEXT,
          is_available INTEGER,
          rating REAL,
          review_count INTEGER,
          FOREIGN KEY (restaurant_id) REFERENCES restaurants (id) ON DELETE CASCADE
        )
      ''');

      // Основные индексы для таблицы блюд
      batch.execute('CREATE INDEX idx_food_restaurant_id ON foods(restaurant_id)');

      // Таблица категорий блюд
      batch.execute('''
        CREATE TABLE food_categories(
          food_id TEXT,
          category TEXT,
          FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE,
          PRIMARY KEY (food_id, category)
        )
      ''');

      // Таблица ингредиентов
      batch.execute('''
        CREATE TABLE ingredients(
          food_id TEXT,
          ingredient TEXT,
          FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE,
          PRIMARY KEY (food_id, ingredient)
        )
      ''');

      // Таблица корзины
      batch.execute('''
        CREATE TABLE cart_items(
          id TEXT PRIMARY KEY,
          food_id TEXT,
          quantity INTEGER,
          FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE
        )
      ''');

      // Индекс для таблицы корзины
      batch.execute('CREATE INDEX idx_cart_food_id ON cart_items(food_id)');

      // Таблица заказов
      batch.execute('''
        CREATE TABLE orders(
          id TEXT PRIMARY KEY,
          user_id TEXT,
          total_amount REAL,
          status TEXT,
          created_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Таблица элементов заказа
      batch.execute('''
        CREATE TABLE order_items(
          order_id TEXT,
          food_id TEXT,
          quantity INTEGER,
          price REAL,
          FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
          FOREIGN KEY (food_id) REFERENCES foods (id) ON DELETE CASCADE,
          PRIMARY KEY (order_id, food_id)
        )
      ''');
      
      // Выполняем все операции одновременно
      await batch.commit(noResult: true);
      print("Database schema created successfully");
    } catch (e) {
      print("Error creating database schema: $e");
      rethrow;
    }
  }

  // Оптимизированные методы для работы с ресторанами
  Future<void> insertRestaurant(Restaurant restaurant) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await insertRestaurantWithTransaction(txn, restaurant);
      });
    } catch (e) {
      print("Error inserting restaurant: $e");
      rethrow;
    }
  }

  // Метод для вставки ресторана с использованием существующей транзакции
  Future<void> insertRestaurantWithTransaction(Transaction txn, Restaurant restaurant) async {
    try {
      await txn.insert('restaurants', {
        'id': restaurant.id,
        'name': restaurant.name,
        'description': restaurant.description,
        'image_url': restaurant.imageUrl,
        'cover_image_url': restaurant.coverImageUrl,
        'rating': restaurant.rating,
        'review_count': restaurant.reviewCount,
        'address': restaurant.address,
        'delivery_fee': restaurant.deliveryFee,
        'delivery_time': restaurant.deliveryTime,
        'min_order_amount': restaurant.minOrderAmount,
        'is_open': restaurant.isOpen ? 1 : 0,
      });

      // Вставляем категории по одной без batch
      for (var category in restaurant.categories) {
        await txn.insert('restaurant_categories', {
          'restaurant_id': restaurant.id,
          'category': category,
        });
      }
    } catch (e) {
      print("Error inserting restaurant with transaction: $e");
      rethrow;
    }
  }

  // Оптимизированный метод получения ресторанов с JOIN запросом
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final db = await database;
      
      // Получаем все рестораны одним запросом
      final List<Map<String, dynamic>> maps = await db.query('restaurants');
      
      if (maps.isEmpty) {
        return [];
      }
      
      // Получаем все категории ресторанов одним запросом
      final List<Map<String, dynamic>> allCategoryMaps = await db.query('restaurant_categories');
      
      // Группируем категории по ID ресторана для быстрого доступа
      final Map<String, List<String>> restaurantCategories = {};
      for (var map in allCategoryMaps) {
        final restaurantId = map['restaurant_id'] as String;
        final category = map['category'] as String;
        
        if (!restaurantCategories.containsKey(restaurantId)) {
          restaurantCategories[restaurantId] = [];
        }
        
        restaurantCategories[restaurantId]!.add(category);
      }
      
      // Собираем объекты ресторанов с категориями
      return maps.map((map) {
        final restaurantId = map['id'] as String;
        return Restaurant(
          id: restaurantId,
          name: map['name'] as String,
          description: map['description'] as String,
          imageUrl: map['image_url'] as String,
          coverImageUrl: map['cover_image_url'] as String,
          rating: (map['rating'] as double?) ?? 0.0,
          reviewCount: (map['review_count'] as int?) ?? 0,
          address: (map['address'] as String?) ?? '',
          deliveryFee: (map['delivery_fee'] as double?) ?? 0.0,
          deliveryTime: (map['delivery_time'] as int?) ?? 0,
          minOrderAmount: (map['min_order_amount'] as double?) ?? 0.0,
          isOpen: (map['is_open'] as int?) == 1,
          categories: restaurantCategories[restaurantId] ?? [],
        );
      }).toList();
    } catch (e) {
      print("Error getting restaurants: $e");
      return [];
    }
  }

  // Оптимизированная вставка блюда
  Future<void> insertFood(Food food) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await insertFoodWithTransaction(txn, food);
      });
    } catch (e) {
      print("Error inserting food: $e");
    }
  }

  // Метод для вставки блюда с использованием существующей транзакции
  Future<void> insertFoodWithTransaction(Transaction txn, Food food) async {
    try {
      await txn.insert('foods', {
        'id': food.id,
        'name': food.name,
        'description': food.description,
        'image_url': food.imageUrl,
        'price': food.price,
        'restaurant_id': food.restaurantId,
        'is_available': food.isAvailable ? 1 : 0,
        'rating': food.rating,
        'review_count': food.reviewCount,
      });

      // Вставляем категории по одной без batch
      for (var category in food.categories) {
        await txn.insert('food_categories', {
          'food_id': food.id,
          'category': category,
        });
      }
      
      // Вставляем ингредиенты, если они есть
      if (food.ingredients != null && food.ingredients!.isNotEmpty) {
        for (var ingredient in food.ingredients!) {
          await txn.insert('ingredients', {
            'food_id': food.id,
            'ingredient': ingredient,
          });
        }
      }
    } catch (e) {
      print("Error inserting food with transaction: $e");
      rethrow;
    }
  }

  // Оптимизированное получение блюд по ресторану
  Future<List<Food>> getFoodsByRestaurant(String restaurantId) async {
    try {
      final db = await database;
      
      // Получаем блюда ресторана
      final List<Map<String, dynamic>> foodMaps = await db.query(
        'foods',
        where: 'restaurant_id = ?',
        whereArgs: [restaurantId],
      );
      
      return _processFoodMaps(db, foodMaps);
    } catch (e) {
      print("Error getting foods by restaurant: $e");
      return [];
    }
  }

  // Вспомогательный метод для обработки карт блюд
  Future<List<Food>> _processFoodMaps(Database db, List<Map<String, dynamic>> foodMaps) async {
    final List<Food> foods = [];
    
    try {
      for (final map in foodMaps) {
        final foodId = map['id'] as String;
        
        // Получаем категории блюда
        final List<Map<String, dynamic>> categoryMaps = await db.query(
          'food_categories',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
        
        final categories = categoryMaps.map((m) => m['category'] as String).toList();
        
        // Получаем ингредиенты блюда
        final List<Map<String, dynamic>> ingredientMaps = await db.query(
          'ingredients',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
        
        final ingredients = ingredientMaps.map((m) => m['ingredient'] as String).toList();
        
        foods.add(Food(
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
    } catch (e) {
      print("Error processing food maps: $e");
    }
    
    return foods;
  }

  // Оптимизированный метод для эффективной загрузки блюд с пагинацией
  Future<List<Food>> getFoodsPaginated({int limit = 10, int offset = 0}) async {
    try {
      final db = await database;
      
      // Получаем блюда с пагинацией
      final List<Map<String, dynamic>> foodMaps = await db.query(
        'foods',
        limit: limit,
        offset: offset,
      );
      
      if (foodMaps.isEmpty) {
        return [];
      }
      
      // Извлекаем ID блюд для оптимизированных запросов
      final List<String> foodIds = foodMaps.map((map) => map['id'] as String).toList();
      final String foodIdsStr = foodIds.map((id) => "'$id'").join(',');
      
      // Получаем все категории этих блюд одним запросом
      final List<Map<String, dynamic>> allCategoryMaps = await db.rawQuery(
        "SELECT * FROM food_categories WHERE food_id IN ($foodIdsStr)"
      );
      
      // Получаем все ингредиенты этих блюд одним запросом
      final List<Map<String, dynamic>> allIngredientMaps = await db.rawQuery(
        "SELECT * FROM ingredients WHERE food_id IN ($foodIdsStr)"
      );
      
      // Группируем категории по ID блюда
      final Map<String, List<String>> foodCategories = {};
      for (var map in allCategoryMaps) {
        final foodId = map['food_id'] as String;
        final category = map['category'] as String;
        
        if (!foodCategories.containsKey(foodId)) {
          foodCategories[foodId] = [];
        }
        
        foodCategories[foodId]!.add(category);
      }
      
      // Группируем ингредиенты по ID блюда
      final Map<String, List<String>> foodIngredients = {};
      for (var map in allIngredientMaps) {
        final foodId = map['food_id'] as String;
        final ingredient = map['ingredient'] as String;
        
        if (!foodIngredients.containsKey(foodId)) {
          foodIngredients[foodId] = [];
        }
        
        foodIngredients[foodId]!.add(ingredient);
      }
      
      // Собираем объекты блюд
      return foodMaps.map((map) {
        final foodId = map['id'] as String;
        return Food(
          id: foodId,
          name: map['name'] as String,
          description: map['description'] as String,
          imageUrl: map['image_url'] as String,
          price: map['price'] as double,
          restaurantId: map['restaurant_id'] as String,
          categories: foodCategories[foodId] ?? [],
          isAvailable: (map['is_available'] as int?) == 1,
          rating: map['rating'] as double?,
          reviewCount: map['review_count'] as int?,
          ingredients: foodIngredients[foodId],
        );
      }).toList();
    } catch (e) {
      print("Error getting paginated foods: $e");
      return [];
    }
  }

  // CART OPERATIONS
  
  // Оптимизированное получение элементов корзины
  Future<List<CartItem>> getCartItems() async {
    try {
      final db = await database;
      
      // Используем JOIN для получения всех данных за один запрос
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT c.id, c.quantity, f.* 
        FROM cart_items c
        JOIN foods f ON c.food_id = f.id
      ''');
      
      final List<CartItem> cartItems = [];
      
      for (final map in maps) {
        final foodId = map['food_id'] as String;
        
        // Получаем категории блюда
        final List<Map<String, dynamic>> categoryMaps = await db.query(
          'food_categories',
          where: 'food_id = ?',
          whereArgs: [foodId],
        );
        
        final categories = categoryMaps.map((m) => m['category'] as String).toList();
        
        // Создаем объект Food
        final food = Food(
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
        );
        
        // Создаем объект CartItem
        cartItems.add(CartItem(
          id: map['id'] as String,
          food: food,
          quantity: map['quantity'] as int,
        ));
      }
      
      return cartItems;
    } catch (e) {
      print("Error getting cart items: $e");
      return [];
    }
  }

  // Вставка элемента корзины
  Future<void> insertCartItem(CartItem item) async {
    try {
      final db = await database;
      await db.insert('cart_items', {
        'id': item.id,
        'food_id': item.food.id,
        'quantity': item.quantity,
      });
    } catch (e) {
      print("Error inserting cart item: $e");
    }
  }

  // Обновление элемента корзины
  Future<void> updateCartItem(CartItem item) async {
    try {
      final db = await database;
      await db.update(
        'cart_items',
        {'quantity': item.quantity},
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } catch (e) {
      print("Error updating cart item: $e");
    }
  }

  // Удаление элемента корзины
  Future<void> deleteCartItem(String id) async {
    try {
      final db = await database;
      await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print("Error deleting cart item: $e");
    }
  }

  // Очистка корзины
  Future<void> clearCart() async {
    try {
      final db = await database;
      await db.delete('cart_items');
    } catch (e) {
      print("Error clearing cart: $e");
    }
  }

  // USER OPERATIONS
  
  // Получение текущего пользователя
  Future<User?> getCurrentUser() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
      
      if (maps.isEmpty) {
        return null;
      }
      
      return User.fromMap(maps.first);
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }
  
  // Обновление пользователя
  Future<void> updateUser(User user) async {
    try {
      final db = await database;
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print("Error updating user: $e");
    }
  }
  
  // CLEANUP - Освобождение ресурсов БД при завершении работы
  Future<void> close() async {
    try {
      final Database? db = _db;
      if (db != null) {
        await db.close();
        _db = null;
        _dbCompleter = null;
        print("Database closed successfully");
      }
    } catch (e) {
      print("Error closing database: $e");
    }
  }
} 