import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/courier.dart';
import '../models/courier_message.dart';

class OrderService {
  // Получение списка заказов пользователя
  Future<List<Order>> getUserOrders(String userId) async {
    // TODO: Реализовать получение заказов из API
    return [
      Order(
        id: '1',
        userId: userId,
        restaurantId: '1',
        restaurantName: 'Burger King',
        items: [
          OrderItem(
            id: '1',
            name: 'Воппер',
            price: 399,
            quantity: 2,
          ),
          OrderItem(
            id: '2',
            name: 'Картофель Фри',
            price: 149,
            quantity: 1,
          ),
        ],
        subtotal: 947,
        deliveryFee: 149,
        serviceFee: 50,
        totalAmount: 1146,
        deliveryAddress: 'ул. Ленина, 10, кв. 5',
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        deliveredAt: DateTime.now().subtract(const Duration(hours: 1)),
        courierId: '1',
        deliveryInfo: DeliveryInfo(
          address: 'ул. Ленина, 10',
          apartment: '5',
          entrance: '2',
          floor: '3',
          intercom: '1234',
          instructions: 'Позвонить за 5 минут',
        ),
        paymentInfo: PaymentInfo(
          method: 'card',
          cardNumber: '**** **** **** 1234',
          cardHolder: 'IVAN IVANOV',
          transactionId: 'TR123456',
        ),
      ),
      Order(
        id: '2',
        userId: userId,
        restaurantId: '2',
        restaurantName: 'KFC',
        items: [
          OrderItem(
            id: '3',
            name: 'Боксмастер',
            price: 299,
            quantity: 1,
          ),
          OrderItem(
            id: '4',
            name: 'Кока-Кола',
            price: 99,
            quantity: 2,
          ),
        ],
        subtotal: 497,
        deliveryFee: 149,
        serviceFee: 50,
        totalAmount: 696,
        deliveryAddress: 'пр. Мира, 15, кв. 10',
        status: OrderStatus.onTheWay,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        courierId: '2',
        deliveryInfo: DeliveryInfo(
          address: 'пр. Мира, 15',
          apartment: '10',
          entrance: '1',
          floor: '5',
          intercom: '5678',
        ),
        paymentInfo: PaymentInfo(
          method: 'cash',
          transactionId: 'TR789012',
        ),
      ),
    ];
  }

  // Получение деталей заказа
  Future<Order> getOrderDetails(String orderId) async {
    // TODO: Реализовать получение деталей заказа из API
    final orders = await getUserOrders('user1');
    return orders.firstWhere((order) => order.id == orderId);
  }

  // Создание нового заказа
  Future<Order> createOrder(Order order) async {
    // TODO: Реализовать создание заказа через API
    print('Создание заказа: ${order.toJson()}');
    return order;
  }

  // Отмена заказа
  Future<void> cancelOrder(String orderId) async {
    // TODO: Реализовать отмену заказа через API
    print('Отмена заказа: $orderId');
  }

  // Обновление статуса заказа
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    // TODO: Реализовать обновление статуса через API
    print('Обновление статуса заказа $orderId: $status');
  }

  // Получение истории сообщений с курьером
  Future<List<CourierMessage>> getCourierChatHistory(String orderId) async {
    // TODO: Реализовать получение истории сообщений из API
    return [
      CourierMessage(
        id: '1',
        orderId: orderId,
        senderId: 'courier1',
        sender: MessageSender.courier,
        type: MessageType.text,
        content: 'Здравствуйте! Я курьер, скоро буду у вас.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
      CourierMessage(
        id: '2',
        orderId: orderId,
        senderId: 'user1',
        sender: MessageSender.user,
        type: MessageType.text,
        content: 'Спасибо! Буду ждать.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        isRead: true,
      ),
      CourierMessage(
        id: '3',
        orderId: orderId,
        senderId: 'courier1',
        sender: MessageSender.courier,
        type: MessageType.text,
        content: 'Я уже подъезжаю к вашему дому.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
    ];
  }

  // Отправка сообщения курьеру
  Future<void> sendMessageToCourier(CourierMessage message) async {
    // TODO: Реализовать отправку сообщения через API
    print('Отправка сообщения курьеру: ${message.toJson()}');
  }

  // Получение информации о курьере
  Future<Courier> getCourierInfo(String courierId) async {
    // TODO: Реализовать получение информации о курьере из API
    return Courier(
      id: courierId,
      name: 'Иван Петров',
      phoneNumber: '+7 (999) 123-45-67',
      avatarUrl: 'https://i.pravatar.cc/150?img=65',
      vehicleType: 'Мотоцикл',
      vehicleNumber: 'A123BC',
      rating: 4.8,
      completedDeliveries: 156,
      currentLocation: const LatLng(55.7558, 37.6173),
      isOnline: true,
    );
  }

  // Получение маршрута курьера
  Future<List<LatLng>> getCourierRoute(String orderId) async {
    // TODO: Реализовать получение маршрута из API
    return [
      const LatLng(55.7558, 37.6173), // Текущее местоположение курьера
      const LatLng(55.7560, 37.6175),
      const LatLng(55.7562, 37.6177),
      const LatLng(55.7564, 37.6179),
      const LatLng(55.7566, 37.6181), // Место доставки
    ];
  }

  // Получение примерного времени доставки
  Future<Duration> getEstimatedDeliveryTime(String orderId) async {
    // TODO: Реализовать получение времени доставки из API
    return const Duration(minutes: 15);
  }

  // Отслеживание местоположения курьера
  Stream<LatLng> trackCourierLocation(String courierId) async* {
    // TODO: Реализовать отслеживание местоположения через API
    final locations = [
      const LatLng(55.7558, 37.6173),
      const LatLng(55.7560, 37.6175),
      const LatLng(55.7562, 37.6177),
      const LatLng(55.7564, 37.6179),
      const LatLng(55.7566, 37.6181),
    ];

    for (final location in locations) {
      await Future.delayed(const Duration(seconds: 5));
      yield location;
    }
  }

  // Оценка курьера
  Future<void> rateCourier(String courierId, double rating, [String? comment]) async {
    // TODO: Реализовать оценку курьера через API
    print('Оценка курьера $courierId: $rating${comment != null ? ', комментарий: $comment' : ''}');
  }
} 