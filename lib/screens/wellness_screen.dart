import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wellness_service.dart';
import '../models/wellness_entry.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_colors.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final List<String> _questions = [
    'Energy',
    'Mood',
    'Tiredness',
    'Stress',
    'Muscle soreness',
  ];

  late Map<String, int> _values;

  @override
  void initState() {
    super.initState();
    _values = {for (var q in _questions) q: 3};
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m}m';
    }
    final m = d.inMinutes;
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<WellnessService>(context);
    final canSubmit = service.canSubmit();
    final timeUntil = service.timeUntilNext();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('How do you feel?', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (var q in _questions) ...[
                    Text(q, style: AppTextStyles.body1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _values[q]!.toDouble(),
                            min: 0,
                            max: 5,
                            divisions: 5,
                            label: _values[q].toString(),
                            activeColor: AppColors.primary,
                            onChanged: (v) {
                              setState(() {
                                _values[q] = v.round();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              _values[q]!.toString(),
                              style: AppTextStyles.h4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: canSubmit
                        ? () async {
                            final entry = WellnessEntry(
                              timestamp: DateTime.now(),
                              answers: Map.from(_values),
                            );
                            await service.addEntry(entry);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved')),
                            );
                            setState(() {});
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(canSubmit ? 'Submit' : 'Submit (locked)',
                        style: AppTextStyles.button),
                  ),
                  if (!canSubmit) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Next entry in ${_formatDuration(timeUntil)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Recent entries', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  for (var e in service.entries.take(7))
                    Card(
                      child: ListTile(
                        title: Text(
                            e.timestamp.toLocal().toString().split('.')[0]),
                        subtitle: Text(
                            'Avg: ${e.averageScore.toStringAsFixed(1)} — ${e.answers.values.join(', ')}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
