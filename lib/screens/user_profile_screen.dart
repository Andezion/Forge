import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../services/leaderboard_service.dart';
import '../services/challenge_service.dart';
import '../services/auth_service.dart';
import '../models/challenge.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final leaderboardService =
        Provider.of<LeaderboardService>(context, listen: false);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      if (widget.userId == auth.firebaseUser?.uid) {
        final stats = await leaderboardService.getCurrentUserStats();
        if (mounted) {
          setState(() {
            _userStats = stats;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userData =
        _userStats != null ? _getUserDataFromStats() : _getMockUserData();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.userName,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(userData),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Achievements'),
                  const SizedBox(height: 12),
                  _buildAchievementsList(userData['achievements']),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Personal Records'),
                  const SizedBox(height: 12),
                  _buildPersonalRecords(userData['records']),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Activity'),
                  const SizedBox(height: 12),
                  _buildActivitySection(userData),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Workouts',
            user['workoutCount'].toString(),
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '${user['streak']} days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.h3);
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: achievement.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement.icon,
                        color: achievement.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.title,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalRecords(List<Map<String, dynamic>> records) {
    return Column(
      children: records.map((record) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            title: Text(record['exercise']),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record['weight']} kg',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '1RM',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivitySection(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityRow(
              'Total Weight Lifted',
              '${user['totalWeight']} kg',
              Icons.fitness_center,
            ),
            const Divider(),
            _buildActivityRow(
              'Wilks Score',
              user['wilks'].toString(),
              Icons.trending_up,
            ),
            const Divider(),
            _buildActivityRow(
              'Member Since',
              user['memberSince'],
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyles.body2),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showChallengeDialog(context),
            icon: const Icon(Icons.emoji_events),
            label: const Text('Challenge'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Compare stats
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compare feature coming soon')),
              );
            },
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare Stats'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getUserDataFromStats() {
    if (_userStats == null) return _getMockUserData();

    return {
      'workoutCount': _userStats!.workoutCount,
      'streak': _userStats!.currentStreak,
      'totalWeight': _userStats!.totalWeightLifted.toInt(),
      'wilks': 0.0,
      'memberSince': _formatMemberSince(_userStats!.lastWorkoutDate),
      'achievements': <Achievement>[],
      'records': _userStats!.exerciseRecords.entries
          .take(3)
          .map((e) => {
                'exercise': e.key,
                'weight': e.value,
              })
          .toList(),
    };
  }

  String _formatMemberSince(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showChallengeDialog(BuildContext context) {
    final templates = ChallengeTemplate.getTemplates();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Challenge ${widget.userName}', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Text(
              'Choose a challenge type',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: template.color.withValues(alpha: 0.2),
                    child: Icon(template.icon, color: template.color),
                  ),
                  title: Text(template.title),
                  subtitle: Text(template.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _createChallenge(context, template);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _createChallenge(
      BuildContext context, ChallengeTemplate template) async {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId = auth.firebaseUser?.uid;
    final currentUserName =
        auth.firebaseUser?.displayName ?? auth.firebaseUser?.email ?? 'You';

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in')),
        );
      }
      return;
    }

    final now = DateTime.now();
    final endDate = now.add(Duration(days: template.defaultDurationDays));

    final result = await challengeService.createChallenge(
      type: template.type,
      title: template.title,
      description: template.description,
      participantIds: [currentUserId, widget.userId],
      participantNames: [currentUserName, widget.userName],
      startDate: now,
      endDate: endDate,
    );

    if (mounted) {
      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challenge sent to ${widget.userName}!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  Map<String, dynamic> _getMockUserData() {
    return {
      'workoutCount': 87,
      'streak': 14,
      'totalWeight': 125000,
      'wilks': 385.5,
      'memberSince': 'Jan 2025',
      'achievements': [
        Achievement(
          id: 'workout_50',
          title: 'Dedicated',
          description: 'Complete 50 workouts',
          icon: Icons.fitness_center,
          color: Colors.purple,
          category: AchievementCategory.workouts,
          requiredValue: 50,
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Achievement(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Train 7 days in a row',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          category: AchievementCategory.consistency,
          requiredValue: 7,
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Achievement(
          id: 'wilks_300',
          title: 'Strong',
          description: 'Reach 300 Wilks coefficient',
          icon: Icons.trending_up,
          color: Colors.orange,
          category: AchievementCategory.strength,
          requiredValue: 300,
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
      'records': [
        {
          'exercise': 'Squat',
          'weight': 140.0,
        },
        {
          'exercise': 'Bench Press',
          'weight': 100.0,
        },
        {
          'exercise': 'Deadlift',
          'weight': 180.0,
        },
      ],
    };
  }
}
