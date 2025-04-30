import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/cart_provider.dart';
import 'order_success_screen.dart';

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
  
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  
  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalAmount = cartProvider.totalPrice + 200; // 200 = доставка + сбор
    
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
      body: Form(
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
            _buildOrderInfoItem('Товары (${cartProvider.itemCount})', '${cartProvider.totalPrice.toStringAsFixed(0)} ₽'),
            _buildOrderInfoItem('Доставка', '150 ₽'),
            _buildOrderInfoItem('Сервисный сбор', '50 ₽'),
            const Divider(height: 32),
            _buildOrderInfoItem(
              'Итого',
              '${totalAmount.toStringAsFixed(0)} ₽',
              isBold: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, totalAmount),
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
  
  Widget _buildOrderInfoItem(String title, String value, {bool isBold = false}) {
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
  
  Widget _buildBottomBar(BuildContext context, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[400],
          ),
          child: _isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Обработка заказа...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Оплатить ${totalAmount.toStringAsFixed(0)} ₽',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
} 