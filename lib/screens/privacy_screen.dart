import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ocuscan_flutter/services/supabase_service.dart';
import 'package:ocuscan_flutter/services/local_db_service.dart';
import 'package:ocuscan_flutter/services/auth_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _password = '';
  bool _isDeleting = false;

  Color get primaryColor => const Color(0xFF1E88E5);

  void _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete your data from OcuScan?', style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.transparent,
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _showPasswordDialogAndDelete();
    }
  }

  Future<void> _showPasswordDialogAndDelete() async {
    _password = '';
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Enter Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please enter your password to confirm deletion.'),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _password = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isDeleting || _password.isEmpty
                      ? null
                      : () async {
                          Navigator.of(context).pop(true);
                        },
                  child: _isDeleting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      await _deleteData();
    }
  }

  Future<void> _deleteData() async {
    setState(() { _isDeleting = true; });
    String errorMsg = '';
    debugPrint('[PrivacyScreen] Starting data deletion...');
    try {
      // 1. Re-authenticate user with password
      final user = SupabaseService.currentUser;
      final email = user?.email;
      final password = _password;
      debugPrint('[PrivacyScreen] Re-authenticating user: email=$email');
      if (email == null) throw Exception('No email found for user.');
      final authResponse = await SupabaseService.signIn(email: email, password: password);
      if (authResponse.user == null) throw Exception('Invalid password.');
      debugPrint('[PrivacyScreen] Password validated.');

      // 2. Sign out user BEFORE deleting from Auth and tables
      debugPrint('[PrivacyScreen] Signing out user...');
      await SupabaseService.signOut();
      debugPrint('[PrivacyScreen] User signed out.');

      // 3. Delete user data from Supabase (remote) and custom tables
      final supabase = SupabaseService.client;
      final userId = user!.id;
      debugPrint('[PrivacyScreen] Deleting from Supabase: userId=$userId');
      await supabase.from('users').delete().eq('id', userId);
      await supabase.from('patients').delete().eq('user_id', userId);
      await supabase.from('scans').delete().eq('user_id', userId);
      debugPrint('[PrivacyScreen] Deleted from Supabase tables.');
      // If you have other tables, add them here

      // 4. Delete local data from SQLite
      debugPrint('[PrivacyScreen] Deleting from SQLite...');

      // 5. Clear onboarding flag so onboarding screen shows again on next launch
      try {
        await AuthService.clearOnboarding();
        debugPrint('[PrivacyScreen] Cleared onboarding flag.');
      } catch (e) {
        debugPrint('[PrivacyScreen] Failed to clear onboarding flag: $e');
      }
      await LocalDbService.database.then((db) async {
        await db.delete('users', where: 'id = ?', whereArgs: [userId]);
        await db.delete('patients');
        await db.delete('scans');
      });
      debugPrint('[PrivacyScreen] Deleted from SQLite tables.');

      // 5. (Optional) Clear any custom local storage here (e.g., SharedPreferences)
      // Example: await SharedPreferences.getInstance().then((prefs) => prefs.clear());

      setState(() { _isDeleting = false; _password = ''; });
      if (!mounted) return;
      debugPrint('[PrivacyScreen] Data deletion complete.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your data has been deleted from OcuScan.')),
      );
      // Redirect to sign-in screen
      if (mounted) context.go('/home');
    } catch (e) {
      errorMsg = e.toString();
      setState(() { _isDeleting = false; });
      debugPrint('[PrivacyScreen] Error: $errorMsg');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E88E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Section(
                            icon: Ionicons.shield_checkmark_outline,
                            title: 'Our Commitment',
                            text: 'Your privacy is critically important to us. We are committed to protecting your personal information and medical data with the highest standards of security and confidentiality.',
                          ),
                          _Section(
                            icon: Ionicons.document_text_outline,
                            title: 'Data Collection',
                            text: 'We collect only the data necessary to provide and improve our services, such as medical images, scan results, and basic user profile information. No unnecessary or unrelated data is collected.',
                          ),
                          _Section(
                            icon: Ionicons.analytics_outline,
                            title: 'Data Usage',
                            text: 'Your data is used solely for delivering scan results, improving accuracy, and ensuring a seamless user experience. We do not sell or share your data with third parties for marketing or advertising purposes.',
                          ),
                          _Section(
                            icon: Ionicons.lock_closed_outline,
                            title: 'Security',
                            text: 'All patient data and images are encrypted in transit and at rest. We comply with medical data protection regulations (such as HIPAA/GDPR) and regularly audit our security practices.',
                          ),
                          _Section(
                            icon: Ionicons.person_circle_outline,
                            title: 'Your Rights',
                            text: 'You have the right to access, update, or delete your personal data at any time. You can also clear all local data using the button below.',
                          ),
                          _Section(
                            icon: Ionicons.mail_outline,
                            title: 'Contact Us',
                            text: 'If you have any questions or concerns about your privacy, please contact our support team at support@ocuscan.com.',
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _showDeleteConfirmation,
                              child: const Text(
                                'Clear Local Data',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Section({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E88E5), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
