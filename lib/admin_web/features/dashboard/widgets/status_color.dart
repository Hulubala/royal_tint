import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'CONFIRMED':
      return const Color(0xFF4CAF50);
    case 'PENDING':
      return const Color(0xFFFFC107);
    case 'COMPLETED':
      return const Color(0xFF2196F3);
    case 'CANCELLED':
      return const Color(0xFFF44336);
    default:
      return Colors.grey;
  }
}