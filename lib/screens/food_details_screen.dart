import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../models/food.dart' as food_model;
import '../models/food_item.dart' as food_item_model;
import '../models/food_adapter.dart';
import '../models/cart_item.dart';
import '../models/selected_option.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_image_showcase.dart';
import '../widgets/add_to_cart_button.dart';
import 'cart_screen.dart';
import '../widgets/food_card.dart';
import '../widgets/safe_image.dart';

class FoodDetailsScreen extends StatefulWidget {
  final String foodId;
  
  const FoodDetailsScreen({
    super.key,
    required this.foodId,
  });

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarCollapsed = false;
  int _quantity = 1;
  double _totalPrice = 0;
  final Map<String, SelectedOption> _selectedOptions = {};
  String? _specialInstructions;
  bool _isAddingToCart = false;
  bool _isLoading = true;
  bool _isFavorite = false;
  food_model.Food? _foodItem;
  final _uuid = const Uuid();
  final TextEditingController _instructionsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFoodData();
  }
  
  Future<void> _loadFoodData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      final food = foodProvider.getFoodById(widget.foodId);
      
      if (food != null) {
        setState(() {
          _foodItem = food;
          _calculateTotalPrice();
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Блюдо не найдено')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $error')),
        );
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.offset > 200 && !_isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = true;
      });
    } else if (_scrollController.offset <= 200 && _isAppBarCollapsed) {
      setState(() {
        _isAppBarCollapsed = false;
      });
    }
  }
  
  void _calculateTotalPrice() {
    if (_foodItem == null) return;
    
    double basePrice = _foodItem!.price * _quantity;
    double optionsPrice = 0;
    
    for (var option in _selectedOptions.values) {
      for (var choice in option.choices) {
        optionsPrice += choice.price * _quantity;
      }
    }
    
    setState(() {
      _totalPrice = basePrice + optionsPrice;
    });
  }
  
  void _increaseQuantity() {
    setState(() {
      _quantity++;
      _calculateTotalPrice();
    });
  }
  
  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _calculateTotalPrice();
      });
    }
  }
  
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Здесь можно добавить логику сохранения избранного
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite 
            ? '${_foodItem!.name} добавлено в избранное' 
            : '${_foodItem!.name} удалено из избранного'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  void _shareProduct() {
    // Здесь можно добавить логику для шаринга
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция поделиться пока не реализована'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _addToCart() async {
    if (_foodItem == null) return;
    
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      // Получаем провайдер корзины
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Создаем список выбранных опций в формате для CartItem
      final selectedOptions = _selectedOptions.values.toList();
      
      // Добавляем товар в корзину
      await cartProvider.addToCart(
        _foodItem!,
        quantity: _quantity,
        specialInstructions: _specialInstructions,
        selectedOptions: selectedOptions,
      );
      
      // Показываем сообщение об успешном добавлении
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_foodItem!.name} добавлен в корзину'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'В корзину',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        );
      }
    } catch (error) {
      // Показываем сообщение об ошибке
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении в корзину: $error')),
        );
      }
    } finally {
      // Снимаем флаг добавления в корзину
      setState(() {
        _isAddingToCart = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    
    if (_foodItem == null) {
      return const Scaffold(
        body: Center(
          child: Text('Ошибка загрузки блюда'),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Основной контент
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Шапка с изображением
              SliverToBoxAdapter(
                child: ProductImageShowcase(
                  imageUrl: _foodItem!.imageUrl,
                  rating: _foodItem!.rating ?? 0.0,
                  reviewCount: _foodItem!.reviewCount ?? 0,
                  category: _foodItem!.categories.isNotEmpty ? _foodItem!.categories[0] : 'Блюдо',
                  isVegetarian: _foodItem!.isVegetarian ?? false,
                  isSpicy: _foodItem!.isSpicy,
                  isFavorite: _isFavorite,
                  onToggleFavorite: _toggleFavorite,
                  onShareTap: _shareProduct,
                  price: _foodItem!.price,
                ),
              ),
              
              // Название и описание
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название блюда
                      Text(
                        _foodItem!.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Время приготовления
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Время приготовления: ${_foodItem!.preparationTime ?? 30} мин',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Описание
                      Text(
                        _foodItem!.description,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Ингредиенты
              if (_foodItem!.ingredients != null && _foodItem!.ingredients!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ингредиенты',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Список ингредиентов
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _foodItem!.ingredients!.map((ingredient) {
                            return Chip(
                              label: Text(
                                ingredient,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Спецальные пожелания
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Особые пожелания',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Поле для комментария
                      TextField(
                        controller: _instructionsController,
                        onChanged: (value) {
                          setState(() {
                            _specialInstructions = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Например: без лука, острее и т.д.',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Рекомендуемые блюда
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120), // Дополнительный отступ снизу для кнопки
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'С этим также заказывают',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Рекомендуемые блюда будут здесь
                      SizedBox(
                        height: 220,
                        child: _buildRecommendedItems(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Кнопка добавления в корзину (фиксированная внизу)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: AddToCartButton(
                  itemName: _foodItem!.name,
                  price: _foodItem!.price,
                  quantity: _quantity,
                  onDecreaseQuantity: _decreaseQuantity,
                  onIncreaseQuantity: _increaseQuantity,
                  onAddToCart: _addToCart,
                  isLoading: _isAddingToCart,
                  heroTag: 'add_to_cart_${_foodItem!.id}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendedItems() {
    final foodProvider = Provider.of<FoodProvider>(context);
    final List<food_model.Food> recommendedFoods = foodProvider.getSimilarFoods(_foodItem!.id, 5);
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recommendedFoods.length,
      itemBuilder: (context, index) {
        final food = recommendedFoods[index];
        final foodItem = FoodAdapter.toFoodItem(food);
        
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 160,
            child: FoodCard(
              foodItem: foodItem,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => FoodDetailsScreen(foodId: food.id),
                  ),
                );
              },
              isGrid: true,
            ),
          ),
        );
      },
    );
  }
} 