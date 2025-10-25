import 'package:flutter/material.dart';
import 'dart:async';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../services/top_products_service.dart';
import '../models/subscription_models.dart';
import '../widgets/tikboost_logo.dart';
import 'premium_upgrade_screen.dart';
import 'top_products_input_screen.dart';
import 'recommendations_screen.dart';
import 'live_analysis_screen.dart';
import 'planner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSettingsPressed;

  const DashboardScreen({super.key, this.onSettingsPressed});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserSubscription? userSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserSubscription();
    _loadUserProducts();
    // Periodic refresh every 2 seconds to catch premium changes
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _loadUserSubscription();
    });
  }

  Future<void> _loadUserProducts() async {
    try {
      await TopProductsService.loadProducts();
      if (mounted) {
        setState(() {}); // Refresh UI after loading products
      }
    } catch (e) {
      print('Error loading products in dashboard: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh subscription state when dependencies change
    _loadUserSubscription();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh when widget updates
    _loadUserSubscription();
  }

  void _loadUserSubscription() {
    final oldIsPremium = userSubscription?.isPremium ?? false;
    setState(() {
      userSubscription = SubscriptionService.currentSubscription;
    });
    final newIsPremium = userSubscription?.isPremium ?? false;
    if (oldIsPremium != newIsPremium) {
      print(
        'Dashboard: Premium status changed from $oldIsPremium to $newIsPremium',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = SubscriptionService.isPremium;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            TikBoostLogoIcon(size: 32),
            SizedBox(width: 12),
            Text(
              'TikBoost',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ],
        ),
        actions: [
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
    String displayName = _formatDisplayName(userName);

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
                      'Selamat Datang, $displayName! 👋',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Boost TikTok Anda dengan AI',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
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
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upgrade ke Premium untuk melihat statistik TikTok, analisis mendalam, dan fitur live stream advanced!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
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
        color: isPremium ? Colors.blue[50] : Colors.grey[100],
        border: Border.all(
          color: isPremium ? Colors.blue[300]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPremium ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              isPremium ? Icons.verified : Icons.account_circle,
              color: isPremium ? Colors.blue[600] : Colors.grey[600],
              size: 30,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremium ? 'Premium Member' : 'Free Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.blue[800] : Colors.grey[700],
                      ),
                    ),
                    if (isPremium) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  isPremium
                      ? 'Akses semua fitur premium TikBoost'
                      : 'Upgrade untuk fitur analisis & live stream',
                  style: TextStyle(
                    fontSize: 14,
                    color: isPremium ? Colors.blue[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[300]!],
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
                      builder:
                          (context) => PremiumUpgradeScreen(
                            featureName: 'Premium Features',
                            onUpgradeSuccess: () {
                              _loadUserSubscription();
                            },
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
                      builder:
                          (context) => PremiumUpgradeScreen(
                            featureName: 'Live Stream Performance',
                            onUpgradeSuccess: () {
                              _loadUserSubscription();
                            },
                          ),
                    ),
                  ).then((_) => _loadUserSubscription());
                },
                icon: Icon(Icons.lock_open),
                label: Text('Unlock Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
                      style: TextStyle(color: Colors.green[500], fontSize: 14),
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

  String _formatDisplayName(String userName) {
    if (userName.isEmpty) return 'User';

    // Split by dots, underscores, or other separators
    List<String> parts = userName.split(RegExp(r'[._@-]'));

    if (parts.isNotEmpty) {
      String firstName = parts[0];
      // Capitalize first letter
      return firstName.isNotEmpty
          ? firstName[0].toUpperCase() + firstName.substring(1).toLowerCase()
          : 'User';
    }

    return userName;
  }

  Widget _buildQuickActions() {
    final isPremium = SubscriptionService.isPremium;
    final hasProducts = TopProductsService.userTopProducts.isNotEmpty;

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
                title: hasProducts ? 'Edit Produk' : 'Input Produk',
                icon: hasProducts ? Icons.edit : Icons.shopping_cart,
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                onTap: () {
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
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Recommendations',
                icon: Icons.auto_awesome,
                colors: [Colors.blue[400]!, Colors.blue[300]!],
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
                colors:
                    isPremium
                        ? [Colors.red[400]!, Colors.pink[400]!]
                        : [Colors.grey[300]!, Colors.grey[400]!],
                onTap:
                    isPremium
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LiveAnalysisScreen(),
                            ),
                          );
                        }
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PremiumUpgradeScreen(
                                    featureName: 'Live Analysis',
                                    onUpgradeSuccess: () {
                                      _loadUserSubscription();
                                    },
                                  ),
                            ),
                          ).then((_) => _loadUserSubscription());
                        },
                isLocked: !isPremium,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Planner',
                icon: Icons.calendar_today,
                colors: [Colors.purple[400]!, Colors.deepPurple[400]!],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlannerScreen()),
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
        width: double.infinity,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock, color: Colors.white70, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _showAnalyticsFeature() {
    final isPremium = SubscriptionService.isPremium;

    if (!isPremium) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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
                        builder:
                            (context) => PremiumUpgradeScreen(
                              featureName: 'Analytics',
                              onUpgradeSuccess: () {
                                _loadUserSubscription();
                              },
                            ),
                      ),
                    ).then((_) => _loadUserSubscription());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
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
