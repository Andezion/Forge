import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

enum StrengthRank { wooden, stone, iron, bronze, silver, gold, diamond }

extension StrengthRankExt on StrengthRank {
  String get displayName {
    switch (this) {
      case StrengthRank.wooden:  return L10n.current.rankWooden;
      case StrengthRank.stone:   return L10n.current.rankStone;
      case StrengthRank.iron:    return L10n.current.rankIron;
      case StrengthRank.bronze:  return L10n.current.rankBronze;
      case StrengthRank.silver:  return L10n.current.rankSilver;
      case StrengthRank.gold:    return L10n.current.rankGold;
      case StrengthRank.diamond: return L10n.current.rankDiamond;
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

  String get assetPath {
    switch (this) {
      case StrengthRank.wooden:  return 'assets/images/wooden_rank.png';
      case StrengthRank.stone:   return 'assets/images/stone_rank.png';
      case StrengthRank.iron:    return 'assets/images/steel_rank.png';
      case StrengthRank.bronze:  return 'assets/images/copper_rank.png';
      case StrengthRank.silver:  return 'assets/images/silver_rank.png';
      case StrengthRank.gold:    return 'assets/images/golden_rank.png';
      case StrengthRank.diamond: return 'assets/images/diamond_rank.png';
    }
  }
}
