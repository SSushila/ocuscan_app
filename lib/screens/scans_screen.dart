import 'package:flutter/material.dart';

class ScansScreen extends StatefulWidget {
  const ScansScreen({super.key});
  @override
  State<ScansScreen> createState() => _ScansScreenState();
}

class _ScansScreenState extends State<ScansScreen> {
  // Mock patient data
  final Map<String, String> patient = {
    'fullName': 'Samuel Green',
    'recordNumber': 'P123456',
  };

  // Simulated selected images (AssetImage paths for demo)
  List<String> selectedImages = [];
  bool isAnalyzing = false;

  void _simulatePickImage() {
    // For demo, just add a local asset or network image
    setState(() {
      selectedImages.add('https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=facearea&w=80&h=80');
    });
  }

  void _simulateTakePhoto() {
    setState(() {
      selectedImages.add('https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=facearea&w=80&h=80');
    });
  }

  void _removeImage(String uri) {
    setState(() {
      selectedImages.remove(uri);
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                            text: patient['fullName'],
                            style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' (Record #${patient['recordNumber']})',
                            style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: const Color(0xFFE0E0E0),
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    // Upload/Images Section
                    selectedImages.isEmpty
                        ? _buildUploadSection(primaryBlue)
                        : _buildImagesSection(primaryBlue),
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
                    child: Image.network(
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
}
