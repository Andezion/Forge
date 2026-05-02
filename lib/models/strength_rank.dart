import 'package:flutter/material.dart';

enum StrengthRank { wooden, stone, iron, bronze, silver, gold, diamond }

extension StrengthRankExt on StrengthRank {
  String get displayName {
    switch (this) {
      case StrengthRank.wooden:  return 'Wooden';
      case StrengthRank.stone:   return 'Stone';
      case StrengthRank.iron:    return 'Iron';
      case StrengthRank.bronze:  return 'Bronze';
      case StrengthRank.silver:  return 'Silver';
      case StrengthRank.gold:    return 'Gold';
      case StrengthRank.diamond: return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
      case StrengthRank.wooden:  return const Color(0xFF8B5E3C);
      case StrengthRank.stone:   return const Color(0xFF6B7280);
      case StrengthRank.iron:    return const Color(0xFF4B5563);
      case StrengthRank.bronze:  return const Color(0xFFCD7F32);
      case StrengthRank.silver:  return const Color(0xFFB0B8C1);
      case StrengthRank.gold:    return const Color(0xFFEAB308);
      case StrengthRank.diamond: return const Color(0xFF67E8F9);
    }
  }

  Color get glowColor {
    switch (this) {
      case StrengthRank.wooden:  return const Color(0x408B5E3C);
      case StrengthRank.stone:   return const Color(0x406B7280);
      case StrengthRank.iron:    return const Color(0x404B5563);
      case StrengthRank.bronze:  return const Color(0x40CD7F32);
      case StrengthRank.silver:  return const Color(0x40B0B8C1);
      case StrengthRank.gold:    return const Color(0x40EAB308);
      case StrengthRank.diamond: return const Color(0x8067E8F9);
    }
  }

  // Минимальный % от мирового рекорда для этого ранга
  double get minPercent {
    switch (this) {
      case StrengthRank.wooden:  return 0.0;
      case StrengthRank.stone:   return 20.0;
      case StrengthRank.iron:    return 35.0;
      case StrengthRank.bronze:  return 50.0;
      case StrengthRank.silver:  return 65.0;
      case StrengthRank.gold:    return 80.0;
      case StrengthRank.diamond: return 92.0;
    }
  }

  double get maxPercent {
    switch (this) {
      case StrengthRank.wooden:  return 20.0;
      case StrengthRank.stone:   return 35.0;
      case StrengthRank.iron:    return 50.0;
      case StrengthRank.bronze:  return 65.0;
      case StrengthRank.silver:  return 80.0;
      case StrengthRank.gold:    return 92.0;
      case StrengthRank.diamond: return 105.0;
    }
  }

  StrengthRank? get next {
    final all = StrengthRank.values;
    final idx = all.indexOf(this);
    if (idx >= all.length - 1) return null;
    return all[idx + 1];
  }
}
