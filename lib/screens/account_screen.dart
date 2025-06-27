import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ocuscan_flutter/services/data_repository.dart';
import 'package:ocuscan_flutter/services/local_db_service.dart';
import 'package:ocuscan_flutter/services/auth_service.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ocuscan_flutter/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String initials = '';
  String userId = '';

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
    _loadUser();
  }

  Future<void> _loadUser() async {
    print('DEBUG: _loadUser() called');
    setState(() => loading = true);
    try {
      final userJson = await AuthService.getUser();
      print('DEBUG: AuthService.getUser() returned: ' + (userJson ?? 'NULL'));
      if (userJson != null) {
        final user = jsonDecode(userJson);
        print('DEBUG: Decoded user map: ' + user.toString());
        String fullName = user['full_name'] ?? '';
        String hospitalName = user['hospital_name'] ?? '';
        String email = user['email'] ?? '';
        String id = user['id'] ?? '';
        // Fallback for missing fields or id
        if (fullName.isEmpty || hospitalName.isEmpty || id.isEmpty) {
          try {
            final localUser = await LocalDbService.getUserByEmail(email);
            print('DEBUG: Local fallback user for missing fields: ' + (localUser != null ? localUser.toString() : 'NULL'));
            if (localUser != null) {
              if (fullName.isEmpty) fullName = localUser['full_name'] ?? '';
              if (hospitalName.isEmpty) hospitalName = localUser['hospital_name'] ?? '';
              if (id.isEmpty) id = localUser['id'] ?? '';
            }
          } catch (e) {
            debugPrint('Failed to fallback from local DB: $e');
          }
        }
        _fullNameController.text = fullName;
        _emailController.text = email;
        _hospitalNameController.text = hospitalName;
        setState(() {
          profile = user;
          userId = id;
          initials = fullName.isNotEmpty ? fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() : '';
        });
      } else {
        // fallback: try to load from local DB if possible
        try {
          // Get email from Supabase Auth
          final supabaseUser = Supabase.instance.client.auth.currentUser;
          final email = supabaseUser?.email;
          print('Supabase Auth email: ' + (email ?? 'NULL'));
          if (email != null) {
            final localUser = await LocalDbService.getUserByEmail(email);
            print('Local user found: ' + (localUser != null ? localUser.toString() : 'NULL'));
            if (localUser != null) {
              _fullNameController.text = localUser['full_name'] ?? '';
              _emailController.text = localUser['email'] ?? '';
              _hospitalNameController.text = localUser['hospital_name'] ?? '';
              setState(() {
                profile = localUser;
                userId = localUser['id'] ?? '';
                initials = _fullNameController.text.isNotEmpty
                    ? _fullNameController.text.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                    : '';
              });
            }
          }
        } catch (e) {
          debugPrint('Failed to load user from local DB: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to load user: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() { saving = true; });
    try {
      final id = userId;
      final email = _emailController.text.trim();
      final fullName = _fullNameController.text.trim();
      final hospitalName = _hospitalNameController.text.trim();
      print('DEBUG: Saving profile with id=$id, email=$email, fullName=$fullName, hospitalName=$hospitalName');
      await DataRepository().updateUser(
        id: id,
        email: email,
        fullName: fullName,
        hospitalName: hospitalName,
      );
      setState(() {
        initials = fullName.isNotEmpty ? fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() : '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e, stack) {
      print('DEBUG: Error saving profile: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() { saving = false; });
    }
  }

  Future<void> _handleChangePassword() async {
    setState(() { changingPassword = true; passwordError = ''; });
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    final email = _emailController.text.trim();
    if (newPass != confirm) {
      setState(() {
        passwordError = 'Passwords do not match';
        changingPassword = false;
      });
      return;
    }
    if (current == newPass) {
      setState(() {
        passwordError = 'New password must be different from the current password.';
        changingPassword = false;
      });
      return;
    }
    // Print debug info about Supabase Auth user and password values
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    print('DEBUG: Supabase Auth user: ' + (supabaseUser != null ? supabaseUser.email ?? supabaseUser.id : 'NULL'));
    print('DEBUG: currentPassword: $current, newPassword: $newPass');

    // Show dialog to confirm Supabase Auth user before changing password
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Password Change'),
          content: Text('You are changing the password for:\nEmail: \'${supabaseUser?.email ?? 'Unknown'}\'\nUser ID: \'${supabaseUser?.id ?? 'Unknown'}\'\n\nProceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      setState(() { changingPassword = false; });
      return;
    }
    try {
      final ok = await DataRepository().changePassword(
        email: email,
        newPassword: newPass,
        currentPassword: current,
      );
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        setState(() {
          showChangePassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        setState(() { passwordError = 'Failed to change password. Check your current password.'; });
      }
    } catch (e) {
      setState(() { passwordError = 'Failed to change password: $e'; });
    } finally {
      setState(() { changingPassword = false; });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
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
