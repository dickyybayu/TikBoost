import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../models/subscription_models.dart';
import 'premium_upgrade_screen.dart';
import 'top_products_input_screen.dart';

class ContentStudioScreen extends StatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Copywriting form controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _keyFeaturesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  // Live Stream Analysis URL controller
  final TextEditingController _tiktokUrlController = TextEditingController();
  
  String _selectedTone = 'Enthusiastic';
  String _selectedFormat = 'Short & Punchy';
  bool _isGenerating = false;
  String? _generatedContent;
  TopProduct? _selectedProduct;
  bool _isAnalyzing = false;
  String? _analysisResult;

  final List<String> _tones = [
    'Enthusiastic',
    'Professional',
    'Casual',
    'Friendly',
    'Urgent',
    'Storytelling',
  ];

  final List<String> _formats = [
    'Short & Punchy',
    'Detailed Description',
    'Story Format',
    'Problem-Solution',
    'Feature-Benefit',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productNameController.dispose();
    _targetAudienceController.dispose();
    _keyFeaturesController.dispose();
    _priceController.dispose();
    _tiktokUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTopProducts = TopProductsService.hasTopProducts;
    final isPremium = SubscriptionService.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Content Studio',
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
          if (!isPremium)
            IconButton(
              icon: const Icon(Icons.star, color: Colors.amber),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PremiumUpgradeScreen(
                      featureName: 'Content Studio Premium Features',
                    ),
                  ),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3B82F6),
          tabs: const [
            Tab(text: 'Copywriting'),
            Tab(text: 'Live Planner'),
            Tab(text: 'Bundling'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: !hasTopProducts 
        ? _buildTopProductsRequired()
        : TabBarView(
            controller: _tabController,
            children: [
              _buildCopywritingTab(),
              _buildLivePlannerTab(),
              _buildBundlingTab(),
              _buildAnalysisTab(isPremium),
            ],
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
              'Input Produk Terlaris Diperlukan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Untuk menggunakan Content Studio, Anda perlu menginput 3 produk terlaris terlebih dahulu.',
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

  Widget _buildCopywritingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Copywriting',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat copywriting yang menarik berdasarkan produk Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // Top Products Dropdown
          if (TopProductsService.hasTopProducts) ...[
            _buildTopProductsDropdown(),
            const SizedBox(height: 16),
          ],

          // Input Fields
          _buildInputField(
            'Product Name',
            'Enter your product name',
            _productNameController,
            Icons.inventory_rounded,
          ),
          const SizedBox(height: 16),
          
          _buildInputField(
            'Target Audience',
            'Who is your target customer?',
            _targetAudienceController,
            Icons.people_rounded,
          ),
          const SizedBox(height: 16),
          
          _buildInputField(
            'Key Features',
            'List the main features or benefits',
            _keyFeaturesController,
            Icons.star_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          _buildInputField(
            'Price',
            'Product price (optional)',
            _priceController,
            Icons.attach_money_rounded,
          ),
          const SizedBox(height: 24),

          // AI Settings
          const Text(
            'AI Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Tone',
            _selectedTone,
            _tones,
            Icons.mood_rounded,
            (value) => setState(() => _selectedTone = value!),
          ),
          const SizedBox(height: 16),
          
          _buildDropdownField(
            'Format',
            _selectedFormat,
            _formats,
            Icons.format_align_left_rounded,
            (value) => setState(() => _selectedFormat = value!),
          ),
          
          const SizedBox(height: 32),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateContent,
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
                      'Generate Copywriting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          // Generated Content
          if (_generatedContent != null) ...[
            const SizedBox(height: 32),
            _buildGeneratedContentCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildLivePlannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Session Planner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dapatkan rekomendasi waktu optimal untuk live streaming',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Schedule Card
          _buildScheduleCard(
            title: 'Jadwal Optimal Minggu Ini',
            icon: Icons.schedule,
            color: const Color(0xFF10B981),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScheduleItem('Senin', '19:00 - 20:30', '⭐ Peak Time'),
                _buildScheduleItem('Selasa', '20:00 - 21:00', 'Good'),
                _buildScheduleItem('Rabu', '19:30 - 21:00', '⭐ Peak Time'),
                _buildScheduleItem('Kamis', '19:00 - 20:30', '🔥 Best Time'),
                _buildScheduleItem('Jumat', '18:30 - 20:00', '🔥 Best Time'),
                _buildScheduleItem('Sabtu', '19:00 - 21:00', '⭐ Peak Time'),
                _buildScheduleItem('Minggu', '20:00 - 21:30', 'Good'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Best Practices Card
          _buildScheduleCard(
            title: 'Tips Live Session',
            icon: Icons.lightbulb,
            color: const Color(0xFFF59E0B),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem('🎯', 'Durasi optimal: 45-60 menit'),
                _buildTipItem('⏰', 'Mulai tepat waktu, audienc sudah menunggu'),
                _buildTipItem('📱', 'Interaksi dengan chat setiap 2-3 menit'),
                _buildTipItem('🎁', 'Siapkan 2-3 produk untuk ditampilkan'),
                _buildTipItem('🔊', 'Pastikan audio jernih dan pencahayaan baik'),
                _buildTipItem('💰', 'Tawarkan promo special untuk viewers'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Calendar Integration (Free Tier)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    Icon(Icons.calendar_today, color: const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    const Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pilih jadwal yang ingin Anda gunakan untuk membuat reminder otomatis',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showReminderDialog();
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Set Live Reminder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundlingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Bundling Strategy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat bundle produk strategis untuk meningkatkan penjualan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // Current Products
          _buildBundleCard(
            title: '📦 Produk Anda',
            color: const Color(0xFF3B82F6),
            content: Column(
              children: TopProductsService.userTopProducts.map((product) =>
                _buildProductItem(product)
              ).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Recommended Bundles
          _buildBundleCard(
            title: '💡 Rekomendasi Bundle',
            color: const Color(0xFF10B981),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBundleRecommendation(
                  'Bundle Komplit',
                  'Semua 3 produk terlaris',
                  '20%',
                  '+35%',
                  Icons.inventory,
                ),
                const SizedBox(height: 12),
                _buildBundleRecommendation(
                  'Bundle Populer',
                  '2 produk dengan rating tertinggi',
                  '15%',
                  '+25%',
                  Icons.star,
                ),
                const SizedBox(height: 12),
                _buildBundleRecommendation(
                  'Bundle Hemat',
                  '2 produk termurah',
                  '12%',
                  '+18%',
                  Icons.savings,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bundle Strategy Tips
          _buildBundleCard(
            title: '🎯 Strategi Bundle',
            color: const Color(0xFFF59E0B),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem('💰', 'Berikan diskon 10-20% untuk bundle'),
                _buildTipItem('📊', 'Gabungkan produk komplementer'),
                _buildTipItem('🎁', 'Highlight value yang didapat customer'),
                _buildTipItem('⏰', 'Buat urgency dengan limited time offer'),
                _buildTipItem('📱', 'Promosikan bundle di live streaming'),
                _buildTipItem('🔄', 'Monitor performa dan adjust bundle'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Create Bundle Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showCreateBundleDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Bundle Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(bool isPremium) {
    if (!isPremium) {
      return _buildPremiumRequired();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Stream Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Analisis performa akun TikTok Anda secara real-time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // TikTok URL Input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    Icon(Icons.link, color: const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    const Text(
                      'Input URL TikTok',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Masukkan URL akun TikTok atau live stream untuk analisis mendalam',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tiktokUrlController,
                  decoration: InputDecoration(
                    labelText: 'TikTok URL',
                    hintText: 'https://www.tiktok.com/@username atau URL live stream',
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _analyzeAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Analyze Account'),
                  ),
                ),
              ],
            ),
          ),

          // Analysis Results
          if (_analysisResult != null) ...[
            const SizedBox(height: 24),
            _buildAnalysisResults(),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumRequired() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Premium Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Stream Analysis membutuhkan subscription Premium. Upgrade sekarang untuk mengakses analisis mendalam!',
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
                    builder: (context) => PremiumUpgradeScreen(
                      featureName: 'Live Stream Analysis',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
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

  // Helper methods for building UI components
  Widget _buildTopProductsDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih dari Produk Terlaris',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TopProduct>(
            value: _selectedProduct,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            hint: const Text('Pilih produk atau isi manual'),
            items: TopProductsService.userTopProducts.map((product) {
              return DropdownMenuItem<TopProduct>(
                value: product,
                child: Text(product.name),
              );
            }).toList(),
            onChanged: (TopProduct? value) {
              setState(() {
                _selectedProduct = value;
                if (value != null) {
                  _productNameController.text = value.name;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildGeneratedContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'AI Generated Content',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
              IconButton(
                onPressed: _copyContent,
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Colors.grey,
                  size: 20,
                ),
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              _generatedContent!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyContent,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateContent,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Regenerate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time, String rating) {
    Color ratingColor = Colors.grey;
    if (rating.contains('Best')) ratingColor = Colors.red;
    else if (rating.contains('Peak')) ratingColor = Colors.orange;
    else if (rating.contains('Good')) ratingColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ratingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rating,
              style: TextStyle(
                fontSize: 12,
                color: ratingColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleCard({
    required String title,
    required Color color,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildProductItem(TopProduct product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          Text(
            '⭐ ${product.rating}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBundleRecommendation(
    String name,
    String description,
    String discount,
    String projectedSales,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Diskon: $discount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Sales: $projectedSales',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
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
  }

  Widget _buildAnalysisResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(Icons.analytics, color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              const Text(
                'Analysis Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisResult!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _generateContent() async {
    if (_productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generatedContent = _generateMockContent();
      });
    }
  }

  String _generateMockContent() {
    final productName = _productNameController.text;
    final isTopProduct = _selectedProduct != null;
    
    if (isTopProduct) {
      final salesCount = _selectedProduct!.salesCount;
      return """🔥 PRODUK TERLARIS! 🔥

✨ $productName ✨
${_selectedProduct!.description}

🎯 Sudah $salesCount orang memilih produk ini!
📈 Trending di kategori ${_selectedProduct!.category}
⭐ Rating ${_selectedProduct!.rating}/5.0

${_generateCopywritingByTone()}

⚡ Buruan! Stok terbatas karena tingginya permintaan!

**PLACEHOLDER**: Konten ini akan dioptimalkan dengan AI model Anda untuk engagement maksimal berdasarkan data produk terlaris.""";
    }
    
    return _generateBasicCopywriting();
  }

  String _generateCopywritingByTone() {
    switch (_selectedTone.toLowerCase()) {
      case 'enthusiastic':
        return "🚀 WOW! Ini dia yang kalian tunggu-tunggu! Jangan sampai kehabisan ya!";
      case 'professional':
        return "Dengan kualitas terjamin dan telah dipercaya ribuan customer, produk ini adalah pilihan terbaik untuk Anda.";
      case 'casual':
        return "Hey guys! Kalian harus coba produk ini deh, worth it banget!";
      case 'urgent':
        return "⚠️ LAST CALL! Hanya tersisa sedikit stock! Order sekarang sebelum kehabisan!";
      default:
        return "Dapatkan ${_productNameController.text} terbaik dengan kualitas premium!";
    }
  }

  String _generateBasicCopywriting() {
    final productName = _productNameController.text;
    final tone = _selectedTone.toLowerCase();
    
    switch (tone) {
      case 'enthusiastic':
        return "🔥 $productName yang LUAR BIASA! 🔥\n\n✨ Kualitas premium dengan harga terjangkau!\n🎯 Perfect untuk ${_targetAudienceController.text.isNotEmpty ? _targetAudienceController.text : 'semua kalangan'}\n💎 ${_keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : 'Fitur unggulan yang memukau'}\n\n🚀 Jangan sampai kehabisan! Order sekarang juga!";
      
      case 'professional':
        return "$productName - Solusi Terbaik untuk Anda\n\nDengan teknologi terdepan dan kualitas yang telah teruji, $productName hadir untuk memenuhi kebutuhan ${_targetAudienceController.text.isNotEmpty ? _targetAudienceController.text : 'modern Anda'}.\n\nKeunggulan:\n${_keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : '• Kualitas premium\n• Desain modern\n• Mudah digunakan'}\n\nInvestasi terbaik untuk masa depan Anda.";
      
      default:
        return "✨ $productName ✨\n\nHey! Kenalan yuk sama produk keren ini. ${_keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : 'Punya banyak keunggulan'} dan cocok banget buat ${_targetAudienceController.text.isNotEmpty ? _targetAudienceController.text : 'kamu'}!\n\nYuk buruan order sebelum kehabisan! 💪";
    }
  }

  void _copyContent() {
    if (_generatedContent != null) {
      Clipboard.setData(ClipboardData(text: _generatedContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard!')),
      );
    }
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Live Reminder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih jadwal live streaming:'),
            SizedBox(height: 16),
            Text('📅 Hari: Kamis'),
            Text('⏰ Waktu: 19:00 - 20:30 WIB'),
            Text('🎯 Status: Peak Time'),
            SizedBox(height: 12),
            Text(
              'Reminder akan dikirim 30 menit sebelum live dimulai.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reminder berhasil diset untuk Kamis 19:00!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }

  void _showCreateBundleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bundle Creator'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎉 Bundle "Komplit Package" berhasil dibuat!'),
            SizedBox(height: 12),
            Text('📦 Isi bundle:'),
            Text('• Semua 3 produk terlaris Anda'),
            Text('• Diskon: 20%'),
            Text('• Proyeksi peningkatan sales: +35%'),
            SizedBox(height: 12),
            Text(
              '💡 Tips: Promosikan bundle ini di live streaming untuk hasil maksimal!',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Could navigate to products page to set up the bundle
            },
            child: const Text('Setup Bundle'),
          ),
        ],
      ),
    );
  }

  void _analyzeAccount() async {
    if (_tiktokUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter TikTok URL')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // Simulate API call to analyze TikTok account
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = _generateMockAnalysis();
      });
    }
  }

  String _generateMockAnalysis() {
    final username = UserService.currentUsername;
    return """📊 Account Analysis Results

🎯 Username: @${username.toLowerCase().replaceAll(' ', '')}
📅 Analysis Date: ${DateTime.now().toString().split(' ')[0]}

📈 Performance Metrics:
• Total Followers: 15.2K (+1.2K this month)
• Average Views: 8.5K per video
• Engagement Rate: 12.3% (Above average!)
• Best Posting Time: 19:00 - 21:00 WIB
• Top Content Category: Product Reviews

🔥 Recent Live Streams:
• Average Viewers: 450-650
• Peak Concurrent: 890 viewers
• Chat Engagement: 45 messages/minute
• Duration: 52 minutes average

💡 AI Recommendations:
• Increase posting frequency on Thursdays
• Focus on product demonstration content
• Collaborate with similar creators
• Use trending sounds for 25% more reach

⚡ Next Live Stream Optimal Time:
Thursday, 19:00 WIB (Expected 700+ viewers)""";
  }
}
