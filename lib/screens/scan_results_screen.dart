import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/prediction_service.dart';
import '../services/pdf_report_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

class ScanResultsScreen extends StatefulWidget {
  final Map<String, dynamic> predictions;
  final String? patientName;
  final String? recordNumber;
  final String? patientNotes;

  const ScanResultsScreen({Key? key, required this.predictions, this.patientName, this.recordNumber, this.patientNotes}) : super(key: key);

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  String search = '';
  bool generatingReport = false;
  bool showSearchBar = false;

  // Modern color scheme
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);

  Map<String, Map<String, DiseasePrediction>> get filteredPredictions {
    if (search.trim().isEmpty) {
      return widget.predictions.map((k, v) => MapEntry(k, (v as Map<String, DiseasePrediction>)));
    }
    final lower = search.toLowerCase();
    final filtered = <String, Map<String, DiseasePrediction>>{};
    widget.predictions.forEach((img, preds) {
      final filteredPreds = (preds as Map<String, DiseasePrediction>)
          .entries
          .where((e) => e.value.fullName.toLowerCase().contains(lower) ||
              e.value.probability.toString().contains(lower))
          .map((e) => MapEntry(e.key, e.value))
          .toList();
      if (filteredPreds.isNotEmpty) {
        filtered[img] = Map.fromEntries(filteredPreds);
      }
    });
    return filtered;
  }

  Color getSeverityColor(double probability) {
    if (probability >= 0.85) return const Color(0xFF10B981); // emerald-500
    if (probability >= 0.6) return const Color(0xFFF59E0B); // amber-500
    return const Color(0xFFEF4444); // red-500
  }

  void generateReport() async {
  setState(() => generatingReport = true);
  try {
    final now = DateTime.now();
    // Flatten predictions for retina report: Map<String, DiseasePrediction>
    final Map<String, dynamic> flatPredictions = {
      for (final diseaseMap in filteredPredictions.values)
        for (final entry in diseaseMap.entries)
          entry.key: entry.value
    };

    final pdfBytes = await generateRetinaReportPdf(
      logoImage: null,
      patientName: widget.patientName ?? '-',
      age: null, // Replace with actual value if available
      sex: null, // Replace with actual value if available
      recordNumber: widget.recordNumber ?? '-',
      scanDate: now,
      predictions: flatPredictions,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Retina_Report_${now.millisecondsSinceEpoch}.pdf',
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate PDF: $e'),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } finally {
    setState(() => generatingReport = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: secondaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Scan Results',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: showSearchBar ? primaryBlue : secondaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            showSearchBar ? Icons.close_rounded : Icons.search_rounded,
                            color: showSearchBar ? Colors.white : primaryBlue,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              showSearchBar = !showSearchBar;
                              if (!showSearchBar) {
                                search = '';
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // Animated Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: showSearchBar ? 56 : 0,
                    child: showSearchBar
                        ? Container(
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              autofocus: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search_rounded, color: primaryBlue, size: 20),
                                border: InputBorder.none,
                                hintText: 'Search diseases or confidence levels...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              onChanged: (value) => setState(() => search = value),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Modern Patient Card
            if (widget.patientName != null || widget.recordNumber != null || widget.patientNotes != null)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Patient Information',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.patientName != null)
                      Text(
                        widget.patientName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (widget.recordNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.badge_outlined, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              'Record #${widget.recordNumber}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.patientNotes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_outlined, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.patientNotes!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // Modern Results
            Expanded(
              child: filteredPredictions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No results match your search',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, top: 12),
                      itemCount: filteredPredictions.length,
                      itemBuilder: (context, idx) {
                        final imgUri = filteredPredictions.keys.elementAt(idx);
                        final preds = filteredPredictions[imgUri]!;
                        final highestProb = preds.values.fold<double>(0, (max, pred) => pred.probability > max ? pred.probability : max);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: secondaryBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Image ${idx + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (highestProb >= 0.6)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: getSeverityColor(highestProb).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.verified_rounded,
                                          size: 16,
                                          color: getSeverityColor(highestProb),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Image
                              if (imgUri.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(imgUri),
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Results
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: highestProb < 0.6
                                    ? Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFFECACA)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning_rounded, color: const Color(0xFFEF4444), size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Image not recognized as retina. Please rescan with a clear retina photo.',
                                                style: const TextStyle(
                                                  color: Color(0xFFEF4444),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'Disease Predictions',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Top 3',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          ...(() {
                                            final topPredictions = preds.entries.toList()
                                              ..sort((a, b) => (b.value.probability).compareTo(a.value.probability));
                                            return topPredictions.take(3).map((diseaseEntry) {
                                              final DiseasePrediction pred = diseaseEntry.value;
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: surfaceColor,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: getSeverityColor(pred.probability),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        pred.fullName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Color(0xFF111827),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: getSeverityColor(pred.probability).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '${(pred.probability * 100).toStringAsFixed(1)}%',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 14,
                                                          color: getSeverityColor(pred.probability),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList();
                                          })(),
                                        ],
                                      ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Modern Floating Action Button
      floatingActionButton: Container(
        margin: const EdgeInsets.all(20),
        child: generatingReport
            ? Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: primaryBlue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.description_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}