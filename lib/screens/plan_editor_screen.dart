import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/training_plan.dart';
import '../models/workout.dart';
import '../services/data_manager.dart';

class PlanEditorScreen extends StatefulWidget {
  final TrainingPlan? existingPlan;

  const PlanEditorScreen({super.key, this.existingPlan});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  final _nameController = TextEditingController();
  // dayOfWeek (1-7) -> list of scheduled workouts for that day
  final Map<int, List<ScheduledWorkout>> _daySchedule = {};

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.name;
      // Rebuild day map from schedule
      for (final sw in widget.existingPlan!.schedule) {
        for (final day in sw.daysOfWeek) {
          _daySchedule.putIfAbsent(day, () => []).add(sw);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addWorkoutToDay(int day) async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final workouts = dataManager.workouts;

    if (workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workouts available. Create one in Workshop first.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final result = await showDialog<_WorkoutFrequencyResult>(
      context: context,
      builder: (ctx) => _WorkoutPickerDialog(workouts: workouts),
    );

    if (result == null) return;

    setState(() {
      // Remove existing entry for same workoutId on this day (replace)
      _daySchedule[day]?.removeWhere((sw) => sw.workoutId == result.workout.id);

      // Check if this workout already exists in schedule (other days)
      final existing = _findExistingEntry(result.workout.id);
      if (existing != null) {
        // Add this day to the existing entry's daysOfWeek
        final updated = existing.copyWith(
          daysOfWeek: [...existing.daysOfWeek, day]..sort(),
          frequencyWeeks: result.frequencyWeeks,
          weekOffset: result.weekOffset,
        );
        _replaceEntry(existing, updated);
      } else {
        _daySchedule.putIfAbsent(day, () => []).add(
              ScheduledWorkout(
                workoutId: result.workout.id,
                workoutName: result.workout.name,
                daysOfWeek: [day],
                frequencyWeeks: result.frequencyWeeks,
                weekOffset: result.weekOffset,
              ),
            );
      }
    });
  }

  ScheduledWorkout? _findExistingEntry(String workoutId) {
    for (final entries in _daySchedule.values) {
      for (final sw in entries) {
        if (sw.workoutId == workoutId) return sw;
      }
    }
    return null;
  }

  void _replaceEntry(ScheduledWorkout old, ScheduledWorkout updated) {
    for (final day in _daySchedule.keys) {
      final list = _daySchedule[day]!;
      final idx = list.indexWhere((sw) => sw.workoutId == old.workoutId);
      if (idx != -1) {
        list[idx] = updated;
      }
    }
    // Ensure new days are populated
    for (final day in updated.daysOfWeek) {
      _daySchedule.putIfAbsent(day, () => []);
      if (!_daySchedule[day]!.any((sw) => sw.workoutId == updated.workoutId)) {
        _daySchedule[day]!.add(updated);
      }
    }
  }

  void _removeWorkoutFromDay(int day, ScheduledWorkout sw) {
    setState(() {
      final daysLeft = sw.daysOfWeek.where((d) => d != day).toList();
      if (daysLeft.isEmpty) {
        // Remove entirely
        for (final d in _daySchedule.keys) {
          _daySchedule[d]?.removeWhere((s) => s.workoutId == sw.workoutId);
        }
      } else {
        final updated = sw.copyWith(daysOfWeek: daysLeft);
        _replaceEntry(sw, updated);
        _daySchedule[day]?.removeWhere((s) => s.workoutId == sw.workoutId);
      }
    });
  }

  List<ScheduledWorkout> _buildFlatSchedule() {
    final seen = <String>{};
    final result = <ScheduledWorkout>[];
    for (final entries in _daySchedule.values) {
      for (final sw in entries) {
        if (seen.add(sw.workoutId)) {
          result.add(sw);
        }
      }
    }
    return result;
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a plan name')),
      );
      return;
    }

    final schedule = _buildFlatSchedule();
    final dataManager = Provider.of<DataManager>(context, listen: false);

    if (widget.existingPlan != null) {
      final updated = widget.existingPlan!.copyWith(
        name: name,
        schedule: schedule,
      );
      dataManager.updateTrainingPlan(updated);
    } else {
      final plan = TrainingPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        schedule: schedule,
      );
      dataManager.addTrainingPlan(plan);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingPlan != null
              ? AppStrings.editPlan
              : AppStrings.createPlan,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              AppStrings.save,
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppStrings.planName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Weekly schedule',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 7,
              itemBuilder: (ctx, i) {
                final day = i + 1; // 1=Mon...7=Sun
                final dayWorkouts = _daySchedule[day] ?? [];
                return _DayCard(
                  dayName: _dayNames[i],
                  dayIndex: day,
                  workouts: dayWorkouts,
                  onAdd: () => _addWorkoutToDay(day),
                  onRemove: (sw) => _removeWorkoutFromDay(day, sw),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String dayName;
  final int dayIndex;
  final List<ScheduledWorkout> workouts;
  final VoidCallback onAdd;
  final void Function(ScheduledWorkout) onRemove;

  const _DayCard({
    required this.dayName,
    required this.dayIndex,
    required this.workouts,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateTime.now().weekday == dayIndex;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      color: isToday
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (workouts.isEmpty)
                  Text(
                    AppStrings.noWorkoutToday,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                  onPressed: onAdd,
                  tooltip: AppStrings.addWorkoutToDay,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (workouts.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...workouts.map(
                (sw) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sw.workoutName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sw.frequencyWeeks == 1
                              ? AppStrings.everyWeek
                              : AppStrings.everyTwoWeeks,
                          style: TextStyle(
                              fontSize: 10, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onRemove(sw),
                        child: Icon(Icons.close,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutFrequencyResult {
  final Workout workout;
  final int frequencyWeeks;
  final int weekOffset;

  _WorkoutFrequencyResult({
    required this.workout,
    required this.frequencyWeeks,
    required this.weekOffset,
  });
}

class _WorkoutPickerDialog extends StatefulWidget {
  final List<Workout> workouts;

  const _WorkoutPickerDialog({required this.workouts});

  @override
  State<_WorkoutPickerDialog> createState() => _WorkoutPickerDialogState();
}

class _WorkoutPickerDialogState extends State<_WorkoutPickerDialog> {
  Workout? _selected;
  int _frequencyWeeks = 1;
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select workout'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.workouts.length,
                itemBuilder: (ctx, i) {
                  final w = widget.workouts[i];
                  return RadioListTile<Workout>(
                    title: Text(w.name,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '${w.exercises.length} exercises',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: w,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                    dense: true,
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
            const Divider(),
            Text(AppStrings.frequency,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: _frequencyWeeks,
              isExpanded: true,
              onChanged: (v) => setState(() => _frequencyWeeks = v!),
              items: const [
                DropdownMenuItem(value: 1, child: Text(AppStrings.everyWeek)),
                DropdownMenuItem(
                    value: 2, child: Text(AppStrings.everyTwoWeeks)),
              ],
            ),
            if (_frequencyWeeks == 2) ...[
              const SizedBox(height: 8),
              Text('Starting week:', style: const TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _weekOffset,
                isExpanded: true,
                onChanged: (v) => setState(() => _weekOffset = v!),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Week A (this week)')),
                  DropdownMenuItem(value: 1, child: Text('Week B (next week)')),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(
                    _WorkoutFrequencyResult(
                      workout: _selected!,
                      frequencyWeeks: _frequencyWeeks,
                      weekOffset: _weekOffset,
                    ),
                  ),
          child: Text(AppStrings.add,
              style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
}
