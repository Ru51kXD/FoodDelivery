import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'order_item.dart';
import 'food.dart';

enum OrderStatus {
  pending,      // ожидает обработки
  confirmed,    // подтвержден рестораном
  preparing,    // готовится
  ready,        // готов к доставке
  onTheWay,     // в пути
  delivered,    // доставлен
  cancelled,    // отменен
}

class CartItem {
  final Food food;
  final int quantity;

  CartItem({
    required this.food,
    required this.quantity,
  });

  double get totalPrice => food.price * quantity;
}

class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double totalAmount;
  final String deliveryAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? courierId; // ID курьера, доставляющего заказ
  final DeliveryInfo deliveryInfo;
  final PaymentInfo paymentInfo;
  final String? promoCode;
  final double? discount;
  final List<CartItem> cartItems;
  
  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    this.courierId,
    required this.deliveryInfo,
    required this.paymentInfo,
    this.promoCode,
    this.discount,
    required this.cartItems,
  });
  
  factory Order.fromJson(Map<String, dynamic> json, List<CartItem> items) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      courierId: json['courierId'] as String?,
      deliveryInfo: DeliveryInfo.fromJson(json['deliveryInfo'] as Map<String, dynamic>),
      paymentInfo: PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>),
      promoCode: json['promoCode'] as String?,
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      cartItems: items,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'courierId': courierId,
      'deliveryInfo': deliveryInfo.toJson(),
      'paymentInfo': paymentInfo.toJson(),
      'promoCode': promoCode,
      'discount': discount,
    };
  }
  
  Order copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? serviceFee,
    double? totalAmount,
    String? deliveryAddress,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? courierId,
    DeliveryInfo? deliveryInfo,
    PaymentInfo? paymentInfo,
    String? promoCode,
    double? discount,
    List<CartItem>? cartItems,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      courierId: courierId ?? this.courierId,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      promoCode: promoCode ?? this.promoCode,
      discount: discount ?? this.discount,
      cartItems: cartItems ?? this.cartItems,
    );
  }
  
  // Получение примерного времени доставки в минутах
  int getEstimatedDeliveryTime() {
    switch (status) {
      case OrderStatus.pending:
        return 45;
      case OrderStatus.confirmed:
        return 40;
      case OrderStatus.preparing:
        return 30;
      case OrderStatus.ready:
        return 25;
      case OrderStatus.onTheWay:
        return 15;
      case OrderStatus.delivered:
        return 0;
      case OrderStatus.cancelled:
        return 0;
    }
  }
  
  // Получение цвета статуса заказа
  Color getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.indigo;
      case OrderStatus.onTheWay:
        return Colors.deepOrange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
  
  // Получение текста статуса заказа
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает подтверждения';
      case OrderStatus.confirmed:
        return 'Подтвержден';
      case OrderStatus.preparing:
        return 'Готовится';
      case OrderStatus.ready:
        return 'Готов к доставке';
      case OrderStatus.onTheWay:
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
  final String? apartment;
  final String? entrance;
  final String? floor;
  final String? intercom;
  final String? instructions;

  DeliveryInfo({
    required this.address,
    this.apartment,
    this.entrance,
    this.floor,
    this.intercom,
    this.instructions,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      address: json['address'] as String,
      apartment: json['apartment'] as String?,
      entrance: json['entrance'] as String?,
      floor: json['floor'] as String?,
      intercom: json['intercom'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'apartment': apartment,
      'entrance': entrance,
      'floor': floor,
      'intercom': intercom,
      'instructions': instructions,
    };
  }
}

class PaymentInfo {
  final String method;
  final String? cardNumber;
  final String? cardHolder;
  final String? transactionId;

  PaymentInfo({
    required this.method,
    this.cardNumber,
    this.cardHolder,
    this.transactionId,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: json['method'] as String,
      cardNumber: json['cardNumber'] as String?,
      cardHolder: json['cardHolder'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'transactionId': transactionId,
    };
  }
}

enum DeliveryType {
  delivery,  // доставка
  pickup,    // самовывоз
} 