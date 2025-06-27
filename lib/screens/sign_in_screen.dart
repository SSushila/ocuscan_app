import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/data_repository.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _formKey.currentState!.save();
    final repo = DataRepository();
    try {
      final result = await repo.signIn(email: _email, password: _password);
      if (result != null) {
      // Save user to AuthService for session persistence
      String userJson;
      if (result is Map<String, dynamic>) {
        // Offline: SQLite user map
        userJson = jsonEncode({
          'email': result['email'] ?? _email,
          'full_name': result['full_name'] ?? '',
          'hospital_name': result['hospital_name'] ?? '',
        });
      } else if (result is AuthResponse) {
        // Online: Supabase AuthResponse
        final user = result.user;
        userJson = jsonEncode({
          'email': user?.email ?? _email,
          'full_name': user?.userMetadata?['full_name'] ?? '',
          'hospital_name': user?.userMetadata?['hospital_name'] ?? '',
        });
      } else if (result is Map && result.containsKey('user')) {
        // Supabase response as Map
        final user = result['user'];
        userJson = jsonEncode({
          'email': user['email'] ?? _email,
          'full_name': user['full_name'] ?? '',
          'hospital_name': user['hospital_name'] ?? '',
        });
      } else {
        userJson = jsonEncode({'email': _email});
      }
      await AuthService.saveUser(userJson);
      if (!await AuthService.hasSeenOnboarding()) {
        if (context.mounted) context.go('/onboarding');
      } else {
        if (context.mounted) context.go('/physician-dashboard');
      }
    } else {
      setState(() {
        _errorMessage = 'Invalid login credentials';
      });
    }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid login credentials';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E88E5)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_errorMessage.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                        const Text('OcuScan', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                        const SizedBox(height: 8),
                        const Text('Sign in to your account', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                        const SizedBox(height: 28),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: const Color(0xFFF6F8FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your email' : null,
                          onSaved: (value) => _email = value!.trim(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: const Color(0xFFF6F8FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                          onSaved: (value) => _password = value!,
                        ),
                         const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _isLoading ? null : _handleSignIn,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Don't have an account? ",
        style: TextStyle(
          color: Color(0xFF666666),
          fontSize: 15,
        ),
      ),
      TextButton(
        onPressed: () => context.go('/create-account'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1E88E5),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        child: const Text('Create Account'),
      ),
    ],
  ),
),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
