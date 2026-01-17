import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/user_stats.dart';
import '../services/leaderboard_service.dart';
import '../services/auth_service.dart';

class StatsComparisonScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const StatsComparisonScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<StatsComparisonScreen> createState() => _StatsComparisonScreenState();
}

class _StatsComparisonScreenState extends State<StatsComparisonScreen> {
  UserStats? _currentUserStats;
  UserStats? _otherUserStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final leaderboardService =
        Provider.of<LeaderboardService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      final currentUserId = auth.firebaseUser?.uid;
      if (currentUserId != null) {
        final currentStats = await leaderboardService.getCurrentUserStats();
        final otherStats =
            await leaderboardService.getUserStats(widget.otherUserId);

        if (mounted) {
          setState(() {
            _currentUserStats = currentStats;
            _otherUserStats = otherStats;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final currentUserName = auth.firebaseUser?.displayName ??
        auth.firebaseUser?.email?.split('@')[0] ??
        'You';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Stats Comparison',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderRow(currentUserName, widget.otherUserName),
                  const SizedBox(height: 24),
                  _buildComparisonCard(
                    'Workouts',
                    _currentUserStats?.workoutCount ?? 0,
                    _otherUserStats?.workoutCount ?? 0,
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonCard(
                    'Current Streak',
                    _currentUserStats?.currentStreak ?? 0,
                    _otherUserStats?.currentStreak ?? 0,
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildComparisonCard(
                    'Total Weight',
                    (_currentUserStats?.totalWeightLifted ?? 0).toInt(),
                    (_otherUserStats?.totalWeightLifted ?? 0).toInt(),
                    Icons.fitness_center,
                    Colors.green,
                    suffix: ' kg',
                  ),
                  const SizedBox(height: 24),
                  Text('Personal Records', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  _buildRecordsComparison(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderRow(String currentUserName, String otherUserName) {
    return Row(
      children: [
        Expanded(
          child: _buildUserHeader(currentUserName, AppColors.primary, true),
        ),
        const SizedBox(width: 16),
        Icon(Icons.compare_arrows, color: AppColors.textSecondary),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUserHeader(otherUserName, AppColors.accent, false),
        ),
      ],
    );
  }

  Widget _buildUserHeader(String name, Color color, bool isCurrentUser) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.person, size: 40, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (isCurrentUser)
          Text(
            '(You)',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildComparisonCard(
    String label,
    int currentValue,
    int otherValue,
    IconData icon,
    Color color, {
    String suffix = '',
  }) {
    final currentIsHigher = currentValue > otherValue;
    final difference = (currentValue - otherValue).abs();
    final percentDiff = otherValue > 0
        ? ((currentValue - otherValue) / otherValue * 100).abs()
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(label, style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    currentValue,
                    suffix,
                    currentIsHigher,
                    AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _buildStatColumn(
                    otherValue,
                    suffix,
                    !currentIsHigher,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            if (currentValue != otherValue) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (currentIsHigher ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentIsHigher
                      ? 'You\'re ahead by $difference$suffix (${percentDiff.toStringAsFixed(1)}%)'
                      : 'Behind by $difference$suffix (${percentDiff.toStringAsFixed(1)}%)',
                  style: AppTextStyles.caption.copyWith(
                    color:
                        currentIsHigher ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      int value, String suffix, bool isHigher, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value$suffix',
              style: AppTextStyles.h3.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isHigher && value > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordsComparison() {
    final currentRecords = _currentUserStats?.exerciseRecords ?? {};
    final otherRecords = _otherUserStats?.exerciseRecords ?? {};

    final allExercises = {...currentRecords.keys, ...otherRecords.keys}.toList()
      ..sort();

    return Column(
      children: allExercises.map((exercise) {
        final currentWeight = currentRecords[exercise] ?? 0.0;
        final otherWeight = otherRecords[exercise] ?? 0.0;
        final currentIsHigher = currentWeight > otherWeight;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercise,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRecordValue(
                        currentWeight,
                        currentIsHigher && currentWeight > 0,
                        AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.divider,
                    ),
                    Expanded(
                      child: _buildRecordValue(
                        otherWeight,
                        !currentIsHigher && otherWeight > 0,
                        AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordValue(double weight, bool isHigher, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          weight > 0 ? '${weight.toStringAsFixed(1)} kg' : 'N/A',
          style: AppTextStyles.body1.copyWith(
            color: weight > 0 ? color : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isHigher)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 16,
            ),
          ),
      ],
    );
  }
}
