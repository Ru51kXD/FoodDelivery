import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String deliveryAddress;
  
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.deliveryAddress,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final List<OrderStatus> _orderStatuses = [
    OrderStatus(
      title: 'Заказ принят',
      description: 'Мы получили ваш заказ',
      icon: Icons.receipt_long_outlined,
      completed: true,
    ),
    OrderStatus(
      title: 'Приготовление',
      description: 'Ваш заказ готовится на кухне',
      icon: Icons.restaurant_outlined,
      completed: true,
    ),
    OrderStatus(
      title: 'В пути',
      description: 'Курьер забрал заказ и направляется к вам',
      icon: Icons.delivery_dining_outlined,
      completed: false,
    ),
    OrderStatus(
      title: 'Доставлен',
      description: 'Заказ доставлен и получен',
      icon: Icons.check_circle_outline,
      completed: false,
    ),
  ];

  late Timer _timer;
  int _currentStatusIndex = 1; // начинаем с этапа "Приготовление"
  int _deliveryTimeInMinutes = 35;
  
  @override
  void initState() {
    super.initState();
    // Имитация изменения статуса заказа каждые 15 секунд
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_currentStatusIndex < _orderStatuses.length - 1) {
        setState(() {
          _currentStatusIndex++;
          _orderStatuses[_currentStatusIndex].completed = true;
          
          // Уменьшаем оставшееся время доставки
          if (_deliveryTimeInMinutes > 10) {
            _deliveryTimeInMinutes -= 5;
          }
        });
      } else {
        _timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Отслеживание заказа',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о заказе
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Номер заказа
                  Text(
                    'Заказ ${widget.orderId}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Время доставки
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ожидаемое время доставки: $_deliveryTimeInMinutes мин',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Адрес доставки
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.deliveryAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Карта доставки (имитация)
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://t4.ftcdn.net/jpg/03/32/80/33/240_F_332803324_Agcc94hAzkrPMwfCfpAzLZfkZiTw4IFm.jpg'
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Индикатор "в пути"
                  if (_orderStatuses[2].completed && !_orderStatuses[3].completed)
                    const Positioned(
                      top: 80,
                      left: 120,
                      child: Icon(
                        Icons.delivery_dining,
                        color: Colors.deepOrange,
                        size: 40,
                      ),
                    ),
                  
                  const Positioned(
                    bottom: 20,
                    right: 20,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            
            // Статус-бар заказа
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Статус заказа',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Список статусов
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orderStatuses.length,
              itemBuilder: (context, index) {
                return _buildStatusItem(
                  _orderStatuses[index],
                  index,
                  isLast: index == _orderStatuses.length - 1,
                  isActive: index == _currentStatusIndex,
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Контакт с курьером (появляется только если заказ в пути)
            if (_orderStatuses[2].completed && !_orderStatuses[3].completed)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://i.pravatar.cc/150?img=65'
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Иван К.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Ваш курьер',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Функция звонка курьеру
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Звонок курьеру...'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.deepOrange,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Функция сообщения курьеру
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Сообщение курьеру...'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.message,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusItem(OrderStatus status, int index, {bool isLast = false, bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Индикатор статуса
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: status.completed ? Colors.deepOrange : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status.icon,
                  color: status.completed ? Colors.white : Colors.grey[500],
                  size: 16,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: status.completed ? Colors.deepOrange : Colors.grey[300],
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Информация о статусе
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status.completed ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatus {
  final String title;
  final String description;
  final IconData icon;
  bool completed;
  
  OrderStatus({
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
  });
} 