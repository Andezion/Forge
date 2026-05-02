import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/strength_rank.dart';

class RankBadgeWidget extends StatelessWidget {
  final StrengthRank rank;
  final double size;

  const RankBadgeWidget({super.key, required this.rank, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RankPainter(rank: rank),
      ),
    );
  }
}

class _RankPainter extends CustomPainter {
  final StrengthRank rank;
  const _RankPainter({required this.rank});

  @override
  void paint(Canvas canvas, Size size) {
    switch (rank) {
      case StrengthRank.wooden:
        _drawWooden(canvas, size);
      case StrengthRank.stone:
        _drawStone(canvas, size);
      case StrengthRank.iron:
        _drawIron(canvas, size);
      case StrengthRank.bronze:
        _drawShield(canvas, size, rank);
      case StrengthRank.silver:
        _drawShield(canvas, size, rank);
      case StrengthRank.gold:
        _drawGold(canvas, size);
      case StrengthRank.diamond:
        _drawDiamond(canvas, size);
    }
  }

  void _drawWooden(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.45;

    final fill = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFA0704A), const Color(0xFF6B3F1F)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, fill);

    // Wood grain lines
    final linePaint = Paint()
      ..color = const Color(0xFF4A2B0A).withValues(alpha: 0.35)
      ..strokeWidth = s.width * 0.03
      ..style = PaintingStyle.stroke;

    for (int i = -2; i <= 2; i++) {
      final y = cy + i * (s.height * 0.14);
      final path = Path()
        ..moveTo(cx - r * 0.8, y)
        ..cubicTo(cx - r * 0.3, y - s.height * 0.04, cx + r * 0.3,
            y + s.height * 0.04, cx + r * 0.8, y);
      canvas.drawPath(path, linePaint);
    }

    final border = Paint()
      ..color = const Color(0xFF3D1F08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.05;
    canvas.drawCircle(Offset(cx, cy), r, border);
  }

  // ─── STONE: irregular polygon ──────────────────────────────────────────────
  void _drawStone(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.44;

    final points = _irregularPolygon(cx, cy, r, 8, seed: 42);
    final path = _pointsToPath(points);

    final fill = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF9CA3AF), const Color(0xFF4B5563)],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(path, fill);

    // Facet lines
    final facet = Paint()
      ..color = const Color(0xFFE5E7EB).withValues(alpha: 0.4)
      ..strokeWidth = s.width * 0.025
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - r * 0.3, cy - r * 0.3),
        Offset(cx + r * 0.2, cy + r * 0.1), facet);
    canvas.drawLine(Offset(cx + r * 0.1, cy - r * 0.4),
        Offset(cx - r * 0.1, cy + r * 0.3), facet);

    final border = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.045;
    canvas.drawPath(path, border);
  }

  // ─── IRON: gear shape ─────────────────────────────────────────────────────
  void _drawIron(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final outerR = s.width * 0.46;
    final innerR = s.width * 0.32;
    final toothDepth = s.width * 0.12;
    const teeth = 8;

    final gearPath = _gearPath(cx, cy, innerR, outerR, toothDepth, teeth);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF6B7280), const Color(0xFF1F2937)],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));
    canvas.drawPath(gearPath, fill);

    // Highlight
    final highlight = Paint()
      ..color = const Color(0xFF9CA3AF).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.03;
    canvas.drawCircle(
        Offset(cx - s.width * 0.08, cy - s.height * 0.08),
        innerR * 0.4,
        highlight);

    // Center hole
    final hole = Paint()..color = const Color(0xFF111827);
    canvas.drawCircle(Offset(cx, cy), innerR * 0.38, hole);

    final border = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.04;
    canvas.drawPath(gearPath, border);
  }

  // ─── BRONZE / SILVER: classic shield ─────────────────────────────────────
  void _drawShield(Canvas canvas, Size s, StrengthRank r) {
    final path = _shieldPath(s);

    final Color c1, c2, borderC;
    if (r == StrengthRank.bronze) {
      c1 = const Color(0xFFE89A50);
      c2 = const Color(0xFF8B4A0A);
      borderC = const Color(0xFF5A2D00);
    } else {
      c1 = const Color(0xFFE2E8F0);
      c2 = const Color(0xFF64748B);
      borderC = const Color(0xFF334155);
    }

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1, c2],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));
    canvas.drawPath(path, fill);

    // Inner emblem: star for silver, cross for bronze
    if (r == StrengthRank.silver) {
      _drawStar(canvas, s.width / 2, s.height * 0.48, s.width * 0.18,
          const Color(0xFFCBD5E1));
    } else {
      _drawCross(canvas, s.width / 2, s.height * 0.48, s.width * 0.22,
          const Color(0xFFCD7F32).withValues(alpha: 0.6));
    }

    final border = Paint()
      ..color = borderC
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.06;
    canvas.drawPath(path, border);
  }

  // ─── GOLD: shield with crown ──────────────────────────────────────────────
  void _drawGold(Canvas canvas, Size s) {
    final shieldPath = _shieldPath(s);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Color(0xFFFDE68A), Color(0xFFB45309)],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));
    canvas.drawPath(shieldPath, fill);

    _drawCrown(canvas, s.width / 2, s.height * 0.45, s.width * 0.35,
        const Color(0xFFFEF3C7));

    final border = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.06;
    canvas.drawPath(shieldPath, border);

    // Glow
    final glow = Paint()
      ..color = const Color(0xFFEAB308).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
    canvas.drawPath(shieldPath, glow);
  }

  // ─── DIAMOND: gem shape with glow ─────────────────────────────────────────
  void _drawDiamond(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final w = s.width * 0.82;
    final topH = s.height * 0.3;
    final botH = s.height * 0.6;

    // Gem outline path
    final path = Path()
      ..moveTo(cx, cy - botH / 2 - topH * 0.6) // top point
      ..lineTo(cx - w / 2, cy - botH / 2)
      ..lineTo(cx - w * 0.22, cy - botH / 2 + topH)
      ..lineTo(cx, cy + botH / 2)
      ..lineTo(cx + w * 0.22, cy - botH / 2 + topH)
      ..lineTo(cx + w / 2, cy - botH / 2)
      ..close();

    // Outer glow
    final glow = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);
    canvas.drawPath(path, glow);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFE0F7FA), Color(0xFF0891B2)],
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height));
    canvas.drawPath(path, fill);

    // Facets
    final facet = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = s.width * 0.025
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - w / 2, cy - botH / 2),
        Offset(cx, cy - botH / 2 - topH * 0.6), facet);
    canvas.drawLine(Offset(cx + w / 2, cy - botH / 2),
        Offset(cx, cy - botH / 2 - topH * 0.6), facet);
    canvas.drawLine(Offset(cx - w / 2, cy - botH / 2), Offset(cx, cy + botH / 2),
        facet..color = Colors.white.withValues(alpha: 0.25));
    canvas.drawLine(Offset(cx - w * 0.22, cy - botH / 2 + topH),
        Offset(cx + w * 0.22, cy - botH / 2 + topH),
        facet..color = Colors.white.withValues(alpha: 0.4));

    final border = Paint()
      ..color = const Color(0xFF0369A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.05;
    canvas.drawPath(path, border);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Path _shieldPath(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.12, h * 0.08)
      ..lineTo(w * 0.88, h * 0.08)
      ..lineTo(w * 0.88, h * 0.58)
      ..quadraticBezierTo(w * 0.88, h * 0.82, w * 0.5, h * 0.94)
      ..quadraticBezierTo(w * 0.12, h * 0.82, w * 0.12, h * 0.58)
      ..close();
  }

  List<Offset> _irregularPolygon(double cx, double cy, double r, int sides,
      {int seed = 0}) {
    final rng = math.Random(seed);
    return List.generate(sides, (i) {
      final angle = 2 * math.pi * i / sides - math.pi / 2;
      final radius = r * (0.75 + rng.nextDouble() * 0.25);
      return Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle));
    });
  }

  Path _pointsToPath(List<Offset> pts) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path..close();
  }

  Path _gearPath(double cx, double cy, double innerR, double outerR,
      double toothW, int teeth) {
    final path = Path();
    final step = 2 * math.pi / teeth;
    final halfTooth = step * 0.25;

    for (int i = 0; i < teeth; i++) {
      final baseAngle = step * i - math.pi / 2;
      path.lineTo(
          cx + innerR * math.cos(baseAngle - halfTooth),
          cy + innerR * math.sin(baseAngle - halfTooth));
      path.lineTo(
          cx + outerR * math.cos(baseAngle - halfTooth * 0.5),
          cy + outerR * math.sin(baseAngle - halfTooth * 0.5));
      path.lineTo(
          cx + outerR * math.cos(baseAngle + halfTooth * 0.5),
          cy + outerR * math.sin(baseAngle + halfTooth * 0.5));
      path.lineTo(
          cx + innerR * math.cos(baseAngle + halfTooth),
          cy + innerR * math.sin(baseAngle + halfTooth));
    }
    return path..close();
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r, Color color) {
    const points = 5;
    final outerR = r;
    final innerR = r * 0.45;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = math.pi * i / points - math.pi / 2;
      final radius = i.isEven ? outerR : innerR;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawCross(
      Canvas canvas, double cx, double cy, double size, Color color) {
    final t = size * 0.28;
    final paint = Paint()..color = color;
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy), width: t, height: size), paint);
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy), width: size, height: t), paint);
  }

  void _drawCrown(
      Canvas canvas, double cx, double cy, double width, Color color) {
    final h = width * 0.55;
    final path = Path()
      ..moveTo(cx - width / 2, cy + h / 2)
      ..lineTo(cx - width / 2, cy - h * 0.1)
      ..lineTo(cx - width * 0.28, cy + h * 0.15)
      ..lineTo(cx - width * 0.12, cy - h / 2)
      ..lineTo(cx, cy + h * 0.1)
      ..lineTo(cx + width * 0.12, cy - h / 2)
      ..lineTo(cx + width * 0.28, cy + h * 0.15)
      ..lineTo(cx + width / 2, cy - h * 0.1)
      ..lineTo(cx + width / 2, cy + h / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    // Crown jewels
    final jewel = Paint()..color = const Color(0xFFF59E0B);
    for (final dx in [-width * 0.22, 0.0, width * 0.22]) {
      canvas.drawCircle(Offset(cx + dx, cy - h * 0.25), width * 0.06, jewel);
    }
  }

  @override
  bool shouldRepaint(_RankPainter old) => old.rank != rank;
}
