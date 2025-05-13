import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

import '../models/food.dart';
import '../models/food_item.dart';
import '../models/food_adapter.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../models/restaurant.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/food_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/category_card.dart';
import '../widgets/minimalist_food_card.dart';
import '../widgets/minimalist_restaurant_card.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'restaurant_details_screen.dart';
import 'food_details_screen.dart';
import 'search_screen.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _searchQuery = '';
  List<Restaurant> _filteredRestaurants = [];
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Инициализируем данные, если они еще не были проинициализированы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      if (!foodProvider.hasInitializedData) {
        foodProvider.initData().then((_) {
          _loadRestaurants();
        });
      } else {
        _loadRestaurants();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }
  
  void _onCategorySelected(String category) {
    setState(() {
      if (_selectedCategory == category) {
        // Если эта категория уже выбрана, снимаем выбор
        _selectedCategory = '';
      } else {
        _selectedCategory = category;
      }
    });
  }
  
  void _onNavigationItemSelected(int index) {
    if (index == _selectedIndex) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Переход на соответствующий экран
    switch (index) {
      case 0:
        // Уже на главном экране
        break;
      case 1:
        // Экран поиска
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        setState(() {
          _selectedIndex = 0; // Возвращаем индекс на главный экран после перехода
        });
        break;
      case 2:
        // Экран корзины
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        setState(() {
          _selectedIndex = 0; // Возвращаем индекс на главный экран после перехода
        });
        break;
      case 3:
        // Экран профиля - просто переходим напрямую без проверок загрузки
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        setState(() {
          _selectedIndex = 0; // Возвращаем индекс на главный экран после перехода
        });
        break;
    }
  }
  
  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailsScreen(restaurantId: restaurant.id),
      ),
    );
  }
  
  void _navigateToFoodDetails(dynamic food) {
    String foodId;
    
    if (food is Food) {
      foodId = food.id;
    } else if (food is FoodItem) {
      foodId = food.id;
    } else {
      // Если тип неизвестен, просто возвращаемся
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodDetailsScreen(foodId: foodId),
      ),
    );
  }

  void _filterBySearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          final nameMatch = restaurant.name.toLowerCase().contains(query.toLowerCase());
          final descriptionMatch = restaurant.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
          return nameMatch || descriptionMatch;
        }).toList();
      }
    });
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      
      // Если данные ещё не загружены, принудительно инициализируем их
      if (foodProvider.restaurants.isEmpty && !foodProvider.isLoading) {
        await foodProvider.initData();
      }
      
      // Ждем пока загрузятся рестораны
      if (foodProvider.restaurants.isEmpty) {
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      setState(() {
        _restaurants = List.from(foodProvider.restaurants);
        _filteredRestaurants = _restaurants;
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Гибкий App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: _isScrolled ? 4 : 0,
            backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: _isScrolled 
                ? Text(
                    'ЕдаДоставка',
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, Гость 👋',
                              style: TextStyle(
                                color: Colors.deepOrange.shade700,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Что хотите заказать?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepOrange.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.deepOrange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Добавляем SearchBar прямо в AppBar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск ресторанов и блюд',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterBySearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _filterBySearch,
                  ),
                ),
              ),
            ),
          ),
          
          // Горизонтальный список категорий
          SliverToBoxAdapter(
            child: foodProvider.isLoading
                ? _buildCategoryShimmer()
                : _buildCategoryList(foodProvider.categories),
          ),
          
          // Заголовок популярных ресторанов
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Популярные рестораны',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Показать все рестораны
                    },
                    child: Text(
                      'Все',
                      style: TextStyle(
                        color: Colors.deepOrange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Горизонтальный список популярных ресторанов
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: foodProvider.isLoading
                  ? _buildRestaurantShimmer()
                  : Container(
                      color: Colors.grey[100],
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: foodProvider.restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = foodProvider.restaurants[index];
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            child: MinimalistRestaurantCard(
                              restaurant: restaurant,
                              onTap: () => _navigateToRestaurant(restaurant),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
          
          // Заголовок популярных блюд
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Популярные блюда',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Показать все популярные блюда
                    },
                    child: Text(
                      'Все',
                      style: TextStyle(
                        color: Colors.deepOrange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Горизонтальный список популярных блюд
          SliverToBoxAdapter(
            child: SizedBox(
              height: 245,
              child: foodProvider.isLoading
                  ? _buildFoodShimmer()
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: foodProvider.getPopularFoodItems().length,
                      itemBuilder: (context, index) {
                        final food = foodProvider.getPopularFoodItems()[index];
                        return MinimalistFoodCard(
                          food: food,
                          onTap: () => _navigateToFoodDetails(food),
                        );
                      },
                    ),
            ),
          ),
          
          // Заголовок раздела "Все рестораны"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Все рестораны',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Фильтр ресторанов
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 16),
                        SizedBox(width: 4),
                        Text('Фильтр'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Сетка всех ресторанов
          foodProvider.isLoading
              ? SliverToBoxAdapter(child: _buildRestaurantsGridShimmer())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Фильтрация по категории, если выбрана
                        final restaurants = _selectedCategory.isEmpty
                            ? foodProvider.restaurants
                            : foodProvider.restaurants
                                .where((r) => r.categories.contains(_selectedCategory))
                                .toList();
                        
                        // Проверяем наличие ресторанов
                        if (restaurants.isEmpty) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text("Нет ресторанов"),
                            ),
                          );
                        }
                        
                        if (index >= restaurants.length) return null;
                        
                        final restaurant = restaurants[index];
                        
                        print("DEBUG: Rendering restaurant card for ${restaurant.name}");
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MinimalistRestaurantCard(
                              restaurant: restaurant,
                              onTap: () => _navigateToRestaurant(restaurant),
                            ),
                          ),
                        );
                      },
                      childCount: _selectedCategory.isEmpty
                          ? foodProvider.restaurants.length
                          : foodProvider.restaurants
                              .where((r) => r.categories.contains(_selectedCategory))
                              .length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavigationItemSelected,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Главная',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search),
                label: 'Поиск',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Корзина',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Заглушки для загрузки
  Widget _buildCategoryShimmer() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ShimmerLoading(
              child: Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRestaurantShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ShimmerLoading(
            child: Container(
              width: 160,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFoodShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ShimmerLoading(
            child: Container(
              width: 140,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRestaurantsGridShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCategoryList(List<String> categories) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return CategoryChip(
            label: category,
            isSelected: isSelected,
            onTap: () => _onCategorySelected(category),
          );
        },
      ),
    );
  }
} 