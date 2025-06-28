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

  // Modern color palette
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color surfaceColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color secondaryBlue = const Color(0xFFEFF6FF);

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
        SnackBar(
          content: const Text('Failed to load patient details'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
        SnackBar(
          content: const Text('Patient details updated successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      _showError('Failed to update patient details');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 3))
            : patient == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_off_outlined, size: 48, color: Colors.red.shade400),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Patient not found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The requested patient could not be located',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            // Modern Avatar with gradient
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: Colors.transparent,
                                child: Text(
                                  _getInitials(patient!.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 32,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              patient!.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: secondaryBlue,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primaryBlue.withOpacity(0.2)),
                              ),
                              child: Text(
                                'Record #${patient!.recordNumber}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Modern Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: secondaryBlue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.person_outline, color: primaryBlue, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Patient Information',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  _modernInfoField(
                                    label: 'Full Name',
                                    child: isEditing
                                        ? _modernTextField(
                                            controller: fullNameController,
                                            hintText: "Enter patient's full name",
                                          )
                                        : Text(
                                            patient!.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 24),
                                  _modernInfoField(
                                    label: 'Record Number',
                                    child: isEditing
                                        ? _modernTextField(
                                            controller: recordNumberController,
                                            hintText: "Enter patient's record number",
                                            keyboardType: TextInputType.number,
                                          )
                                        : Text(
                                            patient!.recordNumber,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 24),
                                  _modernInfoField(
                                    label: 'Notes',
                                    child: isEditing
                                        ? _modernTextField(
                                            controller: notesController,
                                            hintText: 'Add any additional notes',
                                            maxLines: 4,
                                            minLines: 3,
                                          )
                                        : Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: surfaceColor,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Text(
                                              patient!.notes?.isNotEmpty == true ? patient!.notes! : 'No notes available',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: patient!.notes?.isNotEmpty == true 
                                                    ? const Color(0xFF374151)
                                                    : Colors.grey.shade500,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Modern Action Buttons
                            if (isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _modernButton(
                                      onPressed: _save,
                                      label: 'Save Changes',
                                      icon: Icons.check_rounded,
                                      isPrimary: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _modernButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing = false;
                                          fullNameController.text = patient!.name;
                                          recordNumberController.text = patient!.recordNumber;
                                          notesController.text = patient!.notes ?? '';
                                        });
                                      },
                                      label: 'Cancel',
                                      icon: Icons.close_rounded,
                                      isPrimary: false,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                child: _modernButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                  label: 'Edit Details',
                                  icon: Icons.edit_outlined,
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Modern Back Button
                      Positioned(
                        left: 20,
                        top: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLines,
    int? minLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        minLines: minLines,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _modernButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBlue : cardColor,
          foregroundColor: isPrimary ? Colors.white : primaryBlue,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isPrimary ? null : BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _modernInfoField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
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
}