import 'package:flutter/material.dart';
import 'screens/account_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/sign_in_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/physician_dashboard_screen.dart';
import 'screens/about_screen.dart';
import 'screens/new_patient_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/settings_screen.dart';
import 'screens/support_screen.dart';
import 'screens/privacy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hinqvmahstkefyeojxzx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbnF2bWFoc3RrZWZ5ZW9qeHp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NTI5ODgsImV4cCI6MjA2MzQyODk4OH0.dIN5oVuB_SptZwAU-92K-ifjYkaVTpzvwbkjlejn78Y',
  );
  await AuthService.init();
  runApp(const OcuScanApp());
}

class OcuScanApp extends StatelessWidget {
  const OcuScanApp({super.key});

  Future<String> _getInitialRoute() async {
    // TODO: In the future, add logic to check for offline/online mode (SQLite/Supabase)
    final seenOnboarding = await AuthService.hasSeenOnboarding();
    if (!seenOnboarding) return '/onboarding';
    final user = await AuthService.getUser();
    if (user == null) return '/home';
    return '/physician-dashboard';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final router = GoRouter(
          initialLocation: snapshot.data!,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/sign-in',
              builder: (context, state) => const SignInScreen(),
            ),
            GoRoute(
              path: '/create-account',
              builder: (context, state) => const CreateAccountScreen(),
            ),
            GoRoute(
              path: '/onboarding',
              builder: (context, state) => const OnboardingScreen(),
            ),
            GoRoute(
              path: '/physician-dashboard',
              builder: (context, state) => const PhysicianDashboardScreen(),
            ),
            GoRoute(
              path: '/patients',
              builder: (context, state) => const PatientsScreen(),
            ),
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/about',
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: '/support',
              builder: (context, state) => const SupportScreen(),
            ),
            GoRoute(
              path: '/privacy',
              builder: (context, state) => const PrivacyScreen(),
            ),
            GoRoute(
              path: '/new-patient',
              builder: (context, state) => const NewPatientScreen(),
            ),
          ],
        );
        return MaterialApp.router(
          title: 'OcuScan',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
