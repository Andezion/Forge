import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart' as app_user;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  fb_auth.User? _firebaseUser;

  AuthService() {
    _auth.userChanges().listen((u) {
      _firebaseUser = u;
      notifyListeners();
    });
  }

  fb_auth.User? get firebaseUser => _firebaseUser;

  Stream<fb_auth.User?> get userChanges => _auth.userChanges();

  Future<fb_auth.UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = cred.user;

      if (_firebaseUser != null) {
        await _firebaseUser!.updateDisplayName(name);

        final profile = {
          'id': _firebaseUser!.uid,
          'name': name,
          'nickname': name,
          'email': email,
          'height': 0.0,
          'weight': 0.0,
          'exerciseMaxes': [],
          'overallRating': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'lastWorkoutDate': null,
        };

        await _db.collection('users').doc(_firebaseUser!.uid).set(profile);

        if (remember) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_email', email);
          await prefs.setBool('remember_email', true);
        }
      }

      notifyListeners();
      return cred;
    } on fb_auth.FirebaseAuthException catch (e) {
      String message = 'Registration failed.';
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }
      throw AuthException(message);
    }
  }

  Future<fb_auth.UserCredential> signInWithEmail({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = cred.user;

      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_email', email);
        await prefs.setBool('remember_email', true);
      }

      notifyListeners();
      return cred;
    } on fb_auth.FirebaseAuthException catch (e) {
      String message = 'Sign in failed.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      }
      throw AuthException(message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<app_user.User?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return app_user.User.fromJson(doc.data()!);
  }
}
