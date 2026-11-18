import 'dart:convert';

import 'package:flutter/widgets.dart';

class AvatarCache extends ChangeNotifier {
  AvatarCache._();
  static final AvatarCache instance = AvatarCache._();

  final Map<String, _AvatarEntry> _entries = {};

  void putFromStats(String userId, Map<String, dynamic>? data) {
    if (data == null) return;
    put(
      userId,
      data['avatar'] as String?,
      (data['avatarVersion'] as num?)?.toInt() ?? 0,
    );
  }

  void put(String userId, String? base64Data, int version) {
    final existing = _entries[userId];
    if (existing != null && version <= existing.version) return;

    ImageProvider? image;
    if (base64Data != null && base64Data.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(base64Data));
      } catch (e) {
        debugPrint('[AVATAR] Bad avatar data for $userId: $e');
      }
    }
    _entries[userId] = _AvatarEntry(version, image);
    notifyListeners();
  }

  ImageProvider? imageFor(String userId) => _entries[userId]?.image;
}

class _AvatarEntry {
  final int version;
  final ImageProvider? image;
  const _AvatarEntry(this.version, this.image);
}
