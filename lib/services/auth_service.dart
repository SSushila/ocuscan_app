import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage();

  /// Clears the onboarding flag so onboarding will show on next app launch
  static Future<void> clearOnboarding() async {
    await _storage.delete(key: 'hasSeenOnboarding');
  }

  static Future<void> init() async {
    // Reserved for future use
  }

  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: 'user', value: userJson);
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: 'user');
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: 'user');
  }

  static Future<void> saveOnboardingSeen() async {
    await _storage.write(key: 'hasSeenOnboarding', value: 'true');
  }

  static Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: 'hasSeenOnboarding');
    return value == 'true';
  }
}
