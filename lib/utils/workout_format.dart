import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'units.dart';

String formatSetsRepsWeight(
  AppLocalizations l10n,
  Units units, {
  required int sets,
  required int reps,
  required double weightKg,
}) {
  final base = '${l10n.setsCount(sets)} × ${l10n.repsCount(reps)}';
  return weightKg > 0 ? '$base @ ${units.weight(weightKg)}' : base;
}
