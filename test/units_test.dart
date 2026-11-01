import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/models/app_settings.dart';
import 'package:dyplom/utils/units.dart';

void main() {
  const kg = Units();
  const lb = Units(weightUnit: WeightUnit.lb);
  const imperial = Units(lengthUnit: DistanceUnit.feet);

  group('weight', () {
    test('kg is shown as stored', () {
      expect(kg.weight(82.5), '82.5 kg');
      expect(kg.weight(100), '100 kg');
      expect(kg.parseWeight('82,5'), 82.5);
    });

    test('lb converts for display and back to kg for storage', () {
      expect(lb.weight(100), '220.5 lb');
      expect(lb.weightValue(60), '132.3');
      expect(lb.parseWeight('225')!, closeTo(102.06, 0.01));
    });

    test('unchanged prefilled value keeps the exact kg (no round-trip drift)', () {
      final shown = lb.weightValue(60);
      expect(lb.parseWeight(shown, originalKg: 60), 60);
      expect(lb.parseWeight('135', originalKg: 60), closeTo(61.23, 0.01));
    });

    test('invalid input returns null', () {
      expect(lb.parseWeight(''), isNull);
      expect(lb.parseWeight('abc'), isNull);
    });

    test('delta keeps sign', () {
      expect(kg.weightDelta(2.5), '+2.5 kg');
      expect(kg.weightDelta(-1), '-1 kg');
    });
  });

  group('height', () {
    test('cm and ft/in', () {
      expect(kg.height(180), '180 cm');
      expect(imperial.height(180), '5\'11"');
      expect(Units.cmToFeetInches(152.4), (5, 0));
      expect(Units.feetInchesToCm(5, 11), closeTo(180.34, 0.01));
    });
  });

  test('number trims trailing zeros', () {
    expect(Units.number(60.0), '60');
    expect(Units.number(60.25, decimals: 2), '60.25');
    expect(Units.number(-0.04), '0');
  });
}
