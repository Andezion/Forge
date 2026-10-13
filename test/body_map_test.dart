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

  Future<MuscleGroup?> tapAt(
      WidgetTester tester, BodyMapSide side, Offset point) async {
    MuscleGroup? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: BodyMapData.width,
          child: BodyMap(side: side, onMuscleTap: (g) => tapped = g),
        ),
      ),
    ));
    await tester.tapAt(point);
    return tapped;
  }

  testWidgets('tapping resolves the muscle under the finger', (tester) async {
    expect(await tapAt(tester, BodyMapSide.front, const Offset(80, 115)),
        MuscleGroup.chest);
    expect(await tapAt(tester, BodyMapSide.front, const Offset(120, 115)),
        MuscleGroup.chest);
    expect(await tapAt(tester, BodyMapSide.front, const Offset(90, 190)),
        MuscleGroup.core);
    expect(await tapAt(tester, BodyMapSide.back, const Offset(80, 250)),
        MuscleGroup.glutes);
    expect(await tapAt(tester, BodyMapSide.back, const Offset(80, 375)),
        MuscleGroup.calves);
    expect(await tapAt(tester, BodyMapSide.front, const Offset(100, 30)),
        isNull);
  });
}
