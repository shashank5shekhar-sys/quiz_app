import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign Up ──────────────────────────────────────────────────────────────
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name.trim());

      // Save user to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone ?? '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
      });

      notifyListeners();
      return AuthResult(success: true, message: 'Signup successful! Welcome aboard 🎉');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      notifyListeners();
      return AuthResult(success: true, message: 'Welcome back! 👋');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, message: 'Something went wrong. Please try again.');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ─── Update Profile ───────────────────────────────────────────────────────
  Future<AuthResult> updateProfile({
    required String name,
    String? phone,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final uid = currentUser!.uid;

      await currentUser!.updateDisplayName(name.trim());

      final Map<String, dynamic> updates = {
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileComplete': true,
      };

      if (phone != null) updates['phone'] = phone.trim();
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (bio != null) updates['bio'] = bio.trim();

      await _firestore.collection('users').doc(uid).update(updates);

      notifyListeners();
      return AuthResult(success: true, message: 'Profile updated successfully!');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update profile.');
    }
  }

  // ─── Get User Data ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // ─── Error Messages ───────────────────────────────────────────────────────
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}
