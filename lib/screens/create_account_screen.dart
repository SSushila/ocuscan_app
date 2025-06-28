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

  // Modern color scheme
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Account Created',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryBlue,
                fontSize: 20,
              ),
            ),
            content: const Text(
              'Your account has been created. Please sign in.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/sign-in');
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Account Creation Failed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontSize: 20,
              ),
            ),
            content: const Text(
              'Unable to create account. Please try again.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Widget _buildTextField({
    required String label,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextInputType? keyboardType,
    bool obscureText = false,
    TextEditingController? controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: secondaryBlue,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          validator: validator,
          onSaved: onSaved,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryBlue, size: 20),
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
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
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
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: primaryBlue,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join our medical community',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          label: 'Full Name',
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your full name' : null,
                          onSaved: (value) => _fullName = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your email' : null,
                          onSaved: (value) => _email = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Hospital Name',
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => (value == null || value.isEmpty) ? 'Enter your hospital name' : null,
                          onSaved: (value) => _hospitalName = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                          onSaved: (value) => _password = value!,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Confirm Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Confirm your password';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          onSaved: (value) => _confirmPassword = value!,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: secondaryBlue,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _acceptedTerms ? primaryBlue : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            title: GestureDetector(
                              onTap: () async {
                                final accepted = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text(
                                        'Terms and Conditions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                          fontSize: 20,
                                        ),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            'By creating an account, you agree to the following terms and conditions:\n\n'
                                            '1. You confirm that you are a licensed physician.\n\n'
                                            '2. You will maintain the confidentiality of patient data.\n\n'
                                            '3. You will use the application in accordance with medical ethics and regulations.\n\n'
                                            '4. You understand that this is a diagnostic aid and not a replacement for professional medical judgment.',
                                            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey[600],
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Accept & Continue', style: TextStyle(fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (accepted == true) {
                                  setState(() => _acceptedTerms = true);
                                }
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: 'I accept the ',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text(
                                        'Terms and Conditions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: primaryBlue,
                                          fontSize: 20,
                                        ),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            'By creating an account, you agree to the following terms and conditions:\n\n'
                                            '1. You confirm that you are a licensed physician.\n\n'
                                            '2. You will maintain the confidentiality of patient data.\n\n'
                                            '3. You will use the application in accordance with medical ethics and regulations.\n\n'
                                            '4. You understand that this is a diagnostic aid and not a replacement for professional medical judgment.',
                                            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.grey[600],
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Accept & Continue', style: TextStyle(fontWeight: FontWeight.w600)),
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
                            activeColor: primaryBlue,
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            subtitle: !_acceptedTerms
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'You must accept terms to continue',
                                      style: TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: _isLoading ? null : _handleCreateAccount,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // TODO: Implement Google Sign-In
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Google Sign-up coming soon!'),
                                  backgroundColor: primaryBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
                                const SizedBox(width: 12),
                                Text(
                                  'Sign up with Google',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/sign-in'),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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