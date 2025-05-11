import 'package:flutter/material.dart';

enum MessageType {
  text,
  image,
  location,
}

enum MessageSender {
  user,
  courier,
}

class CourierMessage {
  final String id;
  final String orderId;
  final String senderId;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, double>? location;

  CourierMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.location,
  });

  factory CourierMessage.fromJson(Map<String, dynamic> json) {
    return CourierMessage(
      id: json['id'],
      orderId: json['orderId'],
      senderId: json['senderId'],
      sender: MessageSender.values.firstWhere(
        (s) => s.toString().split('.').last == json['sender'],
      ),
      type: MessageType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      location: json['location'] != null
          ? Map<String, double>.from(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'sender': sender.toString().split('.').last,
      'type': type.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'location': location,
    };
  }
} 