import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/data_manager.dart';
import 'package:provider/provider.dart';
import '../models/workout_history.dart';
import '../models/workout_session.dart';

class FullCalendarScreen extends StatefulWidget {
  const FullCalendarScreen({super.key});

  @override
  State<FullCalendarScreen> createState() => _FullCalendarScreenState();
}

class _FullCalendarScreenState extends State<FullCalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.h4,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textPrimary,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: AppTextStyles.body1,
                weekendTextStyle: AppTextStyles.body1,
                selectedTextStyle: AppTextStyles.body1.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: AppTextStyles.body1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 6,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                final dataManager = Provider.of<DataManager>(context);
                final hasWorkout = dataManager.hasWorkoutOnDate(day);
                return hasWorkout ? [true] : [];
              },
            ),
          ),
          Expanded(
            child: _buildSelectedDayWorkouts(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayWorkouts() {
    final workouts = DataManager().getWorkoutHistoryForDate(_selectedDay);

    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts on this day',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: workouts.length,
      itemBuilder: (context, index) =>
          _WorkoutCardWidget(workout: workouts[index]),
    );
  }
}

class _WorkoutCardWidget extends StatefulWidget {
  final WorkoutHistory workout;

  const _WorkoutCardWidget({required this.workout});

  @override
  State<_WorkoutCardWidget> createState() => _WorkoutCardWidgetState();
}

class _WorkoutCardWidgetState extends State<_WorkoutCardWidget> {
  bool _isExpanded = false;

  Map<String, int> _getPreviousSessionReps() {
    final dataManager = DataManager();
    final allHistory = dataManager.workoutHistory;
    final currentDate = widget.workout.date;
    final workoutId = widget.workout.session.workoutId;

    WorkoutSession? previousSession;
    for (var i = allHistory.length - 1; i >= 0; i--) {
      final h = allHistory[i];
      if (h.session.workoutId == workoutId && h.date.isBefore(currentDate)) {
        previousSession = h.session;
        break;
      }
    }

    if (previousSession == null) return {};

    final result = <String, int>{};
    for (var exerciseResult in previousSession.exerciseResults) {
      final totalReps = exerciseResult.setResults.fold<int>(
        0,
        (sum, set) => sum + set.actualReps,
      );
      result[exerciseResult.exercise.id] = totalReps;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.workout.session;
    final duration = session.totalDurationSeconds;
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    final previousReps = _isExpanded ? _getPreviousSessionReps() : <String, int>{};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session.workoutName,
                    style: AppTextStyles.h4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Completed',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  durationText,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${session.exerciseResults.length} exercises',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                ),
              ],
            ),
            if (!_isExpanded && session.exerciseResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...session.exerciseResults.take(3).map((result) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${result.exercise.name}: ${result.setResults.length} sets',
                      style: AppTextStyles.body2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (session.exerciseResults.length > 3)
                Text(
                  '  +${session.exerciseResults.length - 3} more...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
            if (_isExpanded && session.exerciseResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ...session.exerciseResults.map((result) {
                final currentTotalReps = result.setResults.fold<int>(
                  0,
                  (sum, set) => sum + set.actualReps,
                );
                final prevReps = previousReps[result.exercise.id];
                final isRegression =
                    prevReps != null && currentTotalReps < prevReps;
                final cardColor = isRegression
                    ? Colors.orange.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.05);
                final borderColor = isRegression
                    ? Colors.orange.withValues(alpha: 0.5)
                    : AppColors.divider;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              result.exercise.name,
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isRegression ? Colors.orange[800] : null,
                              ),
                            ),
                          ),
                          if (isRegression)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_down,
                                      size: 12, color: Colors.orange[800]),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$currentTotalReps / $prevReps reps',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...result.setResults.map((set) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isRegression
                                      ? Colors.orange
                                      : AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${set.setNumber}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  '${set.actualReps} reps × ${set.weight.toStringAsFixed(1)} kg',
                                  style: AppTextStyles.body2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${set.durationSeconds}s',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
