import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chart_data.dart';
import '../models/exercise.dart';
import '../services/progress_analytics_service.dart';
import '../services/data_manager.dart';
import '../services/profile_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/units.dart';

class ProgressChartsScreen extends StatefulWidget {
  const ProgressChartsScreen({super.key});

  @override
  State<ProgressChartsScreen> createState() => _ProgressChartsScreenState();
}

class _ProgressChartsScreenState extends State<ProgressChartsScreen> {
  final _analyticsService = ProgressAnalyticsService();
  final _dataManager = DataManager();

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
  DateTimeRange? _customDateRange;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  Units get _units => Units.of(context, listen: false);

  double get _weightScale => _units.toDisplayWeight(1);

  String get _locale => Localizations.localeOf(context).toString();

  @override
  void initState() {
    super.initState();
    _dataManager.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileService>(context, listen: false)
          .addListener(_onDataChanged);
    });
    _loadData();
  }

  @override
  void dispose() {
    _dataManager.removeListener(_onDataChanged);
    try {
      Provider.of<ProfileService>(context, listen: false)
          .removeListener(_onDataChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onDataChanged() {
    debugPrint('[PROGRESS_CHARTS] Data changed, reloading charts...');
    _loadData();
  }

  void _onPeriodSelected(int days) async {
    if (days == -1) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDateRange: _customDateRange,
      );
      if (range != null && mounted) {
        final daysDiff = DateTime.now().difference(range.start).inDays + 1;
        setState(() {
          _customDateRange = range;
          _lookbackDays = daysDiff;
        });
        _loadData();
        if (_selectedExercise != null) _loadExerciseData(_selectedExercise!);
      }
    } else {
      setState(() {
        _lookbackDays = days;
        _customDateRange = null;
      });
      _loadData();
      if (_selectedExercise != null) _loadExerciseData(_selectedExercise!);
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileService =
          Provider.of<ProfileService>(context, listen: false);

      await _dataManager.initialize();
      final histories = _dataManager.workoutHistory;

      if (histories.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noDataAvailable),
              duration: const Duration(seconds: 3),
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
        profileService.weightKg ?? 70.0,
        lookbackDays: _lookbackDays,
        weightHistory: profileService.weightHistory,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      _volumeData = _analyticsService.analyzeWorkoutVolume(
        histories,
        lookbackDays: _lookbackDays,
        userBodyWeight: profileService.weightKg ?? 70.0,
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

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading progress data: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  Future<void> _loadExerciseData(Exercise exercise) async {
    if (!mounted) return;
    setState(() {
      _selectedExercise = exercise;
      _isLoading = true;
    });

    try {
      final histories = _dataManager.workoutHistory;
      final profileService =
          Provider.of<ProfileService>(context, listen: false);

      _exerciseProgressData = _analyticsService.analyzeExerciseProgress(
        exercise.id,
        exercise.name,
        histories,
        lookbackDays: _lookbackDays,
        userBodyWeight: profileService.weightKg ?? 70.0,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedTab = 'exercise';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Units.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.progressCharts),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: _onPeriodSelected,
            itemBuilder: (context) => [
              PopupMenuItem(value: 30, child: Text(l10n.thirtyDays)),
              PopupMenuItem(value: 90, child: Text(l10n.ninetyDays)),
              PopupMenuItem(value: 180, child: Text(l10n.oneHundredEightyDays)),
              PopupMenuItem(value: 365, child: Text(l10n.oneYear)),
              PopupMenuItem(value: -1, child: Text(l10n.customRange)),
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
                    l10n.loadingData,
                    style: AppTextStyles.body1.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
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
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noDataAvailable,
                          style: AppTextStyles.h2.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.completeOneWorkout,
                          style: AppTextStyles.body1.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton('overall', l10n.overallStrength, Icons.trending_up),
            _buildTabButton('body', l10n.bodyWeightTab, Icons.monitor_weight),
            _buildTabButton('volume', l10n.volume, Icons.fitness_center),
            _buildTabButton('frequency', l10n.frequency, Icons.calendar_month),
            _buildTabButton(
                'consistency', l10n.consistency, Icons.check_circle),
            _buildTabButton('exercise', l10n.exerciseProgress, Icons.list),
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
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
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
        final l10n = AppLocalizations.of(context)!;
        return Center(child: Text(l10n.selectATab));
    }
  }

  Widget _buildOverallStrengthView() {
    final l10n = AppLocalizations.of(context)!;
    if (_overallStrengthData == null) {
      return Center(child: Text(l10n.noData));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          _l10n.strengthCoefficient,
          _overallStrengthData!.currentTotalStrength.toStringAsFixed(1),
          _overallStrengthData!.progressPercentage,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _l10n.aboutStrengthCoefficient,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _l10n.strengthCoefficientDesc,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.strengthCoefficientProgress,
          _buildLineChart(
            _overallStrengthData!.totalStrengthData,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildContributionsCard(),
      ],
    );
  }

  Widget _buildBodyWeightView() {
    final l10n = AppLocalizations.of(context)!;
    if (_bodyWeightData == null) {
      return Center(child: Text(l10n.noData));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          _l10n.currentWeight,
          _units.weight(_bodyWeightData!.currentWeight),
          (_bodyWeightData!.weightChange / _bodyWeightData!.startWeight) * 100,
        ),
        const SizedBox(height: 16),
        if (_bodyWeightData!.weightData.length > 1) ...[
          _buildWeightChart(),
          const SizedBox(height: 16)
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.information,
                    style: AppTextStyles.h2.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                const SizedBox(height: 12),
                _buildInfoRow(_l10n.startingWeight,
                    _units.weight(_bodyWeightData!.startWeight)),
                _buildInfoRow(_l10n.change,
                    _units.weightDelta(_bodyWeightData!.weightChange)),
                _buildInfoRow(_l10n.averageWeight,
                    _units.weight(_bodyWeightData!.averageWeight)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _l10n.weightTrackingTip,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  _l10n.weightTrackingTipDesc(_l10n.weight),
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeView() {
    final l10n = AppLocalizations.of(context)!;
    if (_volumeData == null) {
      return Center(child: Text(l10n.noData));
    }

    String periodLabel;
    if (_customDateRange != null) {
      final fmt = DateFormat('dd.MM.yy');
      periodLabel =
          '${fmt.format(_customDateRange!.start)} – ${fmt.format(_customDateRange!.end)}';
    } else if (_lookbackDays <= 7) {
      periodLabel = _l10n.periodThisWeek;
    } else if (_lookbackDays <= 30) {
      periodLabel = _l10n.periodLast30Days;
    } else if (_lookbackDays <= 90) {
      periodLabel = _l10n.periodLast90Days;
    } else if (_lookbackDays <= 180) {
      periodLabel = _l10n.periodLast180Days;
    } else {
      periodLabel = _l10n.periodLastYear;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          _l10n.totalVolumeFor(periodLabel),
          _formatWeight(_volumeData!.totalPeriodVolume),
          _volumeData!.previousWeekVolume > 0
              ? ((_volumeData!.currentWeekVolume -
                          _volumeData!.previousWeekVolume) /
                      _volumeData!.previousWeekVolume) *
                  100
              : 0,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMiniStatsCard(
                _l10n.avgPerWeek,
                _formatWeight(_volumeData!.averageVolume),
                Icons.show_chart,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatsCard(
                _l10n.periodThisWeek,
                _formatWeight(_volumeData!.currentWeekVolume),
                Icons.fitness_center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.weeklyVolume,
          _buildBarChart(_volumeData!.weeklyVolumeData, yScale: _weightScale),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.dailyVolume,
          _buildLineChart(
            _volumeData!.dailyVolumeData,
            color: Colors.green,
            yScale: _weightScale,
          ),
        ),
      ],
    );
  }

  String _formatWeight(double kg) {
    final weight = _units.toDisplayWeight(kg);
    final String value;
    if (weight >= 1000000) {
      value = '${(weight / 1000000).toStringAsFixed(1)} ${_l10n.millionSuffix}';
    } else if (weight >= 1000) {
      value = '${(weight / 1000).toStringAsFixed(1)} ${_l10n.thousandSuffix}';
    } else {
      value = weight.toStringAsFixed(0);
    }
    return '$value ${_units.weightLabel}';
  }

  Widget _buildWeightChart() {
    if (_bodyWeightData == null || _bodyWeightData!.weightData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.weightHistory,
              style: AppTextStyles.h2.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(
                _bodyWeightData!.weightData,
                color: AppColors.primary,
                yAxisDecimals: 1,
                yScale: _weightScale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyView() {
    final l10n = AppLocalizations.of(context)!;
    if (_frequencyData == null) {
      return Center(child: Text(l10n.noData));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniStatsCard(
                _l10n.workoutsPerWeek,
                _frequencyData!.currentWeekFrequency.toStringAsFixed(1),
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniStatsCard(
                _l10n.streak,
                _l10n.durationDaysCount(_frequencyData!.currentStreak),
                Icons.local_fire_department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          _l10n.totalWorkouts,
          '${_frequencyData!.totalWorkouts}',
          0,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.workoutFrequencyChart,
          _buildBarChart(_frequencyData!.weeklyFrequencyData),
        ),
      ],
    );
  }

  Widget _buildConsistencyView() {
    final l10n = AppLocalizations.of(context)!;
    if (_consistencyData == null) {
      return Center(child: Text(l10n.noData));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildStatsCard(
          _l10n.completionRate,
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
                Text(l10n.statistics,
                    style: AppTextStyles.h2.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                const SizedBox(height: 12),
                _buildInfoRow(_l10n.setsCompleted,
                    '${_consistencyData!.totalSetsCompleted}'),
                _buildInfoRow(
                    _l10n.setsPlanned, '${_consistencyData!.totalSetsPlanned}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.workoutCompletionRate,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectExercise,
                  style: AppTextStyles.h2.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
              const SizedBox(height: 12),
              DropdownButtonFormField<Exercise>(
                value: _selectedExercise,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: Text(l10n.selectExercise),
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
                          size: 64,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      const SizedBox(height: 16),
                      Text(
                        l10n.selectAnExercise,
                        style: AppTextStyles.body1.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
          _l10n.maximumWeight,
          _units.weight(_exerciseProgressData!.currentMax),
          _exerciseProgressData!.progressPercentage,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.maximumWeightProgress,
          _buildLineChart(
            _exerciseProgressData!.maxWeightData,
            color: AppColors.primary,
            yScale: _weightScale,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.volumeWeightReps,
          _buildLineChart(
            _exerciseProgressData!.volumeData,
            color: Colors.green,
            yScale: _weightScale,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          _l10n.intensityPercent,
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.exerciseContributions,
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
            const SizedBox(height: 12),
            ...sorted.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      _units.weight(entry.value),
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
    int yAxisDecimals = 0,
    double yScale = 1,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return Center(child: Text(l10n.noDataToDisplay));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value * yScale))
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
                  value.toStringAsFixed(yAxisDecimals),
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
                  final fmt = _lookbackDays >= 180
                      ? DateFormat('MMM yy', _locale)
                      : DateFormat('dd/MM');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      fmt.format(date),
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

  Widget _buildBarChart(List<ChartDataPoint> data, {double yScale = 1}) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return Center(child: Text(l10n.noDataToDisplay));
    }

    final barWidth = data.length > 26
        ? 6.0
        : data.length > 13
            ? 10.0
            : 16.0;
    final barGroups = data
        .asMap()
        .entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value * yScale,
                  color: AppColors.primary,
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ))
        .toList();

    final double barLabelInterval =
        data.length > 8 ? (data.length / 5).ceilToDouble() : 1.0;
    final barFmt =
        _lookbackDays >= 180 ? DateFormat('MMM yy', _locale) : DateFormat('dd/MM');

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
              interval: barLabelInterval,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final date = data[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      barFmt.format(date),
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
