import 'package:flutter/material.dart';

import '../services/avatar_cache.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallback;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.radius,
    this.backgroundColor,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AvatarCache.instance,
      builder: (context, _) {
        final image = AvatarCache.instance.imageFor(userId);
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: image,
          child: image == null ? fallback : null,
        );
      },
    );
  }
}
