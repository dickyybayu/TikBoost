import '../models/product_models.dart';

class TopProductsService {
  static List<Product> _userTopProducts = [];

  static List<Product> get userTopProducts => List.unmodifiable(_userTopProducts);
  
  static bool get hasTopProducts => _userTopProducts.length >= 3;

  static void addProduct(Product product) {
    if (_userTopProducts.length < 3) {
      _userTopProducts.add(product);
    }
  }

  static void removeProduct(int index) {
    if (index >= 0 && index < _userTopProducts.length) {
      _userTopProducts.removeAt(index);
    }
  }

  static void updateProduct(int index, Product product) {
    if (index >= 0 && index < _userTopProducts.length) {
      _userTopProducts[index] = product;
    }
  }

  static void clearProducts() {
    _userTopProducts.clear();
  }

  static void setProducts(List<Product> products) {
    _userTopProducts = products.take(3).toList();
  }
}
