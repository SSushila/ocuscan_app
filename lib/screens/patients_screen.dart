import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/patient.dart';
import '../services/data_repository.dart';
import 'patient_details_screen.dart';
import 'scans_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final Color primaryBlue = const Color(0xFF1E88E5);
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isLoading = false;
  bool _isRefreshing = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged();
    });
    _scrollController.addListener(_onScroll);
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() { _isLoading = true; });
    try {
      final repo = DataRepository();
      final result = await repo.getPatients();
      _patients = result.map<Patient>((p) => Patient.fromMap(p)).toList();
      _filteredPatients = List.from(_patients);
      _hasMore = _patients.length >= _pageSize;
    } catch (e) {
      _patients = [];
      _filteredPatients = [];
    }
    if (!mounted) return;
    setState(() { _isLoading = false; });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore && !_isLoading) {
      _loadMorePatients();
    }
  }

  Future<void> _loadMorePatients() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final repo = DataRepository();
      final result = await repo.getPatients();
      final newPatients = result.map<Patient>((p) => Patient.fromMap(p)).toList();
      if (newPatients.length < _pageSize) _hasMore = false;
      _patients = newPatients;
      _filteredPatients = _patients.where(_matchesSearch).toList();
    } catch (e) {
      _hasMore = false;
    }
    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  bool _matchesSearch(Patient p) {
    final name = p.name.toLowerCase();
    final record = p.recordNumber.toLowerCase();
    final notes = p.notes.toLowerCase();
    final s = _search.toLowerCase();
    return name.contains(s) || record.contains(s) || notes.contains(s);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    setState(() {
      _search = _searchController.text;
      _isLoading = true;
    });
    final repo = DataRepository();
    try {
      List<dynamic> result;
      if (_search.isEmpty) {
        result = await repo.getPatients();
      } else {
        result = await repo.searchPatients(_search);
      }
      _patients = result.map<Patient>((p) => Patient.fromMap(p)).toList();
      _filteredPatients = List.from(_patients);
      _hasMore = _patients.length >= _pageSize;
    } catch (e) {
      _patients = [];
      _filteredPatients = [];
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshPatients() async {
    setState(() => _isRefreshing = true);
    if (_search.isEmpty) {
      await _fetchPatients();
    } else {
      await _onSearchChanged();
    }
    if (!mounted) return;
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PatientDetailsScreen(patientId: patient['id']!),
                  ),
                );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/physician-dashboard');
          },
        ),
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
              elevation: 2,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE3EAF2), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.search, color: Color(0xFF1E88E5), size: 26),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search patients by name or record...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500, fontSize: 16),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                        cursorColor: primaryBlue,
                      ),
                    ),
                    if (_search.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _search = '';
                              _filteredPatients = List.from(_patients);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Color(0xFF888888), size: 20),
                          ),
                        ),
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
                    child: _filteredPatients.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text('No patient registered yet.',
                                    style: TextStyle(fontSize: 17, color: Color(0xFF888888), fontWeight: FontWeight.w500)),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  elevation: 0,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {}, // Placeholder for navigation
                                    onLongPress: () => _showPatientActions({
                                      'id': patient.id ?? '',
                                      'fullName': patient.name,
                                      'recordNumber': patient.recordNumber,
                                      'notes': patient.notes,
                                    }),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Leading avatar
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: const Color(0xFFE3F0FF),
                                            child: Text(
                                              (patient.name.isNotEmpty)
                                                  ? patient.name[0]
                                                  : '',
                                              style: TextStyle(
                                                  color: primaryBlue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          // Main info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  patient.name,
                                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Record #${patient.recordNumber}',
                                                  style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                                ),
                                                if ((patient.notes).isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    child: Text(
                                                      patient.notes,
                                                      style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontStyle: FontStyle.italic),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Actions
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove_red_eye_outlined, color: primaryBlue, size: 22),
                                                tooltip: 'Take Scan',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ScansScreen(patient: patient),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.description_outlined, color: primaryBlue, size: 22),
                                                tooltip: 'Patient Actions',
                                                onPressed: () => _showPatientActions({
                                                  'id': patient.id ?? '',
                                                  'fullName': patient.name,
                                                  'recordNumber': patient.recordNumber,
                                                  'notes': patient.notes,
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
    );
  }
}
