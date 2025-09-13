import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_models.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';

class TopProductsService {
  static const String _storageKey = 'user_top_products';
  static List<Product> _userTopProducts = [];

  static List<Product> get userTopProducts =>
      List.unmodifiable(_userTopProducts);

  static bool get hasTopProducts => _userTopProducts.length >= 3;

  // Load products from backend first, fallback to SharedPreferences
  static Future<void> loadProducts() async {
    try {
      final username = UserService.currentUsername;
      print('Loading products for user: $username');

      // Try to load from backend first
      if (username.isNotEmpty) {
        print('Attempting to load from backend...');
        final apiService = ApiService();
        final backendProducts = await apiService.loadUserProducts(username);

        if (backendProducts != null) {
          print('Backend loaded ${backendProducts.length} products');
          _userTopProducts =
              backendProducts
                  .map(
                    (json) => Product(
                      id: json['id'] ?? '',
                      name: json['name'] ?? '',
                      price: (json['price'] ?? 0.0).toDouble(),
                      salesCount: json['salesCount'] ?? 0,
                    ),
                  )
                  .toList();

          // Also save to local storage as backup
          await _saveToLocal();
          print('Products saved to local backup');
          return;
        } else {
          print('Backend returned null, trying local storage...');
        }
      } else {
        print('No username available, trying local storage...');
      }

      // Fallback to SharedPreferences
      print('Loading from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString(_storageKey);

      if (productsJson != null) {
        final List<dynamic> productsList = jsonDecode(productsJson);
        _userTopProducts =
            productsList
                .map(
                  (json) => Product(
                    id: json['id'] ?? '',
                    name: json['name'] ?? '',
                    price: (json['price'] ?? 0.0).toDouble(),
                    salesCount: json['salesCount'] ?? 0,
                  ),
                )
                .toList();
        print('Local loaded ${_userTopProducts.length} products');
      } else {
        print('No local products found');
      }
    } catch (e) {
      print('💥 Error loading products: $e');
      _userTopProducts = [];
    }

    print('Final products count: ${_userTopProducts.length}');
  }

  // Save products to both backend and SharedPreferences
  static Future<void> saveProducts() async {
    try {
      final username = UserService.currentUsername;

      // Convert products to JSON format
      final productsJson =
          _userTopProducts
              .map(
                (product) => {
                  'id': product.id,
                  'name': product.name,
                  'price': product.price,
                  'salesCount': product.salesCount,
                },
              )
              .toList();

      // Save to backend first
      if (username.isNotEmpty) {
        final apiService = ApiService();
        final success = await apiService.saveUserProducts(
          productsJson,
          username,
        );
        print('Backend save result: $success');
      }

      // Always save to local storage as backup
      await _saveToLocal();
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  // Save to local storage only
  static Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson =
          _userTopProducts
              .map(
                (product) => {
                  'id': product.id,
                  'name': product.name,
                  'price': product.price,
                  'salesCount': product.salesCount,
                },
              )
              .toList();

      await prefs.setString(_storageKey, jsonEncode(productsJson));
    } catch (e) {
      print('Error saving products to local: $e');
    }
  }

  static Future<void> addProduct(Product product) async {
    if (_userTopProducts.length < 3) {
      _userTopProducts.add(product);
      await saveProducts();
    }
  }

  static Future<void> removeProduct(int index) async {
    if (index >= 0 && index < _userTopProducts.length) {
      _userTopProducts.removeAt(index);
      await saveProducts();
    }
  }

  static Future<void> updateProduct(int index, Product product) async {
    if (index >= 0 && index < _userTopProducts.length) {
      _userTopProducts[index] = product;
      await saveProducts();
    }
  }

  static Future<void> clearProducts() async {
    _userTopProducts.clear();
    await saveProducts();
  }

  static Future<void> setTopProducts(List<Product> products) async {
    _userTopProducts = products.take(3).toList();
    await saveProducts();
  }

  static Future<void> setProducts(List<Product> products) async {
    _userTopProducts = products.take(3).toList();
    await saveProducts();
  }
}
