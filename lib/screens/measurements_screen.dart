import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/body_measurement.dart';
import '../services/profile_service.dart';
import '../utils/units.dart';
import '../widgets/body_measurement_map.dart';

String bodyMeasurementLabel(AppLocalizations l10n, BodyMeasurement type) =>
    switch (type) {
      BodyMeasurement.shoulders => l10n.measurementShoulders,
      BodyMeasurement.chest => l10n.measurementChest,
      BodyMeasurement.bicepsRight => l10n.measurementBicepsRight,
      BodyMeasurement.bicepsLeft => l10n.measurementBicepsLeft,
      BodyMeasurement.forearmRight => l10n.measurementForearmRight,
      BodyMeasurement.forearmLeft => l10n.measurementForearmLeft,
      BodyMeasurement.thighRight => l10n.measurementThighRight,
      BodyMeasurement.thighLeft => l10n.measurementThighLeft,
      BodyMeasurement.calfRight => l10n.measurementCalfRight,
      BodyMeasurement.calfLeft => l10n.measurementCalfLeft,
    };

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  BodyMeasurement? _editing;

  Future<void> _edit(BodyMeasurement type) async {
    final profile = Provider.of<ProfileService>(context, listen: false);
    setState(() => _editing = type);
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MeasurementSheet(
        type: type,
        entry: profile.measurements[type],
      ),
    );
    if (!mounted) return;
    setState(() => _editing = null);
    if (result != null) await profile.setMeasurement(type, result.cm);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final units = Units.of(context);
    final measurements = Provider.of<ProfileService>(context).measurements;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurements, style: AppTextStyles.h4),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Text(
                l10n.measurementsHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: BodyMeasurementMap(
                    values: {
                      for (final e in measurements.entries)
                        e.key: units.circumferenceValue(e.value.cm),
                    },
                    active: _editing,
                    onOrbitTap: _edit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetResult {
  final double? cm;
  const _SheetResult(this.cm);
}

class _MeasurementSheet extends StatefulWidget {
  final BodyMeasurement type;
  final BodyMeasurementEntry? entry;

  const _MeasurementSheet({required this.type, this.entry});

  @override
  State<_MeasurementSheet> createState() => _MeasurementSheetState();
}

class _MeasurementSheetState extends State<_MeasurementSheet> {
  static const double _minCm = 5;
  static const double _maxCm = 250;

  late final Units _units;
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _units = Units.of(context, listen: false);
    _controller = TextEditingController(
      text: widget.entry == null
          ? ''
          : _units.circumferenceValue(widget.entry!.cm),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l10n) {
    final cm = _units.parseCircumference(_controller.text,
        originalCm: widget.entry?.cm);
    if (cm == null || cm < _minCm || cm > _maxCm) {
      setState(() => _error = l10n.measurementInvalid(
            _units.circumferenceValue(_minCm, decimals: 0),
            _units.circumferenceValue(_maxCm, decimals: 0),
          ));
      return;
    }
    Navigator.of(context).pop(_SheetResult(cm));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entry = widget.entry;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(bodyMeasurementLabel(l10n, widget.type),
                style: AppTextStyles.h3),
            if (entry != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.measurementUpdated(
                    DateFormat.yMMMd(locale).format(entry.date)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(l10n),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l10n.measurementCircumference,
                suffixText: _units.circumferenceLabel,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (entry != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(const _SheetResult(null)),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error),
                      child: Text(l10n.delete),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _save(l10n),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black),
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
