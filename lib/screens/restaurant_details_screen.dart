import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/safe_image.dart';
import 'cart_screen.dart';
import 'food_details_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;
  
  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  Restaurant? _restaurant;
  List<FoodItem> _menu = [];
  List<FoodItem> _filteredMenu = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isAppBarCollapsed = false;
  String _selectedCategory = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      
      // Загружаем данные о ресторане
      final restaurant = await foodProvider.getRestaurantById(widget.restaurantId);
      if (restaurant == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Загружаем меню ресторана
      final menu = await foodProvider.getFoodItemsByRestaurant(widget.restaurantId);
      
      setState(() {
        _restaurant = restaurant;
        _menu = menu as List<FoodItem>;
        _filteredMenu = menu as List<FoodItem>;
        _isLoading = false;
      });
      
      // Проверяем, добавлен ли ресторан в избранное
      _checkFavoriteStatus();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $error')),
        );
      }
    }
  }
  
  void _checkFavoriteStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      setState(() {
        _isFavorite = userProvider.user!.favoriteRestaurants.contains(widget.restaurantId);
      });
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    final isCollapsed = _scrollController.hasClients && 
        _scrollController.offset > 200;  // Высота изображения
    
    if (isCollapsed != _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = isCollapsed;
      });
    }
  }
  
  Future<void> _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо войти в систему')),
      );
      return;
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    try {
      await userProvider.toggleFavoriteRestaurant(widget.restaurantId);
    } catch (error) {
      // Вернуть предыдущее состояние в случае ошибки
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $error')),
        );
      }
    }
  }
  
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category == _selectedCategory ? '' : category;
      
      if (_selectedCategory.isEmpty) {
        _filteredMenu = _menu;
      } else {
        _filteredMenu = _menu.where(
          (food) => food.categories?.contains(_selectedCategory) ?? false
        ).toList();
      }
    });
  }
  
  void _filterBySearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMenu = _selectedCategory.isEmpty
            ? _menu
            : _menu.where(
                (food) => food.categories?.contains(_selectedCategory) ?? false
              ).toList();
      });
      return;
    }
    
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredMenu = _menu.where((food) {
        final nameMatch = food.name.toLowerCase().contains(lowercaseQuery);
        final descriptionMatch = food.description.toLowerCase().contains(lowercaseQuery);
        final categoryMatch = _selectedCategory.isEmpty || 
                               (food.categories?.contains(_selectedCategory) ?? false);
        
        return (nameMatch || descriptionMatch) && categoryMatch;
      }).toList();
    });
  }
  
  void _navigateToFoodDetails(FoodItem food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodDetailsScreen(foodId: food.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? _buildLoadingView() 
        : _restaurant == null 
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ресторан не найден'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Вернуться назад'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Формируем список категорий из меню ресторана
    final categories = <String>{};
    for (final food in _menu) {
      categories.addAll(food.categories ?? []);
    }
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: Colors.white,
          elevation: _isAppBarCollapsed ? 4 : 0,
          title: _isAppBarCollapsed
              ? Text(
                  _restaurant!.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _isAppBarCollapsed ? Colors.black87 : Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isAppBarCollapsed ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              color: _isAppBarCollapsed ? Colors.black87 : Colors.white,
              onPressed: () {
                // Функция для шаринга
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: SafeImage(
              imageUrl: _restaurant!.coverImageUrl ?? 'https://via.placeholder.com/800x400',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о ресторане
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _restaurant!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _restaurant!.categories.join(' • '),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _restaurant!.rating.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                // Информация о доставке
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${_restaurant!.deliveryTime} мин',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.delivery_dining, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _restaurant!.deliveryFee > 0
                          ? '${_restaurant!.deliveryFee.toInt()} ₽'
                          : 'Бесплатная доставка',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                // Адрес
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _restaurant!.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                // Статус (открыт/закрыт)
                Row(
                  children: [
                    Icon(
                      _restaurant!.isOpen ? Icons.circle : Icons.circle_outlined,
                      color: _restaurant!.isOpen ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _restaurant!.isOpen ? 'Открыто' : 'Закрыто',
                      style: TextStyle(
                        color: _restaurant!.isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                // Минимальная сумма заказа
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Минимальная сумма заказа: ${_restaurant!.minOrderAmount.toInt()} ₽',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                // Описание ресторана
                Text(
                  _restaurant!.description ?? 'Нет описания',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                // Поле поиска
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск блюд',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _filterBySearch,
                ),
                
                const SizedBox(height: 16),
                // Категории
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _filterByCategory(category),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Меню ресторана
        _filteredMenu.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Нет блюд, соответствующих критериям поиска',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final food = _filteredMenu[index];
                      return FoodCard(
                        foodItem: food,
                        isGrid: true,
                        onTap: () => _navigateToFoodDetails(food),
                      );
                    },
                    childCount: _filteredMenu.length,
                  ),
                ),
              ),
      ],
    );
  }
} 