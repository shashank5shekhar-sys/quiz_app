import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── CURRENT USER ─────────────────────────────
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ─── SIGN UP ──────────────────────────────────
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          'phone': phone ?? '',
          'profileComplete': false,
        },
      );

      if (response.user != null) {
        // Create user profile in DB
        await _client.from('users').insert({
          'id': response.user!.id,
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone ?? '',
          'photo_url': '',
          'bio': '',
          'profile_complete': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        notifyListeners();
        return AuthResult(
          success: true,
          message: 'Signup successful! Welcome 🎉',
        );
      }

      return AuthResult(success: false, message: 'Signup failed');
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // ─── LOGIN ─────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        notifyListeners();
        return AuthResult(
          success: true,
          message: 'Welcome back! 👋',
        );
      }

      return AuthResult(success: false, message: 'Login failed');
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  // ─── LOGOUT ───────────────────────────────────
  Future<void> logout() async {
    await _client.auth.signOut();
    notifyListeners();
  }

  // ─── UPDATE PROFILE ───────────────────────────
  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'User not logged in',
        );
      }

      final updates = {
        'name': name.trim(),
        'phone': phone ?? '',
        'photo_url': photoUrl ?? '',
        'bio': bio ?? '',
        'profile_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('users').update(updates).eq('id', user.id);

      notifyListeners();
      return AuthResult(
        success: true,
        message: 'Profile updated successfully!',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to update profile',
      );
    }
  }

  // ─── GET USER DATA ────────────────────────────
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return data;
    } catch (e) {
      return null;
    }
  }
}

// ─── RESULT MODEL ───────────────────────────────
class AuthResult {
  final bool success;
  final String message;

  AuthResult({
    required this.success,
    required this.message,
  });
}
