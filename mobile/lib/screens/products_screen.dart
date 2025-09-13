import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'top_products_input_screen.dart';
import '../services/subscription_service.dart';
import '../services/top_products_service.dart';
import '../models/subscription_models.dart';
import '../models/product_models.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final userTopProducts = TopProductsService.userTopProducts;
    final hasTopProducts = TopProductsService.hasTopProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Products',
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
            icon: const Icon(Icons.add_rounded, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Products Section
            if (hasTopProducts) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '3 Produk Terlaris',
                    style: TextStyle(
                      fontSize: 20,
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
              const SizedBox(height: 16),

              // Top Products List
              ...userTopProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;
                return Column(
                  children: [
                    _buildTopProductCard(context, product, index + 1, index),
                    const SizedBox(height: 12),
                  ],
                );
              }),

              const SizedBox(height: 32),
            ] else ...[
              // No Top Products - Show input card
              _buildNoTopProductsCard(),
              const SizedBox(height: 32),
            ],

            // Product Bundles Section (Free Feature)
            if (hasTopProducts) ...[
              const Text(
                'Recommended Product Bundles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Bundle Cards based on top products - Available for FREE
              _buildBundleCardFromTopProducts(
                userTopProducts.take(2).toList(),
                'Cultural Heritage Bundle',
                'Save 15%',
              ),
              const SizedBox(height: 12),

              _buildBundleCardFromTopProducts(
                userTopProducts,
                'Complete Collection',
                'Save 20%',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoTopProductsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_business, size: 48, color: Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Produk Terlaris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Input 3 produk terlaris Anda untuk mendapatkan insight dan rekomendasi yang lebih personal',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Input Produk Terlaris'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductCard(
    BuildContext context,
    Product product,
    int rank,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  rank == 1
                      ? Colors.amber
                      : rank == 2
                      ? Colors.grey.shade400
                      : Colors.orange.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory, color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)} • ${product.salesCount} terjual',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  _showDeleteProductDialog(product, index);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              // Detail button only for premium users
              if (SubscriptionService.isPremium)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailScreen(
                              productName: product.name,
                              soldCount: '${product.salesCount} terjual',
                            ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBundleCardFromTopProducts(
    List<Product> products,
    String bundleName,
    String discount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bundleName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bundling: ${products.map((p) => p.name).join(' + ')}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Show bundle details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bundle "$bundleName" details'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(Product product, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Produk Terlaris'),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${product.name}" dari daftar produk terlaris?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeProduct(index);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  Future<void> _removeProduct(int index) async {
    await TopProductsService.removeProduct(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
