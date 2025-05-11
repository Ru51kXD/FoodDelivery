import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import '../models/promo_code.dart';
import '../services/loyalty_service.dart';
import '../widgets/promo_code_input.dart';
import 'order_success_screen.dart';
import '../models/delivery_time_slot.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _loyaltyService = LoyaltyService();
  final _commentController = TextEditingController();
  final _promoController = TextEditingController();
  
  String _selectedPaymentMethod = 'Наличные';
  bool _isProcessing = false;
  PromoCode? _appliedPromoCode;
  bool _useLoyaltyPoints = false;
  int _availablePoints = 0;
  int _pointsToUse = 0;
  bool _isScheduledDelivery = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  DeliveryTimeSlot? _selectedTimeSlot;
  bool _isPromoValid = false;
  double _promoDiscount = 0.0;
  
  // Доступные временные слоты доставки
  final List<DeliveryTimeSlot> _timeSlots = [
    DeliveryTimeSlot(
      id: '1',
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
      isAvailable: true,
    ),
    DeliveryTimeSlot(
      id: '2',
      startTime: TimeOfDay(hour: 12, minute: 0),
      endTime: TimeOfDay(hour: 14, minute: 0),
      isAvailable: true,
    ),
    DeliveryTimeSlot(
      id: '3',
      startTime: TimeOfDay(hour: 14, minute: 0),
      endTime: TimeOfDay(hour: 16, minute: 0),
      isAvailable: true,
    ),
    DeliveryTimeSlot(
      id: '4',
      startTime: TimeOfDay(hour: 16, minute: 0),
      endTime: TimeOfDay(hour: 18, minute: 0),
      isAvailable: true,
    ),
    DeliveryTimeSlot(
      id: '5',
      startTime: TimeOfDay(hour: 18, minute: 0),
      endTime: TimeOfDay(hour: 20, minute: 0),
      isAvailable: true,
    ),
    DeliveryTimeSlot(
      id: '6',
      startTime: TimeOfDay(hour: 20, minute: 0),
      endTime: TimeOfDay(hour: 22, minute: 0),
      isAvailable: true,
    ),
  ];
  
  // Словарь промокодов
  final Map<String, double> _promoCodes = {
    'WELCOME': 10.0,
    'SALE20': 20.0,
    'FOOD50': 50.0,
    'СКИДКА15': 15.0,
  };
  
  @override
  void initState() {
    super.initState();
    _loadLoyaltyPoints();
  }

  Future<void> _loadLoyaltyPoints() async {
    // TODO: Заменить на реальный ID пользователя
    const userId = 'user123';
    final loyaltyProgram = await _loyaltyService.getUserLoyaltyProgram(userId);
    setState(() {
      _availablePoints = loyaltyProgram.points;
    });
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _handlePromoCodeApplied(PromoCode? promoCode) {
    setState(() {
      _appliedPromoCode = promoCode;
    });
  }

  void _handlePromoCodeError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  void _toggleLoyaltyPoints(bool? value) {
    setState(() {
      _useLoyaltyPoints = value ?? false;
      if (!_useLoyaltyPoints) {
        _pointsToUse = 0;
      }
    });
  }

  void _updatePointsToUse(int points) {
    setState(() {
      _pointsToUse = points;
    });
  }
  
  void _processOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });
      
      // Имитация обработки заказа
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // После обработки заказа очищаем корзину
      context.read<CartProvider>().clearCart();
      
      // Переходим на экран успешного заказа
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            deliveryAddress: _addressController.text,
            customerName: _nameController.text,
          ),
        ),
      );
    }
  }

  double _calculateDiscount() {
    double discount = 0;
    
    // Скидка по промокоду
    if (_appliedPromoCode != null) {
      discount += _appliedPromoCode!.calculateDiscount(_getSubtotal());
    }
    
    // Скидка по бонусным баллам (1 балл = 1 рубль)
    if (_useLoyaltyPoints && _pointsToUse > 0) {
      discount += _pointsToUse.toDouble();
    }
    
    return discount;
  }

  double _getSubtotal() {
    final cartProvider = Provider.of<CartProvider>(context);
    return cartProvider.totalPrice;
  }

  double _getDeliveryFee() {
    return 150.0;
  }

  double _getServiceFee() {
    return 50.0;
  }

  double _getTotal() {
    return _getSubtotal() + _getDeliveryFee() + _getServiceFee() - _calculateDiscount();
  }

  // Проверка промокода
  void _checkPromoCode() {
    final promoCode = _promoController.text.trim().toUpperCase();
    
    if (_promoCodes.containsKey(promoCode)) {
      setState(() {
        _isPromoValid = true;
        _promoDiscount = _promoCodes[promoCode]!;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Промокод применен! Скидка: $_promoDiscount%'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _isPromoValid = false;
        _promoDiscount = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Недействительный промокод'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Выбор даты доставки
  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate;
      });
    }
  }
  
  // Форматирование времени доставки
  String _formatTimeSlot(DeliveryTimeSlot slot) {
    return '${slot.startTime.hour}:${slot.startTime.minute.toString().padLeft(2, '0')} - '
        '${slot.endTime.hour}:${slot.endTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Получение полной информации о доставке
  String _getDeliveryInfo() {
    if (!_isScheduledDelivery) {
      return 'Как можно скорее';
    }
    
    final dateStr = DateFormat('dd.MM.yyyy').format(_scheduledDate!);
    final timeStr = _selectedTimeSlot != null 
        ? _formatTimeSlot(_selectedTimeSlot!)
        : 'Время не выбрано';
        
    return '$dateStr, $timeStr';
  }
  
  // Расчет общей суммы заказа с учетом скидки
  double _calculateTotal(double subtotal) {
    final deliveryFee = 99.0;
    double total = subtotal + deliveryFee;
    
    if (_isPromoValid) {
      final discount = total * (_promoDiscount / 100);
      total -= discount;
    }
    
    return total;
  }
  
  // Оформление заказа
  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      // Здесь будет логика оформления заказа
      setState(() {
        _isProcessing = true;
      });
      
      // Имитация задержки заказа
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          // Очистка корзины
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          cartProvider.clearCart();
          
          // Показ сообщения об успешном заказе
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isScheduledDelivery
                    ? 'Ваш заказ оформлен на ${_getDeliveryInfo()}'
                    : 'Ваш заказ оформлен! Ожидайте доставку.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Возврат на предыдущий экран
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final subtotal = cartProvider.totalPrice;
    final total = _calculateTotal(subtotal);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Оформление заказа',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Контактная информация
                  Text(
                    'Контактная информация',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Имя
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Ваше имя',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите ваше имя';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Телефон
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Номер телефона',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите номер телефона';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Адрес доставки
                  Text(
                    'Адрес доставки',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Поле адреса
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'Укажите точный адрес доставки',
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите адрес доставки';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Способ оплаты
                  Text(
                    'Способ оплаты',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Выбор способа оплаты
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 24),
                  
                  // Промокод
                  PromoCodeInput(
                    orderAmount: _getSubtotal(),
                    onPromoCodeApplied: _handlePromoCodeApplied,
                    onError: _handlePromoCodeError,
                  ),
                  const SizedBox(height: 16),
                  
                  // Бонусные баллы
                  if (_availablePoints > 0) _buildLoyaltyPointsSection(),
                  const SizedBox(height: 24),
                  
                  // Информация о заказе
                  Text(
                    'Информация о заказе',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Итоговая информация
                  _buildOrderInfoItem('Товары (${cartProvider.itemCount})', '${_getSubtotal().toStringAsFixed(0)} ₽'),
                  _buildOrderInfoItem('Доставка', '${_getDeliveryFee().toStringAsFixed(0)} ₽'),
                  _buildOrderInfoItem('Сервисный сбор', '${_getServiceFee().toStringAsFixed(0)} ₽'),
                  
                  // Скидки
                  if (_calculateDiscount() > 0) ...[
                    _buildOrderInfoItem(
                      'Скидка',
                      '-${_calculateDiscount().toStringAsFixed(0)} ₽',
                      isDiscount: true,
                    ),
                  ],
                  
                  const Divider(height: 32),
                  _buildOrderInfoItem(
                    'Итого',
                    '${_getTotal().toStringAsFixed(0)} ₽',
                    isBold: true,
                  ),
                  const SizedBox(height: 40),
                  
                  // Время доставки
                  _buildSectionTitle('Время доставки'),
                  SwitchListTile(
                    title: Text(
                      'Запланировать доставку',
                      style: GoogleFonts.poppins(),
                    ),
                    value: _isScheduledDelivery,
                    onChanged: (value) {
                      setState(() {
                        _isScheduledDelivery = value;
                        if (value && _scheduledDate == null) {
                          _scheduledDate = DateTime.now().add(const Duration(days: 1));
                        }
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  
                  if (_isScheduledDelivery) ...[
                    const SizedBox(height: 8),
                    // Выбор даты
                    ListTile(
                      title: Text(
                        'Дата доставки',
                        style: GoogleFonts.poppins(),
                      ),
                      subtitle: Text(
                        _scheduledDate != null 
                            ? DateFormat('dd.MM.yyyy').format(_scheduledDate!)
                            : 'Выберите дату',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Заголовок временных слотов
                    Text(
                      'Выберите временной слот:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Список временных слотов
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _timeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot?.id == slot.id;
                        return ChoiceChip(
                          label: Text(_formatTimeSlot(slot)),
                          selected: isSelected,
                          selectedColor: Colors.deepOrange,
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: slot.isAvailable ? (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                          } : null,
                          backgroundColor: slot.isAvailable 
                              ? Colors.grey[200]
                              : Colors.grey[300],
                          disabledColor: Colors.grey[300],
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Способ оплаты
                  _buildSectionTitle('Способ оплаты'),
                  _buildPaymentMethodRadio('Наличные', 'Оплата наличными при получении'),
                  _buildPaymentMethodRadio('Карта', 'Оплата картой при получении'),
                  _buildPaymentMethodRadio('Онлайн', 'Онлайн-оплата картой'),
                  
                  const SizedBox(height: 24),
                  
                  // Промокод
                  _buildSectionTitle('Промокод'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            hintText: 'Введите промокод',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _isPromoValid
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _checkPromoCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Применить',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Комментарий к заказу
                  _buildSectionTitle('Комментарий к заказу'),
                  TextFormField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Комментарий к заказу (необязательно)',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Итоговая сумма
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow('Сумма заказа', '${subtotal.toStringAsFixed(0)} ₽'),
                        _buildPriceRow('Доставка', '99 ₽'),
                        if (_isPromoValid)
                          _buildPriceRow(
                            'Скидка',
                            '- ${((subtotal + 99) * _promoDiscount / 100).toStringAsFixed(0)} ₽',
                            valueColor: Colors.green,
                          ),
                        const Divider(),
                        _buildPriceRow(
                          'Итого',
                          '${total.toStringAsFixed(0)} ₽',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Кнопка оформления заказа
                  ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Оформить заказ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoyaltyPointsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Бонусные баллы',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Доступно: $_availablePoints',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Использовать бонусные баллы'),
              value: _useLoyaltyPoints,
              onChanged: _toggleLoyaltyPoints,
            ),
            if (_useLoyaltyPoints) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _pointsToUse.toDouble(),
                      min: 0,
                      max: _availablePoints.toDouble(),
                      divisions: _availablePoints,
                      label: '$_pointsToUse баллов',
                      onChanged: (value) => _updatePointsToUse(value.round()),
                    ),
                  ),
                  Text(
                    '$_pointsToUse',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(' баллов'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.deepOrange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        // Оплата картой
        _buildPaymentMethodItem(
          title: 'Банковская карта',
          subtitle: 'Visa, MasterCard, Мир',
          icon: Icons.credit_card,
          value: 'card',
        ),
        const SizedBox(height: 12),
        
        // Наличными
        _buildPaymentMethodItem(
          title: 'Наличными курьеру',
          subtitle: 'Оплата при получении',
          icon: Icons.money,
          value: 'cash',
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: Colors.deepOrange,
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoItem(String title, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? Colors.deepOrange : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodRadio(String value, String title) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: GoogleFonts.poppins(),
      ),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (newValue) {
        setState(() {
          _selectedPaymentMethod = newValue!;
        });
      },
      activeColor: Colors.deepOrange,
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
} 