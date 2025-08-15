import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String actionText;
  final bool isUrgent;
  final DateTime timestamp;
  final VoidCallback? onAction;
  
  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionText,
    this.isUrgent = false,
    required this.timestamp,
    this.onAction,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
  });
  
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  
  String? get formattedOriginalPrice =>
      originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : null;
  
  String? get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return null;
    final discount = ((originalPrice! - price) / originalPrice! * 100).round();
    return '$discount% OFF';
  }
  
  bool get isOnSale => originalPrice != null && originalPrice! > price;
}

class ProductBundle {
  final String id;
  final String name;
  final List<Product> products;
  final double bundlePrice;
  final String description;
  
  const ProductBundle({
    required this.id,
    required this.name,
    required this.products,
    required this.bundlePrice,
    this.description = '',
  });
  
  double get totalOriginalPrice =>
      products.fold(0.0, (sum, product) => sum + (product.originalPrice ?? product.price));
  
  double get savings => totalOriginalPrice - bundlePrice;
  
  String get formattedBundlePrice => '\$${bundlePrice.toStringAsFixed(2)}';
  
  String get formattedTotalPrice => '\$${totalOriginalPrice.toStringAsFixed(2)}';
  
  String get formattedSavings => '\$${savings.toStringAsFixed(2)}';
}

typedef VoidCallback = void Function();
