import 'package:flutter/material.dart';

class CategoryIcons {
  static final Map<String, (IconData, Color)> icons = {
    'Home': (Icons.home_rounded, Colors.blue),
    'Work': (Icons.work_rounded, Colors.orange),
    'Restaurant': (Icons.restaurant_rounded, Colors.red),
    'Shopping': (Icons.shopping_cart_rounded, Colors.green),
    'Gym': (Icons.fitness_center_rounded, Colors.purple),
    'School': (Icons.school_rounded, Colors.brown),
    'Park': (Icons.park_rounded, Colors.lightGreen),
    'Other': (Icons.place_rounded, Colors.grey),
  };

  static (IconData, Color) getCategoryData(String? category) {
    return icons[category] ?? (Icons.place_rounded, Colors.grey);
  }
}
