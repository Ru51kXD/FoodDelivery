import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/courier.dart' as courier_model;

class CourierService {
  // Имитация получения информации о курьере
  Future<courier_model.Courier> getCourierInfo(String courierId) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
    return courier_model.Courier(
      id: courierId,
      name: 'Иван Петров',
      phone: '+7 (999) 123-45-67',
      vehicleType: 'Автомобиль',
      vehicleNumber: 'A123BC',
      rating: 4.8,
      currentLocation: const LatLng(55.7558, 37.6173),
      completedDeliveries: 150,
    );
  }

  // Имитация получения маршрута курьера
  Future<List<LatLng>> getCourierRoute(String orderId) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
    return [
      const LatLng(55.7558, 37.6173), // Текущее местоположение
      const LatLng(55.7559, 37.6174),
      const LatLng(55.7560, 37.6175),
      const LatLng(55.7561, 37.6176),
      const LatLng(55.7562, 37.6177), // Местоположение заказа
    ];
  }

  // Имитация получения примерного времени доставки
  Future<int> getEstimatedDeliveryTime(String orderId) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
    return 15; // минут
  }

  // Имитация получения истории сообщений
  Future<List<courier_model.CourierMessage>> getChatHistory(String orderId) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
    return [
      courier_model.CourierMessage(
        id: '1',
        orderId: orderId,
        senderId: 'courier1',
        sender: courier_model.MessageSender.courier,
        text: 'Здравствуйте! Я курьер, скоро буду у вас.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      courier_model.CourierMessage(
        id: '2',
        orderId: orderId,
        senderId: 'user1',
        sender: courier_model.MessageSender.user,
        text: 'Спасибо, буду ждать!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }

  // Имитация отправки сообщения
  Future<void> sendMessage(String orderId, String text) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
  }

  // Имитация оценки курьера
  Future<void> rateCourier(String courierId, double rating, String comment) async {
    // В реальном приложении здесь будет запрос к API
    await Future.delayed(const Duration(seconds: 1));
  }

  // Имитация отслеживания местоположения курьера
  Stream<LatLng> trackCourierLocation(String courierId) async* {
    // В реальном приложении здесь будет WebSocket соединение
    final route = [
      const LatLng(55.7558, 37.6173),
      const LatLng(55.7559, 37.6174),
      const LatLng(55.7560, 37.6175),
      const LatLng(55.7561, 37.6176),
      const LatLng(55.7562, 37.6177),
    ];

    for (var location in route) {
      await Future.delayed(const Duration(seconds: 2));
      yield location;
    }
  }
} 