import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'patients_screen.dart';
import 'scans_screen.dart';
import 'education_screen.dart';
import 'settings_screen.dart';
import 'physician_dashboard_tab.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class PhysicianDashboardScreen extends StatefulWidget {
  const PhysicianDashboardScreen({super.key});

  @override
  State<PhysicianDashboardScreen> createState() => _PhysicianDashboardScreenState();
}

class _PhysicianDashboardScreenState extends State<PhysicianDashboardScreen> {
  int _selectedIndex = 2;
  static const Color primaryBlue = Color(0xFF1E88E5); // Use this for all tabs


  final List<Widget> _screens = [
    PatientsScreen(),
    ScansScreen(patient: null),
    PhysicianDashboardTab(),
    EducationScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    // Sync GoRouter with tab selection
    switch (index) {
      case 0:
        context.go('/patients');
        break;
      case 1:
        context.go('/scans');
        break;
      case 2:
        context.go('/physician-dashboard');
        break;
      case 3:
        context.go('/education');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 12,
        currentIndex: _selectedIndex,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[500],
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E88E5)),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF9E9E9E)),
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.image_outlined), label: 'Scans'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Education'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

// Dashboard content as a separate widget for the tab
class PhysicianDashboardTab extends StatelessWidget {
  const PhysicianDashboardTab({super.key});

  Future<String> _getFirstName() async {
    final userStr = await AuthService.getUser();
    if (userStr != null) {
      try {
        final Map<String, dynamic> userMap = userStr.contains('{') ? Map<String, dynamic>.from(jsonDecode(userStr)) : {};
        final fullName = userMap['full_name'] ?? userMap['name'] ?? '';
        if (fullName is String && fullName.isNotEmpty) {
          return fullName.split(' ').first;
        }
      } catch (_) {}
    }
    return 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.42;

    return FutureBuilder<String>(
      future: _getFirstName(),
      builder: (context, snapshot) {
        final firstName = snapshot.data ?? 'Doctor';
        final int patientCount = 12;
        final int scanCount = 34;
        final Map<String, int> diseaseStats = {
          'Glaucoma': 7,
          'DR': 3,
          'AMD': 2,
        };

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F8CFF), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: _PhysicianDashboardScreenState.primaryBlue),
                    ),
                  ),
                ],
                centerTitle: true,
              ),
            ),
          ),
          body: Container(
            color: const Color(0xFFF6F8FB),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            'Welcome $firstName',
                            style: const TextStyle(fontSize: 26, color: Color(0xFF222B45), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DashboardStatCard(
                                icon: Icons.people_outline,
                                label: 'Patients',
                                value: patientCount.toString(),
                                color: _PhysicianDashboardScreenState.primaryBlue,
                                width: cardWidth,
                              ),
                              DashboardStatCard(
                                icon: Icons.image_outlined,
                                label: 'Scans',
                                value: scanCount.toString(),
                                color: _PhysicianDashboardScreenState.primaryBlue,
                                width: cardWidth,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Disease Overview',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: diseaseStats.isEmpty
                                ? const Text(
                                    'No disease data yet.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  )
                                : SizedBox(
                                    height: 220,
                                    child: BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.spaceAround,
                                        maxY: (diseaseStats.values.isNotEmpty
                                                ? (diseaseStats.values.reduce((a, b) => a > b ? a : b) + 2).toDouble()
                                                : 10),
                                        barTouchData: BarTouchData(enabled: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 28,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toInt().toString(),
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final keys = diseaseStats.keys.toList();
                                                if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 6),
                                                    child: Text(
                                                      keys[value.toInt()].length > 10
                                                          ? keys[value.toInt()].substring(0, 10) + '…'
                                                          : keys[value.toInt()],
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(0xFF1E88E5),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        gridData: FlGridData(show: false),
                                        barGroups: List.generate(diseaseStats.length, (i) {
                                          return BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: diseaseStats.values.elementAt(i).toDouble(),
                                                color: _PhysicianDashboardScreenState.primaryBlue,
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
