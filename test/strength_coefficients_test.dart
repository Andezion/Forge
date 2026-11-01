import 'package:flutter_test/flutter_test.dart';
import 'package:dyplom/utils/strength_coefficients.dart';

void main() {
  group('DOTS', () {
    test('male 100 kg bodyweight, 700 kg total', () {
      expect(StrengthCoefficients.dots(100, 700), closeTo(430.9, 0.1));
    });

    test('female 60 kg bodyweight, 400 kg total', () {
      expect(StrengthCoefficients.dots(60, 400, isMale: false),
          closeTo(443.4, 0.1));
    });

    test('invalid input returns 0', () {
      expect(StrengthCoefficients.dots(0, 500), 0);
      expect(StrengthCoefficients.dots(80, 0), 0);
    });
  });

  group('Wilks', () {
    test('male 100 kg bodyweight, 700 kg total', () {
      expect(StrengthCoefficients.wilks(100, 700), closeTo(426.0, 0.1));
    });

    test('female 60 kg bodyweight, 400 kg total', () {
      expect(StrengthCoefficients.wilks(60, 400, isMale: false),
          closeTo(445.95, 0.1));
    });
  });
}
