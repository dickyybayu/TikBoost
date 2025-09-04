import '../models/subscription_models.dart';

class SubscriptionService {
  static UserSubscription _currentSubscription = UserSubscription(
    userId: 'user_1',
    tier: subscriptionTiers.first, // Default to free tier
    isActive: true,
  );

  static UserSubscription get currentSubscription => _currentSubscription;

  static bool get isPremium => _currentSubscription.isPremium;
  static bool get isFree => _currentSubscription.isFree;

  static void upgradeToPremium() {
    _currentSubscription = UserSubscription(
      userId: _currentSubscription.userId,
      tier: subscriptionTiers.firstWhere((tier) => tier.id == 'premium'),
      expiryDate: DateTime.now().add(const Duration(days: 30)), // 30 days trial
      isActive: true,
    );
    print('🎉 PREMIUM UPGRADED! isPremium: ${_currentSubscription.isPremium}');
  }

  static void downgradeToFree() {
    _currentSubscription = UserSubscription(
      userId: _currentSubscription.userId,
      tier: subscriptionTiers.firstWhere((tier) => tier.id == 'free'),
      isActive: true,
    );
  }

  // Method untuk reset subscription ke default
  static void resetToDefault() {
    _currentSubscription = UserSubscription(
      userId: 'user_1',
      tier: subscriptionTiers.first, // Reset ke free tier
      isActive: true,
    );
  }
}

class TopProductsService {
  static List<TopProduct> _userTopProducts = []; // Mulai dengan list kosong

  static List<TopProduct> get userTopProducts => _userTopProducts;

  static void setTopProducts(List<TopProduct> products) {
    if (products.length > 3) {
      _userTopProducts = products.take(3).toList();
    } else {
      _userTopProducts = products;
    }
  }

  static bool get hasTopProducts => _userTopProducts.isNotEmpty;

  // Method untuk menghapus produk
  static void removeProduct(String productId) {
    _userTopProducts.removeWhere((product) => product.id == productId);
  }

  // Method untuk clear semua produk
  static void clearAllProducts() {
    _userTopProducts.clear();
  }

  // Method untuk reset products saja
  static void resetProducts() {
    _userTopProducts.clear();
  }

  // Dummy data untuk contoh (tidak auto-load)
  static List<TopProduct> getDummyTopProducts() {
    return [
      TopProduct(
        id: '1',
        name: 'Handmade Batik Scarf',
        description: 'Authentic Indonesian batik scarf with traditional patterns',
        imageUrl: 'assets/images/batik_scarf.jpg',
        salesCount: 150,
        rating: 4.8,
        category: 'Fashion',
      ),
      TopProduct(
        id: '2',
        name: 'Indonesian Coffee Beans',
        description: 'Premium arabica coffee beans from Java mountains',
        imageUrl: 'assets/images/coffee_beans.jpg',
        salesCount: 120,
        rating: 4.9,
        category: 'Food & Beverage',
      ),
      TopProduct(
        id: '3',
        name: 'Traditional Wayang Kulit',
        description: 'Handcrafted leather puppet for traditional shadow play',
        imageUrl: 'assets/images/wayang_kulit.jpg',
        salesCount: 85,
        rating: 4.7,
        category: 'Art & Culture',
      ),
    ];
  }
}
