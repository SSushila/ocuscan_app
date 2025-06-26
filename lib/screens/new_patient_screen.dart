import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';

  void _handleAddPatient() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // In a real app, add patient to backend or state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patient "$_name" added!')),
    );
    context.go('/patients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Patient')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleAddPatient,
                  child: const Text('Add Patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
