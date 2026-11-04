import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/body_measurement.dart';
import 'body_map/body_map.dart';
import 'body_map/body_map_data.dart';

class MeasurementOrbit {
  final BodyMeasurement type;
  final Offset center;
  final double rx;
  final double ry;

  const MeasurementOrbit(this.type, this.center, this.rx, this.ry);

  MeasurementOrbit _mirrored(BodyMeasurement type) => MeasurementOrbit(
      type, Offset(BodyMapData.width - center.dx, center.dy), rx, ry);

  static const _rightLimbs = [
    MeasurementOrbit(BodyMeasurement.bicepsRight, Offset(43, 150), 17, 5.5),
    MeasurementOrbit(BodyMeasurement.forearmRight, Offset(39, 203), 17.5, 5.5),
    MeasurementOrbit(BodyMeasurement.thighRight, Offset(78.7, 272), 21, 6.5),
    MeasurementOrbit(BodyMeasurement.calfRight, Offset(79.7, 365), 18.5, 5.5),
  ];

  static const _leftOf = {
    BodyMeasurement.bicepsRight: BodyMeasurement.bicepsLeft,
    BodyMeasurement.forearmRight: BodyMeasurement.forearmLeft,
    BodyMeasurement.thighRight: BodyMeasurement.thighLeft,
    BodyMeasurement.calfRight: BodyMeasurement.calfLeft,
  };

  static final List<MeasurementOrbit> all = [
    const MeasurementOrbit(BodyMeasurement.shoulders, Offset(100, 100), 74, 9),
    const MeasurementOrbit(BodyMeasurement.chest, Offset(100, 124), 47, 8),
    for (final orbit in _rightLimbs) ...[
      orbit,
      orbit._mirrored(_leftOf[orbit.type]!),
    ],
  ];

  double distanceTo(Offset point) {
    final dx = (point.dx - center.dx) / rx;
    final dy = (point.dy - center.dy) / ry;
    if (dx * dx + dy * dy <= 1) return 0;
    var best = double.infinity;
    const samples = 72;
    for (var i = 0; i < samples; i++) {
      final t = 2 * math.pi * i / samples;
      final p = center + Offset(rx * math.cos(t), ry * math.sin(t));
      best = math.min(best, (p - point).distance);
    }
    return best;
  }

  static MeasurementOrbit? hit(Offset point, {double tolerance = 8}) {
    MeasurementOrbit? result;
    var best = tolerance;
    for (final orbit in all) {
      final d = orbit.distanceTo(point);
      if (d <= best) {
        best = d;
        result = orbit;
      }
    }
    return result;
  }
}

class BodyMeasurementMap extends StatefulWidget {
  final Map<BodyMeasurement, String> values;
  final BodyMeasurement? active;
  final ValueChanged<BodyMeasurement> onOrbitTap;

  const BodyMeasurementMap({
    super.key,
    required this.values,
    required this.onOrbitTap,
    this.active,
  });

  @override
  State<BodyMeasurementMap> createState() => _BodyMeasurementMapState();
}

class _BodyMeasurementMapState extends State<BodyMeasurementMap> {
  BodyMeasurement? _pressed;

  BodyMeasurement? _hit(Offset local, double scale) =>
      MeasurementOrbit.hit(local / scale)?.type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ) ??
        TextStyle(fontSize: 11, color: scheme.onSurface);

    return AspectRatio(
      aspectRatio: BodyMapData.width / BodyMapData.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / BodyMapData.width;
          final active = _pressed ?? widget.active;

          _OrbitPainter painter(bool back) => _OrbitPainter(
                back: back,
                values: widget.values,
                active: active,
                idle: scheme.onSurface.withValues(alpha: 0.5),
                highlight: scheme.primary,
                textStyle: textStyle,
              );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) =>
                setState(() => _pressed = _hit(d.localPosition, scale)),
            onTapCancel: () => setState(() => _pressed = null),
            onTapUp: (d) {
              final type = _hit(d.localPosition, scale);
              setState(() => _pressed = null);
              if (type != null) widget.onOrbitTap(type);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: painter(true)),
                const BodyMap(side: BodyMapSide.front),
                CustomPaint(painter: painter(false)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final bool back;
  final Map<BodyMeasurement, String> values;
  final BodyMeasurement? active;
  final Color idle;
  final Color highlight;
  final TextStyle textStyle;

  _OrbitPainter({
    required this.back,
    required this.values,
    required this.active,
    required this.idle,
    required this.highlight,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / BodyMapData.width;

    for (final orbit in MeasurementOrbit.all) {
      final isActive = orbit.type == active;
      final color = isActive ? highlight : idle;
      final rect = Rect.fromCenter(
        center: orbit.center * scale,
        width: orbit.rx * 2 * scale,
        height: orbit.ry * 2 * scale,
      );
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isActive ? 3.2 : 2.4
        ..color = back ? color.withValues(alpha: color.a * 0.6) : color;

      if (back) {
        canvas.drawArc(rect, math.pi, math.pi, false, ring);
        continue;
      }

      final value = values[orbit.type];
      final labelColor = isActive ? highlight : textStyle.color;
      final label = TextPainter(
        text: TextSpan(
          text: value ?? '?',
          style: textStyle.copyWith(
            color: value == null ? color : labelColor,
            fontSize: value == null ? 9 : null,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final anchor = Offset(rect.center.dx, rect.bottom);
      final badgeRadius = value == null ? 6.5 : 0.0;
      final halfGap = (value == null ? badgeRadius : label.width / 2) + 4;
      final gap = math.asin(math.min(1.0, halfGap / (rect.width / 2)));

      final sweep = math.pi / 2 - gap;
      if (sweep > 0) {
        canvas.drawArc(rect, 0, sweep, false, ring);
        canvas.drawArc(rect, math.pi / 2 + gap, sweep, false, ring);
      }

      if (value == null) {
        canvas.drawCircle(
          anchor,
          badgeRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = color,
        );
      }
      label.paint(
          canvas, anchor - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.back != back ||
      old.active != active ||
      old.idle != idle ||
      old.highlight != highlight ||
      old.textStyle != textStyle ||
      !_sameValues(old.values, values);

  static bool _sameValues(
      Map<BodyMeasurement, String> a, Map<BodyMeasurement, String> b) {
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}
