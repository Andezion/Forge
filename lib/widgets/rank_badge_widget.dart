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
      child: Image.asset(
        rank.assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            CustomPaint(painter: _FallbackBadgePainter(rank: rank)),
      ),
    );
  }
}

class _FallbackBadgePainter extends CustomPainter {
  final StrengthRank rank;
  const _FallbackBadgePainter({required this.rank});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.08)
      ..lineTo(size.width * 0.88, size.height * 0.08)
      ..lineTo(size.width * 0.88, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.82,
          size.width * 0.5, size.height * 0.94)
      ..quadraticBezierTo(size.width * 0.12, size.height * 0.82,
          size.width * 0.12, size.height * 0.58)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [rank.color, rank.color.withValues(alpha: 0.6)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fill);

    final border = Paint()
      ..color = rank.color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_FallbackBadgePainter old) => old.rank != rank;
}
