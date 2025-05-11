import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_tracking_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String deliveryAddress;
  final String customerName;
  final String? orderId;
  final String? courierId;

  const OrderSuccessScreen({
    super.key,
    required this.deliveryAddress,
    required this.customerName,
    this.orderId,
    this.courierId,
  });

  @override
  Widget build(BuildContext context) {
    // Генерация номера заказа, если не был передан
    final orderNumber = orderId ?? 'OD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}';
    
    // Расчет предполагаемого времени доставки (30-45 минут от текущего времени)
    final now = DateTime.now();
    final deliveryTimeStart = now.add(const Duration(minutes: 30));
    final deliveryTimeEnd = now.add(const Duration(minutes: 45));
    
    final timeFormat = (DateTime time) => 
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    final estimatedDeliveryTime = 
        '${timeFormat(deliveryTimeStart)} - ${timeFormat(deliveryTimeEnd)}';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Анимация успеха
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Заголовок успешного заказа
                    Text(
                      'Заказ оформлен!',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Сообщение об успешном заказе
                    Text(
                      'Ваш заказ успешно оформлен и скоро будет передан в доставку',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Информация о заказе
                    _buildOrderInfoCard(context, orderNumber, estimatedDeliveryTime),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Кнопки внизу экрана
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Возврат на главный экран
                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        '/', 
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Вернуться на главную',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Переход к отслеживанию заказа
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingScreen(
                            orderId: orderId ?? '',
                            courierId: courierId ?? '',
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      side: const BorderSide(color: Colors.deepOrange),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Отслеживать заказ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoCard(BuildContext context, String orderNumber, String estimatedDeliveryTime) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfoItem(
            'Номер заказа',
            orderNumber,
            Icons.receipt_long_outlined,
          ),
          const Divider(height: 30),
          _buildOrderInfoItem(
            'Время доставки',
            estimatedDeliveryTime,
            Icons.access_time,
          ),
          const Divider(height: 30),
          _buildOrderInfoItem(
            'Адрес доставки',
            deliveryAddress,
            Icons.location_on_outlined,
          ),
          const Divider(height: 30),
          _buildOrderInfoItem(
            'Получатель',
            customerName,
            Icons.person_outline,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderInfoItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.deepOrange,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 