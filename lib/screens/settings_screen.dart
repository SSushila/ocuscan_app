import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocuscan_flutter/services/data_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _signingOut = false;

  Future<void> handleSignOut(BuildContext context) async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await DataRepository().signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
      context.go('/home');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settings = [
      {
        'title': 'Account',
        'icon': Icons.person_outline,
        'action': () => context.go('/account'),
        'isSignOut': false,
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none_outlined,
        'action': () => Navigator.pushNamed(context, '/notifications'),
        'isSignOut': false,
      },
      {
        'title': 'Privacy',
        'icon': Icons.shield_outlined,
        'action': () => context.go('/privacy'),
        'isSignOut': false,
      },
      {
        'title': 'Help & Support',
        'icon': Icons.help_outline,
        'action': () => context.go('/support'),
        'isSignOut': false,
      },
      {
        'title': 'About',
        'icon': Icons.info_outline,
        'action': () => context.go('/about'),
        'isSignOut': false,
      },
      {
        'title': 'Sign Out',
        'icon': Icons.logout,
        'isSignOut': true,
      },
    ];

    return Scaffold(  
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: settings.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = settings[index];
                final isSignOut = item['isSignOut'] == true;
                return ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: isSignOut ? Colors.redAccent : Colors.blueGrey[700],
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSignOut ? Colors.redAccent : null,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: isSignOut
                      ? (_signingOut ? null : () => handleSignOut(context))
                      : item['action'] as void Function(),
                  enabled: !isSignOut || !_signingOut,
                  minLeadingWidth: 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
