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

  // Initialize subscription for a new user (ALWAYS starts as free)
  static void initializeForUser(String userId, {bool isPremium = false}) {
    _currentSubscription = UserSubscription(
      userId: userId,
      tier:
          isPremium
              ? subscriptionTiers.firstWhere((tier) => tier.id == 'premium')
              : subscriptionTiers.firstWhere((tier) => tier.id == 'free'),
      expiryDate:
          isPremium ? DateTime.now().add(const Duration(days: 30)) : null,
      isActive: true,
    );
    print(
      '🔄 User $userId subscription initialized: ${isPremium ? "PREMIUM" : "FREE"}',
    );
  }

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

  // Method untuk reset subscription ke default (FREE)
  static void resetToDefault() {
    _currentSubscription = UserSubscription(
      userId: 'user_1',
      tier: subscriptionTiers.first, // Reset ke free tier
      isActive: true,
    );
    print('🔄 Subscription reset to default (FREE)');
  }

  // Clear subscription data (for logout)
  static void clearSubscription() {
    _currentSubscription = UserSubscription(
      userId: 'guest',
      tier: subscriptionTiers.first, // Free tier
      isActive: false,
    );
    print('🔄 Subscription cleared');
  }
}
