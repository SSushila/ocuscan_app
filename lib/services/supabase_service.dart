import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Example: Sign up user
  static Future<AuthResponse> signUp({required String email, required String password}) async {
    return await client.auth.signUp(email: email, password: password);
  }

  // Example: Sign in user
  static Future<AuthResponse> signIn({required String email, required String password}) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  // Example: Sign out user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Example: Get current user
  static User? get currentUser => client.auth.currentUser;

  // TODO: Add methods for patients and scans CRUD
}
