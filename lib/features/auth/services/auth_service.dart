import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Custom exception so UI/provider can read a clean message + code.
class AuthFailure implements Exception {
  final String message;
  final String? code;
  AuthFailure(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('Login failed. Please try again.');
      }

      final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
      final doc = await userDocRef.get();

      // ✅ FIX: if Firestore user doc doesn't exist, create it (prevents doc.data()! crash)
      if (!doc.exists || doc.data() == null) {
        final displayName = (firebaseUser.displayName?.trim().isNotEmpty ?? false)
            ? firebaseUser.displayName!.trim()
            : (email.split('@').first);

        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await userDocRef.set(newUser.toJson(), SetOptions(merge: true));
        return newUser;
      }

      return UserModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthFailure('Login failed: ${e.toString()}');
    }
  }

  Future<UserModel> register(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthFailure('Registration failed. Please try again.');
      }

      // Optional: set Auth display name too (nice to have)
      await firebaseUser.updateDisplayName(displayName);

      final user = UserModel(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthFailure('Registration failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthFailure('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      // ✅ FIX: handle missing Firestore doc gracefully
      if (!doc.exists || doc.data() == null) {
        final displayName = (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : (user.email?.split('@').first ?? 'User');

        final fallback = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(fallback.toJson(), SetOptions(merge: true));
        return fallback;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  AuthFailure _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthFailure('This email is already registered. Please login instead.', code: e.code);
      case 'invalid-email':
        return AuthFailure('Invalid email address.', code: e.code);
      case 'operation-not-allowed':
        return AuthFailure('Operation not allowed. Please contact support.', code: e.code);
      case 'weak-password':
        return AuthFailure('Password is too weak. Please use a stronger password.', code: e.code);
      case 'user-disabled':
        return AuthFailure('This account has been disabled.', code: e.code);
      case 'user-not-found':
        return AuthFailure('No account found with this email.', code: e.code);
      case 'wrong-password':
        return AuthFailure('Incorrect password.', code: e.code);
      case 'invalid-credential':
        return AuthFailure('Invalid email or password.', code: e.code);
      case 'too-many-requests':
        return AuthFailure('Too many attempts. Please try again later.', code: e.code);
      case 'network-request-failed':
        return AuthFailure('Network error. Please check your internet connection.', code: e.code);
      default:
        return AuthFailure(e.message ?? 'An error occurred. Please try again.', code: e.code);
    }
  }
}