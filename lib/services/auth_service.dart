import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';

import '../models/user.dart' as app_user;

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
  }) async {
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
        'email': email,
        'height': 0.0,
        'weight': 0.0,
        'exerciseMaxes': [],
        'overallRating': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
        'lastWorkoutDate': null,
      };

      await _db.collection('users').doc(_firebaseUser!.uid).set(profile);
    }

    notifyListeners();
    return cred;
  }

  Future<fb_auth.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _firebaseUser = cred.user;
    notifyListeners();
    return cred;
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
