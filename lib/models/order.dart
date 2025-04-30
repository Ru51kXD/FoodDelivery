import 'cart_item.dart';

enum OrderStatus {
  pending,      // ожидает обработки
  confirmed,    // подтвержден рестораном
  preparing,    // готовится
  ready,        // готов к доставке
  delivering,   // в пути
  delivered,    // доставлен
  cancelled,    // отменен
}

class Order {
  final String id;
  final List<CartItem> items;
  final String restaurantId;
  final String restaurantName;
  final DateTime createdAt;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;
  final OrderStatus status;
  final DeliveryInfo deliveryInfo;
  final PaymentInfo paymentInfo;
  final String? promoCode;
  final double? discount;
  
  Order({
    required this.id,
    required this.items,
    required this.restaurantId,
    required this.restaurantName,
    required this.createdAt,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.totalAmount,
    required this.status,
    required this.deliveryInfo,
    required this.paymentInfo,
    this.promoCode,
    this.discount,
  });
  
  factory Order.fromJson(Map<String, dynamic> json, List<CartItem> cartItems) {
    return Order(
      id: json['id'],
      items: cartItems,
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      createdAt: DateTime.parse(json['createdAt']),
      subtotal: json['subtotal'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      serviceFee: json['serviceFee'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryInfo: DeliveryInfo.fromJson(json['deliveryInfo']),
      paymentInfo: PaymentInfo.fromJson(json['paymentInfo']),
      promoCode: json['promoCode'],
      discount: json['discount']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemIds': items.map((item) => item.id).toList(),
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'createdAt': createdAt.toIso8601String(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryInfo': deliveryInfo.toJson(),
      'paymentInfo': paymentInfo.toJson(),
      'promoCode': promoCode,
      'discount': discount,
    };
  }
  
  // Получение примерного времени доставки в минутах
  int get estimatedDeliveryTimeInMinutes {
    // Расчет времени доставки в зависимости от статуса
    switch (status) {
      case OrderStatus.pending:
        return 60; // Если ожидает обработки - около часа
      case OrderStatus.confirmed:
        return 50; // Если подтвержден - около 50 минут
      case OrderStatus.preparing:
        return 30; // Если готовится - около 30 минут
      case OrderStatus.ready:
        return 20; // Если готов к доставке - около 20 минут
      case OrderStatus.delivering:
        return 15; // Если в пути - около 15 минут
      case OrderStatus.delivered:
        return 0; // Уже доставлен
      case OrderStatus.cancelled:
        return 0; // Отменен
    }
  }
  
  // Получение строки статуса на русском языке
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает обработки';
      case OrderStatus.confirmed:
        return 'Подтвержден';
      case OrderStatus.preparing:
        return 'Готовится';
      case OrderStatus.ready:
        return 'Готов к доставке';
      case OrderStatus.delivering:
        return 'В пути';
      case OrderStatus.delivered:
        return 'Доставлен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }
}

class DeliveryInfo {
  final String address;
  final String customerName;
  final String phoneNumber;
  final String? apartment;
  final String? buildingCode;
  final String? floor;
  final String? deliveryInstructions;
  final DeliveryType deliveryType;
  final Map<String, double>? coordinates; // широта и долгота
  
  DeliveryInfo({
    required this.address,
    required this.customerName,
    required this.phoneNumber,
    this.apartment,
    this.buildingCode,
    this.floor,
    this.deliveryInstructions,
    required this.deliveryType,
    this.coordinates,
  });
  
  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      address: json['address'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      apartment: json['apartment'],
      buildingCode: json['buildingCode'],
      floor: json['floor'],
      deliveryInstructions: json['deliveryInstructions'],
      deliveryType: DeliveryType.values.firstWhere(
        (type) => type.toString().split('.').last == json['deliveryType'],
        orElse: () => DeliveryType.delivery,
      ),
      coordinates: json['coordinates'] != null
          ? Map<String, double>.from(json['coordinates'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'apartment': apartment,
      'buildingCode': buildingCode,
      'floor': floor,
      'deliveryInstructions': deliveryInstructions,
      'deliveryType': deliveryType.toString().split('.').last,
      'coordinates': coordinates,
    };
  }
}

enum DeliveryType {
  delivery,  // доставка
  pickup,    // самовывоз
}

class PaymentInfo {
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? cardLast4;
  final String? transactionId;
  
  PaymentInfo({
    required this.paymentMethod,
    required this.paymentStatus,
    this.cardLast4,
    this.transactionId,
  });
  
  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      cardLast4: json['cardLast4'],
      transactionId: json['transactionId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'cardLast4': cardLast4,
      'transactionId': transactionId,
    };
  }
}

enum PaymentMethod {
  cash,       // наличные
  card,       // банковская карта
  applepay,   // Apple Pay
  googlepay,  // Google Pay
}

enum PaymentStatus {
  pending,    // в ожидании
  completed,  // завершен
  failed,     // не удался
  refunded,   // возвращен
} 