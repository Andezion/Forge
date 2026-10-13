import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import 'body_map_data.dart';

enum BodyMapSide { front, back }

class BodyMap extends StatelessWidget {
  final BodyMapSide side;
  final Map<MuscleGroup, Color> fills;

  final BodyMapRegion? selected;

  final ValueChanged<BodyMapRegion>? onMuscleTap;

  const BodyMap({
    super.key,
    required this.side,
    this.fills = const {},
    this.selected,
    this.onMuscleTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shapes = _BodyMapShapes.of(side);

    return AspectRatio(
      aspectRatio: BodyMapData.width / BodyMapData.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / BodyMapData.width;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onMuscleTap == null
                ? null
                : (details) {
                    final region =
                        shapes.regionAt(details.localPosition / scale);
                    if (region != null) onMuscleTap!(region);
                  },
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _BodyMapPainter(
                shapes: shapes,
                fills: fills,
                selected: selected,
                skin: scheme.surfaceContainerHighest,
                muscle: scheme.outlineVariant,
                outline: scheme.onSurface.withValues(alpha: 0.85),
                highlight: scheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BodyMapShapes {
  final Path silhouette;
  final Path outline;
  final List<(BodyMapRegion, Path)> regions;
  final Path details;

  _BodyMapShapes._(this.silhouette, this.outline, this.regions, this.details);

  static final Map<BodyMapSide, _BodyMapShapes> _cache = {};

  static _BodyMapShapes of(BodyMapSide side) =>
      _cache.putIfAbsent(side, () => _build(side));

  static _BodyMapShapes _build(BodyMapSide side) {
    final isFront = side == BodyMapSide.front;
    final regions = isFront ? BodyMapData.front : BodyMapData.back;
    final details = Path();
    for (final d in isFront ? BodyMapData.frontDetails : BodyMapData.backDetails) {
      details.addPath(_mirrored(parseSvgPath(d)), Offset.zero);
    }
    return _BodyMapShapes._(
      _mirrored(parseSvgPath(BodyMapData.silhouette)),
      _mirrored(parseSvgPath(BodyMapData.silhouetteOutline)),
      [
        for (final region in regions)
          (
            region,
            region.mirrored
                ? _mirrored(parseSvgPath(region.path))
                : parseSvgPath(region.path),
          ),
      ],
      details,
    );
  }

  static final Float64List _mirror = Float64List.fromList([
    -1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    BodyMapData.width, 0, 0, 1,
  ]);

  static Path _mirrored(Path half) =>
      Path.from(half)..addPath(half.transform(_mirror), Offset.zero);

  BodyMapRegion? regionAt(Offset point) {
    for (final (region, path) in regions.reversed) {
      if (path.contains(point)) return region.group == null ? null : region;
    }
    return null;
  }
}

class _BodyMapPainter extends CustomPainter {
  final _BodyMapShapes shapes;
  final Map<MuscleGroup, Color> fills;
  final BodyMapRegion? selected;
  final Color skin;
  final Color muscle;
  final Color outline;
  final Color highlight;

  _BodyMapPainter({
    required this.shapes,
    required this.fills,
    required this.selected,
    required this.skin,
    required this.muscle,
    required this.outline,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / BodyMapData.width);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = outline;

    canvas.drawPath(shapes.silhouette, Paint()..color = skin);

    for (final (region, path) in shapes.regions) {
      canvas.drawPath(path, Paint()..color = fills[region.group] ?? muscle);
      canvas.drawPath(path, stroke..strokeWidth = 0.7);
    }

    canvas.drawPath(shapes.details, stroke..strokeWidth = 0.6);
    canvas.drawPath(shapes.outline, stroke..strokeWidth = 1.4);

    if (selected != null) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..color = highlight;
      for (final (region, path) in shapes.regions) {
        if (region.group == selected!.group) {
          canvas.drawPath(path, ring..strokeWidth = 1.2);
        }
      }
      for (final (region, path) in shapes.regions) {
        if (region.name == selected!.name) {
          canvas.drawPath(path, ring..strokeWidth = 2.4);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BodyMapPainter old) =>
      old.shapes != shapes ||
      old.selected != selected ||
      old.skin != skin ||
      old.muscle != muscle ||
      old.outline != outline ||
      old.highlight != highlight ||
      !_sameFills(old.fills, fills);

  static bool _sameFills(Map<MuscleGroup, Color> a, Map<MuscleGroup, Color> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

@visibleForTesting
Path parseSvgPath(String data) {
  final tokens = RegExp(r'[MLCQZ]|-?\d*\.?\d+')
      .allMatches(data)
      .map((m) => m.group(0)!)
      .toList();
  final path = Path();
  var i = 0;
  var command = '';

  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    if (RegExp(r'^[MLCQZ]$').hasMatch(tokens[i])) {
      command = tokens[i++];
      if (command == 'Z') {
        path.close();
        continue;
      }
    }
    switch (command) {
      case 'M':
        path.moveTo(next(), next());
        command = 'L';
      case 'L':
        path.lineTo(next(), next());
      case 'C':
        path.cubicTo(next(), next(), next(), next(), next(), next());
      case 'Q':
        path.quadraticBezierTo(next(), next(), next(), next());
      default:
        throw FormatException('Unsupported path data', data, i);
    }
  }
  return path;
}
