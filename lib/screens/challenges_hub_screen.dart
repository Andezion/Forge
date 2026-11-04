import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/personal_challenge.dart';
import '../services/personal_challenge_service.dart';
import '../widgets/rank_badge_widget.dart';
import 'challenges_screen.dart';
import 'pose_camera_screen.dart';

class ChallengesHubScreen extends StatelessWidget {
  const ChallengesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: Text(
            l10n.challenges,
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
          bottom: TabBar(
            labelColor: AppColors.textOnPrimary,
            unselectedLabelColor:
                AppColors.textOnPrimary.withValues(alpha: 0.7),
            indicatorColor: AppColors.textOnPrimary,
            tabs: [
              Tab(icon: const Icon(Icons.groups), text: l10n.challengesSocial),
              Tab(
                  icon: const Icon(Icons.person),
                  text: l10n.challengesPersonal),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChallengesScreen(embedded: true),
            _PersonalChallengesView(),
          ],
        ),
      ),
    );
  }
}

class _PersonalChallengesView extends StatelessWidget {
  const _PersonalChallengesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = context.watch<PersonalChallengeService>();
    const exercise = PersonalExercise.pushUps;
    final challenges = PersonalChallenge.forExercise(exercise);
    final best = service.bestFor(exercise);

    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      children: [
        Card(
          elevation: 0,
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.videocam, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.personalChallengesIntro,
                    style: AppTextStyles.body2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(exercise.icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.exercisePushUps, style: AppTextStyles.h3),
            ),
            Text(
              l10n.personalBest(best),
              style:
                  AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...challenges.map((c) => _PersonalChallengeCard(
              challenge: c,
              best: best,
              completed: service.isCompleted(c),
            )),
      ],
    );
  }
}

class _PersonalChallengeCard extends StatelessWidget {
  final PersonalChallenge challenge;
  final int best;
  final bool completed;

  const _PersonalChallengeCard({
    required this.challenge,
    required this.best,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = (best / challenge.targetReps).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: completed
            ? BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PoseCameraScreen(challenge: challenge),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Opacity(
                opacity: completed ? 1 : 0.55,
                child: RankBadgeWidget(rank: challenge.tier, size: 44),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.repsCount(challenge.targetReps),
                      style: AppTextStyles.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              completed
                  ? Chip(
                      avatar: Icon(Icons.check,
                          size: 16, color: AppColors.success),
                      label: Text(l10n.personalChallengeDone),
                      visualDensity: VisualDensity.compact,
                    )
                  : FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PoseCameraScreen(challenge: challenge),
                        ),
                      ),
                      icon: const Icon(Icons.videocam, size: 18),
                      label: Text(l10n.startAttempt),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
