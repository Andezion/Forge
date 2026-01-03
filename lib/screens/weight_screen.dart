import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/profile_service.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final int _minKg = 30;
  final int _maxKg = 200;
  late int _selectedKg;
  late int _selectedGramsIndex;
  final List<int> _gramsList = List<int>.generate(100, (i) => i * 10);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileService>(context, listen: false);
    final current = profile.weightKg ?? 75.0;
    _selectedKg = current.floor();
    final grams = ((current - _selectedKg) * 1000).round();
    final g = (grams / 10).round();
    _selectedGramsIndex = g.clamp(0, _gramsList.length - 1);
  }

  double _composeWeight() {
    final grams = _gramsList[_selectedGramsIndex];
    return _selectedKg + grams / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Weight', style: AppTextStyles.h4),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text('Specify your current weight', style: AppTextStyles.h3),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                        initialItem: (_selectedKg - _minKg)),
                    childCount: _maxKg - _minKg + 1,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedKg = _minKg + i),
                    itemBuilder: (context, index) {
                      final kg = _minKg + index;
                      return Center(
                          child: Text('$kg kg', style: AppTextStyles.body1));
                    },
                  ),
                ),
                Container(width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: CupertinoPicker.builder(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedGramsIndex),
                    childCount: _gramsList.length,
                    onSelectedItemChanged: (i) =>
                        setState(() => _selectedGramsIndex = i),
                    itemBuilder: (context, index) {
                      final g = _gramsList[index];
                      return Center(
                          child: Text('$g g', style: AppTextStyles.body1));
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
                          _selectedKg = 75;
                          _selectedGramsIndex = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final weight = _composeWeight();
                        await profile.setWeightKg(weight);
                        if (mounted) Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black),
                      child: const Text('Save'),
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
