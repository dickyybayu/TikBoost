import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'utils/app_constants.dart';
import 'utils/theme_notifier.dart';
import 'screens/dashboard_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/products_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/subscription_service.dart';

void main() {
  // Reset subscription to default on app start
  SubscriptionService.resetToDefault();
  runApp(TikBoostApp());
}

class TikBoostApp extends StatefulWidget {
  TikBoostApp({super.key});

  @override
  State<TikBoostApp> createState() => _TikBoostAppState();
}

class _TikBoostAppState extends State<TikBoostApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          routes: {
            '/dashboard':
                (context) => MainScreen(themeNotifier: _themeNotifier),
            '/login': (context) => LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
          home:
              _isAuthenticated
                  ? MainScreen(themeNotifier: _themeNotifier)
                  : LoginScreen(key: const Key('login')),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const MainScreen({super.key, required this.themeNotifier});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<BottomNavigationBarItem> _navigationItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.auto_awesome_rounded),
      label: 'Recommendations',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_rounded),
      label: 'Planner',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory_rounded),
      label: 'Products',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeNotifier.isDark;

    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(onSettingsPressed: () => _navigateToSettings());
      case 1:
        return const RecommendationsScreen();
      case 2:
        return const PlannerScreen();
      case 3:
        return const ProductsScreen();
      case 4:
        return SettingsScreen(themeNotifier: widget.themeNotifier);
      default:
        return DashboardScreen(onSettingsPressed: () => _navigateToSettings());
    }
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.black54,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _navigationItems,
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SettingsScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }
}
