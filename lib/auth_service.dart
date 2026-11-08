import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── REGISTER ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? guardianEmail,
    String? guardianPhone,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final String uid = cred.user!.uid;

      // 2. Save profile to Firestore
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'guardianEmail': guardianEmail ?? '',
        'guardianPhone': guardianPhone ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'role': role};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Try again.'};
    }
  }

  // ─── LOGIN ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final String uid = cred.user!.uid;

      // Fetch user role from Firestore
      final DocumentSnapshot doc =
      await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        return {'success': false, 'error': 'User profile not found.'};
      }

      final String role = doc['role'] ?? 'user';
      final String name = doc['name'] ?? '';

      return {'success': true, 'role': role, 'name': name, 'uid': uid};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _friendlyError(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Try again.'};
    }
  }

  // ─── LOGOUT ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── GET CURRENT USER PROFILE ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final DocumentSnapshot doc =
    await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return doc.data() as Map<String, dynamic>;
  }

  // ─── GET CURRENT UID ──────────────────────────────────────────────────────
  static String? getCurrentUid() => _auth.currentUser?.uid;

  // ─── FRIENDLY ERROR MESSAGES ──────────────────────────────────────────────
  static String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}