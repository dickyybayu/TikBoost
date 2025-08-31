import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final api = ApiService();
    final token = await api.login(_emailController.text.trim(), _passwordController.text);
    setState(() {
      _isLoading = false;
    });
    if (token != null) {
      // Save token and navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _error = 'Login failed. Please check your credentials.';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() {
          _isLoading = false;
        });
        return; // user cancelled
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Missing Google idToken');
      final token = await ApiService().loginWithGoogle(idToken);
      setState(() {
        _isLoading = false;
      });
      if (token != null && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _error = 'Google sign-in failed.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Google sign-in error: ${e.toString()}';
      });
    }
  }

  Future<void> _loginWithTikTok() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final startUrl = await ApiService().getTikTokAuthUrl();
      if (startUrl == null) throw Exception('TikTok not configured');
      final callbackScheme = 'tikboost';
      final result = await FlutterWebAuth2.authenticate(
        url: startUrl.toString(),
        callbackUrlScheme: callbackScheme,
      );
      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      setState(() {
        _isLoading = false;
      });
      if (token != null && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _error = 'TikTok sign-in failed.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'TikTok sign-in error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _loginWithGoogle,
                child: const Text('Continue with Google'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _loginWithTikTok,
                child: const Text('Continue with TikTok'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/register');
                    },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
