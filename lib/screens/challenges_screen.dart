import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/challenge.dart';
import '../models/strength_rank.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../services/challenge_service.dart';
import '../models/friend.dart';
import '../utils/units.dart';
import '../widgets/rank_badge_widget.dart';

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
    final challengeService = Provider.of<ChallengeService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppLocalizations.of(context)!.challenges,
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
          tabs: [
            Tab(text: AppLocalizations.of(context)!.active),
            Tab(text: AppLocalizations.of(context)!.completed),
            Tab(text: AppLocalizations.of(context)!.pending),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengesStreamList(
              challengeService.getActiveChallengesStream()),
          _buildChallengesStreamList(
              challengeService.getCompletedChallengesStream()),
          _buildChallengesStreamList(
              challengeService.getPendingChallengesStream()),
        ],
      ),
    );
  }

  Widget _buildChallengesStreamList(Stream<List<Challenge>> stream) {
    return StreamBuilder<List<Challenge>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.errorLoadingChallenges,
              style:
                  AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        final challenges = snapshot.data ?? [];
        return _buildChallengesList(challenges);
      },
    );
  }

  Widget _buildChallengesList(List<Challenge> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: RankBadgeWidget(rank: StrengthRank.wooden, size: 64),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noChallengesYet,
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.createChallengeDesc,
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
                                ChallengeTemplate.titleFor(challenge.type),
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isLeading)
                              RankBadgeWidget(
                                rank: StrengthRank.gold,
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
                            child:
                                RankBadgeWidget(rank: StrengthRank.gold, size: 16),
                          ),
                        Text(
                          isCurrentUser
                              ? AppLocalizations.of(context)!.you
                              : name,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          score.toStringAsFixed(0),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    Text(ChallengeTemplate.titleFor(challenge.type),
                        style: AppTextStyles.h3),
                    Text(
                      ChallengeTemplate.descriptionFor(challenge.type),
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
            AppLocalizations.of(context)!.start,
            _formatDate(challenge.startDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.event,
            AppLocalizations.of(context)!.end,
            _formatDate(challenge.endDate),
          ),
          if (challenge.exerciseName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.fitness_center,
              AppLocalizations.of(context)!.exerciseLabel,
              challenge.exerciseName!,
            ),
          ],
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.leaderboard,
              style: AppTextStyles.h3),
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
                      isCurrentUser
                          ? AppLocalizations.of(context)!.you
                          : participant['name'] as String,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    _formatScore(
                        (participant['score'] as num).toDouble(), challenge.type),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      final challengeService =
                          Provider.of<ChallengeService>(context, listen: false);
                      final result =
                          await challengeService.acceptChallenge(challenge.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result == 'success'
                                ? AppLocalizations.of(context)!.challengeAccepted
                                : result),
                            backgroundColor:
                                result == 'success' ? AppColors.success : null,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.of(context)!.accept),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final challengeService =
                          Provider.of<ChallengeService>(context, listen: false);
                      final result =
                          await challengeService.declineChallenge(challenge.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result == 'success'
                                ? AppLocalizations.of(context)!.challengeDeclined
                                : result),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.of(context)!.decline),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.addFriendsFirst),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.createChallenge,
              style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.chooseChallengeType,
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
    final selectedFriends = <Friend>{};
    int durationDays = template.defaultDurationDays;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectFriends),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.selectFriendsToChallenge,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ...friends.map((friend) {
                  final isSelected = selectedFriends.contains(friend);
                  return CheckboxListTile(
                    title: Text(friend.name),
                    subtitle: Text(friend.email),
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          selectedFriends.add(friend);
                        } else {
                          selectedFriends.remove(friend);
                        }
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.durationDays,
                  style: AppTextStyles.body1,
                ),
                Slider(
                  value: durationDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: AppLocalizations.of(context)!
                      .durationDaysCount(durationDays),
                  onChanged: (value) {
                    setDialogState(() {
                      durationDays = value.toInt();
                    });
                  },
                ),
                Text(
                  AppLocalizations.of(context)!.durationDaysCount(durationDays),
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: selectedFriends.isEmpty
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _createChallenge(
                          template, selectedFriends.toList(), durationDays);
                    },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createChallenge(ChallengeTemplate template,
      List<Friend> selectedFriends, int durationDays) async {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final currentUserId = auth.firebaseUser?.uid;
    final currentUserName =
        auth.firebaseUser?.displayName ?? auth.firebaseUser?.email ?? 'You';

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mustBeLoggedIn)),
      );
      return;
    }

    final participantIds = [
      currentUserId,
      ...selectedFriends.map((f) => f.userId)
    ];
    final participantNames = [
      currentUserName,
      ...selectedFriends.map((f) => f.name)
    ];

    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));

    final result = await challengeService.createChallenge(
      type: template.type,
      title: template.title,
      description: template.description,
      participantIds: participantIds,
      participantNames: participantNames,
      startDate: now,
      endDate: endDate,
    );

    if (mounted) {
      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.challengeCreated)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
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

  String _formatScore(double score, ChallengeType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case ChallengeType.workouts:
        return l10n.workoutsCount(score.round());
      case ChallengeType.totalWeight:
      case ChallengeType.specificExercise:
        return Units.of(context).weight(score, decimals: 0);
      case ChallengeType.streak:
      case ChallengeType.consistency:
        return l10n.durationDaysCount(score.round());
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
    final l10n = AppLocalizations.of(context)!;
    if (duration.isNegative) return l10n.challengeEnded;
    if (duration.inDays > 0) return l10n.daysLeft(duration.inDays);
    if (duration.inHours > 0) return l10n.hoursLeft(duration.inHours);
    return l10n.minutesLeft(duration.inMinutes);
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
