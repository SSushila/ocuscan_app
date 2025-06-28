import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color surfaceColor = const Color(0xFFFAFAFA);
    final Color cardColor = Colors.white;
    final Color secondaryBlue = const Color(0xFFEFF6FF);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'OcuScan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your AI-powered retinal disease\ndetection assistant',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              context.go('/sign-in');
                            },
                            child: const Text(
                              'Sign In', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              )
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryBlue, width: 1.5),
                              backgroundColor: cardColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.go('/create-account');
                            },
                            child: Text(
                              'Create Account', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600, 
                                color: primaryBlue,
                                letterSpacing: 0.2,
                              )
                            ),
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
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // How It Works
                    Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w700, 
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        _StepWidget(
                          image: 'assets/illustrations/patient-registration.png',
                          title: 'Register Patient',
                          text: 'Quickly add patient details securely and easily.',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _StepWidget(
                          image: 'assets/illustrations/image-capture.png',
                          title: 'Capture Retinal Image',
                          text: 'Take a retinal image using your phone or connected device.',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _StepWidget(
                          image: 'assets/illustrations/analysis.png',
                          title: 'AI Analysis',
                          text: 'Let OcuScan analyze the image for signs of retinal disease.',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _StepWidget(
                          image: 'assets/illustrations/history.png',
                          title: 'View Results & History',
                          text: 'Get instant results and track patient history over time.',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Common Retinal Diseases',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.w700, 
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/retina.jpeg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        _DiseaseWidget(
                          title: 'Diabetic Retinopathy',
                          description: 'A diabetes complication affecting the retina\'s blood vessels',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _DiseaseWidget(
                          title: 'Age-related Macular Degeneration',
                          description: 'Deterioration of the macula, affecting central vision',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _DiseaseWidget(
                          title: 'Glaucoma',
                          description: 'Damage to the optic nerve, often due to high eye pressure',
                          primaryBlue: primaryBlue,
                          cardColor: cardColor,
                          secondaryBlue: secondaryBlue,
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
  final Color primaryBlue;
  final Color cardColor;
  final Color secondaryBlue;

  const _StepWidget({
    required this.image, 
    required this.title, 
    required this.text,
    required this.primaryBlue,
    required this.cardColor,
    required this.secondaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title, 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: const Color(0xFF1E293B),
              letterSpacing: -0.2,
            )
          ),
          const SizedBox(height: 8),
          Text(
            text, 
            style: const TextStyle(
              fontSize: 15, 
              color: Color(0xFF64748B), 
              height: 1.5,
              fontWeight: FontWeight.w400,
            )
          ),
        ],
      ),
    );
  }
}

class _DiseaseWidget extends StatelessWidget {
  final String title;
  final String description;
  final Color primaryBlue;
  final Color cardColor;
  final Color secondaryBlue;

  const _DiseaseWidget({
    required this.title, 
    required this.description,
    required this.primaryBlue,
    required this.cardColor,
    required this.secondaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: secondaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.remove_red_eye_outlined, 
              color: primaryBlue, 
              size: 24
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  )
                ),
                const SizedBox(height: 6),
                Text(
                  description, 
                  style: const TextStyle(
                    fontSize: 14, 
                    color: Color(0xFF64748B), 
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}