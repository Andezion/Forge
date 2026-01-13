import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendsService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  List<Friend> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];
  bool _loading = false;

  List<Friend> get friends => _friends;
  List<FriendRequest> get receivedRequests => _receivedRequests;
  List<FriendRequest> get sentRequests => _sentRequests;
  bool get loading => _loading;

  String? get _currentUserId => _auth.currentUser?.uid;
  String? get _currentUserEmail => _auth.currentUser?.email;
  String? get _currentUserName => _auth.currentUser?.displayName;

  Future<void> loadFriends() async {
    if (_currentUserId == null) return;

    _loading = true;
    notifyListeners();

    try {
      final friendsSnapshot = await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('friends')
          .get();

      _friends = friendsSnapshot.docs.map((doc) {
        return Friend.fromJson(doc.data());
      }).toList();

      _friends.sort((a, b) {
        if (a.lastWorkoutDate == null && b.lastWorkoutDate == null) return 0;
        if (a.lastWorkoutDate == null) return 1;
        if (b.lastWorkoutDate == null) return -1;
        return b.lastWorkoutDate!.compareTo(a.lastWorkoutDate!);
      });
    } catch (e) {
      debugPrint('Error loading friends: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadReceivedRequests() async {
    if (_currentUserId == null) return;

    try {
      final requestsSnapshot = await _db
          .collection('friendRequests')
          .where('toUserId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _receivedRequests = requestsSnapshot.docs.map((doc) {
        return FriendRequest.fromJson(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading received requests: $e');
    }
  }

  Future<void> loadSentRequests() async {
    if (_currentUserId == null) return;

    try {
      final requestsSnapshot = await _db
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _sentRequests = requestsSnapshot.docs.map((doc) {
        return FriendRequest.fromJson(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sent requests: $e');
    }
  }

  Future<String> sendFriendRequest(String email) async {
    if (_currentUserId == null || _currentUserEmail == null) {
      return 'You must be logged in to send friend requests';
    }

    if (email.trim().isEmpty) {
      return 'Please enter an email address';
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == _currentUserEmail!.toLowerCase()) {
      return 'You cannot add yourself as a friend';
    }

    try {
      final usersSnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        return 'No user found with this email address';
      }

      final targetUser = usersSnapshot.docs.first;
      final targetUserId = targetUser.id;

      final friendDoc = await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('friends')
          .doc(targetUserId)
          .get();

      if (friendDoc.exists) {
        return 'You are already friends with this user';
      }

      final existingRequestSnapshot = await _db
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: _currentUserId)
          .where('toUserId', isEqualTo: targetUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequestSnapshot.docs.isNotEmpty) {
        return 'Friend request already sent';
      }

      final request = FriendRequest(
        id: '',
        fromUserId: _currentUserId!,
        fromUserName: _currentUserName ?? 'Unknown',
        fromUserEmail: _currentUserEmail!,
        toUserId: targetUserId,
        toUserEmail: normalizedEmail,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await _db.collection('friendRequests').add(request.toJson());

      await loadSentRequests();

      return 'success';
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return 'Failed to send friend request. Please try again.';
    }
  }

  Future<String> acceptFriendRequest(FriendRequest request) async {
    if (_currentUserId == null) {
      return 'You must be logged in';
    }

    try {
      await _db.collection('friendRequests').doc(request.id).update({
        'status': 'accepted',
        'respondedAt': DateTime.now().toIso8601String(),
      });

      final fromUserDoc =
          await _db.collection('users').doc(request.fromUserId).get();
      final toUserDoc =
          await _db.collection('users').doc(request.toUserId).get();

      if (!fromUserDoc.exists || !toUserDoc.exists) {
        return 'User data not found';
      }

      final fromUserData = fromUserDoc.data()!;
      final toUserData = toUserDoc.data()!;

      final now = DateTime.now();

      final friendForCurrentUser = Friend(
        userId: request.fromUserId,
        name: fromUserData['nickname'] ?? fromUserData['name'] ?? 'Unknown',
        email: fromUserData['email'] ?? '',
        weight: fromUserData['weight'] != null
            ? (fromUserData['weight'] as num).toDouble()
            : null,
        overallRating: fromUserData['overallRating'] != null
            ? (fromUserData['overallRating'] as num).toDouble()
            : null,
        lastWorkoutDate: fromUserData['lastWorkoutDate'] != null
            ? DateTime.parse(fromUserData['lastWorkoutDate'])
            : null,
        friendsSince: now,
      );

      final friendForRequestSender = Friend(
        userId: request.toUserId,
        name: toUserData['nickname'] ?? toUserData['name'] ?? 'Unknown',
        email: toUserData['email'] ?? '',
        weight: toUserData['weight'] != null
            ? (toUserData['weight'] as num).toDouble()
            : null,
        overallRating: toUserData['overallRating'] != null
            ? (toUserData['overallRating'] as num).toDouble()
            : null,
        lastWorkoutDate: toUserData['lastWorkoutDate'] != null
            ? DateTime.parse(toUserData['lastWorkoutDate'])
            : null,
        friendsSince: now,
      );

      await _db
          .collection('users')
          .doc(request.toUserId)
          .collection('friends')
          .doc(request.fromUserId)
          .set(friendForCurrentUser.toJson());

      await _db
          .collection('users')
          .doc(request.fromUserId)
          .collection('friends')
          .doc(request.toUserId)
          .set(friendForRequestSender.toJson());

      await loadFriends();
      await loadReceivedRequests();

      return 'success';
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return 'Failed to accept friend request. Please try again.';
    }
  }

  Future<String> rejectFriendRequest(FriendRequest request) async {
    if (_currentUserId == null) {
      return 'You must be logged in';
    }

    try {
      await _db.collection('friendRequests').doc(request.id).update({
        'status': 'rejected',
        'respondedAt': DateTime.now().toIso8601String(),
      });

      await loadReceivedRequests();

      return 'success';
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return 'Failed to reject friend request. Please try again.';
    }
  }

  Future<String> removeFriend(String friendUserId) async {
    if (_currentUserId == null) {
      return 'You must be logged in';
    }

    try {
      await _db
          .collection('users')
          .doc(_currentUserId)
          .collection('friends')
          .doc(friendUserId)
          .delete();

      await _db
          .collection('users')
          .doc(friendUserId)
          .collection('friends')
          .doc(_currentUserId)
          .delete();

      await loadFriends();

      return 'success';
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return 'Failed to remove friend. Please try again.';
    }
  }

  Future<String> cancelSentRequest(String requestId) async {
    try {
      await _db.collection('friendRequests').doc(requestId).delete();
      await loadSentRequests();
      return 'success';
    } catch (e) {
      debugPrint('Error canceling request: $e');
      return 'Failed to cancel request. Please try again.';
    }
  }

  Future<List<Friend>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final normalizedQuery = query.trim().toLowerCase();

      final nicknameSnapshot = await _db
          .collection('users')
          .where('nickname', isGreaterThanOrEqualTo: normalizedQuery)
          .where('nickname', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(5)
          .get();

      final emailSnapshot = await _db
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: normalizedQuery)
          .where('email', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
          .limit(5)
          .get();

      final userIds = <String>{};
      final results = <Friend>[];

      for (var doc in [...nicknameSnapshot.docs, ...emailSnapshot.docs]) {
        if (!userIds.contains(doc.id) && doc.id != _currentUserId) {
          userIds.add(doc.id);
          final data = doc.data();
          results.add(Friend(
            userId: doc.id,
            name: data['nickname'] ?? data['name'] ?? 'Unknown',
            email: data['email'] ?? '',
            weight: data['weight'] != null
                ? (data['weight'] as num).toDouble()
                : null,
            overallRating: data['overallRating'] != null
                ? (data['overallRating'] as num).toDouble()
                : null,
            lastWorkoutDate: data['lastWorkoutDate'] != null
                ? DateTime.parse(data['lastWorkoutDate'])
                : null,
            friendsSince: DateTime.now(),
          ));
        }
      }

      return results.take(10).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }
}
