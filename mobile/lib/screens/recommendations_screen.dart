import 'package:flutter/material.dart';
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
  final ApiService _apiService = ApiService();
  String _loadingMessage = 'AI sedang menganalisis...';

  @override
  void initState() {
    super.initState();
    _loadCachedRecommendations();
  }

  // Load cached recommendations from backend first, then SharedPreferences as fallback
  Future<void> _loadCachedRecommendations() async {
    try {
      // Try to load from backend first
      final backendData = await _apiService.loadAIRecommendations('current_user');
      
      if (backendData != null) {
        setState(() {
          _recommendations = RecommendationsResult(
            copywriting1: backendData['copywriting1'] ?? backendData['copywriting'] ?? '',
            copywriting2: backendData['copywriting2'] ?? '',
            copywriting3: backendData['copywriting3'] ?? '',
            optimalTime: backendData['optimalTime'] ?? '',
            bundleRecommendation: backendData['bundleRecommendation'] ?? '',
          );
        });
        print('Loaded recommendations from backend');
        return;
      }

      // Fallback to SharedPreferences if backend fails
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_storageKey);

      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        setState(() {
          _recommendations = RecommendationsResult(
            copywriting1:
                data['copywriting1'] ??
                data['copywriting'] ??
                '', // Backward compatibility
            copywriting2: data['copywriting2'] ?? '',
            copywriting3: data['copywriting3'] ?? '',
            optimalTime: data['optimalTime'] ?? '',
            bundleRecommendation: data['bundleRecommendation'] ?? '',
          );
        });
        print('Loaded cached recommendations from local storage');
      }
    } catch (e) {
      print('Error loading cached recommendations: $e');
    }
  }

  void _loadTopProducts() {
    // Trigger rebuild to refresh top products display
    setState(() {
      // TopProducts.TopProductsService automatically manages state
      // This setState will refresh the UI to show updated top products
    });
  }

  // Save recommendations to SharedPreferences
  Future<void> _saveCachedRecommendations(
    RecommendationsResult recommendations,
  ) async {
    try {
      final Map<String, dynamic> data = {
        'copywriting1': recommendations.copywriting1,
        'copywriting2': recommendations.copywriting2,
        'copywriting3': recommendations.copywriting3,
        'optimalTime': recommendations.optimalTime,
        'bundleRecommendation': recommendations.bundleRecommendation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to backend first (primary storage)
      final backendSaved = await _apiService.saveAIRecommendations(data, 'current_user');
      
      // Also save to SharedPreferences as backup/cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(data));
      
      if (backendSaved) {
        print('Saved recommendations to backend and local cache');
      } else {
        print('Saved recommendations to local cache only (backend failed)');
      }
    } catch (e) {
      print('Error saving recommendations: $e');
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
                  colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
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
      body:
          !hasTopProducts
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
                      builder:
                          (context) => TopProductsInputScreen(
                            onProductsAdded: () => setState(() {}),
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Input Produk Terlaris',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color(0xFF2563EB);
                    }
                    return const Color(0xFF3B82F6);
                  }),
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
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
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
                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                  colors: [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
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
                child:
                    _isGenerating
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _loadingMessage,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Mohon tunggu sebentar...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _recommendations != null
                                  ? Icons.refresh
                                  : Icons.auto_awesome_rounded,
                              size: 20,
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

          // Add Edit Products button if top products exist
          if (TopProducts.TopProductsService.hasTopProducts) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF3B82F6), // Solid blue color
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TopProductsInputScreen(),
                      ),
                    ).then((_) {
                      // Refresh top products when returning from edit screen
                      _loadTopProducts();
                    });
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text(
                    'Edit Produk Terlaris',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

        // Copywriting Sections (show all 3 if available)
        _buildResultCard(
          title: 'COPYWRITING OPTION 1',
          icon: Icons.edit,
          color: Colors.blue[600]!,
          content: _recommendations!.copywriting1,
        ),

        if (_recommendations!.copywriting2.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildResultCard(
            title: 'COPYWRITING OPTION 2',
            icon: Icons.edit_note,
            color: Colors.blue[600]!,
            content: _recommendations!.copywriting2,
          ),
        ],

        if (_recommendations!.copywriting3.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildResultCard(
            title: 'COPYWRITING OPTION 3',
            icon: Icons.edit_outlined,
            color: Colors.blue[600]!,
            content: _recommendations!.copywriting3,
          ),
        ],

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
                    colors: [color, color.withOpacity(0.8)],
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
    if (!mounted) return;

    setState(() {
      _isGenerating = true;
      _loadingMessage = 'Memproses data produk...';
    });

    try {
      final topProducts = TopProducts.TopProductsService.userTopProducts;

      // Prepare products data for RunPod API (need exactly 3 products)
      final productsData =
          topProducts
              .map(
                (product) => {
                  'name': product.name,
                  'price': product.price,
                  'sold': product.salesCount,
                },
              )
              .toList();

      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Menganalisis strategi penjualan...';
      });

      // Call RunPod AI API
      final apiService = ApiService();
      
      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Membuat rekomendasi...';
      });
      
      final result = await apiService.generateRecommendations(
        products: productsData,
      );

      if (!mounted) return;
      setState(() {
        _loadingMessage = 'Menyelesaikan...';
      });

      if (mounted) {
        setState(() {
          _isGenerating = false;

          if (result != null) {
            // Use RunPod AI response - get all 3 copywriting variants
            _recommendations = RecommendationsResult(
              copywriting1:
                  result['copy1'] ??
                  _generateFallbackCopywriting(topProducts.first),
              copywriting2: result['copy2'] ?? '',
              copywriting3: result['copy3'] ?? '',
              optimalTime: result['time'] ?? _generateOptimalTime(),
              bundleRecommendation:
                  result['bundle'] ??
                  _generateBundleRecommendation(topProducts),
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('AI recommendations generated!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // Fallback to local generation if RunPod API fails
            _recommendations = RecommendationsResult(
              copywriting1: _generateFallbackCopywriting(topProducts.first),
              optimalTime: _generateOptimalTime(),
              bundleRecommendation: _generateBundleRecommendation(topProducts),
            );

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'RunPod API tidak tersedia. Menggunakan template lokal.',
                ),
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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

}

class RecommendationsResult {
  final String copywriting1;
  final String copywriting2;
  final String copywriting3;
  final String optimalTime;
  final String bundleRecommendation;

  RecommendationsResult({
    required this.copywriting1,
    this.copywriting2 = '',
    this.copywriting3 = '',
    required this.optimalTime,
    required this.bundleRecommendation,
  });

  // Legacy getter for backward compatibility
  String get copywriting => copywriting1;
}
