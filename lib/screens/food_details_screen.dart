import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../models/food_item.dart';
import '../models/cart_item.dart';
import '../providers/food_provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

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
  final Map<String, List<String>> _selectedOptions = {};
  String? _specialInstructions;
  bool _isAddingToCart = false;
  bool _isLoading = true;
  FoodItem? _foodItem;
  final _uuid = const Uuid();
  
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
      final foodItem = foodProvider.getFoodItemById(widget.foodId);
      
      if (foodItem != null) {
        setState(() {
          _foodItem = foodItem;
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
    
    double optionsPrice = 0;
    
    // Расчет цены с учетом выбранных опций
    for (final entry in _selectedOptions.entries) {
      final optionName = entry.key;
      final selectedChoices = entry.value;
      
      final options = _foodItem!.options;
      if (options == null || options.isEmpty) continue;
      
      final option = options.firstWhere(
        (option) => option.name == optionName,
        orElse: () => FoodOption(name: '', choices: []),
      );
      
      for (final choiceName in selectedChoices) {
        final choice = option.choices.firstWhere(
          (choice) => choice.name == choiceName,
          orElse: () => FoodOptionChoice(name: '', priceAdd: 0),
        );
        optionsPrice += choice.priceAdd;
      }
    }
    
    // Обновляем итоговую цену
    setState(() {
      _totalPrice = (_foodItem!.price + optionsPrice) * _quantity;
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
  
  void _toggleOption(String optionName, String choiceName) {
    if (_foodItem == null || _foodItem!.options == null || _foodItem!.options!.isEmpty) return;
    
    setState(() {
      // Получаем текущую опцию
      final option = _foodItem!.options!.firstWhere(
        (option) => option.name == optionName,
        orElse: () => FoodOption(name: '', choices: []),
      );
      
      // Инициализируем список выбранных вариантов, если его еще нет
      if (!_selectedOptions.containsKey(optionName)) {
        _selectedOptions[optionName] = [];
      }
      
      final selectedChoices = _selectedOptions[optionName]!;
      
      // Проверяем, выбран ли уже этот вариант
      if (selectedChoices.contains(choiceName)) {
        // Если вариант уже выбран и не является обязательным, удаляем его
        if (!option.required || selectedChoices.length > 1) {
          selectedChoices.remove(choiceName);
        }
      } else {
        // Если вариант не выбран, добавляем его
        
        // Если опция допускает только один вариант, сначала очищаем список
        if (option.maxChoices == 1) {
          selectedChoices.clear();
        }
        
        // Если не превышено максимальное количество вариантов, добавляем
        if (selectedChoices.length < option.maxChoices) {
          selectedChoices.add(choiceName);
        }
      }
      
      // Пересчитываем общую стоимость
      _calculateTotalPrice();
    });
  }
  
  Future<void> _addToCart() async {
    if (_foodItem == null) return;
    
    // Устанавливаем флаг, что добавляем в корзину
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      // Получаем провайдер корзины
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Создаем список выбранных опций в формате для CartItem
      final selectedOptions = _selectedOptions.entries.map((entry) {
        final optionName = entry.key;
        final selectedChoices = entry.value;
        
        if (_foodItem!.options == null || _foodItem!.options!.isEmpty) {
          return SelectedOption(name: optionName, choices: []);
        }
        
        final option = _foodItem!.options!.firstWhere(
          (option) => option.name == optionName,
          orElse: () => FoodOption(name: '', choices: []),
        );
        
        final choices = selectedChoices.map((choiceName) {
          final choice = option.choices.firstWhere(
            (choice) => choice.name == choiceName,
            orElse: () => FoodOptionChoice(name: '', priceAdd: 0),
          );
          
          return SelectedChoice(
            name: choiceName,
            priceAdd: choice.priceAdd,
          );
        }).toList();
        
        return SelectedOption(
          name: optionName,
          choices: choices,
        );
      }).toList();
      
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_foodItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: const Center(child: Text('Блюдо не найдено')),
      );
    }
    
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Гибкий AppBar с изображением блюда
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            elevation: _isAppBarCollapsed ? 4 : 0,
            title: _isAppBarCollapsed
                ? Text(
                    _foodItem!.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black,
                      ),
                    ),
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _foodItem!.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Информация о блюде
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название и цена блюда
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _foodItem!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _foodItem!.categories?.join(' • ') ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_foodItem!.price.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Рейтинг и время приготовления
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _foodItem!.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '(${_foodItem!.reviewCount})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_foodItem!.preparationTime} мин',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_foodItem!.isVegetarian)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Вегетарианское',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_foodItem!.isSpicy ?? false)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.red, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Острое',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Описание блюда
                  const Text(
                    'Описание',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _foodItem!.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Опции блюда (если есть)
                  if (_foodItem!.options != null && _foodItem!.options!.isNotEmpty) ...[
                    ..._foodItem!.options!.map((option) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                option.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (option.required)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Обязательно',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                option.maxChoices > 1
                                    ? 'Выберите до ${option.maxChoices}'
                                    : 'Выберите один',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...option.choices.map((choice) {
                            final isSelected = _selectedOptions[option.name]?.contains(choice.name) ?? false;
                            
                            return GestureDetector(
                              onTap: () {
                                _toggleOption(option.name, choice.name);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        choice.name,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (choice.priceAdd > 0)
                                          Text(
                                            '+${choice.priceAdd.toStringAsFixed(0)} ₽',
                                            style: TextStyle(
                                              color: isSelected ? Colors.deepOrange : Colors.grey[600],
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? Colors.deepOrange : Colors.grey[400]!,
                                            ),
                                            color: isSelected ? Colors.deepOrange : Colors.white,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ],
                  
                  // Поле для особых инструкций
                  const Text(
                    'Особые инструкции',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Например: "Без лука" или "Средняя прожарка"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _specialInstructions = value.isNotEmpty ? value : null;
                      });
                    },
                  ),
                  
                  // Пустое пространство внизу (для нижней панели)
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Нижняя панель с количеством и кнопкой добавления в корзину
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            // Селектор количества
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decreaseQuantity,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _increaseQuantity,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Кнопка добавления в корзину
            Expanded(
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Добавить ${_totalPrice.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 