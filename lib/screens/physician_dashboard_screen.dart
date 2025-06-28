// Modern Physician Dashboard UI - Enhanced with Beautiful Animations and Floating User Greeting
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import '../services/auth_service.dart';
import '../services/data_repository.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import 'package:go_router/go_router.dart';
import 'patients_screen.dart';
import 'scans_screen.dart';
import 'education_screen.dart';
import 'settings_screen.dart';

class PhysicianDashboardScreen extends StatefulWidget {
  const PhysicianDashboardScreen({super.key});

  @override
  State<PhysicianDashboardScreen> createState() => _PhysicianDashboardScreenState();
}

class _PhysicianDashboardScreenState extends State<PhysicianDashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF7C4DFF);
  late AnimationController _navController;
  late Animation<double> _navAnimation;

  final List<Widget> _screens = [
    PatientsScreen(),
    ScansScreen(patient: null),
    const PhysicianDashboardTab(),
    EducationScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = CurvedAnimation(parent: _navController, curve: Curves.easeInOut);
    _navController.forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
    _navController.reverse().then((_) {
      _navController.forward();
    });
    context.go(
      [
        '/patients',
        '/scans',
        '/physician-dashboard',
        '/education',
        '/settings',
      ][index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _navAnimation.value)),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  backgroundColor: Colors.white,
                  onDestinationSelected: _onTabTapped,
                  indicatorColor: primaryBlue.withOpacity(0.15),
                  height: 70,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      selectedIcon: Icon(Icons.people_alt, color: primaryBlue),
                      label: 'Patients',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.image_outlined),
                      selectedIcon: Icon(Icons.image, color: primaryBlue),
                      label: 'Scans',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard, color: primaryBlue),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school, color: primaryBlue),
                      label: 'Education',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings, color: primaryBlue),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedCounter extends StatefulWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const AnimatedCounter({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<int> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _pulseController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    
    _animation = IntTween(begin: 0, end: widget.count).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
    Timer(const Duration(milliseconds: 500), () {
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.color.withOpacity(0.1), widget.color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.color.withOpacity(0.2), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  _animation.value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FloatingUserGreeting extends StatefulWidget {
  final String firstName;

  const FloatingUserGreeting({required this.firstName, Key? key}) : super(key: key);

  @override
  State<FloatingUserGreeting> createState() => _FloatingUserGreetingState();
}

class _FloatingUserGreetingState extends State<FloatingUserGreeting> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _floatAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _floatController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    
    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _floatAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
    _floatController.repeat(reverse: true);
    
    // Auto-hide after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted && _isVisible) {
        _hideGreeting();
      }
    });
  }

  void _hideGreeting() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return Positioned(
      top: 100,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _opacityAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value, _floatAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: GestureDetector(
                onTap: _hideGreeting,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2196F3).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.waving_hand, color: Color(0xFF2196F3), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Hello, ${widget.firstName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.close, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhysicianDashboardTab extends StatefulWidget {
  const PhysicianDashboardTab({super.key});

  @override
  State<PhysicianDashboardTab> createState() => _PhysicianDashboardTabState();
}

class _PhysicianDashboardTabState extends State<PhysicianDashboardTab> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    
    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(index * 0.2, (index * 0.2) + 0.6, curve: Curves.elasticOut),
      ));
    });
    
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<String> _getFirstName() async {
    final userStr = await AuthService.getUser();
    if (userStr != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userStr);
        final email = userMap['email'] ?? '';
        final response = await DataRepository().isOnline
            ? await SupabaseService.client.from('users').select('full_name').eq('email', email).single()
            : await LocalDbService.getUserByEmail(email);
        final fullName = response != null ? response['full_name'] as String? : '';
        return (fullName != null && fullName.isNotEmpty)
            ? fullName.split(' ').first
            : email.split('@')[0];
      } catch (_) {}
    }
    return 'Doctor';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    const Color accentPurple = Color(0xFF7C4DFF);
    
    return FutureBuilder<String>(
      future: _getFirstName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        final firstName = snapshot.data ?? 'Doctor';

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FAFF), Color(0xFFF0F4FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Dr. $firstName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          AnimatedBuilder(
                            animation: _cardAnimations[0],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[0].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[0].value.clamp(0.0, 1.0),
                                  child: _buildModernStatsCard(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          AnimatedBuilder(
                            animation: _cardAnimations[1],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[1].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[1].value.clamp(0.0, 1.0),
                                  child: _buildModernBarChart(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          AnimatedBuilder(
                            animation: _cardAnimations[2],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[2].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[2].value.clamp(0.0, 1.0),
                                  child: _buildModernCalendar(),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _cardAnimations[3],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - _cardAnimations[3].value)),
                                child: Opacity(
                                  opacity: _cardAnimations[3].value.clamp(0.0, 1.0),
                                  child: _buildModernReminders(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 100), // Bottom padding for nav bar
                        ]),
                      ),
                    ),
                  ],
                ),
                FloatingUserGreeting(firstName: firstName),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildModernStatsCard() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.insights, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Text(
              "Today's Overview",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(
              child: AnimatedCounter(
                label: 'Patients',
                count: 12,
                color: Color(0xFF4CAF50),
                icon: Icons.people,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AnimatedCounter(
                label: 'Scans',
                count: 34,
                color: Color(0xFF2196F3),
                icon: Icons.image,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AnimatedCounter(
                label: 'Alerts',
                count: 5,
                color: Color(0xFFFF9800),
                icon: Icons.warning,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    required this.color,
    this.size = 8.0,
    Key? key,
  }) : super(key: key);

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    required this.child,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final IconData? icon;

  const GradientButton({
    required this.text,
    required this.onPressed,
    this.gradientColors = const [Color(0xFF2196F3), Color(0xFF7C4DFF)],
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradientColors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ParticleBackground extends StatefulWidget {
  final Widget child;

  const ParticleBackground({required this.child, Key? key}) : super(key: key);

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    // Generate particles
    for (int i = 0; i < 20; i++) {
      particles.add(Particle());
    }
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(particles, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  late double direction;

  Particle() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 4 + 1;
    color = [
      const Color(0xFF2196F3).withOpacity(0.3),
      const Color(0xFF7C4DFF).withOpacity(0.3),
      const Color(0xFFE91E63).withOpacity(0.3),
    ][math.Random().nextInt(3)];
    speed = math.Random().nextDouble() * 0.02 + 0.01;
    direction = math.Random().nextDouble() * 2 * math.pi;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      // Update particle position
      particle.x += math.cos(particle.direction) * particle.speed;
      particle.y += math.sin(particle.direction) * particle.speed;

      // Wrap around screen
      if (particle.x > 1) particle.x = 0;
      if (particle.x < 0) particle.x = 1;
      if (particle.y > 1) particle.y = 0;
      if (particle.y < 0) particle.y = 1;

      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced Theme Data
class AppTheme {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE91E63);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8FAFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: surface,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: primaryBlue.withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );

  static Gradient get primaryGradient => const LinearGradient(
    colors: [primaryBlue, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

Widget _buildModernBarChart() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Text(
              'Disease Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: 7,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: 3,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: 5,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFFA5D6A7)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const style = TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
                      switch (value.toInt()) {
                        case 0: return const Text('Glaucoma', style: style);
                        case 1: return const Text('DR', style: style);
                        case 2: return const Text('AMD', style: style);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildModernCalendar() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Text(
              'Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            weekendTextStyle: TextStyle(color: Colors.grey[600]),
            outsideDaysVisible: false,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onDaySelected: (selectedDay, focusedDay) {},
          selectedDayPredicate: (day) => false,
        ),
      ],
    ),
  );
}

Widget _buildModernReminders() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.notifications, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Text(
              'Reminders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildReminderItem(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          title: 'Review Patient Reports',
          subtitle: 'Due today at 5 PM',
          isUrgent: false,
        ),
        const SizedBox(height: 16),
        _buildReminderItem(
          icon: Icons.warning_amber_outlined,
          iconColor: const Color(0xFFFF9800),
          title: 'Follow-up: John Doe',
          subtitle: 'Tomorrow at 10 AM',
          isUrgent: true,
        ),
        const SizedBox(height: 16),
        _buildReminderItem(
          icon: Icons.schedule,
          iconColor: const Color(0xFF2196F3),
          title: 'Team Meeting',
          subtitle: 'Friday at 2 PM',
          isUrgent: false,
        ),
      ],
    ),
  );
}

Widget _buildReminderItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required bool isUrgent,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: iconColor.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isUrgent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    ),
  );
}