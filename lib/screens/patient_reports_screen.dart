import 'package:flutter/material.dart';
import '../services/data_repository.dart';
import '../models/scan.dart';
import 'scan_results_screen.dart';
import 'dart:convert';
import '../services/prediction_service.dart';

class PatientReportsScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;
  final String? recordNumber;
  final String? notes;
  const PatientReportsScreen({Key? key, required this.patientId, this.patientName, this.recordNumber, this.notes}) : super(key: key);

  @override
  State<PatientReportsScreen> createState() => _PatientReportsScreenState();
}

class _PatientReportsScreenState extends State<PatientReportsScreen> {
  late Future<List<dynamic>> _scansFuture;
  
  // Modern color scheme
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);

  @override
  void initState() {
    super.initState();
    _scansFuture = DataRepository().getScansByPatient(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.patientName != null ? 'Reports for ${widget.patientName}' : 'Patient Reports',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          // Patient details card
          if (widget.patientName != null || widget.recordNumber != null || widget.notes != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: primaryBlue, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.patientName ?? '-',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.recordNumber != null && widget.recordNumber!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Record #: ${widget.recordNumber}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_outlined, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.notes!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          // Expanded for scan list below
          Expanded(
            child: _buildScanList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildScanList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _scansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading reports...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        final scans = snapshot.data ?? [];
        
        if (scans.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: secondaryBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.folder_open_outlined,
                      size: 48,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No scans found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No scans have been recorded for this patient yet.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: scans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scan = scans[index];
              final createdAt = scan['created_at'] ?? '';
              final diagnosis = scan['diagnosis'] ?? '';
              final confidence = scan['confidence_score']?.toStringAsFixed(2) ?? '';
              
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Parse diagnosis JSON to predictions map
                      Map<String, dynamic> predictions = {};
                      try {
                        final decoded = jsonDecode(diagnosis);
                        // If decoded is Map<String, double>, convert to Map<String, DiseasePrediction>
                        if (decoded is Map<String, dynamic>) {
                          predictions = decoded.map((k, v) {
                            if (v is Map<String, dynamic>) {
                              return MapEntry(k, DiseasePrediction.fromJson(v));
                            } else if (v is num) {
                              return MapEntry(k, DiseasePrediction(probability: v.toDouble(), detected: v.toDouble() >= 0.6, fullName: k));
                            } else {
                              return MapEntry(k, v);
                            }
                          });
                        }
                      } catch (_) {}
                      // Always wrap predictions in a map keyed by a dummy image, as ScanResultsScreen expects Map<String, Map<String, DiseasePrediction>>
                      final imagePath = scan['image_path'] ?? 'scan';
                      final predictionsMap = <String, Map<String, DiseasePrediction>>{
                        imagePath: Map<String, DiseasePrediction>.from(predictions)
                      };

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScanResultsScreen(
                            predictions: predictionsMap,
                            patientName: widget.patientName,
                            recordNumber: widget.recordNumber,
                            patientNotes: widget.notes,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: secondaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medical_information_outlined,
                              size: 24,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scan ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Created: $createdAt',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Confidence: $confidence',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: secondaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}