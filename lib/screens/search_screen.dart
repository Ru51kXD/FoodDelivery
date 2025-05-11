import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/food_provider.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../models/food.dart';
import '../widgets/food_card.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/shimmer_loading.dart';
import 'food_details_screen.dart';
import 'restaurant_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FoodProvider _foodProvider = FoodProvider();
  List<Restaurant> _searchResults = [];
  List<FoodItem> filteredFoods = [];
  List<Restaurant> filteredRestaurants = [];
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;
  bool _showClearButton = false;
  
  // Фильтры
  double _maxPrice = 2000;
  List<String> _selectedCategories = [];
  bool _onlyAvailable = false;
  
  // Для анимации
  final List<String> _recentSearches = [
    'Пицца',
    'Суши',
    'Бургеры',
    'Завтраки',
    'Супы'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
    
    // Имитация загрузки для лучшего UX
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final foodProvider = Provider.of<FoodProvider>(context, listen: false);
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Фильтры',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Диапазон цен
                  Text(
                    'Максимальная цена: ${_maxPrice.toInt()} ₽',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.deepOrange,
                      thumbColor: Colors.deepOrange,
                      overlayColor: Colors.deepOrange.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      min: 100,
                      max: 3000,
                      value: _maxPrice,
                      divisions: 29,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Категории
                  Text(
                    'Категории',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: foodProvider.categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.deepOrange.withOpacity(0.2),
                        showCheckmark: false,
                        avatar: isSelected ? const Icon(Icons.check, size: 16, color: Colors.deepOrange) : null,
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.deepOrange : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Только доступные
                  SwitchListTile(
                    title: Text(
                      'Только доступные',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _onlyAvailable,
                    activeColor: Colors.deepOrange,
                    onChanged: (value) {
                      setState(() {
                        _onlyAvailable = value;
                      });
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Кнопки применения и сброса
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _maxPrice = 2000;
                              _selectedCategories = [];
                              _onlyAvailable = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Сбросить',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performSearch(_searchController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Применить',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _foodProvider.searchRestaurants(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  void _navigateToFoodDetails(FoodItem food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodDetailsScreen(foodId: food.id),
      ),
    );
  }

  void _navigateToRestaurant(Restaurant restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailsScreen(restaurantId: restaurant.id),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'пицца':
        return Icons.local_pizza;
      case 'суши':
        return Icons.set_meal;
      case 'бургеры':
        return Icons.fastfood;
      case 'десерты':
        return Icons.cake;
      case 'напитки':
        return Icons.local_drink;
      case 'салаты':
        return Icons.eco;
      case 'супы':
        return Icons.soup_kitchen;
      case 'завтраки':
        return Icons.free_breakfast;
      default:
        return Icons.restaurant;
    }
  }
  
  Widget _buildSearchResults(List<FoodItem> foods, List<Restaurant> restaurants) {
    if (foods.isEmpty && restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос или фильтры',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.poppins(),
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(text: 'Блюда (${foods.length})'),
                Tab(text: 'Рестораны (${restaurants.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Вкладка с блюдами
                foods.isEmpty
                    ? Center(
                        child: Text(
                          'Блюда не найдены',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FoodCard(
                              foodItem: foods[index],
                              onTap: () => _navigateToFoodDetails(foods[index]),
                            ),
                          );
                        },
                      ),
                
                // Вкладка с ресторанами
                restaurants.isEmpty
                    ? Center(
                        child: Text(
                          'Рестораны не найдены',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RestaurantCard(
                              restaurant: restaurants[index],
                              onTap: () => _navigateToRestaurant(restaurants[index]),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    
    if (_searchController.text.isNotEmpty) {
      // Поиск блюд
      filteredFoods = foodProvider.searchFoodItems(_searchController.text)
          .where((food) => 
              (_selectedCategories.isEmpty || 
               (food.categories?.any((cat) => _selectedCategories.contains(cat)) ?? false)) &&
              food.price <= _maxPrice &&
              (!_onlyAvailable || food.isAvailable == true))
          .toList();
      
      // Поиск ресторанов
      filteredRestaurants = _searchResults
          .where((restaurant) => 
              (_selectedCategories.isEmpty || 
               restaurant.categories.any((c) => _selectedCategories.contains(c))) &&
              (!_onlyAvailable || restaurant.isOpen))
          .toList();
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Поиск',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Найти блюда или рестораны...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _showClearButton
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _performSearch,
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.deepOrange),
                  onPressed: _showFilterDialog,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _searchController.text.isEmpty
              ? _buildInitialSearchState()
              : _buildSearchResults(filteredFoods, filteredRestaurants),
    );
  }
  
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 20, width: 150),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      ShimmerLoading(height: 80, width: 80, borderRadius: 12),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(height: 16, width: double.infinity),
                            const SizedBox(height: 8),
                            ShimmerLoading(height: 14, width: 150),
                            const SizedBox(height: 8),
                            ShimmerLoading(height: 14, width: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInitialSearchState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Недавние поиски',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                label: Text(search),
                avatar: const Icon(Icons.history, size: 16),
                labelStyle: GoogleFonts.poppins(),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Популярные категории',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<FoodProvider>(
            builder: (context, foodProvider, child) {
              final categories = foodProvider.categories.take(6).toList();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      _searchController.text = categories[index];
                      _performSearch(categories[index]);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(categories[index]),
                            color: Colors.deepOrange,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categories[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
} 