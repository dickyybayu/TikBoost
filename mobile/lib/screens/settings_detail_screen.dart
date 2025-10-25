import 'package:flutter/material.dart';
import '../utils/theme_notifier.dart';

class SettingsDetailScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final String name;
  final String email;

  const SettingsDetailScreen({
    super.key,
    required this.themeNotifier,
    required this.name,
    required this.email,
  });

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _darkMode = widget.themeNotifier.isDark;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: 'Profile',
              child: Column(
                children: [
                  _textField(label: 'Full Name', controller: _nameController),
                  const SizedBox(height: 12),
                  _textField(label: 'Email', controller: _emailController, enabled: false),
                  const SizedBox(height: 12),
                  _textField(label: 'Username', controller: _usernameController),
                  const SizedBox(height: 12),
                  _textField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _textField(label: 'Bio', controller: _bioController, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              title: 'Social Accounts',
              child: Column(
                children: [
                  _textField(label: 'TikTok Username', controller: _tiktokController),
                  const SizedBox(height: 12),
                  _textField(label: 'YouTube Username', controller: _youtubeController),
                  const SizedBox(height: 12),
                  _textField(label: 'Instagram Username', controller: _instagramController),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              title: 'Appearance',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Switch.adaptive(
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() => _darkMode = v);
                      widget.themeNotifier.toggleTheme();
                    },
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Changes'),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _save() {
    // For demo, just show a SnackBar. Wire to backend later if needed.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
    Navigator.pop(context);
  }
}

