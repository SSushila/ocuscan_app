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

  // Modern color scheme
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);

  Future<void> handleSignOut(BuildContext context) async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await DataRepository().signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed out successfully'),
          backgroundColor: primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.go('/home');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign out'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
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
        'icon': Icons.person_outline_rounded,
        'action': () => context.go('/account'),
        'isSignOut': false,
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none_rounded,
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
        'icon': Icons.help_outline_rounded,
        'action': () => context.go('/support'),
        'isSignOut': false,
      },
      {
        'title': 'About',
        'icon': Icons.info_outline_rounded,
        'action': () => context.go('/about'),
        'isSignOut': false,
      },
      {
        'title': 'Sign Out',
        'icon': Icons.logout_rounded,
        'isSignOut': true,
      },
    ];

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/physician-dashboard'),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: settings.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: surfaceColor,
                      indent: 60,
                    ),
                    itemBuilder: (context, index) {
                      final item = settings[index];
                      final isSignOut = item['isSignOut'] == true;
                      final isFirst = index == 0;
                      final isLast = index == settings.length - 1;
                      
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: isFirst ? const Radius.circular(12) : Radius.zero,
                            bottom: isLast ? const Radius.circular(12) : Radius.zero,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSignOut 
                                  ? Colors.red.withOpacity(0.1)
                                  : secondaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: isSignOut ? Colors.red : primaryBlue,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: isSignOut 
                                  ? Colors.red 
                                  : Colors.grey[800],
                            ),
                          ),
                          trailing: _signingOut && isSignOut
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                          onTap: isSignOut
                              ? (_signingOut ? null : () => handleSignOut(context))
                              : item['action'] as void Function(),
                          enabled: !isSignOut || !_signingOut,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: isFirst ? const Radius.circular(12) : Radius.zero,
                              bottom: isLast ? const Radius.circular(12) : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    },
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