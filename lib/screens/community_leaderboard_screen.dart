import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import '../services/data_manager.dart';
import '../services/profile_service.dart';
import '../models/user_stats.dart';
import '../models/exercise.dart';
import '../models/friend.dart';
import 'user_profile_screen.dart';

class CommunityLeaderboardScreen extends StatefulWidget {
  const CommunityLeaderboardScreen({super.key});

  @override
  State<CommunityLeaderboardScreen> createState() =>
      _CommunityLeaderboardScreenState();
}

class _CommunityLeaderboardScreenState
    extends State<CommunityLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedScope = 'Global';
  String _selectedPeriod = 'All Time';
  Exercise? _selectedExercise;

  static const _scopes = ['Global', 'My League', 'Country', 'City'];
  static const _periods = ['All Time', 'This Month', 'This Week'];

  static const _scopeIcons = {
    'Global': Icons.public,
    'My League': Icons.shield,
    'Country': Icons.flag_outlined,
    'City': Icons.location_city,
  };

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
          Expanded(child: _buildScopeChip()),
          const SizedBox(width: 8),
          Expanded(
            child: _buildFilterDropdown(_selectedPeriod, _periods, (v) {
              setState(() => _selectedPeriod = v);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip() {
    return DropdownButtonFormField<String>(
      value: _selectedScope,
      dropdownColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
      ),
      style: AppTextStyles.body2.copyWith(color: Colors.black),
      items: _scopes.map((scope) {
        return DropdownMenuItem<String>(
          value: scope,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_scopeIcons[scope], size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(scope,
                  style: AppTextStyles.body2.copyWith(color: Colors.black)),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedScope = v);
      },
    );
  }

  Widget _buildFilterDropdown(
      String value, List<String> options, void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textOnPrimary),
        ),
      ),
      style: AppTextStyles.body2.copyWith(color: Colors.black),
      items: options
          .map((o) => DropdownMenuItem<String>(
              value: o,
              child:
                  Text(o, style: AppTextStyles.body2.copyWith(color: Colors.black))))
          .toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }

  // ─── Scope helpers ────────────────────────────────────────────────────────

  String? get _userCountry =>
      Provider.of<ProfileService>(context, listen: false).country;
  String? get _userCity =>
      Provider.of<ProfileService>(context, listen: false).city;

  Widget _buildScopeEmptyState() {
    String message;
    if (_selectedScope == 'Country' && _userCountry == null) {
      message = 'Set your country in Profile → About Me to see country rankings';
    } else if (_selectedScope == 'City' && _userCity == null) {
      message = 'Set your city in Profile → About Me to see city rankings';
    } else if (_selectedScope == 'My League') {
      message = 'Add friends to see your league rankings';
    } else {
      message = 'No data available yet';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _scopeIcons[_selectedScope] ?? Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ─── Tab content ──────────────────────────────────────────────────────────

  Widget _buildWorkoutsLeaderboard() {
    final leaderboardService = Provider.of<LeaderboardService>(context);
    return StreamBuilder<List<UserStats>>(
      stream: leaderboardService.getWorkoutCountLeaderboard(
        scope: _selectedScope,
        userCountry: _userCountry,
        userCity: _userCity,
      ),
      builder: (context, snapshot) => _buildStreamBody(
        snapshot,
        (user) => '${user.workoutCount} workouts',
        Icons.fitness_center,
      ),
    );
  }

  Widget _buildTotalWeightLeaderboard() {
    final leaderboardService = Provider.of<LeaderboardService>(context);
    return StreamBuilder<List<UserStats>>(
      stream: leaderboardService.getTotalWeightLeaderboard(
        scope: _selectedScope,
        userCountry: _userCountry,
        userCity: _userCity,
      ),
      builder: (context, snapshot) => _buildStreamBody(
        snapshot,
        (user) => '${user.totalWeightLifted.toStringAsFixed(0)} kg',
        Icons.bar_chart,
      ),
    );
  }

  Widget _buildRecordsLeaderboard() {
    final dataManager = Provider.of<DataManager>(context);
    final leaderboardService = Provider.of<LeaderboardService>(context);
    final exercises = dataManager.exercises;

    if (_selectedExercise == null && exercises.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedExercise = exercises.first);
      });
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              Text('Exercise:',
                  style: AppTextStyles.body1
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Exercise>(
                  value: _selectedExercise,
                  dropdownColor: AppColors.surface,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: AppTextStyles.body2.copyWith(color: Colors.black),
                  items: exercises
                      .map((ex) => DropdownMenuItem<Exercise>(
                          value: ex,
                          child: Text(ex.name,
                              style: AppTextStyles.body2
                                  .copyWith(color: Colors.black))))
                      .toList(),
                  onChanged: (ex) {
                    if (ex != null) setState(() => _selectedExercise = ex);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedExercise == null
              ? const Center(child: Text('Select an exercise'))
              : StreamBuilder<List<UserStats>>(
                  stream: leaderboardService.getExerciseRecordLeaderboard(
                    exerciseId: _selectedExercise!.id,
                    scope: _selectedScope,
                    userCountry: _userCountry,
                    userCity: _userCity,
                  ),
                  builder: (context, snapshot) => _buildStreamBody(
                    snapshot,
                    (user) {
                      final record =
                          user.exerciseRecords[_selectedExercise!.id];
                      return record != null
                          ? '${record.toStringAsFixed(1)} kg'
                          : 'No record';
                    },
                    Icons.emoji_events,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStreakLeaderboard() {
    final leaderboardService = Provider.of<LeaderboardService>(context);
    return StreamBuilder<List<UserStats>>(
      stream: leaderboardService.getStreakLeaderboard(
        scope: _selectedScope,
        userCountry: _userCountry,
        userCity: _userCity,
      ),
      builder: (context, snapshot) => _buildStreamBody(
        snapshot,
        (user) => '${user.currentStreak} days',
        Icons.local_fire_department,
      ),
    );
  }

  Widget _buildProgressLeaderboard() {
    final leaderboardService = Provider.of<LeaderboardService>(context);
    return StreamBuilder<List<UserStats>>(
      stream: leaderboardService.getProgressLeaderboard(
        scope: _selectedScope,
        userCountry: _userCountry,
        userCity: _userCity,
      ),
      builder: (context, snapshot) => _buildStreamBody(
        snapshot,
        (user) => '+${user.weeklyProgressPercentage.toStringAsFixed(1)}%',
        Icons.trending_up,
      ),
    );
  }

  Widget _buildStreamBody(
    AsyncSnapshot<List<UserStats>> snapshot,
    String Function(UserStats) getSubtitle,
    IconData icon,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    final users = snapshot.data ?? [];
    if (users.isEmpty) return _buildScopeEmptyState();
    return _buildLeaderboardList(users, getSubtitle, icon);
  }

  // ─── List UI ──────────────────────────────────────────────────────────────

  Widget _buildLeaderboardList(
    List<UserStats> users,
    String Function(UserStats) getSubtitle,
    IconData icon,
  ) {
    final auth = Provider.of<AuthService>(context);
    final currentUserId = auth.firebaseUser?.uid;

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
                : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        friend: Friend(
                          userId: user.userId,
                          name: user.displayName,
                          email: '',
                          friendsSince: DateTime.now(),
                        ),
                      ),
                    )),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRankBadge(rank),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      _getRankColor(rank).withValues(alpha: 0.2),
                  child: Icon(Icons.person, color: _getRankColor(rank)),
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.displayName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: isCurrentUser
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'You',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold),
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
                  if (user.country != null) ...[
                    const SizedBox(width: 8),
                    Text('· ${user.country}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            trailing: rank <= 3
                ? Icon(Icons.emoji_events,
                    color: _getRankColor(rank), size: 28)
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
      decoration:
          BoxDecoration(color: _getRankColor(rank), shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rank',
          style: AppTextStyles.body2.copyWith(
              color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return AppColors.primary;
    }
  }
}
