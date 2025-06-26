import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(55),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'OcuScan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(140, 30, 136, 229), // #1E88E5 with ~55% opacity
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                              Shadow(
                                color: Color.fromARGB(46, 0, 0, 0), // black with ~18% opacity
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your AI-powered retinal disease detection assistant',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF1E88E5),
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              context.go('/sign-in');
                            },
                            child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E88E5), width: 1.3),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.go('/create-account');
                            },
                            child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E88E5))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // How It Works
                    const Text(
                      'How It Works',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E88E5), letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        _StepWidget(
                          image: 'assets/illustrations/patient-registration.png',
                          title: 'Register Patient',
                          text: 'Quickly add patient details securely and easily.',
                        ),
                        const SizedBox(height: 14),
                        _StepWidget(
                          image: 'assets/illustrations/image-capture.png',
                          title: 'Capture Retinal Image',
                          text: 'Take a retinal image using your phone or connected device.',
                        ),
                        const SizedBox(height: 14),
                        _StepWidget(
                          image: 'assets/illustrations/analysis.png',
                          title: 'AI Analysis',
                          text: 'Let OcuScan analyze the image for signs of retinal disease.',
                        ),
                        const SizedBox(height: 14),
                        _StepWidget(
                          image: 'assets/illustrations/history.png',
                          title: 'View Results & History',
                          text: 'Get instant results and track patient history over time.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Common Retinal Diseases',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1E88E5), letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF1E88E5), width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/retina.jpeg',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: const [
                        _DiseaseWidget(
                          title: 'Diabetic Retinopathy',
                          description: 'A diabetes complication affecting the retina\'s blood vessels',
                        ),
                        SizedBox(height: 12),
                        _DiseaseWidget(
                          title: 'Age-related Macular Degeneration',
                          description: 'Deterioration of the macula, affecting central vision',
                        ),
                        SizedBox(height: 12),
                        _DiseaseWidget(
                          title: 'Glaucoma',
                          description: 'Damage to the optic nerve, often due to high eye pressure',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  const _StepWidget({required this.image, required this.title, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E88E5))),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4)),
        ],
      ),
    );
  }
}

class _DiseaseWidget extends StatelessWidget {
  final String title;
  final String description;
  const _DiseaseWidget({required this.title, required this.description});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.remove_red_eye, color: Color(0xFF1E88E5), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E88E5))),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
