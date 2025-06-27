import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocuscan_flutter/models/patient.dart';
import 'package:ocuscan_flutter/services/local_db_service.dart';
import '../services/data_repository.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Patient? patient;
  bool isLoading = true;
  bool isEditing = false;
  late TextEditingController fullNameController;
  late TextEditingController recordNumberController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    recordNumberController = TextEditingController();
    notesController = TextEditingController();
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Load all patients and filter by ID
final patients = await DataRepository().getPatients();
Patient? loadedPatient;
try {
  loadedPatient = patients.map((p) => Patient.fromMap(p)).firstWhere((p) => p.id == widget.patientId);
} catch (_) {
  loadedPatient = null;
}
      if (loadedPatient != null) {
        patient = loadedPatient;
        fullNameController.text = loadedPatient.name;
        recordNumberController.text = loadedPatient.recordNumber;
        notesController.text = loadedPatient.notes ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load patient details')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    final fullName = fullNameController.text.trim();
    final recordNumber = recordNumberController.text.trim();
    final notes = notesController.text.trim();
    if (fullName.isEmpty) {
      _showError('Please enter the patient\'s full name');
      return;
    }
    if (recordNumber.isEmpty) {
      _showError('Please enter the patient\'s record number');
      return;
    }
    try {
      await DataRepository().updatePatient(
        id: widget.patientId,
        name: fullName,
        recordNumber: recordNumber,
        notes: notes,
      );
      setState(() {
        patient = patient!.copyWith(
          name: fullName,
          recordNumber: recordNumber,
          notes: notes,
        );
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient details updated successfully')),
      );
    } catch (e) {
      _showError('Failed to update patient details');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    recordNumberController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E88E5);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
            : patient == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text('Patient not found', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Avatar
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Text(
                                _getInitials(patient!.name),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              patient!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Record #${patient!.recordNumber}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Info Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline, color: primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Patient Information',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _infoRow(
  label: 'Full Name',
  child: isEditing
      ? TextField(
          controller: fullNameController,
          decoration: const InputDecoration(
            hintText: "Enter patient's full name",
          ),
        )
      : Text(patient!.name, style: const TextStyle(fontSize: 16)),
),
const SizedBox(height: 12),
_infoRow(
  label: 'Record Number',
  child: isEditing
      ? TextField(
          controller: recordNumberController,
          decoration: const InputDecoration(
            hintText: "Enter patient's record number",
          ),
          keyboardType: TextInputType.number,
        )
      : Text(patient!.recordNumber, style: const TextStyle(fontSize: 16)),
),
const SizedBox(height: 12),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Notes',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  isEditing
                                      ? TextField(
                                          controller: notesController,
                                          decoration: const InputDecoration(
                                            hintText: 'Add any additional notes',
                                          ),
                                          maxLines: 4,
                                          minLines: 2,
                                        )
                                      : Text(
                                          patient!.notes?.isNotEmpty == true ? patient!.notes! : 'No notes',
                                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isEditing) ...[
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    label: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                                    onPressed: _save,
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    icon: Icon(Icons.close, color: primaryColor),
                                    label: Text('Cancel', style: TextStyle(color: primaryColor)),
                                    onPressed: () {
                                      setState(() {
                                        isEditing = false;
                                        fullNameController.text = patient!.name;
                                        recordNumberController.text = patient!.recordNumber;
                                        notesController.text = patient!.notes ?? '';
                                      });
                                    },
                                  ),
                                ] else ...[
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    label: const Text('Edit Details', style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Back button
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: primaryColor, size: 28),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            tooltip: 'Go back',
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final names = fullName.split(' ');
    if (names.length == 1) return names[0][0];
    return names.map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _infoRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}
