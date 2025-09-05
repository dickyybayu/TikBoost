class SubscriptionTier {
  final String id;
  final String name;
  final String description;
  final bool isFree;
  final List<String> features;
  final List<String> limitations;

  SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.isFree,
    required this.features,
    required this.limitations,
  });
}

class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final bool isActive;

  UserSubscription({
    required this.userId,
    required this.tier,
    this.expiryDate,
    required this.isActive,
  });

  bool get isPremium => !tier.isFree && isActive;
  bool get isFree => tier.isFree;
}

class TopProduct {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int salesCount;
  final double rating;

  TopProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.salesCount,
    required this.rating,
  });
}

// Dummy data untuk subscription tiers
final List<SubscriptionTier> subscriptionTiers = [
  SubscriptionTier(
    id: 'free',
    name: 'Free Tier',
    description: 'Generate copywriting untuk 3 produk terlaris',
    isFree: true,
    features: [
      'Generate copywriting berdasarkan 3 produk terlaris',
      'Akses dasar ke AI content generator',
    ],
    limitations: [
      'Tidak ada akses ke key metrics evaluation',
      'Tidak ada akses ke live session planner',
      'Tidak ada akses ke live stream analysis',
    ],
  ),
  SubscriptionTier(
    id: 'premium',
    name: 'Premium Tier',
    description: 'Akses lengkap ke semua fitur TikBoost',
    isFree: false,
    features: [
      'Semua fitur Free Tier',
      'Key metrics evaluation',
      'Live session planner dengan jam optimal',
      'Live stream analysis real-time',
      'Bundle product recommendations',
      'Advanced analytics',
    ],
    limitations: [],
  ),
];
