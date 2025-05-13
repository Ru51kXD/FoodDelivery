import 'package:flutter/foundation.dart';
import 'order.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<String> favoriteRestaurants;
  final List<String> favoriteFoods;
  final List<Order> orders;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? fcmToken;
  
  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.avatarUrl,
    this.addresses = const [],
    this.paymentMethods = const [],
    this.favoriteRestaurants = const [],
    this.favoriteFoods = const [],
    this.orders = const [],
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.fcmToken,
  });
  
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarUrl,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    List<String>? favoriteRestaurants,
    List<String>? favoriteFoods,
    List<Order>? orders,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      orders: orders ?? this.orders,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
  
  // Метод для создания объекта User из карты базы данных
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      favoriteRestaurants: (map['favorite_restaurants'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      favoriteFoods: (map['favorite_foods'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      isEmailVerified: (map['is_email_verified'] as int?) == 1,
      isPhoneVerified: (map['is_phone_verified'] as int?) == 1,
    );
  }
  
  // Метод для преобразования объекта User в карту для базы данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
      'favorite_restaurants': favoriteRestaurants.join(','),
      'favorite_foods': favoriteFoods.join(','),
      'is_email_verified': isEmailVerified ? 1 : 0,
      'is_phone_verified': isPhoneVerified ? 1 : 0,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      addresses: json['addresses'] != null
          ? List<Address>.from(
              json['addresses'].map((address) => Address.fromJson(address)))
          : [],
      paymentMethods: json['paymentMethods'] != null
          ? List<PaymentMethod>.from(
              json['paymentMethods'].map((method) => PaymentMethod.fromJson(method)))
          : [],
      favoriteRestaurants: List<String>.from(json['favoriteRestaurants'] ?? []),
      favoriteFoods: List<String>.from(json['favoriteFoods'] ?? []),
      orders: json['orders'] != null 
          ? List<Order>.from(json['orders'].map((order) => 
              Order.fromJson(order, []))) // Предполагается, что CartItems будут загружены отдельно
          : [],
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      fcmToken: json['fcmToken'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'avatarUrl': avatarUrl,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'paymentMethods': paymentMethods.map((method) => method.toJson()).toList(),
      'favoriteRestaurants': favoriteRestaurants,
      'favoriteFoods': favoriteFoods,
      'orders': orders.map((order) => order.toJson()).toList(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'fcmToken': fcmToken,
    };
  }
}

class Address {
  final String id;
  final String street;
  final String house;
  final String? apartment;
  final String? entrance;
  final int? floor;
  final String? note;
  final bool isDefault;
  
  Address({
    required this.id,
    required this.street,
    required this.house,
    this.apartment,
    this.entrance,
    this.floor,
    this.note,
    this.isDefault = false,
  });
  
  Address copyWith({
    String? id,
    String? street,
    String? house,
    String? apartment,
    String? entrance,
    int? floor,
    String? note,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      house: house ?? this.house,
      apartment: apartment ?? this.apartment,
      entrance: entrance ?? this.entrance,
      floor: floor ?? this.floor,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      house: json['house'],
      apartment: json['apartment'],
      entrance: json['entrance'],
      floor: json['floor'] != null ? json['floor'] as int : null,
      note: json['note'],
      isDefault: json['isDefault'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'house': house,
      'apartment': apartment,
      'entrance': entrance,
      'floor': floor,
      'note': note,
      'isDefault': isDefault,
    };
  }
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String title; // название метода оплаты, например, "Visa •••• 1234"
  final bool isDefault;
  // Данные для банковской карты
  final String? cardBrand; // Visa, MasterCard, и т.д.
  final String? last4; // Последние 4 цифры карты
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardholderName;
  
  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    this.isDefault = false,
    this.cardBrand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.cardholderName,
  });
  
  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? title,
    bool? isDefault,
    String? cardBrand,
    String? last4,
    String? expiryMonth,
    String? expiryYear,
    String? cardholderName,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      isDefault: isDefault ?? this.isDefault,
      cardBrand: cardBrand ?? this.cardBrand,
      last4: last4 ?? this.last4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardholderName: cardholderName ?? this.cardholderName,
    );
  }
  
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => PaymentType.cash,
      ),
      title: json['title'],
      isDefault: json['isDefault'] ?? false,
      cardBrand: json['cardBrand'],
      last4: json['last4'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cardholderName: json['cardholderName'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'isDefault': isDefault,
      'cardBrand': cardBrand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardholderName': cardholderName,
    };
  }
}

enum PaymentType {
  cash,
  card,
  applepay,
  googlepay,
} 