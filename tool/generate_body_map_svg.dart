import 'dart:io';

import 'package:dyplom/models/exercise.dart';
import 'package:dyplom/widgets/body_map/body_map_data.dart';

const _gap = 40.0;
const _outline = '#2B2B2B';
const _skin = '#ECECEC';
const _muscle = '#D9D9D9';

void main(List<String> args) {
  final out = args.isNotEmpty ? args.first : 'assets/images/body_map.svg';
  const w = BodyMapData.width;
  const h = BodyMapData.height;
  final buffer = StringBuffer()
    ..writeln('<svg xmlns="http://www.w3.org/2000/svg" '
        'width="${w * 2 + _gap}" height="$h" viewBox="0 0 ${w * 2 + _gap} $h">')
    ..writeln('<style>.m{fill:$_muscle;stroke:$_outline;stroke-width:1;'
        'stroke-linejoin:round}.d{fill:none;stroke:$_outline;stroke-width:0.8;'
        'stroke-linecap:round}</style>');

  _figure(buffer, 'front', 0, BodyMapData.front, BodyMapData.frontDetails);
  _figure(buffer, 'back', w + _gap, BodyMapData.back, BodyMapData.backDetails);

  buffer.writeln('</svg>');
  File(out).writeAsStringSync(buffer.toString());
  stdout.writeln('Wrote $out');
}

void _figure(StringBuffer buffer, String id, double dx,
    List<BodyMapRegion> regions, List<String> details) {
  buffer.writeln('<g id="$id" transform="translate($dx 0)">');
  _mirrored(buffer, '<path d="${BodyMapData.silhouette}" fill="$_skin"/>');
  _mirrored(
      buffer,
      '<path d="${BodyMapData.silhouetteOutline}" fill="none" '
      'stroke="$_outline" stroke-width="1.6" stroke-linejoin="round"/>');

  for (final group in MuscleGroup.values) {
    final shapes = regions.where((r) => r.group == group).toList();
    if (shapes.isEmpty) continue;
    buffer.writeln('<g id="$id-${group.name}" class="m">');
    for (final region in shapes) {
      final path = '<path d="${region.path}"/>';
      region.mirrored ? _mirrored(buffer, path) : buffer.writeln(path);
    }
    buffer.writeln('</g>');
  }

  buffer.writeln('<g class="d">');
  for (final detail in details) {
    _mirrored(buffer, '<path d="$detail"/>');
  }
  buffer
    ..writeln('</g>')
    ..writeln('</g>');
}

void _mirrored(StringBuffer buffer, String element) {
  buffer
    ..writeln(element)
    ..writeln('<g transform="matrix(-1 0 0 1 ${BodyMapData.width} 0)">'
        '$element</g>');
}
