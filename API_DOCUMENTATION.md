# FoodDelivery API Documentation

В этом документе описаны основные компоненты API приложения FoodDelivery, их взаимодействие и методы.

## Содержание
1. [Модели данных](#модели-данных)
2. [Провайдеры](#провайдеры)
3. [Сервисы](#сервисы)
4. [Маршрутизация](#маршрутизация)

## Модели данных

### User

Модель пользователя содержит информацию о пользователе приложения.

```dart
class User {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<String> favoriteRestaurants;
  final List<String> favoriteFoods;
  final List<Order> orders;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? fcmToken;
  
  // Конструктор и методы...
}
```

#### Основные методы:
- `copyWith()` - создает копию объекта с измененными параметрами
- `toMap()` - преобразует объект в Map для сохранения в базе данных
- `fromMap()` - создает объект из Map, полученного из базы данных
- `toJson()` - преобразует объект в JSON
- `fromJson()` - создает объект из JSON

### Food

Модель блюда содержит информацию о блюдах, предлагаемых ресторанами.

```dart
class Food {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String restaurantId;
  final List<String> categories;
  final bool isAvailable;
  final double? rating;
  final int? reviewCount;
  final List<String>? ingredients;
  final int? preparationTime;
  final bool? isVegetarian;
  final bool? isSpicy;
  
  // Конструктор и методы...
}
```

### Restaurant

Модель ресторана содержит информацию о ресторанах.

```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String coverImageUrl;
  final double rating;
  final int reviewCount;
  final String address;
  final List<String> categories;
  final double deliveryFee;
  final int deliveryTime;
  final double minOrderAmount;
  final bool isOpen;
  
  // Конструктор и методы...
}
```

### CartItem

Модель элемента корзины.

```dart
class CartItem {
  final String id;
  final Food food;
  final int quantity;
  final String? specialInstructions;
  final List<SelectedOption>? selectedOptions;
  
  // Конструктор и методы...
  
  double get totalPrice { /* расчет полной стоимости */ }
}
```

## Провайдеры

### UserProvider

Управляет состоянием пользователя, включая аутентификацию и данные профиля.

```dart
class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
}
```

#### Основные методы:
- `init()` - инициализация пользователя при запуске приложения
- `register(String name, String email, String password)` - регистрация нового пользователя
- `login(String email, String password)` - вход в систему
- `logout()` - выход из системы
- `updateUser()` - обновление данных пользователя

### FoodProvider

Управляет данными о блюдах и ресторанах.

```dart
class FoodProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  List<Food> _allFoods = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  List<Restaurant> get restaurants => _restaurants;
  List<Food> get allFoods => _allFoods;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasInitializedData => _hasInitializedData;
}
```

#### Основные методы:
- `initData()` - инициализация данных при запуске приложения
- `getRestaurantById(String id)` - получение ресторана по ID
- `getFoodById(String id)` - получение блюда по ID
- `getFoodsByRestaurant(String restaurantId)` - получение блюд определенного ресторана
- `getFoodsByCategory(String category)` - получение блюд определенной категории
- `getPopularFoods()` - получение популярных блюд
- `searchFoods(String query)` - поиск блюд по запросу
- `searchRestaurants(String query)` - поиск ресторанов по запросу

### CartProvider

Управляет корзиной покупок.

```dart
class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
}
```

#### Основные методы:
- `addToCart(Food food, {int quantity = 1})` - добавление блюда в корзину
- `removeFromCart(String id)` - удаление блюда из корзины
- `updateQuantity(String id, int quantity)` - обновление количества
- `clearCart()` - очистка корзины
- `checkout()` - оформление заказа

## Сервисы

### DatabaseService

Отвечает за взаимодействие с локальной базой данных SQLite.

```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() {
    return _instance;
  }
  
  Database? _db;
  
  // Геттеры и методы инициализации...
}
```

#### Основные методы:
- `getCurrentUser()` - получение текущего пользователя из БД
- `getUserByEmail(String email)` - поиск пользователя по email
- `updateUser(User user)` - обновление данных пользователя
- `getRestaurants()` - получение всех ресторанов
- `getFoodsByRestaurant(String restaurantId)` - получение блюд по ID ресторана
- `getFoodsPaginated({int limit = 10, int offset = 0})` - получение блюд с пагинацией
- `getCartItems()` - получение элементов корзины
- `insertCartItem(CartItem item)` - добавление элемента в корзину
- `clearCart()` - очистка корзины

## Маршрутизация

Приложение использует следующие именованные маршруты:

| Путь          | Экран                    | Описание                                   |
|---------------|--------------------------|-------------------------------------------|
| `/`           | `AuthCheckScreen`        | Проверка аутентификации                    |
| `/register`   | `RegisterScreen`         | Экран регистрации                          |
| `/login`      | `LoginScreen`            | Экран входа                                |
| `/home`       | `HomeScreen`             | Главный экран                              |
| `/welcome`    | `WelcomeScreen`          | Приветственный экран                       |

### Процесс навигации

При запуске приложения показывается `SplashScreen`, который затем перенаправляет пользователя на экран регистрации (`RegisterScreen`). Пользователь может пройти регистрацию, войти в существующий аккаунт или продолжить как гость, после чего он будет перенаправлен на главный экран (`HomeScreen`).

## Оптимизации производительности

В приложении реализованы следующие оптимизации:

1. **Кэширование данных** - FoodProvider кэширует результаты запросов к базе данных для уменьшения количества обращений
2. **Ленивая загрузка** - большинство провайдеров инициализируются лениво (параметр `lazy: true`)
3. **Поэтапная загрузка данных** - данные загружаются поэтапно для предотвращения блокировки UI
4. **Пагинация** - для больших списков используется пагинация с подгрузкой данных по мере прокрутки
5. **Оптимизация изображений** - для загрузки и кэширования изображений используется пакет `cached_network_image` 