import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/friend.dart';
import '../models/user_stats.dart';
import '../services/friends_service.dart';
import '../services/challenge_service.dart';
import '../services/auth_service.dart';
import '../models/challenge.dart';
import 'stats_comparison_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Friend friend;

  const UserProfileScreen({super.key, required this.friend});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final friendsService =
        Provider.of<FriendsService>(context, listen: false);
    final stats =
        await friendsService.fetchFriendProfile(widget.friend.userId);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : (_stats == null || !_stats!.isProfilePublic)
                    ? _buildPrivateProfile()
                    : _buildPublicProfile(_stats!),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.friend.name,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
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
                child: Icon(Icons.person, size: 50, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.lock_outline, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Private Profile', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              '${widget.friend.name} has a private profile.\nOnly their username and avatar are visible.',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicProfile(UserStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(stats),
          const SizedBox(height: 16),
          _buildVolumeCard(stats),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Streak',
            '${stats.currentStreak}',
            'days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Overall',
            widget.friend.overallRating?.toStringAsFixed(1) ?? '—',
            'coeff',
            Icons.trending_up,
            AppColors.primary,
          ),
        ),
        if (widget.friend.weight != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Weight',
              widget.friend.weight!.toStringAsFixed(1),
              'kg',
              Icons.monitor_weight_outlined,
              Colors.teal,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            Text(unit, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeCard(UserStats stats) {
    final volumeT = (stats.totalWeightLifted / 1000).toStringAsFixed(1);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fitness_center,
                  color: Colors.deepPurple, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Volume', style: AppTextStyles.caption),
                Text(
                  '$volumeT t',
                  style: AppTextStyles.h3.copyWith(color: Colors.deepPurple),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Workouts', style: AppTextStyles.caption),
                Text(
                  '${stats.workoutCount}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsComparisonScreen(
                    otherUserId: widget.friend.userId,
                    otherUserName: widget.friend.name,
                  ),
                ),
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

  void _showChallengeDialog(BuildContext context) {
    final templates = ChallengeTemplate.getTemplates();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Challenge ${widget.friend.name}', style: AppTextStyles.h3),
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
                    Navigator.pop(ctx);
                    _createChallenge(template);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _createChallenge(ChallengeTemplate template) async {
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
      participantIds: [currentUserId, widget.friend.userId],
      participantNames: [currentUserName, widget.friend.name],
      startDate: now,
      endDate: endDate,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result == 'success'
              ? 'Challenge sent to ${widget.friend.name}!'
              : result),
          backgroundColor:
              result == 'success' ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
