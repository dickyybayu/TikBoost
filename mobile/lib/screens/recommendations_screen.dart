import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_service.dart';
import '../models/subscription_models.dart';
import '../widgets/tikboost_logo.dart';
import 'premium_upgrade_screen.dart';
import 'top_products_input_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isGenerating = false;
  RecommendationsResult? _recommendations;

  @override
  Widget build(BuildContext context) {
    final hasTopProducts = TopProductsService.hasTopProducts;
    final isPremium = SubscriptionService.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TikBoostLogoIcon(size: 24),
            SizedBox(width: 8),
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isPremium)
            IconButton(
              icon: const Icon(Icons.star, color: Colors.amber),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PremiumUpgradeScreen(
                      featureName: 'Premium Analysis Features',
                      onUpgradeSuccess: () => setState(() {}),
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
        ],
      ),
      body: !hasTopProducts 
        ? _buildTopProductsRequired()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 24),
                _buildTopProductsDisplay(),
                const SizedBox(height: 24),
                _buildGenerateSection(),
                if (_recommendations != null) ...[
                  const SizedBox(height: 32),
                  _buildRecommendationsResult(),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildTopProductsRequired() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Input 3 Produk Terlaris',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Untuk mendapatkan rekomendasi AI, silakan input 3 produk terlaris Anda terlebih dahulu.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopProductsInputScreen(
                      onProductsAdded: () => setState(() {}),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Input Produk Terlaris'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Recommendations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dapatkan copywriting, jadwal optimal, dan rekomendasi bundle berdasarkan 3 produk terlaris Anda',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsDisplay() {
    final topProducts = TopProductsService.userTopProducts;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                '3 Produk Terlaris Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[600],
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${product.salesCount} terjual • ⭐ ${product.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.purple[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Copywriting + Jadwal + Bundle dalam satu klik',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Generate All Recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsResult() {
    if (_recommendations == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Copywriting Section
        _buildResultCard(
          title: 'COPYWRITING',
          icon: Icons.edit,
          color: Colors.blue[600]!,
          content: _recommendations!.copywriting,
        ),
        
        const SizedBox(height: 16),
        
        // Time Section  
        _buildResultCard(
          title: 'JADWAL OPTIMAL',
          icon: Icons.schedule,
          color: Colors.green[600]!,
          content: _recommendations!.optimalTime,
        ),
        
        const SizedBox(height: 16),
        
        // Bundle Section
        _buildResultCard(
          title: 'BUNDLE RECOMMENDATIONS',
          icon: Icons.inventory,
          color: Colors.purple[600]!,
          content: _recommendations!.bundleRecommendation,
        ),
        
        const SizedBox(height: 24),
        
        // Copy All Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copyAllRecommendations(),
            icon: const Icon(Icons.copy),
            label: const Text('Copy All Recommendations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyText(content),
                icon: Icon(Icons.copy, size: 20, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateRecommendations() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    final topProducts = TopProductsService.userTopProducts;
    final mainProduct = topProducts.first;
    
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _recommendations = RecommendationsResult(
          copywriting: _generateCopywriting(mainProduct),
          optimalTime: _generateOptimalTime(),
          bundleRecommendation: _generateBundleRecommendation(topProducts),
        );
      });
    }
  }

  String _generateCopywriting(TopProduct product) {
    return """🔥 ${product.name} VIRAL ALERT! 🔥

✨ Produk #1 terlaris yang udah dipercaya ${product.salesCount}+ customers!
⭐ Rating ${product.rating}/5.0 - Bukti kualitas terbaik!

${product.description}

💥 PROMO LIVE STREAMING HARI INI:
🎁 Buy 1 Get 1 GRATIS untuk 50 pembeli pertama!
⚡ Extra diskon 15% untuk pembelian bundle!
🚀 FREE ONGKIR seluruh Indonesia!

Jangan sampai menyesal! Stock terbatas karena demand tinggi!

#TikTokShop #${product.name.replaceAll(' ', '')} #ViralProduct""";
  }

  String _generateOptimalTime() {
    return """📅 JADWAL LIVE STREAMING OPTIMAL:

🔥 PRIME TIME (Rekomendasi Utama):
• Kamis: 19:00 - 21:00 WIB
• Jumat: 18:30 - 20:30 WIB  
• Sabtu: 19:30 - 21:30 WIB

⭐ WAKTU ALTERNATIF:
• Senin: 19:00 - 20:30 WIB
• Rabu: 19:30 - 21:00 WIB

💡 TIPS TIMING:
• Mulai 15 menit sebelum jadwal untuk warm-up
• Durasi optimal: 60-90 menit
• Peak engagement: menit ke 20-40
• Closing yang kuat di 15 menit terakhir""";
  }

  String _generateBundleRecommendation(List<TopProduct> products) {
    return """📦 BUNDLE STRATEGY RECOMMENDATIONS:

🎯 BUNDLE 1: "${products[0].name} + ${products[1].name}"
• Diskon: 15% (dari harga normal)
• Target: Customers yang suka variety
• Projected sales: +30%

💎 BUNDLE 2: "Complete Set (3 Produk)"
• Diskon: 25% (Best value!)
• Target: Loyal customers & bulk buyers  
• Projected sales: +45%

🔥 BUNDLE 3: "${products[0].name} Twin Pack"
• Diskon: 12% 
• Target: Gift buyers & resellers
• Projected sales: +20%

💡 STRATEGI PENJUALAN:
• Highlight total savings dalam Rupiah
• Buat urgency: "Bundle terbatas untuk live ini saja!"
• Showcase semua produk secara visual
• Berikan bonus untuk bundle termahal""";
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyAllRecommendations() {
    if (_recommendations == null) return;
    
    final allText = """${_recommendations!.copywriting}

---

${_recommendations!.optimalTime}

---

${_recommendations!.bundleRecommendation}""";
    
    Clipboard.setData(ClipboardData(text: allText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All recommendations copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class RecommendationsResult {
  final String copywriting;
  final String optimalTime;
  final String bundleRecommendation;

  RecommendationsResult({
    required this.copywriting,
    required this.optimalTime,
    required this.bundleRecommendation,
  });
}
