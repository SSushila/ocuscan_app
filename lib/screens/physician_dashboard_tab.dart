import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PhysicianDashboardTab extends StatelessWidget {
  const PhysicianDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E88E5);
    final double cardWidth = MediaQuery.of(context).size.width * 0.42;
    final String firstName = 'Doctor';
    final int patientCount = 12;
    final int scanCount = 34;
    final Map<String, int> diseaseStats = {
      'Glaucoma': 7,
      'DR': 3,
      'AMD': 2,
    };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: primaryBlue),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF6AB7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text('Welcome back,', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 4),
                      Text(firstName, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DashboardStatCard(
                      icon: Icons.people_outline,
                      label: 'Patients',
                      value: patientCount.toString(),
                      color: primaryBlue,
                      width: cardWidth,
                    ),
                    DashboardStatCard(
                      icon: Icons.image_outlined,
                      label: 'Scans',
                      value: scanCount.toString(),
                      color: primaryBlue,
                      width: cardWidth,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Disease Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: diseaseStats.isEmpty
                      ? const Text('No disease data yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey))
                      : SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (diseaseStats.values.isNotEmpty ? (diseaseStats.values.reduce((a, b) => a > b ? a : b) + 2).toDouble() : 10),
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) {
                                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 13, color: Color(0xFF333333)));
                                  }),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                                    final keys = diseaseStats.keys.toList();
                                    if (value.toInt() >= 0 && value.toInt() < keys.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          keys[value.toInt()].length > 10 ? keys[value.toInt()].substring(0, 10) + '…' : keys[value.toInt()],
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E88E5), fontWeight: FontWeight.w600),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
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
                                      color: primaryBlue,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 22,
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
        ),
      ),
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double width;
  const DashboardStatCard({Key? key, required this.icon, required this.label, required this.value, required this.color, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        ],
      ),
    );
  }
}
