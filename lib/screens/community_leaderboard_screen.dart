import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/auth_service.dart';
import 'user_profile_screen.dart';

class CommunityLeaderboardScreen extends StatefulWidget {
  const CommunityLeaderboardScreen({super.key});

  @override
  State<CommunityLeaderboardScreen> createState() =>
      _CommunityLeaderboardScreenState();
}

class _CommunityLeaderboardScreenState extends State<CommunityLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedScope = 'Global';
  String _selectedPeriod = 'All Time';

  final List<String> _scopes = ['Global', 'Friends', 'Country', 'City'];
  final List<String> _periods = ['All Time', 'This Month', 'This Week'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          'Community Rankings',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildFilters(),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor:
                    AppColors.textOnPrimary.withValues(alpha: 0.7),
                indicatorColor: AppColors.textOnPrimary,
                tabs: const [
                  Tab(text: 'Workouts'),
                  Tab(text: 'Total Weight'),
                  Tab(text: 'Records'),
                  Tab(text: 'Streak'),
                  Tab(text: 'Progress'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutsLeaderboard(),
          _buildTotalWeightLeaderboard(),
          _buildRecordsLeaderboard(),
          _buildStreakLeaderboard(),
          _buildProgressLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterChip(_selectedScope, _scopes, (value) {
              setState(() => _selectedScope = value);
            }),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterChip(_selectedPeriod, _periods, (value) {
              setState(() => _selectedPeriod = value);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
      ),
      style: AppTextStyles.body2.copyWith(color: AppColors.textOnPrimary),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: AppTextStyles.body2.copyWith(color: AppColors.textOnPrimary),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget _buildWorkoutsLeaderboard() {
    final leaderboard = _getWorkoutsLeaderboard();
    return _buildLeaderboardList(
      leaderboard,
      (user) => '${user.workoutCount} workouts',
      Icons.fitness_center,
    );
  }

  Widget _buildTotalWeightLeaderboard() {
    final leaderboard = _getTotalWeightLeaderboard();
    return _buildLeaderboardList(
      leaderboard,
      (user) => '${user.totalWeight.toStringAsFixed(0)} kg',
      Icons.bar_chart,
    );
  }

  Widget _buildRecordsLeaderboard() {
    final leaderboard = _getRecordsLeaderboard();
    return _buildLeaderboardList(
      leaderboard,
      (user) => user.exerciseDetails,
      Icons.emoji_events,
    );
  }

  Widget _buildStreakLeaderboard() {
    final leaderboard = _getStreakLeaderboard();
    return _buildLeaderboardList(
      leaderboard,
      (user) => '${user.streak} days',
      Icons.local_fire_department,
    );
  }

  Widget _buildProgressLeaderboard() {
    final leaderboard = _getProgressLeaderboard();
    return _buildLeaderboardList(
      leaderboard,
      (user) => '+${user.improvement.toStringAsFixed(1)}%',
      Icons.trending_up,
    );
  }

  Widget _buildLeaderboardList(
    List<LeaderboardUser> users,
    String Function(LeaderboardUser) getSubtitle,
    IconData icon,
  ) {
    final auth = Provider.of<AuthService>(context);
    final currentUserId = auth.firebaseUser?.uid;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to see rankings',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.userId == currentUserId;
        final rank = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isCurrentUser ? 4 : 1,
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isCurrentUser
                ? BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            onTap: isCurrentUser
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userId: user.userId,
                          userName: user.name,
                        ),
                      ),
                    );
                  },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRankBadge(rank),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRankColor(rank).withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    color: _getRankColor(rank),
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'You',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(getSubtitle(user)),
                ],
              ),
            ),
            trailing: rank <= 3
                ? Icon(
                    Icons.emoji_events,
                    color: _getRankColor(rank),
                    size: 28,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getRankColor(rank),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  List<LeaderboardUser> _getWorkoutsLeaderboard() {
    // TODO: Fetch from Firebase/backend
    return [
      LeaderboardUser(
        userId: 'user1',
        name: 'Alex Johnson',
        workoutCount: 145,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user2',
        name: 'Maria Garcia',
        workoutCount: 132,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user3',
        name: 'James Smith',
        workoutCount: 128,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'current',
        name: 'You',
        workoutCount: 87,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user5',
        name: 'Sarah Williams',
        workoutCount: 76,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
    ];
  }

  List<LeaderboardUser> _getTotalWeightLeaderboard() {
    return [
      LeaderboardUser(
        userId: 'user1',
        name: 'Marcus Thompson',
        workoutCount: 0,
        totalWeight: 245000,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user2',
        name: 'David Chen',
        workoutCount: 0,
        totalWeight: 232000,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user3',
        name: 'John Davis',
        workoutCount: 0,
        totalWeight: 218000,
        streak: 0,
        improvement: 0,
        exerciseDetails: '',
      ),
    ];
  }

  List<LeaderboardUser> _getRecordsLeaderboard() {
    return [
      LeaderboardUser(
        userId: 'user1',
        name: 'Robert Brown',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: 'Squat: 220kg',
      ),
      LeaderboardUser(
        userId: 'user2',
        name: 'Michael Wilson',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: 'Bench: 180kg',
      ),
      LeaderboardUser(
        userId: 'user3',
        name: 'Chris Anderson',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 0,
        exerciseDetails: 'Deadlift: 280kg',
      ),
    ];
  }

  List<LeaderboardUser> _getStreakLeaderboard() {
    return [
      LeaderboardUser(
        userId: 'user1',
        name: 'Emma Taylor',
        workoutCount: 0,
        totalWeight: 0,
        streak: 127,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user2',
        name: 'Olivia Martinez',
        workoutCount: 0,
        totalWeight: 0,
        streak: 98,
        improvement: 0,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user3',
        name: 'Sophia Lee',
        workoutCount: 0,
        totalWeight: 0,
        streak: 85,
        improvement: 0,
        exerciseDetails: '',
      ),
    ];
  }

  List<LeaderboardUser> _getProgressLeaderboard() {
    return [
      LeaderboardUser(
        userId: 'user1',
        name: 'Lucas White',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 45.3,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user2',
        name: 'Ethan Harris',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 38.7,
        exerciseDetails: '',
      ),
      LeaderboardUser(
        userId: 'user3',
        name: 'Noah Clark',
        workoutCount: 0,
        totalWeight: 0,
        streak: 0,
        improvement: 32.1,
        exerciseDetails: '',
      ),
    ];
  }
}

class LeaderboardUser {
  final String userId;
  final String name;
  final int workoutCount;
  final double totalWeight;
  final int streak;
  final double improvement;
  final String exerciseDetails;

  LeaderboardUser({
    required this.userId,
    required this.name,
    required this.workoutCount,
    required this.totalWeight,
    required this.streak,
    required this.improvement,
    required this.exerciseDetails,
  });
}
