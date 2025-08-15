import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Optimal Live Time Notification
          _buildNotificationCard(
            Icons.access_time_rounded,
            'Optimal Live Time',
            'Best time to go live today: 19:00 WIB',
            [
              _buildActionButton('Copy', false),
              _buildActionButton('Go Live', true),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bundling Opportunity Notification
          _buildNotificationCard(
            Icons.card_giftcard_rounded,
            'Bundling Opportunity',
            'New bundle available: Masker + Serum (15% Off)',
            [
              _buildActionButton('Copy', false),
              _buildActionButton('Try Now', true),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Boost Notification
          _buildNotificationCard(
            Icons.trending_up_rounded,
            'Performance Boost',
            'Your live performance has increased by 20% this week.',
            [
              _buildActionButton('Copy', false),
              _buildActionButton('View Report', true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard(
    IconData icon,
    String title,
    String description,
    List<Widget> actions,
  ) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.black54,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: actions.map((action) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: action,
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String text, bool isPrimary) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary 
          ? const Color(0xFF3B82F6) 
          : const Color(0xFFF0F0F0),
        foregroundColor: isPrimary 
          ? Colors.white 
          : Colors.black54,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
