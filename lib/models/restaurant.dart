import 'package:flutter/material.dart';
import 'menu_item.dart';

class Restaurant {
  final String id;
  final String name;
  final String emoji;
  final String cuisine;
  final double rating;
  final int reviews;
  final String deliveryTime;
  final double deliveryFee;
  final List<String> tags;
  final Color color;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cuisine,
    required this.rating,
    required this.reviews,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.tags,
    required this.color,
    required this.menu,
  });

  bool get isSupermarket => cuisine.toLowerCase().contains('supermarket');

  /// Rough minutes used for sorting by "fastest".
  int get deliveryMinutes {
    final digits = RegExp(r'\d+').allMatches(deliveryTime).map((m) => int.parse(m.group(0)!));
    return digits.isEmpty ? 999 : digits.reduce((a, b) => a + b) ~/ digits.length;
  }
}

class FoodCategory {
  final String label;
  final String filter;
  final String emoji;

  const FoodCategory({required this.label, required this.filter, required this.emoji});
}
