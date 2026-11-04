import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/models/body_measurement.dart';
import 'package:dyplom/widgets/body_measurement_map.dart';

void main() {
  group('MeasurementOrbit.hit', () {
    test('picks the orbit under the point', () {
      expect(MeasurementOrbit.hit(const Offset(100, 132))?.type,
          BodyMeasurement.chest);
      expect(MeasurementOrbit.hit(const Offset(27, 100))?.type,
          BodyMeasurement.shoulders);
    });

    test('limbs are split into right (image left) and left sides', () {
      const pairs = {
        BodyMeasurement.bicepsRight: (Offset(43, 150), BodyMeasurement.bicepsLeft),
        BodyMeasurement.forearmRight: (Offset(39, 204), BodyMeasurement.forearmLeft),
        BodyMeasurement.thighRight: (Offset(78, 272), BodyMeasurement.thighLeft),
        BodyMeasurement.calfRight: (Offset(80, 366), BodyMeasurement.calfLeft),
      };
      for (final MapEntry(key: right, value: (point, left)) in pairs.entries) {
        expect(MeasurementOrbit.hit(point)?.type, right);
        expect(MeasurementOrbit.hit(Offset(200 - point.dx, point.dy))?.type,
            left);
      }
    });

    test('every measurement has exactly one orbit', () {
      expect(MeasurementOrbit.all.map((o) => o.type).toSet(),
          BodyMeasurement.values.toSet());
      expect(MeasurementOrbit.all.length, BodyMeasurement.values.length);
    });

    test('ignores points far from every orbit', () {
      expect(MeasurementOrbit.hit(const Offset(80, 440)), isNull);
      expect(MeasurementOrbit.hit(const Offset(100, 20)), isNull);
    });

    test('orbits do not overlap', () {
      final orbits = MeasurementOrbit.all;
      for (final a in orbits) {
        for (final b in orbits) {
          if (a == b) continue;
          expect(a.distanceTo(b.center), greaterThan(0),
              reason: '${a.type} contains ${b.type} center');
        }
      }
    });
  });

  testWidgets('tapping an orbit reports it', (tester) async {
    BodyMeasurement? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 200,
          height: 460,
          child: BodyMeasurementMap(
            values: const {BodyMeasurement.chest: '102.5'},
            onOrbitTap: (t) => tapped = t,
          ),
        ),
      ),
    ));
    final origin = tester.getTopLeft(find.byType(BodyMeasurementMap));
    await tester.tapAt(origin + const Offset(43, 150));
    expect(tapped, BodyMeasurement.bicepsRight);
  });
}
