import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Courier {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double rating;
  final LatLng currentLocation;
  final String? avatarUrl;
  final int completedDeliveries;

  Courier({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.rating,
    required this.currentLocation,
    this.avatarUrl,
    this.completedDeliveries = 0,
  });

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      rating: (json['rating'] as num).toDouble(),
      currentLocation: LatLng(
        json['currentLocation']['latitude'] as double,
        json['currentLocation']['longitude'] as double,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      completedDeliveries: json['completedDeliveries'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
      'currentLocation': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'avatarUrl': avatarUrl,
      'completedDeliveries': completedDeliveries,
    };
  }
}

class CourierMessage {
  final String id;
  final String orderId;
  final String senderId;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;

  CourierMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory CourierMessage.fromJson(Map<String, dynamic> json) {
    return CourierMessage(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      senderId: json['senderId'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == 'MessageSender.${json['sender']}',
        orElse: () => MessageSender.user,
      ),
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'sender': sender.toString().split('.').last,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum MessageSender {
  user,
  courier,
} 