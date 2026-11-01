import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/profile_service.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';
import '../utils/units.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  static const double _minKg = 30;
  static const double _maxKg = 200;
  static const double _defaultKg = 75;

  late final Units _units;
  late final int _minWhole;
  late final int _maxWhole;
  late int _selectedWhole;
  late int _selectedTenths;
  double? _initialKg;
  late final int _initialWhole;
  late final int _initialTenths;

  @override
  void initState() {
    super.initState();
    _units = Units.of(context, listen: false);
    _minWhole = _units.toDisplayWeight(_minKg).floor();
    _maxWhole = _units.toDisplayWeight(_maxKg).ceil();

    final profile = Provider.of<ProfileService>(context, listen: false);
    _initialKg = profile.weightKg;
    _setFromKg(_initialKg ?? _defaultKg);
    _initialWhole = _selectedWhole;
    _initialTenths = _selectedTenths;
  }

  void _setFromKg(double kg) {
    final tenthsTotal = (_units.toDisplayWeight(kg) * 10).round();
    _selectedWhole = (tenthsTotal ~/ 10).clamp(_minWhole, _maxWhole);
    _selectedTenths = tenthsTotal % 10;
  }

  double _composeWeightKg() {
    if (_initialKg != null &&
        _selectedWhole == _initialWhole &&
        _selectedTenths == _initialTenths) {
      return _initialKg!;
    }
    return _units.toKg(_selectedWhole + _selectedTenths / 10.0);
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weight, style: AppTextStyles.h4),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(l10n.specifyWeight, style: AppTextStyles.h3),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                        initialItem: (_selectedWhole - _minWhole)),
                    childCount: _maxWhole - _minWhole + 1,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedWhole = _minWhole + i),
                    itemBuilder: (context, index) {
                      final value = _minWhole + index;
                      return Center(
                          child: Text('$value ${_units.weightLabel}',
                              style: AppTextStyles.body1));
                    },
                  ),
                ),
                Container(width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedTenths),
                    childCount: 10,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedTenths = i),
                    itemBuilder: (context, index) {
                      return Center(
                          child: Text('.$index', style: AppTextStyles.body1));
                    },
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          _initialKg = null;
                          _setFromKg(_defaultKg);
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black),
                      child: Text(l10n.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final weight = _composeWeightKg();
                        await profile.setWeightKg(weight);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
