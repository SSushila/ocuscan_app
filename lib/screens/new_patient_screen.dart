import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/data_repository.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _recordNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _acceptedDisclaimer = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _recordNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAddPatient() async {
    if (!_formKey.currentState!.validate() || !_acceptedDisclaimer) return;
    setState(() => _isSubmitting = true);
    try {
      final name = _nameController.text.trim();
      final recordNumber = _recordNumberController.text.trim();
      final notes = _notesController.text.trim();
      final repo = DataRepository();
      await repo.addPatient(name: name, recordNumber: recordNumber, notes: notes);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient "$name" added!')),
      );
      context.go('/patients');
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      print('Add Patient Error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add patient. $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/physician-dashboard');
          },
        ),
        title: const Text(
          'Add New Patient',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter patient's full name",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 20),
                // Record Number
                Text('Record Number *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _recordNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter patient's record number",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter a record number' : null,
                ),
                const SizedBox(height: 20),
                // Notes
                Text('Notes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: "Add any additional notes",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
                const SizedBox(height: 24),
                // Disclaimer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedDisclaimer,
                      onChanged: (val) {
                        setState(() => _acceptedDisclaimer = val ?? false);
                      },
                      activeColor: const Color(0xFF1E88E5),
                      checkColor: Colors.white,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "I confirm that I have obtained the patient's consent to store their data in accordance with data protection regulations. I understand that I am responsible for maintaining the confidentiality of this information.",
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: (_isSubmitting || !_acceptedDisclaimer)
                          ? Colors.grey[400]
                          : const Color(0xFF1E88E5),
                    ),
                    onPressed: (_isSubmitting || !_acceptedDisclaimer)
                        ? null
                        : _handleAddPatient,
                    child: Text(
                      _isSubmitting ? 'Adding Patient...' : 'Add Patient',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
