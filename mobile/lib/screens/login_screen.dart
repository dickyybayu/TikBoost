import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../widgets/tikboost_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final api = ApiService();
    final token = await api.login(_emailController.text.trim(), _passwordController.text);
    
    if (token != null) {
      // Get user profile and save to UserService
      final userProfile = await api.getUserProfile(token);
      if (userProfile != null) {
        UserService.setUserData(
          username: userProfile['username'] ?? userProfile['email'] ?? 'User',
          email: userProfile['email'] ?? _emailController.text.trim(),
          token: token,
        );
      } else {
        // Fallback if profile fetch fails
        UserService.setUserData(
          username: _emailController.text.trim().split('@').first,
          email: _emailController.text.trim(),
          token: token,
        );
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Login failed. Please check your credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Masuk',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TikBoost Logo
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: TikBoostLogo(size: 100),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Masuk untuk menggunakan TikBoost',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
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
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.blue[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue[400]!),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outlined, color: Colors.blue[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue[400]!),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 24),
                          if (_error != null) ...[
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/register');
                        },
                  child: RichText(
                    text: TextSpan(
                      text: "Belum punya akun? ",
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: "Daftar",
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
