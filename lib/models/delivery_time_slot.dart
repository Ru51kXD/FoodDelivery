import 'package:flutter/material.dart';

class DeliveryTimeSlot {
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;

  DeliveryTimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });
} 