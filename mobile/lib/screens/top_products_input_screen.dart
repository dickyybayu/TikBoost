import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/top_products_service.dart';

class TopProductsInputScreen extends StatefulWidget {
  final VoidCallback? onProductsAdded;

  const TopProductsInputScreen({super.key, this.onProductsAdded});

  @override
  State<TopProductsInputScreen> createState() => _TopProductsInputScreenState();
}

class _TopProductsInputScreenState extends State<TopProductsInputScreen> {
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> _priceControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> _salesControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProducts();
  }

  // Load existing products if available
  void _loadExistingProducts() {
    final existingProducts = TopProductsService.userTopProducts;
    for (int i = 0; i < existingProducts.length && i < 3; i++) {
      _nameControllers[i].text = existingProducts[i].name;
      _priceControllers[i].text = existingProducts[i].price.toString();
      _salesControllers[i].text = existingProducts[i].salesCount.toString();
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
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
        title: Text(
          TopProductsService.userTopProducts.isNotEmpty
              ? 'Edit 3 Produk Terlaris'
              : 'Input 3 Produk Terlaris',
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
                child: Text(
                  TopProductsService.userTopProducts.isNotEmpty
                      ? 'Update Produk'
                      : 'Simpan Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

          // Product Price
          _buildTextField(
            controller: _priceControllers[index],
            label: 'Harga Produk',
            hint: 'Masukkan harga dalam Rupiah (contoh: 150000)',
            keyboardType: TextInputType.number,
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

  void _saveProducts() async {
    // Validate input
    for (int i = 0; i < 3; i++) {
      if (_nameControllers[i].text.isEmpty ||
          _priceControllers[i].text.isEmpty ||
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
    final products = <Product>[];
    for (int i = 0; i < 3; i++) {
      products.add(
        Product(
          id: 'user_product_${i + 1}',
          name: _nameControllers[i].text,
          price: double.tryParse(_priceControllers[i].text) ?? 0.0,
          salesCount: int.tryParse(_salesControllers[i].text) ?? 0,
        ),
      );
    }

    // Save to service
    await TopProductsService.setProducts(products);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TopProductsService.userTopProducts.isNotEmpty
              ? 'Produk berhasil diupdate!'
              : 'Produk berhasil disimpan!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
    widget.onProductsAdded?.call();
  }
}
