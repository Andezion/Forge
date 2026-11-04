import 'package:flutter/widgets.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class Units {
  static const double lbPerKg = 2.20462;
  static const double cmPerInch = 2.54;

  final WeightUnit weightUnit;
  final DistanceUnit lengthUnit;
  final String kgLabel;
  final String lbLabel;
  final String cmLabel;
  final String inLabel;

  const Units({
    this.weightUnit = WeightUnit.kg,
    this.lengthUnit = DistanceUnit.meters,
    this.kgLabel = 'kg',
    this.lbLabel = 'lb',
    this.cmLabel = 'cm',
    this.inLabel = 'in',
  });

  static Units _current = const Units();

  static Units get current => _current;

  static void setCurrent(WeightUnit weightUnit, DistanceUnit lengthUnit) {
    final l10n = L10n.current;
    _current = Units(
      weightUnit: weightUnit,
      lengthUnit: lengthUnit,
      kgLabel: l10n.unitKg,
      lbLabel: l10n.unitLb,
      cmLabel: l10n.unitCm,
      inLabel: l10n.unitIn,
    );
  }

  factory Units.of(BuildContext context, {bool listen = true}) {
    final settings = Provider.of<SettingsService>(context, listen: listen);
    final l10n = listen ? AppLocalizations.of(context) : L10n.current;
    return Units(
      weightUnit: settings.weightUnit,
      lengthUnit: settings.distanceUnit,
      kgLabel: l10n?.unitKg ?? 'kg',
      lbLabel: l10n?.unitLb ?? 'lb',
      cmLabel: l10n?.unitCm ?? 'cm',
      inLabel: l10n?.unitIn ?? 'in',
    );
  }

  bool get isLb => weightUnit == WeightUnit.lb;
  bool get isImperialLength => lengthUnit == DistanceUnit.feet;

  String get weightLabel => isLb ? lbLabel : kgLabel;

  double toDisplayWeight(double kg) => isLb ? kg * lbPerKg : kg;

  double toKg(double displayed) => isLb ? displayed / lbPerKg : displayed;

  static String number(double value, {int decimals = 1}) {
    final fixed = value.toStringAsFixed(decimals);
    if (!fixed.contains('.')) return fixed;
    final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
    return trimmed == '-0' ? '0' : trimmed;
  }

  String weightValue(double kg, {int decimals = 1}) =>
      number(toDisplayWeight(kg), decimals: decimals);

  String weight(double kg, {int decimals = 1}) =>
      '${weightValue(kg, decimals: decimals)} $weightLabel';

  String weightDelta(double kg, {int decimals = 1}) =>
      '${kg >= 0 ? '+' : ''}${weight(kg, decimals: decimals)}';

  double? parseWeight(String text, {double? originalKg}) {
    final trimmed = text.trim();
    if (originalKg != null && trimmed == weightValue(originalKg)) {
      return originalKg;
    }
    final value = double.tryParse(trimmed.replaceAll(',', '.'));
    return value == null ? null : toKg(value);
  }

  String height(double cm) {
    if (!isImperialLength) return '${cm.round()} $cmLabel';
    final (feet, inches) = cmToFeetInches(cm);
    return '$feet\'$inches"';
  }

  String get circumferenceLabel => isImperialLength ? inLabel : cmLabel;

  double toDisplayLength(double cm) => isImperialLength ? cm / cmPerInch : cm;

  double toCm(double displayed) =>
      isImperialLength ? displayed * cmPerInch : displayed;

  String circumferenceValue(double cm, {int decimals = 1}) =>
      number(toDisplayLength(cm), decimals: decimals);

  double? parseCircumference(String text, {double? originalCm}) {
    final trimmed = text.trim();
    if (originalCm != null && trimmed == circumferenceValue(originalCm)) {
      return originalCm;
    }
    final value = double.tryParse(trimmed.replaceAll(',', '.'));
    return value == null ? null : toCm(value);
  }

  static (int, int) cmToFeetInches(double cm) {
    final totalInches = (cm / cmPerInch).round();
    return (totalInches ~/ 12, totalInches % 12);
  }

  static double feetInchesToCm(int feet, int inches) =>
      (feet * 12 + inches) * cmPerInch;
}
