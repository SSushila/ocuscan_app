import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ocuscan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            full_name TEXT,
            email TEXT UNIQUE,
            hospital_name TEXT,
            password TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE patients(
            id TEXT PRIMARY KEY,
            name TEXT,
            record_number TEXT,
            notes TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE scans(
            id TEXT PRIMARY KEY,
            patient_id TEXT,
            image_path TEXT,
            created_at TEXT,
            FOREIGN KEY(patient_id) REFERENCES patients(id)
          );
        ''');
      },
    );
  }

  // Example: Insert user (for demo, add more methods as needed)
  static Future<String> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    // Add uuid if not present
    if (!user.containsKey('id')) {
      user['id'] = LocalDbService.generateUuid();
    }
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    return user['id'];
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // --- UUID GENERATION ---
  static String generateUuid() {
    return const Uuid().v4();
  }

  // --- PATIENTS ---
  static Future<String> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    if (!patient.containsKey('id')) {
      patient['id'] = LocalDbService.generateUuid();
    }
    await db.insert('patients', patient, conflictAlgorithm: ConflictAlgorithm.replace);
    return patient['id'];
  }

  static Future<List<Map<String, dynamic>>> getAllPatients() async {
    final db = await database;
    return await db.query('patients');
  }

  static Future<int> updatePatient(String id, Map<String, dynamic> patient) async {
    final db = await database;
    return await db.update('patients', patient, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deletePatient(String id) async {
    final db = await database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // --- SCANS ---
  static Future<String> insertScan(Map<String, dynamic> scan) async {
    final db = await database;
    if (!scan.containsKey('id')) {
      scan['id'] = LocalDbService.generateUuid();
    }
    await db.insert('scans', scan, conflictAlgorithm: ConflictAlgorithm.replace);
    return scan['id'];
  }

  static Future<List<Map<String, dynamic>>> getScansByPatient(String patientId) async {
    final db = await database;
    return await db.query('scans', where: 'patient_id = ?', whereArgs: [patientId]);
  }

  static Future<int> deleteScan(String id) async {
    final db = await database;
    return await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }
}

