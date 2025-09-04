import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_models.dart';

class AIContentGeneratorScreen extends StatefulWidget {
  final String contentType;
  final String title;
  final String description;

  const AIContentGeneratorScreen({
    super.key,
    required this.contentType,
    required this.title,
    required this.description,
  });

  @override
  State<AIContentGeneratorScreen> createState() => _AIContentGeneratorScreenState();
}

class _AIContentGeneratorScreenState extends State<AIContentGeneratorScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _keyFeaturesController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  String _selectedTone = 'Enthusiastic';
  String _selectedFormat = 'Short & Punchy';
  bool _isGenerating = false;
  String? _generatedContent;
  TopProduct? _selectedProduct;

  final List<String> _tones = [
    'Enthusiastic',
    'Professional',
    'Casual',
    'Friendly',
    'Confident',
    'Urgent'
  ];

  final List<String> _formats = [
    'Short & Punchy',
    'Detailed',
    'Story-driven',
    'Feature-focused',
    'Benefit-focused'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select first top product if available
    final topProducts = TopProductsService.userTopProducts;
    if (topProducts.isNotEmpty) {
      _selectedProduct = topProducts.first;
      _productNameController.text = _selectedProduct!.name;
      _keyFeaturesController.text = _selectedProduct!.description;
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.black87),
            onPressed: () {
              // Show generation history
              _showGenerationHistory();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
              ),
              child: Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E40AF),
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Input Form
            const Text(
              'Product Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Top Products Dropdown (if available)
            if (TopProductsService.hasTopProducts) ...[
              _buildTopProductsDropdown(),
              const SizedBox(height: 16),
            ],
            
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
            
            // Tone Selection
            _buildDropdownField(
              'Tone',
              _selectedTone,
              _tones,
              Icons.mood_rounded,
              (value) => setState(() => _selectedTone = value!),
            ),
            const SizedBox(height: 16),
            
            // Format Selection
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
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateContent,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Content'),
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
            
            if (_generatedContent != null) ...[
              const SizedBox(height: 32),
              
              // Generated Content
              const Text(
                'Generated Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
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
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generatedContent!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _regenerateContent,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveContent,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
    List<String> options,
    IconData icon,
    void Function(String?) onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _generateContent() async {
    if (_productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedContent = null;
    });

    // **PLACEHOLDER**: This is where you would integrate with your AI model
    // For now, we'll show dummy generated content
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generatedContent = _generateEnhancedContent();
      });
    }
  }

  String _generateEnhancedContent() {
    final productName = _productNameController.text;
    final isTopProduct = _selectedProduct != null;
    
    // **PLACEHOLDER**: Enhanced dummy content based on whether it's a top product
    if (widget.contentType == 'copywriting') {
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

#TikTokShop #$productName #Trending #${_selectedProduct!.category}""";
      } else {
        return """✨ $productName ✨

${_keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : 'Produk berkualitas tinggi yang wajib Anda miliki!'}

${_generateCopywritingByTone()}

🛒 Pesan sekarang dan rasakan perbedaannya!

#TikTokShop #$productName""";
      }
    } else if (widget.contentType == 'script') {
      if (isTopProduct) {
        return """\"Halo viewers! Selamat datang di live streaming hari ini! 👋

Hari ini saya mau bahas produk yang lagi VIRAL banget - $productName!

Kalian tau gak? Ini adalah produk terlaris nomor ${TopProductsService.userTopProducts.indexOf(_selectedProduct!) + 1} di kategori ${_selectedProduct!.category}! 

Sudah ${_selectedProduct!.salesCount} orang yang beli dan rata-rata kasih rating ${_selectedProduct!.rating} bintang!

${_selectedProduct!.description}

Tapi tunggu dulu... khusus untuk live streaming hari ini, ada PROMO SPECIAL!

Siapa yang mau order? Ketik 'SAYA MINAT' di chat sekarang!\"
        
**PLACEHOLDER**: Script ini akan dioptimalkan dengan AI model Anda untuk engagement maksimal berdasarkan data produk terlaris.""";
      }
    }
    
    return _getMockGeneratedContent();
  }

  String _getMockGeneratedContent() {
    final productName = _productNameController.text;
    final tone = _selectedTone.toLowerCase();
    
    switch (widget.contentType) {
      case 'copywriting':
        return "🌟 Dapatkan $productName sekarang! \n\nProduk revolusioner yang akan mengubah hidup Anda. Dengan teknologi terdepan dan kualitas premium, $productName hadir untuk memberikan solusi terbaik. \n\n✨ Manfaat utama:\n• Hasil terlihat dalam 7 hari\n• Teruji klinis dan aman\n• Garansi 100% uang kembali\n\n🔥 PROMO TERBATAS! Diskon 50% hanya untuk 100 pembeli pertama. Jangan sampai terlewat!";
      
      case 'script':
        return "\"Halo semuanya! Selamat datang di live streaming hari ini! 👋\n\nHari ini saya punya produk yang luar biasa untuk kalian - $productName! \n\nKalian tau gak? Produk ini sudah terbukti memberikan hasil yang amazing. Lihat nih testimonial dari customer kita...\n\n[Tunjukkan testimonial]\n\nNah, khusus untuk viewers setia hari ini, saya kasih promo special. Tapi inget ya, stoknya terbatas!\n\nSiapa yang mau order? Ketik 'SAYA MINAT' di chat!\"";
      
      case 'description':
        return "$productName - Solusi Inovatif untuk Gaya Hidup Modern\n\nDeskripsi Produk:\n$productName hadir sebagai jawaban atas kebutuhan Anda akan kualitas dan kepraktisan. Dirancang dengan teknologi terkini dan bahan premium, produk ini memberikan pengalaman yang tak terlupakan.\n\nSpesifikasi:\n• Material berkualitas tinggi\n• Desain ergonomis dan stylish\n• Mudah digunakan untuk semua usia\n• Ramah lingkungan\n\nCocok untuk Anda yang menghargai kualitas dan efisiensi dalam setiap aktivitas.";
      
      default:
        return "Konten AI telah berhasil dibuat untuk $productName dengan tone $tone. Konten ini dioptimalkan untuk engagement maksimal dan conversion yang tinggi.";
    }
  }

  void _regenerateContent() {
    _generateContent();
  }

  void _copyContent() {
    // Copy to clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard!')),
    );
  }

  void _saveContent() {
    // Save content functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content saved successfully!')),
    );
  }

  void _showGenerationHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Generation History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(
                    'Generated content #${index + 1}',
                    '2 hours ago',
                    'Product: Sample Product ${index + 1}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String time, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsDropdown() {
    final topProducts = TopProductsService.userTopProducts;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih dari Produk Terlaris',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TopProduct>(
              value: _selectedProduct,
              hint: const Text('Pilih produk terlaris'),
              items: [
                const DropdownMenuItem<TopProduct>(
                  value: null,
                  child: Text('Manual input'),
                ),
                ...topProducts.map((product) {
                  return DropdownMenuItem<TopProduct>(
                    value: product,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                  );
                }),
              ],
              onChanged: (TopProduct? product) {
                setState(() {
                  _selectedProduct = product;
                  if (product != null) {
                    _productNameController.text = product.name;
                    _keyFeaturesController.text = product.description;
                  } else {
                    _productNameController.clear();
                    _keyFeaturesController.clear();
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  String _generateCopywritingByTone() {
    switch (_selectedTone) {
      case 'Enthusiastic':
        return '🎉 WOW! Ini dia yang lagi viral! Jangan sampai ketinggalan tren!';
      case 'Professional':
        return '✅ Kualitas terjamin dengan standar internasional. Investasi terbaik untuk Anda.';
      case 'Casual':
        return '😊 Guys, ini sih emang juara! Recommended banget deh!';
      case 'Friendly':
        return '💝 Halo sahabat! Aku mau share produk favorit yang bikin hidup jadi lebih mudah nih!';
      case 'Confident':
        return '💪 PASTI suka! Garansi 100% atau uang kembali. Berani jamin karena kualitasnya memang top!';
      case 'Urgent':
        return '⏰ PROMO TERBATAS! Hanya tersisa beberapa unit lagi. Jangan sampai menyesal!';
      default:
        return '✨ Produk pilihan yang tepat untuk Anda!';
    }
  }
}
