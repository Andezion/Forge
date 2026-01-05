import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/chart_data.dart';
import '../models/exercise.dart';
import '../services/progress_analytics_service.dart';
import '../services/data_manager.dart';
import '../services/profile_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ProgressChartsScreen extends StatefulWidget {
  const ProgressChartsScreen({super.key});

  @override
  State<ProgressChartsScreen> createState() => _ProgressChartsScreenState();
}

class _ProgressChartsScreenState extends State<ProgressChartsScreen> {
  final _analyticsService = ProgressAnalyticsService();
  final _dataManager = DataManager();
  final _profileService = ProfileService();

  bool _isLoading = true;
  String _selectedTab = 'overall';

  OverallStrengthData? _overallStrengthData;
  BodyWeightData? _bodyWeightData;
  WorkoutVolumeData? _volumeData;
  WorkoutFrequencyData? _frequencyData;
  ConsistencyData? _consistencyData;

  Exercise? _selectedExercise;
  List<Exercise> _availableExercises = [];
  ExerciseProgressData? _exerciseProgressData;

  int _lookbackDays = 90;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _dataManager.initialize();
      await _profileService.load();
      final histories = _dataManager.workoutHistory;

      if (histories.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No data available for analysis. Complete at least one workout!'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final exerciseMap = <String, Exercise>{};
      for (var history in histories) {
        for (var result in history.session.exerciseResults) {
          exerciseMap[result.exercise.id] = result.exercise;
        }
      }
      _availableExercises = exerciseMap.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      _overallStrengthData = _analyticsService.analyzeOverallStrength(
        histories,
        lookbackDays: _lookbackDays,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      _bodyWeightData = _analyticsService.analyzeBodyWeight(
        histories,
        _profileService.weightKg ?? 70.0,
        lookbackDays: _lookbackDays,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      _volumeData = _analyticsService.analyzeWorkoutVolume(
        histories,
        lookbackDays: _lookbackDays,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      _frequencyData = _analyticsService.analyzeWorkoutFrequency(
        histories,
        lookbackDays: _lookbackDays,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      _consistencyData = _analyticsService.analyzeConsistency(
        histories,
        lookbackDays: _lookbackDays,
      );

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      print('Error loading progress data: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadExerciseData(Exercise exercise) async {
    setState(() {
      _selectedExercise = exercise;
      _isLoading = true;
    });

    try {
      final histories = _dataManager.workoutHistory;

      _exerciseProgressData = _analyticsService.analyzeExerciseProgress(
        exercise.id,
        exercise.name,
        histories,
        lookbackDays: _lookbackDays,
      );

      setState(() {
        _isLoading = false;
        _selectedTab = 'exercise';
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercise data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progress Charts'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (days) {
              setState(() => _lookbackDays = days);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 30, child: Text('30 days')),
              const PopupMenuItem(value: 90, child: Text('90 days')),
              const PopupMenuItem(value: 180, child: Text('180 days')),
              const PopupMenuItem(value: 365, child: Text('1 year')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading data...',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : _availableExercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No data available for display',
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Complete at least one workout to see progress charts',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildTabBar(),
                    Expanded(child: _buildContent()),
                  ],
                ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton('overall', 'Overall Strength', Icons.trending_up),
            _buildTabButton('body', 'Body Weight', Icons.monitor_weight),
            _buildTabButton('volume', 'Volume', Icons.fitness_center),
            _buildTabButton('frequency', 'Frequency', Icons.calendar_month),
            _buildTabButton('consistency', 'Consistency', Icons.check_circle),
            _buildTabButton('exercise', 'Exercises', Icons.list),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'overall':
        return _buildOverallStrengthView();
      case 'body':
        return _buildBodyWeightView();
      case 'volume':
        return _buildVolumeView();
      case 'frequency':
        return _buildFrequencyView();
      case 'consistency':
        return _buildConsistencyView();
      case 'exercise':
        return _buildExerciseView();
      default:
        return const Center(child: Text('Select a tab'));
    }
  }

  Widget _buildOverallStrengthView() {
    if (_overallStrengthData == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          'Current Overall Strength',
          '${_overallStrengthData!.currentTotalStrength.toStringAsFixed(1)} kg',
          _overallStrengthData!.progressPercentage,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Overall Strength Progress',
          _buildLineChart(
            _overallStrengthData!.totalStrengthData,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Average Strength per Exercise',
          _buildLineChart(
            _overallStrengthData!.averageStrengthData,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 16),
        _buildContributionsCard(),
      ],
    );
  }

  Widget _buildBodyWeightView() {
    if (_bodyWeightData == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          'Current Weight',
          '${_bodyWeightData!.currentWeight.toStringAsFixed(1)} kg',
          (_bodyWeightData!.weightChange / _bodyWeightData!.startWeight) * 100,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Information', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                _buildInfoRow('Starting Weight',
                    '${_bodyWeightData!.startWeight.toStringAsFixed(1)} kg'),
                _buildInfoRow('Change',
                    '${_bodyWeightData!.weightChange >= 0 ? '+' : ''}${_bodyWeightData!.weightChange.toStringAsFixed(1)} kg'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tip: For complete weight tracking, use the "Weight" feature in the main menu',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeView() {
    if (_volumeData == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          'Current Week Volume',
          '${_volumeData!.currentWeekVolume.toStringAsFixed(0)} kg',
          _volumeData!.previousWeekVolume > 0
              ? ((_volumeData!.currentWeekVolume -
                          _volumeData!.previousWeekVolume) /
                      _volumeData!.previousWeekVolume) *
                  100
              : 0,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Weekly Volume',
          _buildBarChart(_volumeData!.weeklyVolumeData),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Daily Volume',
          _buildLineChart(
            _volumeData!.dailyVolumeData,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyView() {
    if (_frequencyData == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniStatsCard(
                'Workouts/Week',
                _frequencyData!.currentWeekFrequency.toStringAsFixed(1),
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatsCard(
                'Streak',
                '${_frequencyData!.currentStreak} days',
                Icons.local_fire_department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          'Total Workouts',
          '${_frequencyData!.totalWorkouts}',
          0,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Workout Frequency (workouts per week)',
          _buildBarChart(_frequencyData!.weeklyFrequencyData),
        ),
      ],
    );
  }

  Widget _buildConsistencyView() {
    if (_consistencyData == null) {
      return const Center(child: Text('No data'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          'Completion Rate',
          '${_consistencyData!.overallCompletionRate.toStringAsFixed(1)}%',
          0,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistics', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                _buildInfoRow('Sets Completed',
                    '${_consistencyData!.totalSetsCompleted}'),
                _buildInfoRow(
                    'Sets Planned', '${_consistencyData!.totalSetsPlanned}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Workout Completion Rate',
          _buildLineChart(
            _consistencyData!.completionRateData,
            color: Colors.purple,
            minY: 0,
            maxY: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Exercise', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              DropdownButtonFormField<Exercise>(
                value: _selectedExercise,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Select Exercise'),
                items: _availableExercises.map((exercise) {
                  return DropdownMenuItem(
                    value: exercise,
                    child: Text(exercise.name),
                  );
                }).toList(),
                onChanged: (exercise) {
                  if (exercise != null) {
                    _loadExerciseData(exercise);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedExercise == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'Select an exercise to view progress',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildExerciseProgressView(),
        ),
      ],
    );
  }

  Widget _buildExerciseProgressView() {
    if (_exerciseProgressData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          'Maximum Weight',
          '${_exerciseProgressData!.currentMax.toStringAsFixed(1)} kg',
          _exerciseProgressData!.progressPercentage,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Maximum Weight Progress',
          _buildLineChart(
            _exerciseProgressData!.maxWeightData,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Volume (weight × repetitions)',
          _buildLineChart(
            _exerciseProgressData!.volumeData,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Intensity (%)',
          _buildLineChart(
            _exerciseProgressData!.intensityData,
            color: Colors.orange,
            minY: 0,
            maxY: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, double change) {
    final isPositive = change >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.body2),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTextStyles.h1),
                if (change != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${change.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatsCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionsCard() {
    if (_overallStrengthData == null ||
        _overallStrengthData!.exerciseContributions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = _overallStrengthData!.exerciseContributions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercise Contributions', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            ...sorted.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      '${entry.value.toStringAsFixed(1)} кг',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(value,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildLineChart(
    List<ChartDataPoint> data, {
    required Color color,
    double? minY,
    double? maxY,
  }) {
    if (data.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              (maxY != null && minY != null) ? (maxY - minY) / 5 : null,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: data.length > 10 ? (data.length / 5).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = data[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: data.length < 20,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<ChartDataPoint> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    final barGroups = data
        .asMap()
        .entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ))
        .toList();

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = data[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
