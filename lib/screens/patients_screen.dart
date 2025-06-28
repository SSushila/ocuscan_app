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
  // Modern color scheme
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);
  
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
    });
    if (_search.isEmpty) {
      setState(() {
        _filteredPatients = List.from(_patients);
      });
    } else {
      setState(() {
        _filteredPatients = _patients.where(_matchesSearch).toList();
      });
    }
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildActionTile(
                icon: Icons.person_outline_rounded,
                title: 'View Details',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PatientDetailsScreen(patientId: patient['id']!),
                    ),
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.description_outlined,
                title: 'View Reports',
                onTap: () {
                  Navigator.pop(context);
                  // Placeholder for navigation
                },
              ),
              _buildActionTile(
                icon: Icons.share_outlined,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  // Placeholder for share
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Modern SliverAppBar
          SliverAppBar(
            expandedHeight: 118,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.go('/physician-dashboard'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Patients',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue,
                      primaryBlue.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Search section
          SliverToBoxAdapter(
            child: Container(
              color: primaryBlue,
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: _buildSearchBar(),
              ),
            ),
          ),

          // Content
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _filteredPatients.isEmpty
                  ? SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPatientCard(_filteredPatients[index]),
                        childCount: _filteredPatients.length,
                      ),
                    ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => context.go('/new-patient'),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search patients...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.search_rounded, color: primaryBlue, size: 20),
          ),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _search = '';
                      _filteredPatients = List.from(_patients);
                    });
                  },
                  icon: Icon(Icons.close_rounded, color: Colors.grey[400]),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No patients found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first patient to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailsScreen(patientId: patient.id!),
              ),
            );
          },
          onLongPress: () => _showPatientActions({
            'id': patient.id ?? '',
            'fullName': patient.name,
            'recordNumber': patient.recordNumber,
            'notes': patient.notes,
          }),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Patient info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: secondaryBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${patient.recordNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      if (patient.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          patient.notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.remove_red_eye_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScansScreen(patient: patient),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.more_vert_rounded,
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
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: primaryBlue, size: 20),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}