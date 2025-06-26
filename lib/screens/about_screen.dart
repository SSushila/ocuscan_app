import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _handleContactSupport(BuildContext context) {
    // TODO: Implement actual support contact logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Support tapped')),
    );
  }

  void _handleVisitWebsite(BuildContext context) {
    // TODO: Implement actual website launch logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit Website tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E88E5);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Color(0xFF1E88E5)),

          onPressed: () => context.go('/settings'),
        ),
        title: const Text('About', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card with logo, app name, version
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: Image.asset('assets/icon.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 16),
                  Text('OcuScan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 6),
                  const Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // About section
            const Text('About OcuScan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 8),
            const Text(
              'OcuScan is a revolutionary mobile application designed to assist healthcare professionals in early detection and monitoring of eye conditions. Our app combines advanced AI technology with user-friendly interfaces to provide accurate and efficient eye screening capabilities.',
              style: TextStyle(fontSize: 16, color: Color(0xFF222222), height: 1.5),
            ),
            const SizedBox(height: 28),
            // Features section
            const Text('Key Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 12),
            Column(
              children: [
                _FeatureItem(
                  icon: Ionicons.camera_outline,
                  title: 'AI-Powered Scanning',
                  description: 'Advanced image processing and machine learning algorithms for accurate eye condition detection',
                  color: primaryColor,
                ),
                _FeatureItem(
                  icon: Ionicons.document_text_outline,
                  title: 'Comprehensive Reports',
                  description: 'Detailed analysis and reports for each scan, helping healthcare providers make informed decisions',
                  color: primaryColor,
                ),
                _FeatureItem(
                  icon: Ionicons.people_outline,
                  title: 'Patient Management',
                  description: 'Easy-to-use patient records system with history tracking and follow-up management',
                  color: primaryColor,
                ),
                _FeatureItem(
                  icon: Ionicons.shield_checkmark_outline,
                  title: 'Data Security',
                  description: 'HIPAA-compliant data storage and transmission ensuring patient privacy and security',
                  color: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Mission section
            const Text('Our Mission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 8),
            const Text(
              'At OcuScan, we are committed to making eye care more accessible and efficient. Our mission is to empower healthcare professionals with cutting-edge technology that helps in early detection and better management of eye conditions, ultimately improving patient outcomes worldwide.',
              style: TextStyle(fontSize: 16, color: Color(0xFF222222), height: 1.5),
            ),
            const SizedBox(height: 28),
            // Contact & Support section
            const Text('Contact & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Ionicons.mail_outline, color: Colors.white),
                    label: const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    onPressed: () => _handleContactSupport(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Ionicons.globe_outline, color: Colors.white),
                    label: const Text('Visit Website', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    onPressed: () => _handleVisitWebsite(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Legal section
            const Text('Legal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            const SizedBox(height: 8),
            const Text(
              '© 2024 OcuScan. All rights reserved.\nThis application is intended for use by healthcare professionals only.\nThe information provided by this app is not a substitute for professional medical advice.',
              style: TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
