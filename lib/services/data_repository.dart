import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ocuscan_flutter/services/auth_service.dart';
import 'local_db_service.dart';
import 'supabase_service.dart';

/// DataRepository will always try Supabase first. If no internet, falls back to SQLite.
class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  bool _isOnline = true;

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
  }

  Future<bool> get isOnline async {
    await checkConnectivity();
    return _isOnline;
  }

  // --- USER METHODS ---
  Future<void> signOut() async {
    try {
      print('SignOut: Checking connectivity...');
      final online = await isOnline;
      print('SignOut: isOnline = $online');
      if (online) {
        print('SignOut: Calling SupabaseService.signOut()');
        await SupabaseService.signOut();
        print('SignOut: SupabaseService.signOut() completed');
      }
      print('SignOut: Calling AuthService.deleteUser()');
      await AuthService.deleteUser();
      print('SignOut: AuthService.deleteUser() completed');
    } catch (e, stack) {
      print('Sign out error:');
      print(e);
      print(stack);
      rethrow;
    }
  }

  Future<dynamic> signUp({required String email, required String password, String? fullName, String? hospitalName}) async {
    if (await isOnline) {
      // Online: Supabase
      final response = await SupabaseService.signUp(email: email, password: password);
      final userId = response.user?.id;
      if (userId != null) {
        // Store user in Supabase users table
        await SupabaseService.client.from('users').insert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'hospital_name': hospitalName,
        });
        // Store user in SQLite as well
        await LocalDbService.insertUser({
          'id': userId,
          'email': email,
          'password': password, // Only for offline support
          'full_name': fullName,
          'hospital_name': hospitalName,
        });
      }
      return response;
    } else {
      // Offline: SQLite
      return await LocalDbService.insertUser({
        'email': email,
        'password': password,
        'full_name': fullName,
        'hospital_name': hospitalName,
      });
    }
  }

  Future<dynamic> signIn({required String email, required String password}) async {
    if (await isOnline) {
      // Online: Supabase
      return await SupabaseService.signIn(email: email, password: password);
    } else {
      // Offline: SQLite
      final user = await LocalDbService.getUserByEmail(email);
      if (user != null && user['password'] == password) {
        return user;
      }
      return null;
    }
  }

  // --- PATIENTS ---
  Future<List<dynamic>> getPatients() async {
    if (await isOnline) {
      // Online: Supabase
      final response = await SupabaseService.client
          .from('patients')
          .select();
      return response;
    } else {
      // Offline: SQLite
      final result = await LocalDbService.getAllPatients();
      return result;
    }
  }

  Future<dynamic> addPatient({required String name, required String recordNumber, required String notes}) async {
    if (await isOnline) {
      // Online: Supabase
      final response = await SupabaseService.client
          .from('patients')
          .insert({
            'name': name,
            'record_number': recordNumber,
            'notes': notes,
          })
          .select();
      return response;
    } else {
      // Offline: SQLite
      return await LocalDbService.insertPatient({
        'name': name,
        'record_number': recordNumber,
        'notes': notes,
      });
    }
  }

  Future<dynamic> updatePatient({required String id, required String name, required String recordNumber, required String notes}) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('patients')
          .update({
            'name': name,
            'record_number': recordNumber,
            'notes': notes,
          })
          .eq('id', id)
          .select();
      return response;
    } else {
      return await LocalDbService.updatePatient(id, {
        'name': name,
        'record_number': recordNumber,
        'notes': notes,
      });
    }
  }

  Future<dynamic> deletePatient(String id) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('patients')
          .delete()
          .eq('id', id);
      return response;
    } else {
      return await LocalDbService.deletePatient(id);
    }
  }

  // --- SCANS ---
  Future<List<dynamic>> getScansByPatient(String patientId) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('scans')
          .select()
          .eq('patient_id', patientId);
      return response;
    } else {
      final result = await LocalDbService.getScansByPatient(patientId);
      return result;
    }
  }

  Future<dynamic> addScan({required String patientId, required String imagePath, required String createdAt}) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('scans')
          .insert({
            'patient_id': patientId,
            'image_path': imagePath,
            'created_at': createdAt,
          })
          .select();
      return response;
    } else {
      return await LocalDbService.insertScan({
        'patient_id': patientId,
        'image_path': imagePath,
        'created_at': createdAt,
      });
    }
  }

  Future<dynamic> deleteScan(String id) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('scans')
          .delete()
          .eq('id', id);
      return response;
    } else {
      return await LocalDbService.deleteScan(id);
    }
  }
}

