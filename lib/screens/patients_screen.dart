import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final Color primaryBlue = const Color(0xFF1E88E5);
  final List<Map<String, String>> _patients = [
    {
      'id': '1',
      'recordNumber': '001',
      'fullName': 'John Doe',
      'notes': 'Diabetic, needs regular checkups.'
    },
    {
      'id': '2',
      'recordNumber': '002',
      'fullName': 'Jane Smith',
      'notes': 'Glaucoma, on medication.'
    },
    {
      'id': '3',
      'recordNumber': '003',
      'fullName': 'Samuel Green',
      'notes': 'No known issues.'
    },
  ];
  List<Map<String, String>> _filteredPatients = [];
  bool _isLoading = false;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _filteredPatients = List.from(_patients);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _search = _searchController.text;
      _filteredPatients = _patients.where((p) {
        final name = p['fullName']?.toLowerCase() ?? '';
        final record = p['recordNumber']?.toLowerCase() ?? '';
        final notes = p['notes']?.toLowerCase() ?? '';
        final s = _search.toLowerCase();
        return name.contains(s) || record.contains(s) || notes.contains(s);
      }).toList();
    });
  }

  Future<void> _refreshPatients() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate refresh
    setState(() => _isRefreshing = false);
  }

  Future<void> _signOut() async {
    await AuthService.deleteUser();
    if (context.mounted) context.go('/sign-in');
  }

  void _showPatientActions(Map<String, String> patient) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // Placeholder for navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('View Reports'),
              onTap: () {
                Navigator.pop(context);
                // Placeholder for navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Placeholder for share
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Patients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => context.go('/new-patient'),
        tooltip: 'Add Patient',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, color: Color(0xFF888888), size: 22),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by name or record number',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_search.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Color(0xFF888888)),
                        onPressed: () => _searchController.clear(),
                        splashRadius: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
                : RefreshIndicator(
                    onRefresh: _refreshPatients,
                    color: primaryBlue,
                    child: _filteredPatients.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 64),
                              child: Text(
                                _search.isNotEmpty
                                    ? 'No patients match your search.'
                                    : 'No patients registered yet.',
                                style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  onTap: () {}, // Placeholder for navigation
                                  onLongPress: () => _showPatientActions(patient),
                                  title: Text(
                                    patient['fullName'] ?? '',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        'Record #${patient['recordNumber']}',
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                      ),
                                      if ((patient['notes'] ?? '').isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            patient['notes']!,
                                            style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3F0FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.remove_red_eye_outlined, color: primaryBlue, size: 22),
                                          tooltip: 'Take Scan',
                                          onPressed: () {
                                            // Placeholder for scan action
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3F0FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.description_outlined, color: primaryBlue, size: 22),
                                          tooltip: 'Patient Actions',
                                          onPressed: () => _showPatientActions(patient),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
