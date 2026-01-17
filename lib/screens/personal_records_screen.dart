import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/exercise.dart';
import '../services/data_manager.dart';
import '../services/profile_service.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Exercise? _selectedExercise;
  String _selectedFederation = 'IPF';

  final List<String> _federations = [
    'IPF',
    'WRPF',
    'GPA',
    'WPC',
    'IPA',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final profile = Provider.of<ProfileService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Personal Records',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          indicatorColor: AppColors.textOnPrimary,
          tabs: const [
            Tab(text: 'My Records'),
            Tab(text: 'World Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRecordsTab(dataManager),
          _buildWorldRecordsTab(profile),
        ],
      ),
    );
  }

  Widget _buildMyRecordsTab(DataManager dataManager) {
    final records = _getPersonalRecords(dataManager);
    final profile = Provider.of<ProfileService>(context, listen: false);
    final userWeight = profile.weightKg ?? 75.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseSelector(dataManager),
          const SizedBox(height: 24),
          if (_selectedExercise != null) ...[
            _buildRecordCard(
              records[_selectedExercise!.id],
              _selectedExercise!,
            ),
            const SizedBox(height: 16),
            _buildStrengthCoefficientCard(
                records[_selectedExercise!.id], userWeight),
            const SizedBox(height: 16),
            _buildProgressChart(_selectedExercise!, dataManager),
            const SizedBox(height: 16),
            _buildRecordHistory(_selectedExercise!, dataManager),
          ] else ...[
            _buildTotalStrengthCard(records, userWeight),
            const SizedBox(height: 24),
            _buildAllRecordsList(records, dataManager),
          ],
        ],
      ),
    );
  }

  Widget _buildWorldRecordsTab(ProfileService profile) {
    final userWeight = profile.weightKg ?? 75.0;
    final weightClass = _getWeightClass(userWeight);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFederationSelector(),
          const SizedBox(height: 16),
          _buildWeightClassInfo(userWeight, weightClass),
          const SizedBox(height: 24),
          Text('World Records', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _buildWorldRecordsList(weightClass),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(DataManager dataManager) {
    final exercises = _getSystemExercises(dataManager);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Exercise', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            DropdownButtonFormField<Exercise?>(
              value: _selectedExercise,
              decoration: InputDecoration(
                hintText: 'All Exercises',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<Exercise?>(
                  value: null,
                  child: Text('All Exercises'),
                ),
                ...exercises.map((ex) => DropdownMenuItem<Exercise?>(
                      value: ex,
                      child: Text(ex.name),
                    )),
              ],
              onChanged: (value) {
                setState(() => _selectedExercise = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(PersonalRecord? record, Exercise exercise) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: AppTextStyles.h2,
                  ),
                ),
                if (record?.isTheoretical ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Theoretical',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (record != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        '${record.weight.toStringAsFixed(1)} kg',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Reps', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        '${record.reps}',
                        style: AppTextStyles.h2,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(record.date),
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('1RM (estimated)', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        '${record.estimated1RM.toStringAsFixed(1)} kg',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No records yet',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordHistory(Exercise exercise, DataManager dataManager) {
    final history = _getRecordHistory(exercise, dataManager);

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record History', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            ...history.map((record) => _buildHistoryItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PersonalRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.weight.toStringAsFixed(1)} kg × ${record.reps}',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(record.date),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '1RM: ${record.estimated1RM.toStringAsFixed(1)} kg',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRecordsList(
    Map<String, PersonalRecord> records,
    DataManager dataManager,
  ) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No records yet',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete workouts to track your personal records',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Personal Records', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        ...records.entries.map((entry) {
          final exercise = _getExerciseById(entry.key, dataManager);
          if (exercise == null) return const SizedBox.shrink();
          return _buildRecordListItem(exercise, entry.value);
        }),
      ],
    );
  }

  Widget _buildRecordListItem(Exercise exercise, PersonalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Icon(Icons.fitness_center, color: AppColors.primary),
        ),
        title: Row(
          children: [
            Expanded(child: Text(exercise.name)),
            if (record.isTheoretical)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'T',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(_formatDate(record.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${record.weight.toStringAsFixed(1)} kg',
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${record.reps} reps',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        onTap: () {
          setState(() => _selectedExercise = exercise);
        },
      ),
    );
  }

  Widget _buildFederationSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Federation', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFederation,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _federations.map((fed) {
                return DropdownMenuItem<String>(
                  value: fed,
                  child: Text(fed),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFederation = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightClassInfo(double userWeight, String weightClass) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.monitor_weight, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Weight Class',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weightClass,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${userWeight.toStringAsFixed(1)} kg',
              style: AppTextStyles.h3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthCoefficientCard(
      PersonalRecord? record, double bodyWeight) {
    if (record == null) return const SizedBox.shrink();

    final wilks = _calculateWilksCoefficient(bodyWeight, record.estimated1RM);
    final dots = _calculateDotsCoefficient(bodyWeight, record.estimated1RM);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strength Coefficients', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCoefficientItem(
                    'Wilks',
                    wilks,
                    _getWilksRating(wilks),
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoefficientItem(
                    'Dots',
                    dots,
                    _getDotsRating(dots),
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These coefficients normalize your strength relative to body weight for fair comparison',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoefficientItem(
      String label, double value, String rating, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: AppTextStyles.h2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            rating,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStrengthCard(
      Map<String, PersonalRecord> records, double bodyWeight) {
    final bigThree = ['Squat', 'Bench Press', 'Deadlift'];
    double total = 0;
    int foundLifts = 0;

    for (final entry in records.entries) {
      final exercise = _getExerciseById(
          entry.key, Provider.of<DataManager>(context, listen: false));
      if (exercise != null && bigThree.contains(exercise.name)) {
        total += entry.value.estimated1RM;
        foundLifts++;
      }
    }

    if (foundLifts == 0) return const SizedBox.shrink();

    final wilks = _calculateWilksCoefficient(bodyWeight, total);
    final dots = _calculateDotsCoefficient(bodyWeight, total);

    return Card(
      elevation: 2,
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Strength', style: AppTextStyles.h3),
                      Text(
                        foundLifts == 3 ? 'Big 3 Total' : '$foundLifts/3 lifts',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Total', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      '${total.toStringAsFixed(1)} kg',
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Column(
                  children: [
                    Text('Wilks', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      wilks.toStringAsFixed(1),
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Column(
                  children: [
                    Text('Dots', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      dots.toStringAsFixed(1),
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(Exercise exercise, DataManager dataManager) {
    final history = _getRecordHistoryChronological(exercise, dataManager);

    if (history.length < 2) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress Over Time', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.divider,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: AppTextStyles.caption,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < history.length) {
                            final date = history[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: AppTextStyles.caption,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.estimated1RM,
                              ))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: AppColors.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldRecordsList(String weightClass) {
    final records = _getWorldRecords(weightClass, _selectedFederation);

    return Column(
      children: records.entries.map((entry) {
        return _buildWorldRecordCard(
          entry.key,
          entry.value,
        );
      }).toList(),
    );
  }

  Widget _buildWorldRecordCard(String exercise, Map<String, double> records) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(exercise, style: AppTextStyles.body1),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: records.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getWeightClassIcon(entry.key),
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)} kg',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, PersonalRecord> _getPersonalRecords(DataManager dataManager) {
    final records = <String, PersonalRecord>{};
    final completedWorkouts = dataManager.workoutHistory;

    for (final workout in completedWorkouts) {
      for (final exercise in workout.session.exerciseResults) {
        for (final set in exercise.setResults) {
          if (set.weight > 0 && set.actualReps > 0) {
            final exerciseId = exercise.exercise.id;
            final weight = set.weight;
            final reps = set.actualReps;
            final estimated1RM = _calculate1RM(weight, reps);

            if (!records.containsKey(exerciseId) ||
                estimated1RM > records[exerciseId]!.estimated1RM) {
              records[exerciseId] = PersonalRecord(
                weight: weight,
                reps: reps,
                date: workout.date,
                estimated1RM: estimated1RM,
                isTheoretical: reps > 1,
              );
            }
          }
        }
      }
    }

    return records;
  }

  List<PersonalRecord> _getRecordHistory(
    Exercise exercise,
    DataManager dataManager,
  ) {
    final history = <PersonalRecord>[];
    final completedWorkouts = dataManager.workoutHistory;

    for (final workout in completedWorkouts) {
      for (final ex in workout.session.exerciseResults) {
        if (ex.exercise.id == exercise.id) {
          for (final set in ex.setResults) {
            if (set.weight > 0 && set.actualReps > 0) {
              final weight = set.weight;
              final reps = set.actualReps;
              final estimated1RM = _calculate1RM(weight, reps);

              history.add(PersonalRecord(
                weight: weight,
                reps: reps,
                date: workout.date,
                estimated1RM: estimated1RM,
                isTheoretical: reps > 1,
              ));
            }
          }
        }
      }
    }

    history.sort((a, b) => b.estimated1RM.compareTo(a.estimated1RM));
    return history.take(10).toList();
  }

  List<Exercise> _getSystemExercises(DataManager dataManager) {
    return dataManager.exercises;
  }

  Exercise? _getExerciseById(String id, DataManager dataManager) {
    try {
      return dataManager.exercises.firstWhere((ex) => ex.id == id);
    } catch (e) {
      return null;
    }
  }

  double _calculate1RM(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  double _calculateWilksCoefficient(double bodyWeight, double totalLifted,
      {bool isMale = true}) {
    final double a, b, c, d, e, f;

    if (isMale) {
      a = -216.0475144;
      b = 16.2606339;
      c = -0.002388645;
      d = -0.00113732;
      e = 7.01863E-06;
      f = -1.291E-08;
    } else {
      a = 594.31747775582;
      b = -27.23842536447;
      c = 0.82112226871;
      d = -0.00930733913;
      e = 0.00004731582;
      f = -0.00000009054;
    }

    final x = bodyWeight;
    final denominator = a +
        b * x +
        c * x * x +
        d * x * x * x +
        e * x * x * x * x +
        f * x * x * x * x * x;

    return 500 / denominator * totalLifted;
  }

  double _calculateDotsCoefficient(double bodyWeight, double totalLifted,
      {bool isMale = true}) {
    final double a, b, c, d, e;

    if (isMale) {
      a = -0.0000010930;
      b = 0.0007391293;
      c = -0.1918759221;
      d = 24.0900756;
      e = -307.75076;
    } else {
      a = -0.0000010706;
      b = 0.0005158568;
      c = -0.1126655495;
      d = 13.6175032;
      e = -57.96288;
    }

    final bw = bodyWeight;
    final denominator = a * bw * bw * bw * bw * bw +
        b * bw * bw * bw * bw +
        c * bw * bw * bw +
        d * bw * bw +
        e * bw +
        1;

    return 500 / denominator * totalLifted;
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getWilksRating(double wilks) {
    if (wilks < 250) return 'Beginner';
    if (wilks < 350) return 'Intermediate';
    if (wilks < 450) return 'Advanced';
    if (wilks < 550) return 'Elite';
    return 'World Class';
  }

  String _getDotsRating(double dots) {
    if (dots < 300) return 'Beginner';
    if (dots < 400) return 'Intermediate';
    if (dots < 500) return 'Advanced';
    if (dots < 600) return 'Elite';
    return 'World Class';
  }

  List<PersonalRecord> _getRecordHistoryChronological(
    Exercise exercise,
    DataManager dataManager,
  ) {
    final history = <PersonalRecord>[];
    final completedWorkouts = dataManager.workoutHistory;

    for (final workout in completedWorkouts) {
      for (final ex in workout.session.exerciseResults) {
        if (ex.exercise.id == exercise.id) {
          for (final set in ex.setResults) {
            if (set.weight > 0 && set.actualReps > 0) {
              final weight = set.weight;
              final reps = set.actualReps;
              final estimated1RM = _calculate1RM(weight, reps);

              history.add(PersonalRecord(
                weight: weight,
                reps: reps,
                date: workout.date,
                estimated1RM: estimated1RM,
                isTheoretical: reps > 1,
              ));
            }
          }
        }
      }
    }

    history.sort((a, b) => a.date.compareTo(b.date));

    final monthlyBest = <String, PersonalRecord>{};
    for (final record in history) {
      final key = '${record.date.year}-${record.date.month}';
      if (!monthlyBest.containsKey(key) ||
          record.estimated1RM > monthlyBest[key]!.estimated1RM) {
        monthlyBest[key] = record;
      }
    }

    final result = monthlyBest.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _getWeightClass(double weight) {
    if (weight <= 59) return '-59 kg';
    if (weight <= 66) return '-66 kg';
    if (weight <= 74) return '-74 kg';
    if (weight <= 83) return '-83 kg';
    if (weight <= 93) return '-93 kg';
    if (weight <= 105) return '-105 kg';
    if (weight <= 120) return '-120 kg';
    return '+120 kg';
  }

  Map<String, Map<String, double>> _getWorldRecords(
    String weightClass,
    String federation,
  ) {
    // TODO: Replace with actual data from database/API
    // This is mock data for demonstration
    return {
      'Squat': {
        _getLowerWeightClass(weightClass): 280.0,
        weightClass: 310.0,
        _getHigherWeightClass(weightClass): 340.0,
      },
      'Bench Press': {
        _getLowerWeightClass(weightClass): 210.0,
        weightClass: 240.0,
        _getHigherWeightClass(weightClass): 270.0,
      },
      'Deadlift': {
        _getLowerWeightClass(weightClass): 320.0,
        weightClass: 360.0,
        _getHigherWeightClass(weightClass): 400.0,
      },
      'Total': {
        _getLowerWeightClass(weightClass): 810.0,
        weightClass: 910.0,
        _getHigherWeightClass(weightClass): 1010.0,
      },
    };
  }

  String _getLowerWeightClass(String current) {
    final classes = [
      '-59 kg',
      '-66 kg',
      '-74 kg',
      '-83 kg',
      '-93 kg',
      '-105 kg',
      '-120 kg',
      '+120 kg'
    ];
    final index = classes.indexOf(current);
    if (index <= 0) return classes[0];
    return classes[index - 1];
  }

  String _getHigherWeightClass(String current) {
    final classes = [
      '-59 kg',
      '-66 kg',
      '-74 kg',
      '-83 kg',
      '-93 kg',
      '-105 kg',
      '-120 kg',
      '+120 kg'
    ];
    final index = classes.indexOf(current);
    if (index >= classes.length - 1) return classes[classes.length - 1];
    return classes[index + 1];
  }

  IconData _getWeightClassIcon(String weightClass) {
    if (weightClass.contains('-')) {
      return Icons.arrow_downward;
    } else if (weightClass.contains('+')) {
      return Icons.arrow_upward;
    }
    return Icons.remove;
  }
}

class PersonalRecord {
  final double weight;
  final int reps;
  final DateTime date;
  final double estimated1RM;
  final bool isTheoretical;

  PersonalRecord({
    required this.weight,
    required this.reps,
    required this.date,
    required this.estimated1RM,
    required this.isTheoretical,
  });
}
