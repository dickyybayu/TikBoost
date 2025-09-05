import 'package:flutter/material.dart';
import 'ai_content_generator_screen.dart';
import 'premium_upgrade_screen.dart';
import 'top_products_input_screen.dart';
import '../services/subscription_service.dart';

class AIContentScreen extends StatefulWidget {
  const AIContentScreen({super.key});

  @override
  State<AIContentScreen> createState() => _AIContentScreenState();
}

class _AIContentScreenState extends State<AIContentScreen> {
  @override
  Widget build(BuildContext context) {
    final hasTopProducts = TopProductsService.hasTopProducts;
    final isPremium = SubscriptionService.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'TikBoost',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status
            _buildSubscriptionStatusCard(isPremium),
            const SizedBox(height: 20),

            const Text(
              'AI Content Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate copywriting dan dapatkan insights berdasarkan 3 produk terlaris Anda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Top Products Section
            if (!hasTopProducts) ...[
              _buildTopProductsInputCard(),
              const SizedBox(height: 16),
            ] else ...[
              _buildTopProductsDisplay(),
              const SizedBox(height: 16),
            ],

            // Main Content Generation Card (Free Tier)
            _buildContentCard(
              'Generate Copywriting untuk Produk Terlaris',
              hasTopProducts
                  ? 'Buat copywriting yang menarik berdasarkan 3 produk terlaris Anda dengan AI'
                  : 'Input 3 produk terlaris terlebih dahulu untuk mulai generate copywriting',
              const Color(0xFFFAE8D4),
              Icons.auto_awesome,
              'Generate',
              hasTopProducts ? () => _navigateToContentGenerator() : null,
              isEnabled: hasTopProducts,
            ),

            const SizedBox(height: 16),

            // Live Session Planner (Free Access)
            _buildContentCard(
              'Live Session Planner',
              'Dapatkan jam optimal untuk live streaming berdasarkan data historis',
              const Color(0xFFF0F7F0),
              Icons.schedule,
              'Get Schedule',
              () => _handleFreeFeature('Live Session Planner'),
              isEnabled: true,
            ),

            const SizedBox(height: 16),

            // Live Stream Analysis (Premium Only)
            _buildPremiumFeatureCard(
              'Live Stream Analysis',
              'Analisis real-time performa live streaming Anda',
              const Color(0xFFEAE3D2),
              Icons.live_tv,
              'Analyze',
              isPremium,
              () => _handlePremiumFeature('Live Stream Analysis'),
            ),

            const SizedBox(height: 16),

            // Bundle Products (Free Access)
            _buildContentCard(
              'Bundle Products Strategically',
              hasTopProducts
                  ? 'Buat bundle produk strategis dari 3 produk terlaris Anda'
                  : 'Input 3 produk terlaris untuk mendapatkan rekomendasi bundle',
              const Color(0xFFF0E6FF),
              Icons.inventory_2_rounded,
              'Generate Bundle',
              hasTopProducts
                  ? () => _handleFreeFeature('Product Bundle Generator')
                  : null,
              isEnabled: hasTopProducts,
            ),

            const SizedBox(height: 32),

            // Refresh Button
            if (hasTopProducts)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TopProductsInputScreen(
                              onProductsAdded: () => setState(() {}),
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Update Produk Terlaris',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(bool isPremium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            isPremium
                ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                )
                : const LinearGradient(
                  colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.verified : Icons.lock,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Member' : 'Free Tier',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPremium
                      ? 'Akses lengkap ke semua fitur'
                      : 'Upgrade untuk mendapatkan fitur lengkap',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (!isPremium)
            TextButton(
              onPressed: () => _upgradeToPromium('General Upgrade'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildTopProductsInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.add_business, size: 40, color: Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          const Text(
            'Input 3 Produk Terlaris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan 3 produk terlaris Anda untuk mulai menggunakan AI content generator',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TopProductsInputScreen(
                          onProductsAdded: () => setState(() {}),
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Input Produk'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsDisplay() {
    final products = TopProductsService.userTopProducts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3 Produk Terlaris Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TopProductsInputScreen(
                            onProductsAdded: () => setState(() {}),
                          ),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${product.salesCount} terjual • ${product.category}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToContentGenerator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => const AIContentGeneratorScreen(
              contentType: 'copywriting',
              title: 'Generate Copywriting',
              description:
                  'Buat copywriting yang menarik berdasarkan 3 produk terlaris Anda menggunakan AI.',
            ),
      ),
    );
  }

  void _handleFreeFeature(String featureName) {
    // Show free feature with some functionality
    _showFreeFeature(featureName);
  }

  void _handlePremiumFeature(String featureName) {
    if (SubscriptionService.isPremium) {
      _showPremiumFeature(featureName);
    } else {
      _upgradeToPromium(featureName);
    }
  }

  void _upgradeToPromium(String featureName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PremiumUpgradeScreen(
              featureName: featureName,
              onUpgradeSuccess: () => setState(() {}),
            ),
      ),
    );
  }

  void _showPremiumFeature(String featureName) {
    // Show dummy data for premium features
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(featureName),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (featureName.contains('Key Metrics')) ...[
                    const Text(
                      '📊 Key Metrics Analysis:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Engagement Rate: 15.2% (+3% dari minggu lalu)',
                    ),
                    const Text('• Conversion Rate: 8.5% (+1.2%)'),
                    const Text('• Average Watch Time: 2m 34s'),
                    const Text('• Click-through Rate: 12.8%'),
                    const Text('• Revenue per Viewer: Rp 4,600'),
                  ] else if (featureName.contains('Live Session')) ...[
                    const Text(
                      '🕐 Optimal Live Session Times:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Hari terbaik: Kamis, Jumat, Sabtu'),
                    const Text('• Jam prime time: 19:00 - 21:00 WIB'),
                    const Text('• Jam siang: 12:00 - 14:00 WIB'),
                    const Text('• Durasi optimal: 45-60 menit'),
                    const Text('• Peak engagement: Menit ke 15-25'),
                  ] else if (featureName.contains('Live Stream Analysis')) ...[
                    const Text(
                      '📺 Live Stream Performance:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Current Viewers: 1,250 (+15% dari rata-rata)',
                    ),
                    const Text('• Engagement Score: 8.7/10'),
                    const Text('• Comments per minute: 45'),
                    const Text('• Products shown: 3/3'),
                    const Text('• Conversion rate (real-time): 9.2%'),
                  ] else if (featureName.contains('Product Bundle')) ...[
                    const Text(
                      '📦 Recommended Product Bundles:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Bundle 1: Batik Scarf + Coffee Beans'),
                    const Text('• Discount: 15% • Projected sales: +25%'),
                    const SizedBox(height: 4),
                    const Text('Bundle 2: All 3 Products Package'),
                    const Text('• Discount: 20% • Projected sales: +35%'),
                    const SizedBox(height: 4),
                    const Text('Bundle 3: Batik + Wayang (Cultural Set)'),
                    const Text('• Discount: 12% • Projected sales: +18%'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showFreeFeature(String featureName) {
    // Show basic functionality for free features
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.free_breakfast, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text(featureName)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (featureName.contains('Live Session')) ...[
                    const Text(
                      '🕐 Basic Live Session Tips (Free):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Waktu terbaik umumnya: 19:00 - 21:00 WIB'),
                    const Text('• Hari optimal: Kamis - Sabtu'),
                    const Text('• Durasi yang disarankan: 30-45 menit'),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Text(
                        '💡 Tips: Upgrade ke Premium untuk analisis mendalam berdasarkan data historis Anda!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ] else if (featureName.contains('Product Bundle')) ...[
                    const Text(
                      '📦 Basic Bundle Ideas (Free):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Gabungkan produk komplementer'),
                    const Text('• Berikan diskon 10-15% untuk bundle'),
                    const Text('• Maksimal 2-3 produk per bundle'),
                    const Text('• Fokus pada value proposition'),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        '💡 Tips: Upgrade ke Premium untuk rekomendasi bundle yang dipersonalisasi!',
                        style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              if (!SubscriptionService.isPremium)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _upgradeToPromium(featureName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
    );
  }

  Widget _buildPremiumFeatureCard(
    String title,
    String description,
    Color backgroundColor,
    IconData icon,
    String buttonText,
    bool isPremium,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon placeholder with lock overlay
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color:
                      isPremium ? Colors.brown.shade400 : Colors.grey.shade400,
                ),
              ),
              if (!isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.black87 : Colors.black54,
                  ),
                ),
              ),
              if (!isPremium)
                const Icon(Icons.lock, size: 16, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isPremium ? Colors.black54 : Colors.black45,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPremium ? const Color(0xFF3B82F6) : Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(isPremium ? buttonText : 'Upgrade'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String title,
    String description,
    Color backgroundColor,
    IconData icon,
    String buttonText,
    VoidCallback? onPressed, {
    bool isEnabled = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon placeholder
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 40,
              color: isEnabled ? Colors.brown.shade400 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.black87 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isEnabled ? Colors.black54 : Colors.black45,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: isEnabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEnabled ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
