import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/top_products_service.dart' as TopProducts;
import '../services/api_service.dart';
import '../models/product_models.dart';
import 'top_products_input_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isGenerating = false;
  RecommendationsResult? _recommendations;
  static const String _storageKey = 'cached_recommendations';

  @override
  void initState() {
    super.initState();
    _loadCachedRecommendations();
  }

  // Load cached recommendations from SharedPreferences
  Future<void> _loadCachedRecommendations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_storageKey);
      
      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        setState(() {
          _recommendations = RecommendationsResult(
            copywriting: data['copywriting'] ?? '',
            optimalTime: data['optimalTime'] ?? '',
            bundleRecommendation: data['bundleRecommendation'] ?? '',
          );
        });
        print('🔄 Loaded cached recommendations');
      }
    } catch (e) {
      print('❌ Error loading cached recommendations: $e');
    }
  }

  // Save recommendations to SharedPreferences
  Future<void> _saveCachedRecommendations(RecommendationsResult recommendations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {
        'copywriting': recommendations.copywriting,
        'optimalTime': recommendations.optimalTime,
        'bundleRecommendation': recommendations.bundleRecommendation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_storageKey, json.encode(data));
      print('💾 Saved recommendations to cache');
    } catch (e) {
      print('❌ Error saving recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTopProducts = TopProducts.TopProductsService.hasTopProducts;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6),
                    const Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'AI Recommendations',
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.35),
                    spreadRadius: 2,
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 60,
                color: Colors.grey[500],
              ),
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Input Produk Terlaris',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(0xFF2563EB);
                      }
                      return const Color(0xFF3B82F6);
                    },
                  ),
                  overlayColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.1),
                  ),
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
    final topProducts = TopProducts.TopProductsService.userTopProducts;
    
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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6),
                          const Color(0xFF1E40AF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          spreadRadius: 0,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                        Row(
                          children: [
                            Text(
                              'Rp ${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                            Text(
                              ' • ${product.salesCount} terjual',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 26,
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6),
                    const Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).copyWith(
                  overlayColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.1),
                  ),
                ),
                child: _isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Generating...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _recommendations != null ? Icons.refresh : Icons.auto_awesome_rounded, 
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _recommendations != null 
                              ? 'Generate Ulang Recommendations'
                              : 'Generate All Recommendations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.grey[700]!,
                  Colors.grey[800]!,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[700]!.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _copyAllRecommendations(),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text(
                'Copy All Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).copyWith(
                overlayColor: MaterialStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: IconButton(
                  onPressed: () => _copyText(content),
                  icon: Icon(Icons.copy_rounded, size: 18, color: Colors.grey[700]),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
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

    try {
      final topProducts = TopProducts.TopProductsService.userTopProducts;
      
      // Prepare products data for API
      final productsData = topProducts.map((product) => {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'salesCount': product.salesCount,
      }).toList();

      // Call AI API
      final apiService = ApiService();
      final result = await apiService.generateRecommendations(
        products: productsData,
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          
          if (result != null) {
            // Use AI response
            _recommendations = RecommendationsResult(
              copywriting: result['copywriting'] ?? _generateFallbackCopywriting(topProducts.first),
              optimalTime: result['optimal_time'] ?? _generateOptimalTime(),
              bundleRecommendation: result['bundle_recommendation'] ?? _generateBundleRecommendation(topProducts),
            );
          } else {
            // Fallback to local generation if API fails
            _recommendations = RecommendationsResult(
              copywriting: _generateFallbackCopywriting(topProducts.first),
              optimalTime: _generateOptimalTime(),
              bundleRecommendation: _generateBundleRecommendation(topProducts),
            );
            
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal terhubung ke AI server. Menggunakan template lokal.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          
          // Save to cache after generating
          if (_recommendations != null) {
            _saveCachedRecommendations(_recommendations!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateFallbackCopywriting(Product product) {
    return """🔥 ${product.name} VIRAL ALERT! 🔥

✨ Produk #1 terlaris yang udah dipercaya ${product.salesCount}+ customers!
💎 Kualitas premium dengan harga Rp ${product.price.toStringAsFixed(0)}!

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

  String _generateBundleRecommendation(List<Product> products) {
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
