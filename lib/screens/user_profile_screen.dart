import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/achievement.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Load actual user data
    final mockUser = _getMockUserData();

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
                userName,
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
                  _buildStatsGrid(mockUser),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Achievements'),
                  const SizedBox(height: 12),
                  _buildAchievementsList(mockUser['achievements']),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Personal Records'),
                  const SizedBox(height: 12),
                  _buildPersonalRecords(mockUser['records']),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Activity'),
                  const SizedBox(height: 12),
                  _buildActivitySection(mockUser),
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
            onPressed: () {
              // TODO: Challenge user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Challenge feature coming soon')),
              );
            },
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Compare stats
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Compare feature coming soon')),
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Send message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Message feature coming soon')),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
