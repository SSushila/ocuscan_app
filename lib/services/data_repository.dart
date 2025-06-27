import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // --- USER PROFILE ---
  Future<void> updateUser({required String id, required String email, required String fullName, required String hospitalName}) async {
    final userMap = {
      'id': id,
      'email': email,
      'full_name': fullName,
      'hospital_name': hospitalName,
    };
    if (await isOnline) {
      // Update Supabase users table
      await SupabaseService.client
          .from('users')
          .update({'full_name': fullName, 'hospital_name': hospitalName})
          .eq('id', id);
      // Update SQLite
      await LocalDbService.insertUser({...userMap});
    } else {
      // Offline: update SQLite only
      await LocalDbService.insertUser({...userMap});
    }
    // Update secure storage
    await AuthService.saveUser(jsonEncode(userMap));
  }

  Future<bool> changePassword({required String email, required String newPassword, String? currentPassword}) async {
    try {
      if (await isOnline) {
        // Change via Supabase Auth
        final user = SupabaseService.client.auth.currentUser;
        if (user == null) {
          print('DEBUG: Supabase Auth user is null');
          throw UnsupportedError('No Supabase Auth user');
        }
        try {
          final res = await SupabaseService.client.auth.updateUser(
            UserAttributes(password: newPassword),
          );
          print('DEBUG: Supabase updateUser result: ' + res.toString());
          if (res.user == null) {
            print('DEBUG: Supabase updateUser returned null user');
            throw UnsupportedError('Supabase password update failed');
          }
        } catch (e, stack) {
          print('DEBUG: Supabase password change error: $e');
          print(stack);
          throw UnsupportedError('Supabase password change error: $e');
        }
        // Also update SQLite for offline
        final localUser = await LocalDbService.getUserByEmail(email);
        if (localUser != null) {
          localUser['password'] = newPassword;
          await LocalDbService.insertUser(localUser);
          await AuthService.saveUser(jsonEncode(localUser));
        }
        return true;
      } else {
        // Offline: update SQLite and secure storage
        final localUser = await LocalDbService.getUserByEmail(email);
        if (localUser != null) {
          localUser['password'] = newPassword;
          await LocalDbService.insertUser(localUser);
          await AuthService.saveUser(jsonEncode(localUser));
          return true;
        }
        return false;
      }
    } catch (e, stack) {
      print('DEBUG: changePassword error: $e');
      print(stack);
      throw UnsupportedError('Failed to change password: $e');
    }
  }

  // --- PATIENTS ---
  Future<List<dynamic>> getPatients() async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('patients')
          .select()
          .eq('is_deleted', false);
      return response;
    } else {
      final result = await LocalDbService.getAllPatients(where: 'is_deleted = ?', whereArgs: [0]);
      return result;
    }
  }

  Future<List<dynamic>> searchPatients(String query) async {
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('patients')
          .select()
          .or('name.ilike.%$query%,record_number.ilike.%$query%,notes.ilike.%$query%');
      return response;
    } else {
      final result = await LocalDbService.searchPatients(query);
      return result;
    }
  }

  Future<dynamic> addPatient({required String name, required String recordNumber, required String notes}) async {
    final now = DateTime.now().toIso8601String();
    final isDeleted = false;
    String? userId;
    if (await isOnline) {
      // Online: Supabase
      userId = SupabaseService.currentUser?.id;
      final response = await SupabaseService.client
          .from('patients')
          .insert({
            'full_name': name,
            'record_number': recordNumber,
            'notes': notes,
            'created_at': now,
            'updated_at': now,
            'user_id': userId,
            'is_deleted': isDeleted,
          })
          .select();
      return response;
    } else {
      // Offline: SQLite
      // Try to get user id from AuthService
      try {
        final userJson = await AuthService.getUser();
        if (userJson != null) {
          final userMap = jsonDecode(userJson);
          userId = userMap['id'] ?? userMap['user_id'];
        }
      } catch (_) {}
      return await LocalDbService.insertPatient({
        'full_name': name,
        'record_number': recordNumber,
        'notes': notes,
        'created_at': now,
        'updated_at': now,
        'user_id': userId,
        'is_deleted': isDeleted ? 1 : 0,
      });
    }
  }

  Future<dynamic> updatePatient({required String id, required String name, required String recordNumber, required String notes}) async {
    final now = DateTime.now().toIso8601String();
    if (await isOnline) {
      final response = await SupabaseService.client
          .from('patients')
          .update({
            'full_name': name,
            'record_number': recordNumber,
            'notes': notes,
          })
          .eq('id', id)
          .select();
      return response;
    } else {
      return await LocalDbService.updatePatient(id, {
        'full_name': name,
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

