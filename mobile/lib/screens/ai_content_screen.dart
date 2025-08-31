import 'package:flutter/material.dart';
import 'ai_content_generator_screen.dart';

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
              'AI Content Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create content for your products using AI insights from trending TikTok data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
            // Generate Content for Your Products Card
            _buildContentCard(
              'Generate Content for Your Products',
              'Create compelling descriptions and scripts based on your products and current TikTok trends.',
              const Color(0xFFFAE8D4),
              Icons.auto_awesome,
              'Generate',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIContentGeneratorScreen(
                      contentType: 'copywriting',
                      title: 'Generate Content',
                      description: 'Create compelling copy that converts viewers into customers using AI insights from trending TikTok data.',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Optimize Your Live Sessions Card
            _buildContentCard(
              'Optimize Your Live Sessions',
              'Get AI recommendations for timing, content, and engagement strategies based on real-time data.',
              const Color(0xFFF5F1EE),
              Icons.trending_up,
              'Get Tips',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIContentGeneratorScreen(
                      contentType: 'script',
                      title: 'Live Session Optimizer',
                      description: 'Get AI-powered recommendations to improve your live session performance using trending data.',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Trending Insights Card
            _buildContentCard(
              'Trending Insights',
              'Discover what\'s trending on TikTok and how to adapt it for your products.',
              const Color(0xFFF0F7F0),
              Icons.insights,
              'View Trends',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIContentGeneratorScreen(
                      contentType: 'insights',
                      title: 'Trending Insights',
                      description: 'Explore current TikTok trends and get AI suggestions on how to incorporate them with your products.',
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Bundle Products Strategically Card
            _buildContentCard(
              'Bundle Products Strategically',
              'Create attractive product bundles to increase sales and customer satisfaction.',
              const Color(0xFFEAE3D2),
              Icons.inventory_2_rounded,
              'Generate',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIContentGeneratorScreen(
                      contentType: 'description',
                      title: 'Generate Product Description',
                      description: 'Create detailed and persuasive product descriptions that highlight key features and benefits.',
                    ),
                  ),
                );
              },
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
