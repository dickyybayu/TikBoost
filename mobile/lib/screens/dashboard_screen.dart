import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../models/subscription_models.dart';
import '../widgets/tikboost_logo.dart';
import 'premium_upgrade_screen.dart';
import 'top_products_input_screen.dart';
import 'recommendations_screen.dart';
import 'live_analysis_screen.dart';
import 'products_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSettingsPressed;

  const DashboardScreen({
    super.key,
    this.onSettingsPressed,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserSubscription? userSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserSubscription();
    // Initialize demo user only if no user is logged in
    if (!UserService.isLoggedIn) {
      UserService.setDemoUser();
    }
  }

  void _loadUserSubscription() {
    setState(() {
      userSubscription = SubscriptionService.currentSubscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = userSubscription?.tier.name == 'Premium';
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            TikBoostLogoIcon(size: 32),
            SizedBox(width: 12),
            Text(
              'TikBoost',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          if (!isPremium)
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(Icons.star_rounded, color: Colors.purple[400]),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumUpgradeScreen(
                        featureName: 'Dashboard Premium Features',
                      ),
                    ),
                  ).then((_) => _loadUserSubscription());
                },
              ),
            ),
          if (widget.onSettingsPressed != null)
            IconButton(
              icon: Icon(Icons.settings_outlined),
              onPressed: widget.onSettingsPressed,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            SizedBox(height: 24),
            _buildSubscriptionStatus(isPremium),
            SizedBox(height: 24),
            if (!isPremium) ...[
              _buildFreeTierLimitation(),
              SizedBox(height: 24),
            ],
            _buildLiveStreamCard(isPremium),
            SizedBox(height: 24),
            _buildKeyMetricsSection(isPremium),
            SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    String userName = UserService.currentUsername;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, $userName! 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Boost TikTok Anda dengan AI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.star,
                color: Colors.purple[400],
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTierLimitation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.blue[600]),
          SizedBox(height: 16),
          Text(
            'Tier Gratis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Anda dapat menggunakan fitur dasar seperti input produk terlaris, generate copywriting, live session planner, dan bundle products.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upgrade ke Premium untuk melihat statistik TikTok, analisis mendalam, dan fitur live stream advanced!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w500,
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
  Widget _buildSubscriptionStatus(bool isPremium) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPremium ? Colors.amber[50] : Colors.grey[100],
        border: Border.all(
          color: isPremium ? Colors.amber : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.star : Icons.account_circle,
            color: isPremium ? Colors.amber : Colors.grey[600],
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Member ⭐' : 'Free Member',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.amber[800] : Colors.grey[700],
                  ),
                ),
                Text(
                  isPremium 
                    ? 'Akses semua fitur premium'
                    : 'Upgrade untuk fitur lengkap',
                  style: TextStyle(
                    fontSize: 14,
                    color: isPremium ? Colors.amber[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.pink[400]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumUpgradeScreen(
                        featureName: 'Premium Features',
                      ),
                    ),
                  ).then((_) => _loadUserSubscription());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Upgrade',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamCard(bool isPremium) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.live_tv, color: Colors.red, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Live Stream Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (!isPremium)
                Icon(Icons.lock, color: Colors.grey[400], size: 20),
            ],
          ),
          SizedBox(height: 20),
          
          if (!isPremium) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.grey[400], size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Fitur Premium',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upgrade untuk analisis live stream',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumUpgradeScreen(
                        featureName: 'Live Stream Performance',
                      ),
                    ),
                  ).then((_) => _loadUserSubscription());
                },
                icon: Icon(Icons.star),
                label: Text('Unlock Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(bool isPremium) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bar_chart, color: Colors.blue[600], size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Key Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (!isPremium)
                Icon(Icons.lock, color: Colors.grey[400], size: 20),
            ],
          ),
          SizedBox(height: 20),
          
          if (!isPremium) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, color: Colors.grey[400], size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Analisis Mendalam',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upgrade untuk melihat metrics detail',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAnalyticsFeature(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Buka Analisis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else ...[
            // Premium content - detailed metrics (placeholder for now)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics, color: Colors.green[600], size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Analytics Premium',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fitur analytics premium aktif',
                      style: TextStyle(
                        color: Colors.green[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final isPremium = userSubscription?.tier.name == 'Premium';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Input Produk',
                icon: Icons.shopping_cart,
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopProductsInputScreen(
                        onProductsAdded: () => setState(() {}),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Recommendations',
                icon: Icons.auto_awesome,
                colors: [Colors.purple[400]!, Colors.pink[400]!],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Live Analysis',
                icon: Icons.live_tv,
                colors: isPremium 
                  ? [Colors.red[400]!, Colors.pink[400]!]
                  : [Colors.grey[300]!, Colors.grey[400]!],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveAnalysisScreen(),
                    ),
                  );
                },
                isLocked: !isPremium,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Products',
                icon: Icons.inventory,
                colors: [Colors.grey[400]!, Colors.grey[600]!],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.lock,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsFeature() {
    final isPremium = userSubscription?.tier.name == 'Premium';
    
    if (!isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('🔒 Fitur Premium'),
          content: Text(
            'Analytics adalah fitur premium. Upgrade ke Premium untuk melihat analisis mendalam tentang performa TikTok Anda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PremiumUpgradeScreen(
                      featureName: 'Analytics',
                    ),
                  ),
                ).then((_) => _loadUserSubscription());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
                foregroundColor: Colors.white,
              ),
              child: Text('Upgrade'),
            ),
          ],
        ),
      );
    } else {
      // Show premium analytics (placeholder)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening Analytics...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
