import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isLastPage = false;

  final List<Map<String, String>> slides = [
    {
      'title': 'AI-Powered Detection',
      'description': 'Advanced machine learning algorithms analyze retinal images for early signs of disease',
      'icon': 'eye',
    },
    {
      'title': 'Instant Results',
      'description': 'Get immediate analysis and recommendations for potential retinal conditions',
      'icon': 'bolt',
    },
    {
      'title': 'Offline Capability',
      'description': 'Work anywhere with offline image analysis and secure data storage',
      'icon': 'cloud_off',
    },
    {
      'title': 'Secure & Private',
      'description': 'Your patient data is encrypted and protected with enterprise-grade security',
      'icon': 'shield',
    },
  ];

  Future<void> _completeOnboarding() async {
    await AuthService.saveOnboardingSeen();
    if (mounted) context.go('/home');
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isLastPage = index == slides.length - 1;
    });
  }

  Widget _buildSlide(Map<String, String> slide) {
    IconData iconData;
    switch (slide['icon']) {
      case 'eye':
        iconData = Icons.remove_red_eye_outlined;
        break;
      case 'bolt':
        iconData = Icons.bolt_rounded;
        break;
      case 'cloud_off':
        iconData = Icons.cloud_off_rounded;
        break;
      case 'shield':
        iconData = Icons.shield_outlined;
        break;
      default:
        iconData = Icons.info_outline;
    }

    return Card(
      elevation: 7,
      margin: const EdgeInsets.symmetric(vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1E88E5).withOpacity(0.10),
              radius: 44,
              child: Icon(iconData, color: const Color(0xFF1E88E5), size: 52),
            ),
            const SizedBox(height: 24),
            Text(
              slide['title']!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              slide['description']!,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF222222),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slides.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isActive ? 1 : 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 4;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Slim, modern header
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Welcome to OcuScan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSlide(slides[index]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildPagination(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          if (_isLastPage) {
                            await _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Text(_isLastPage ? 'Get Started' : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              Positioned(
                top: topPadding,
                right: 18,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    foregroundColor: const Color(0xFF1E88E5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _completeOnboarding,
                  child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
