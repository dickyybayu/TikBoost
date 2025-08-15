import 'package:flutter/material.dart';

class AIContentScreen extends StatelessWidget {
  const AIContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'AI Content Suggestions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Craft Compelling Copywriting Card
            _buildContentCard(
              'Craft Compelling Copywriting',
              'Generate engaging product descriptions and scripts for your live sessions.',
              const Color(0xFFFAE8D4),
              Icons.edit_rounded,
              'Generate',
              () {},
            ),
            
            const SizedBox(height: 16),
            
            // Optimize Live Session Timing Card
            _buildContentCard(
              'Optimize Live Session Timing',
              'Discover the best times to go live based on your audience\'s activity patterns.',
              const Color(0xFFF5F1EE),
              Icons.access_time_rounded,
              'View',
              () {},
            ),
            
            const SizedBox(height: 16),
            
            // Match with the Right Host Card
            _buildContentCard(
              'Match with the Right Host',
              'Find hosts whose style and audience align with your products.',
              const Color(0xFFF0F7F0),
              Icons.handshake_rounded,
              'Find Hosts',
              () {},
            ),
            
            const SizedBox(height: 16),
            
            // Bundle Products Strategically Card
            _buildContentCard(
              'Bundle Products Strategically',
              'Create attractive product bundles to increase sales and customer satisfaction.',
              const Color(0xFFEAE3D2),
              Icons.inventory_2_rounded,
              'Create Bundle',
              () {},
            ),
            
            const SizedBox(height: 32),
            
            // Refresh Suggestions Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
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
                  'Refresh Suggestions',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContentCard(
    String title,
    String description,
    Color backgroundColor,
    IconData icon,
    String buttonText,
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
              color: Colors.brown.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onPressed,
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
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
