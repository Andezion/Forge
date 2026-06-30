import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/achievement.dart';
import '../services/challenge_service.dart';
import '../services/data_manager.dart';
import '../services/friends_service.dart';
import '../services/profile_service.dart';
import '../utils/achievement_progress.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ({int wins, int completed}) _challengeStats = (wins: 0, completed: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChallengeStats());
  }

  Future<void> _loadChallengeStats() async {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    final stats = await challengeService.getCurrentUserChallengeStats();
    if (mounted) setState(() => _challengeStats = stats);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);
    final achievements = _calculateAchievements(dataManager);

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Achievements',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events,
                        color: AppColors.textOnPrimary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlockedCount / $totalCount Unlocked',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.textOnPrimary),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: unlockedCount / totalCount,
                            backgroundColor:
                                AppColors.textOnPrimary.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor:
                    AppColors.textOnPrimary.withValues(alpha: 0.7),
                indicatorColor: AppColors.textOnPrimary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Workouts'),
                  Tab(text: 'Strength'),
                  Tab(text: 'Consistency'),
                  Tab(text: 'Social'),
                  Tab(text: 'Special'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementsList(achievements),
          _buildAchievementsList(achievements
              .where((a) => a.category == AchievementCategory.workouts)
              .toList()),
          _buildAchievementsList(achievements
              .where((a) => a.category == AchievementCategory.strength)
              .toList()),
          _buildAchievementsList(achievements
              .where((a) => a.category == AchievementCategory.consistency)
              .toList()),
          _buildAchievementsList(achievements
              .where((a) => a.category == AchievementCategory.social)
              .toList()),
          _buildAchievementsList(achievements
              .where((a) => a.category == AchievementCategory.special)
              .toList()),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements in this category',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    achievements.sort((a, b) {
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return b.progressPercentage.compareTo(a.progressPercentage);
    });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: achievement.isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: achievement.isUnlocked
              ? LinearGradient(
                  colors: [
                    achievement.color.withValues(alpha: 0.2),
                    achievement.color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: achievement.isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: achievement.color,
                            size: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: AppTextStyles.body2.copyWith(
                        color: achievement.isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!achievement.isUnlocked) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: achievement.progressPercentage,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${achievement.currentProgress}/${achievement.requiredValue}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            achievement.unlockedAt != null
                                ? 'Unlocked ${_formatDate(achievement.unlockedAt!)}'
                                : 'Unlocked',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Achievement> _calculateAchievements(DataManager dataManager) {
    final friendsService = Provider.of<FriendsService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);

    return AchievementProgress.calculateAll(
      AchievementProgressInput(
        workoutHistory: dataManager.workoutHistory,
        friendsCount: friendsService.friends.length,
        bodyWeightKg: profileService.weightKg ?? 0.0,
        isMale: profileService.gender != 'female',
        challengeWinCount: _challengeStats.wins,
        completedChallengeCount: _challengeStats.completed,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
