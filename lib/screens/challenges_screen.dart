import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/challenge.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../models/friend.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Challenges',
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateChallengeDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textOnPrimary,
          unselectedLabelColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
          indicatorColor: AppColors.textOnPrimary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengesList(_getActiveChallenges()),
          _buildChallengesList(_getCompletedChallenges()),
          _buildChallengesList(_getPendingChallenges()),
        ],
      ),
    );
  }

  Widget _buildChallengesList(List<Challenge> challenges) {
    if (challenges.isEmpty) {
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
              'No challenges yet',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a challenge to compete with friends',
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(challenges[index]);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId = auth.firebaseUser?.uid ?? '';
    final isParticipant = challenge.participantIds.contains(currentUserId);
    final currentScore = challenge.scores[currentUserId] ?? 0;

    String leaderId = '';
    double leadScore = 0;
    challenge.scores.forEach((id, score) {
      if (score > leadScore) {
        leadScore = score;
        leaderId = id;
      }
    });

    final isLeading = leaderId == currentUserId && leadScore > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLeading
            ? BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getChallengeColor(challenge.type)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getChallengeIcon(challenge.type),
                      color: _getChallengeColor(challenge.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                challenge.title,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isLeading)
                              Icon(
                                Icons.emoji_events,
                                color: AppColors.success,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (challenge.isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: challenge.progress,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getChallengeColor(challenge.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeRemaining(challenge.timeRemaining),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: challenge.participantIds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final userId = entry.value;
                  final name = challenge.participantNames[index];
                  final score = challenge.scores[userId] ?? 0;
                  final isCurrentUser = userId == currentUserId;
                  final isWinner = challenge.winnerId == userId;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrentUser
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isWinner)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                        Text(
                          isCurrentUser ? 'You' : name,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${score.toStringAsFixed(0)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetails(Challenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildChallengeDetailsSheet(challenge),
    );
  }

  Widget _buildChallengeDetailsSheet(Challenge challenge) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId = auth.firebaseUser?.uid ?? '';

    final sortedParticipants = challenge.participantIds
        .asMap()
        .entries
        .map((e) => {
              'id': e.value,
              'name': challenge.participantNames[e.key],
              'score': challenge.scores[e.value] ?? 0.0,
            })
        .toList()
      ..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _getChallengeColor(challenge.type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getChallengeIcon(challenge.type),
                  color: _getChallengeColor(challenge.type),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: AppTextStyles.h3),
                    Text(
                      challenge.description,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            'Start',
            _formatDate(challenge.startDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.event,
            'End',
            _formatDate(challenge.endDate),
          ),
          if (challenge.exerciseName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.fitness_center,
              'Exercise',
              challenge.exerciseName!,
            ),
          ],
          const SizedBox(height: 24),
          Text('Leaderboard', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...sortedParticipants.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final participant = entry.value;
            final isCurrentUser = participant['id'] == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrentUser ? AppColors.primary : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Container(
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCurrentUser ? 'You' : participant['name'] as String,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${(participant['score'] as double).toStringAsFixed(0)} ${_getScoreUnit(challenge.type)}',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          if (challenge.isPending &&
              challenge.participantIds.contains(currentUserId)) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Accept challenge
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Decline challenge
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        Text(value, style: AppTextStyles.body2),
      ],
    );
  }

  void _showCreateChallengeDialog() {
    final friendsService = Provider.of<FriendsService>(context, listen: false);
    final friends = friendsService.friends;

    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add friends first to create challenges'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateChallengeSheet(friends),
    );
  }

  Widget _buildCreateChallengeSheet(List<Friend> friends) {
    final templates = ChallengeTemplate.getTemplates();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Challenge', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Text(
            'Choose a challenge type',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
                  _showSelectFriendsDialog(template, friends);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showSelectFriendsDialog(
      ChallengeTemplate template, List<Friend> friends) {
    // TODO: Implement friend selection and challenge creation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Friends'),
        content: Text('Friend selection coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create challenge
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.workouts:
        return Icons.fitness_center;
      case ChallengeType.totalWeight:
        return Icons.fitness_center;
      case ChallengeType.specificExercise:
        return Icons.emoji_events;
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.consistency:
        return Icons.calendar_today;
    }
  }

  Color _getChallengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.workouts:
        return Colors.blue;
      case ChallengeType.totalWeight:
        return Colors.orange;
      case ChallengeType.specificExercise:
        return Colors.purple;
      case ChallengeType.streak:
        return Colors.red;
      case ChallengeType.consistency:
        return Colors.green;
    }
  }

  String _getScoreUnit(ChallengeType type) {
    switch (type) {
      case ChallengeType.workouts:
        return 'workouts';
      case ChallengeType.totalWeight:
        return 'kg';
      case ChallengeType.specificExercise:
        return 'kg';
      case ChallengeType.streak:
        return 'days';
      case ChallengeType.consistency:
        return 'days';
    }
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

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) return 'Ended';
    if (duration.inDays > 0) return '${duration.inDays}d left';
    if (duration.inHours > 0) return '${duration.inHours}h left';
    return '${duration.inMinutes}m left';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  List<Challenge> _getActiveChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: '1',
        creatorId: 'user1',
        creatorName: 'John',
        participantIds: ['user1', 'current', 'user3'],
        participantNames: ['John', 'You', 'Mike'],
        type: ChallengeType.workouts,
        title: 'Weekly Workout Challenge',
        description: 'Most workouts in 7 days',
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        status: ChallengeStatus.active,
        scores: {'user1': 5, 'current': 7, 'user3': 4},
      ),
      Challenge(
        id: '2',
        creatorId: 'current',
        creatorName: 'You',
        participantIds: ['current', 'user2'],
        participantNames: ['You', 'Sarah'],
        type: ChallengeType.totalWeight,
        title: 'Weight Lifting Challenge',
        description: 'Lift the most total weight',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        status: ChallengeStatus.active,
        scores: {'current': 5500, 'user2': 4800},
      ),
    ];
  }

  List<Challenge> _getCompletedChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: '3',
        creatorId: 'user1',
        creatorName: 'John',
        participantIds: ['user1', 'current'],
        participantNames: ['John', 'You'],
        type: ChallengeType.streak,
        title: 'Streak Challenge',
        description: 'Longest training streak',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 1)),
        status: ChallengeStatus.completed,
        scores: {'user1': 12, 'current': 14},
        winnerId: 'current',
      ),
    ];
  }

  List<Challenge> _getPendingChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: '4',
        creatorId: 'user2',
        creatorName: 'Sarah',
        participantIds: ['user2', 'current'],
        participantNames: ['Sarah', 'You'],
        type: ChallengeType.specificExercise,
        title: 'Bench Press Challenge',
        description: 'Best bench press 1RM',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 8)),
        status: ChallengeStatus.pending,
        exerciseId: 'bench_press',
        exerciseName: 'Bench Press',
      ),
    ];
  }
}
