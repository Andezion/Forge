import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../models/public_program.dart';
import '../models/workout.dart';

class StoreOfflineException implements Exception {
  @override
  String toString() => 'StoreOfflineException';
}

class StoreNotSignedInException implements Exception {}

enum StoreSort { popular, newest }

class StorePage {
  final List<PublicProgram> programs;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;

  const StorePage(this.programs, this.lastDoc, this.hasMore);
}

class PublicProgramService {
  static const pageSize = 20;
  static const _timeout = Duration(seconds: 12);
  static const _serverOnly = GetOptions(source: Source.server);

  final FirebaseFirestore _db;
  final fb_auth.FirebaseAuth _auth;

  PublicProgramService({FirebaseFirestore? db, fb_auth.FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? fb_auth.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('public_programs');

  String? get currentUserId => _auth.currentUser?.uid;

  String _requireUid() {
    final uid = currentUserId;
    if (uid == null) throw StoreNotSignedInException();
    return uid;
  }

  Future<T> _server<T>(Future<T> future) async {
    try {
      return await future.timeout(_timeout);
    } on TimeoutException {
      throw StoreOfflineException();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        throw StoreOfflineException();
      }
      rethrow;
    }
  }

  Future<StorePage> fetchApproved({
    StoreSort sort = StoreSort.popular,
    ProgramCategory? category,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> q =
        _col.where('status', isEqualTo: PublicProgramStatus.approved.name);
    if (category != null) {
      q = q.where('category', isEqualTo: category.name);
    }
    q = sort == StoreSort.popular
        ? q
            .orderBy('downloadCount', descending: true)
            .orderBy('createdAt', descending: true)
        : q.orderBy('createdAt', descending: true);
    if (startAfter != null) q = q.startAfterDocument(startAfter);

    final snap = await _server(q.limit(pageSize).get(_serverOnly));
    final programs = snap.docs.map(PublicProgram.fromFirestore).toList();
    return StorePage(
      programs,
      snap.docs.isEmpty ? startAfter : snap.docs.last,
      snap.docs.length == pageSize,
    );
  }

  Future<PublicProgram?> fetchById(String id) async {
    final doc = await _server(_col.doc(id).get(_serverOnly));
    return doc.exists ? PublicProgram.fromFirestore(doc) : null;
  }

  Future<List<PublicProgram>> fetchMyPublications() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final snap = await _col
          .where('authorId', isEqualTo: uid)
          .get()
          .timeout(_timeout);
      return snap.docs.map(PublicProgram.fromFirestore).toList();
    } catch (e) {
      debugPrint('[STORE] fetchMyPublications failed: $e');
      return [];
    }
  }

  Future<void> submit({
    required Workout workout,
    required String name,
    required String description,
    required ProgramCategory category,
    required String authorNickname,
    required String language,
  }) async {
    final uid = _requireUid();
    final ref = _col.doc(PublicProgram.docIdFor(uid, workout.id));

    final existing = await _server(ref.get(_serverOnly));
    final downloads = existing.exists
        ? (existing.data()?['downloadCount'] as num?)?.toInt() ?? 0
        : 0;

    await _server(ref.set(PublicProgram.submissionData(
      authorId: uid,
      authorNickname: authorNickname,
      name: name,
      description: description,
      category: category,
      language: language,
      workout: workout,
      downloadCount: downloads,
    )));
  }

  Future<void> remove(String programId) async {
    _requireUid();
    await _server(_col.doc(programId).get(_serverOnly)); 
    await _server(_col.doc(programId).delete());
  }

  Future<List<PublicProgram>> fetchUnseenReviews() async {
    final mine = await fetchMyPublications();
    return mine.where((p) => p.hasUnseenReview).toList();
  }

  Future<void> markAuthorNotified(String programId) async {
    try {
      await _col.doc(programId).update({'authorNotified': true});
    } catch (e) {
      debugPrint('[STORE] markAuthorNotified failed: $e');
    }
  }

  Future<void> recordDownload(String programId) async {
    final uid = currentUserId;
    if (uid == null) return;
    final programRef = _col.doc(programId);
    final markerRef = programRef.collection('downloads').doc(uid);
    try {
      final snap = await markerRef.get(_serverOnly).timeout(_timeout);
      if (snap.exists) return;
      final batch = _db.batch()
        ..set(markerRef, {'at': FieldValue.serverTimestamp()})
        ..update(programRef, {'downloadCount': FieldValue.increment(1)});
      await batch.commit().timeout(_timeout);
    } catch (e) {
      debugPrint('[STORE] recordDownload failed: $e');
    }
  }
}
