import 'package:flutter/material.dart';

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
        const SnackBar(content: Text('Please enter a product name')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedContent = null;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock generated content based on content type
    String generatedText = _getMockGeneratedContent();

    setState(() {
      _isGenerating = false;
      _generatedContent = generatedText;
    });
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
}
