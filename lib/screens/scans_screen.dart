import 'package:flutter/material.dart';

import '../models/patient.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ScansScreen extends StatefulWidget {
  final Patient? patient;
  const ScansScreen({Key? key, required this.patient}) : super(key: key);
  @override
  State<ScansScreen> createState() => _ScansScreenState();
}

class _ScansScreenState extends State<ScansScreen> {

  // Remove mock patient data, use widget.patient


  // Simulated selected images (AssetImage paths for demo)
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isAnalyzing = false;

  Future<void> _simulatePickImage() async {
    if (widget.patient == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile>? pickedFiles = await _picker.pickMultiImage();
                  if (pickedFiles != null && pickedFiles.isNotEmpty) {
                    setState(() {
                      selectedImages.addAll(pickedFiles.map((xfile) => File(xfile.path)));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Select from Files'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
                    allowMultiple: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      selectedImages.addAll(result.files
                          .where((f) => f.path != null)
                          .map((f) => File(f.path!)));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _simulateTakePhoto() async {
    if (widget.patient == null) return;
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(File file) {
    setState(() {
      selectedImages.remove(file);
    });
  }

  void _clearAll() {
    setState(() {
      selectedImages.clear();
    });
  }

  Future<void> _analyzeImages() async {
    if (selectedImages.isEmpty) return;
    setState(() => isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate analysis delay
    setState(() => isAnalyzing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Images analyzed (demo only).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF1E88E5);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text('Scan Retina', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upload/Images Section
                    selectedImages.isEmpty
                        ? _buildUploadSection(primaryBlue)
                        : _buildImagesSection(primaryBlue),

                    // --- Instructions Card ---
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Color(0xFFF4F8FE),
                      margin: EdgeInsets.only(top: 18),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 26),
                                SizedBox(width: 8),
                                Text('How to Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E88E5))),
                              ],
                            ),
                            SizedBox(height: 10),
                            _buildInstructionStep(Icons.person_search, 'Select the correct patient from the list.'),
                            _buildInstructionStep(Icons.camera_alt_outlined, 'Take a retina photo or upload images.'),
                            _buildInstructionStep(Icons.image_search_outlined, 'Review thumbnails and remove any unwanted images.'),
                            _buildInstructionStep(Icons.analytics_outlined, 'Tap "Analyze Images" to process the scans.'),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Retina scan for ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A1A)),
                        children: [
                          TextSpan(
                            text: widget.patient!.name,
                            style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' (Record #${widget.patient!.recordNumber})',
                            style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(Color primaryBlue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 64, color: primaryBlue),
          const SizedBox(height: 16),
          const Text(
            'Take a photo or upload images of the retina',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.image_outlined, color: primaryBlue),
                  label: Text('Upload', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _simulatePickImage,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.camera_alt, color: primaryBlue),
                  label: Text('Camera', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _simulateTakePhoto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(Color primaryBlue) {
    return Column(
      children: [
        // Thumbnails
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final uri = selectedImages[idx];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      uri,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeImage(uri),
                      tooltip: 'Remove',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearAll,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Clear All', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isAnalyzing || selectedImages.isEmpty ? null : _analyzeImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isAnalyzing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Analyze Images', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget for instruction steps
  Widget _buildInstructionStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF1E88E5), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }
}

