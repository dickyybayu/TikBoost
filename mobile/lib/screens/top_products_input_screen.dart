import 'package:flutter/material.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

class TopProductsInputScreen extends StatefulWidget {
  final VoidCallback? onProductsAdded;

  const TopProductsInputScreen({
    super.key,
    this.onProductsAdded,
  });

  @override
  State<TopProductsInputScreen> createState() => _TopProductsInputScreenState();
}

class _TopProductsInputScreenState extends State<TopProductsInputScreen> {
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  final List<TextEditingController> _descriptionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  final List<TextEditingController> _salesControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<String> _selectedCategories = ['Fashion', 'Fashion', 'Fashion'];
  
  final List<String> _categories = [
    'Fashion',
    'Food & Beverage',
    'Art & Culture',
    'Electronics',
    'Beauty & Health',
    'Home & Living',
    'Sports & Outdoor',
    'Books & Education',
  ];

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _salesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Input 3 Produk Terlaris',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan 3 produk terlaris Anda untuk mendapatkan copywriting AI yang optimal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Product Input Cards
            for (int i = 0; i < 3; i++) ...[
              _buildProductInputCard(i + 1, i),
              const SizedBox(height: 16),
            ],
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Use Demo Data Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _useDemoData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Gunakan Data Demo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInputCard(int productNumber, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk #$productNumber',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Product Name
          _buildTextField(
            controller: _nameControllers[index],
            label: 'Nama Produk',
            hint: 'Masukkan nama produk',
          ),
          const SizedBox(height: 16),
          
          // Product Description
          _buildTextField(
            controller: _descriptionControllers[index],
            label: 'Deskripsi Produk',
            hint: 'Masukkan deskripsi singkat produk',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Category Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategories[index],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategories[index] = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sales Count
          _buildTextField(
            controller: _salesControllers[index],
            label: 'Jumlah Penjualan (hari ini)',
            hint: 'Contoh: 150',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
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

  void _saveProducts() {
    // Validate input
    for (int i = 0; i < 3; i++) {
      if (_nameControllers[i].text.isEmpty ||
          _descriptionControllers[i].text.isEmpty ||
          _salesControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harap lengkapi semua field untuk Produk #${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Create products from input
    final products = <TopProduct>[];
    for (int i = 0; i < 3; i++) {
      products.add(
        TopProduct(
          id: 'user_product_${i + 1}',
          name: _nameControllers[i].text,
          description: _descriptionControllers[i].text,
          imageUrl: 'assets/images/placeholder_product.jpg',
          salesCount: int.tryParse(_salesControllers[i].text) ?? 0,
          rating: 4.5, // Default rating
          category: _selectedCategories[i],
        ),
      );
    }

    // Save to service
    TopProductsService.setTopProducts(products);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil disimpan!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
    widget.onProductsAdded?.call();
  }

  void _useDemoData() {
    final demoProducts = TopProductsService.getDummyTopProducts();
    TopProductsService.setTopProducts(demoProducts);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data demo berhasil dimuat!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
    widget.onProductsAdded?.call();
  }
}
