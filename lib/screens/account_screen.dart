import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ocuscan_flutter/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool loading = true;
  bool saving = false;
  bool showChangePassword = false;
  bool changingPassword = false;
  String passwordError = '';

  Map<String, dynamic>? profile;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);
    try {
      final userJson = await AuthService.getUser();
      if (userJson == null) {
        setState(() { loading = false; });
        return;
      }
      final user = jsonDecode(userJson);
      setState(() {
        profile = Map<String, dynamic>.from(user);
        loading = false;
      });
      _fullNameController.text = profile!['fullName'] ?? '';
      _emailController.text = profile!['email'] ?? '';
      _hospitalNameController.text = profile!['hospitalName'] ?? '';
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _handleSave() async {
    if (profile == null) return;
    setState(() => saving = true);
    try {
      profile!['fullName'] = _fullNameController.text;
      profile!['email'] = _emailController.text;
      profile!['hospitalName'] = _hospitalNameController.text;
      await AuthService.saveUser(jsonEncode(profile!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  Future<void> _handleChangePassword() async {
    setState(() { passwordError = ''; });
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => passwordError = 'All fields are required.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => passwordError = 'New passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => passwordError = 'Password must be at least 6 characters.');
      return;
    }
    setState(() => changingPassword = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      final updateRes = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (updateRes.user == null) throw Exception('Password update failed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      setState(() {
        showChangePassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() => passwordError = 'Failed to change password.');
    } finally {
      setState(() => changingPassword = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _hospitalNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E88E5);
    final initials = (profile != null && profile!['fullName'] != null && profile!['fullName'].toString().isNotEmpty)
        ? profile!['fullName'].toString().trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : profile == null
              ? const Center(child: Text('No profile data found'))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: primaryColor.withOpacity(0.15),
                              child: initials.isNotEmpty
                                  ? Text(initials, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor))
                                  : Icon(Icons.person, color: primaryColor, size: 36),
                            ),
                            const SizedBox(height: 16),
                            Text('Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                            const SizedBox(height: 4),
                            Text('Manage your profile information', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                            const SizedBox(height: 24),
                            Card(
                              color: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Profile Information', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _fullNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.person, color: primaryColor.withOpacity(0.7)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _emailController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.email, color: primaryColor.withOpacity(0.7)),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _hospitalNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Hospital Name',
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        prefixIcon: Icon(Icons.local_hospital, color: primaryColor.withOpacity(0.7)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: primaryColor,
                                        side: BorderSide(color: primaryColor, width: 1.2),
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.lock_outline),
                                      label: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onPressed: () => setState(() => showChangePassword = !showChangePassword),
                                    ),
                                    AnimatedCrossFade(
                                      duration: const Duration(milliseconds: 250),
                                      crossFadeState: showChangePassword ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 14),
                                          TextField(
                                            controller: _currentPasswordController,
                                            decoration: InputDecoration(
                                              labelText: 'Current Password',
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              prefixIcon: Icon(Icons.lock, color: primaryColor.withOpacity(0.7)),
                                            ),
                                            obscureText: true,
                                            autocorrect: false,
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _newPasswordController,
                                            decoration: InputDecoration(
                                              labelText: 'New Password',
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor.withOpacity(0.7)),
                                            ),
                                            obscureText: true,
                                            autocorrect: false,
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _confirmPasswordController,
                                            decoration: InputDecoration(
                                              labelText: 'Confirm New Password',
                                              filled: true,
                                              fillColor: Colors.grey[50],
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor.withOpacity(0.7)),
                                            ),
                                            obscureText: true,
                                            autocorrect: false,
                                          ),
                                          if (passwordError.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(passwordError, style: const TextStyle(color: Colors.red)),
                                            ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
),
                                                  onPressed: changingPassword ? null : _handleChangePassword,
                                                  child: changingPassword
                                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                      : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.grey),
                                                onPressed: () => setState(() => showChangePassword = false),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 3,
),
                                        onPressed: saving ? null : _handleSave,
                                        child: saving
                                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                            : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
