import 'package:dyplom/models/exercise.dart';
import 'package:dyplom/widgets/body_map/body_map.dart';
import 'package:dyplom/widgets/body_map/body_map_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every body map path parses', () {
    final paths = [
      BodyMapData.silhouette,
      BodyMapData.silhouetteOutline,
      ...BodyMapData.frontDetails,
      ...BodyMapData.backDetails,
      for (final region in [...BodyMapData.front, ...BodyMapData.back])
        region.path,
    ];
    for (final data in paths) {
      final bounds = parseSvgPath(data).getBounds();
      expect(bounds.width + bounds.height, greaterThan(0), reason: data);
    }
  });

  test('every trackable muscle group is drawn', () {
    final expected = MuscleGroup.values.toSet()..remove(MuscleGroup.cardio);
    expect(BodyMapData.drawnGroups, expected);
  });

  test('muscles stay inside the silhouette half', () {
    final body = parseSvgPath(BodyMapData.silhouette).getBounds().inflate(1);
    for (final region in [...BodyMapData.front, ...BodyMapData.back]) {
      final bounds = parseSvgPath(region.path).getBounds();
      expect(body.contains(bounds.topLeft) && body.contains(bounds.bottomRight),
          isTrue,
          reason: region.name);
    }
  });

  Future<BodyMapRegion?> tapAt(
      WidgetTester tester, BodyMapSide side, Offset point) async {
    BodyMapRegion? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: BodyMapData.width,
          child: BodyMap(side: side, onMuscleTap: (m) => tapped = m),
        ),
      ),
    ));
    await tester.tapAt(point);
    return tapped;
  }

  testWidgets('tapping resolves the muscle under the finger', (tester) async {
    final cases = {
      (BodyMapSide.front, const Offset(80, 125)):
          ('Pectoralis major (sternal head)', MuscleGroup.chest),
      (BodyMapSide.front, const Offset(120, 125)):
          ('Pectoralis major (sternal head)', MuscleGroup.chest),
      (BodyMapSide.front, const Offset(90, 185)):
          ('Rectus abdominis', MuscleGroup.core),
      (BodyMapSide.front, const Offset(64, 285)):
          ('Vastus lateralis', MuscleGroup.legs),
      (BodyMapSide.front, const Offset(66, 245)):
          ('Tensor fasciae latae', MuscleGroup.glutes),
      (BodyMapSide.back, const Offset(80, 265)):
          ('Gluteus maximus', MuscleGroup.glutes),
      (BodyMapSide.back, const Offset(74, 365)):
          ('Gastrocnemius (lateral head)', MuscleGroup.calves),
      (BodyMapSide.back, const Offset(36, 160)):
          ('Triceps brachii (lateral head)', MuscleGroup.triceps),
    };
    for (final MapEntry(key: (side, point), value: (name, group))
        in cases.entries) {
      final muscle = await tapAt(tester, side, point);
      expect(muscle?.name, name, reason: '$side $point');
      expect(muscle?.group, group);
    }

    expect(await tapAt(tester, BodyMapSide.front, const Offset(100, 30)),
        isNull);
    expect(await tapAt(tester, BodyMapSide.front, const Offset(94, 78)),
        isNull);
  });
}
