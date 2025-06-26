import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/data_repository.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  String _fullName = '';
  String _email = '';
  String _hospitalName = '';
  String _password = '';
  String _confirmPassword = '';
  bool _acceptedTerms = false;
  bool _isLoading = false;

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) return;
    setState(() => _isLoading = true);
    _formKey.currentState!.save();
    final repo = DataRepository();
    final result = await repo.signUp(
      email: _email,
      password: _password,
      fullName: _fullName,
      hospitalName: _hospitalName,
    );
    if (result != null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Created'),
            content: const Text('Your account has been created. Please sign in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/sign-in');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Creation Failed'),
            content: const Text('Unable to create account. Please try again.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      }
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Create Account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Full Name',
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
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your full name' : null,
                          onSaved: (value) => _fullName = value!.trim(),
                        ),
                        const SizedBox(height: 16),
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
                            labelText: 'Hospital Name',
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
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your hospital name' : null,
                          onSaved: (value) => _hospitalName = value!.trim(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
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
                          validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                          onSaved: (value) => _password = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Confirm your password';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          onSaved: (value) => _confirmPassword = value!,
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: GestureDetector(
                            onTap: () async {
                              final accepted = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: const Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          'By creating an account, you agree to the following terms and conditions:\n\n'
                                          '1. You confirm that you are a licensed physician.\n\n'
                                          '2. You will maintain the confidentiality of patient data.\n\n'
                                          '3. You will use the application in accordance with medical ethics and regulations.\n\n'
                                          '4. You understand that this is a diagnostic aid and not a replacement for professional medical judgment.',
                                          style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF1E88E5),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Accept & Continue'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (accepted == true) {
                                setState(() => _acceptedTerms = true);
                              }
                            },
                            child: const Text.rich(
                              TextSpan(
                                text: 'I accept the ',
                                style: TextStyle(color: Color(0xFF333333)),
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          value: _acceptedTerms,
                          onChanged: (v) async {
                            if (v == true) {
                              final accepted = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: const Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          'By creating an account, you agree to the following terms and conditions:\n\n'
                                          '1. You confirm that you are a licensed physician.\n\n'
                                          '2. You will maintain the confidentiality of patient data.\n\n'
                                          '3. You will use the application in accordance with medical ethics and regulations.\n\n'
                                          '4. You understand that this is a diagnostic aid and not a replacement for professional medical judgment.',
                                          style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF1E88E5),
                                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Accept & Continue'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              setState(() => _acceptedTerms = accepted == true);
                            } else {
                              setState(() => _acceptedTerms = false);
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          subtitle: !_acceptedTerms
                            ? const Text('You must accept terms to continue', style: TextStyle(color: Colors.redAccent, fontSize: 13))
                            : null,
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: _isLoading ? null : _handleCreateAccount,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                         const SizedBox(height: 12),
                        Row(
  mainAxisAlignment: MainAxisAlignment.center,
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(child: Divider(thickness: 1, color: Color(0xFFE0E0E0), indent: 10, endIndent: 10)),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('or', style: TextStyle(color: Color(0xFF999999), fontSize: 14), overflow: TextOverflow.ellipsis),
    ),
    Flexible(child: Divider(thickness: 1, color: Color(0xFFE0E0E0), indent: 10, endIndent: 10)),
  ],
),
                        const SizedBox(height: 20),

                        // Google Sign-In Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF1E88E5), width: 1.3),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // TODO: Implement Google Sign-In
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Google Sign-up coming soon!')),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/google_logo.png',
                                  height: 22,
                                  width: 22,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Sign up with Google',
                                  style: TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/sign-in'),
                              child: const Text('Already have an account? Sign In'),
                            ),
                          ],
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
