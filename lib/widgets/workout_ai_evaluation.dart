import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../constants/app_text_styles.dart';
import '../utils/muscle_group_utils.dart';

class _WorkoutAiResult {
  final String grade;
  final Color gradeColor;
  final Color gradeBgColor;
  final String summary;
  final String detail;
  final int recoveryDays;
  final double score;

  const _WorkoutAiResult({
    required this.grade,
    required this.gradeColor,
    required this.gradeBgColor,
    required this.summary,
    required this.detail,
    required this.recoveryDays,
    required this.score,
  });
}

class WorkoutAiEvaluation extends StatelessWidget {
  final Workout workout;

  const WorkoutAiEvaluation({super.key, required this.workout});

  _WorkoutAiResult _evaluate() {
    final exercises = workout.exercises;

    if (exercises.isEmpty) {
      return const _WorkoutAiResult(
        grade: 'F',
        gradeColor: Color(0xFFB71C1C),
        gradeBgColor: Color(0xFFFFEBEE),
        summary: 'Empty workout',
        detail: 'Add exercises to get an AI evaluation.',
        recoveryDays: 0,
        score: 0,
      );
    }

    final muscleLoad = <MuscleGroup, double>{};
    final muscleSets = <MuscleGroup, int>{};
    int totalSets = 0;

    for (final we in exercises) {
      totalSets += we.sets;
      for (final tag in we.exercise.muscleGroups) {
        muscleLoad[tag.group] =
            (muscleLoad[tag.group] ?? 0) + tag.score * we.sets;
        muscleSets[tag.group] = (muscleSets[tag.group] ?? 0) + we.sets;
      }
    }

    final totalLoad = muscleLoad.values.fold(0.0, (a, b) => a + b);
    final groupCount = muscleLoad.length;
    final exerciseCount = exercises.length;

    double score = 0;

    if (exerciseCount >= 3 && exerciseCount <= 7) {
      score += 3;
    } else if (exerciseCount == 2 || exerciseCount == 8) {
      score += 2;
    } else if (exerciseCount == 1 || exerciseCount > 8) {
      score += 1;
    }

    if (totalSets >= 9 && totalSets <= 25) {
      score += 3;
    } else if (totalSets >= 6 && totalSets <= 30) {
      score += 2;
    } else {
      score += 1;
    }

    if (groupCount >= 4) {
      score += 2;
    } else if (groupCount >= 2) {
      score += 1;
    }

    if (totalLoad > 0) {
      final maxLoad =
          muscleLoad.values.fold(0.0, (prev, v) => v > prev ? v : prev);
      final dominance = maxLoad / totalLoad;
      if (dominance <= 0.40) {
        score += 2;
      } else if (dominance <= 0.60) {
        score += 1;
      }
    }

    int recoveryDays;
    if (totalLoad < 10) {
      recoveryDays = 1;
    } else if (totalLoad < 22) {
      recoveryDays = 2;
    } else {
      recoveryDays = 3;
    }

    String grade;
    Color gradeColor;
    Color gradeBgColor;
    String summary;
    String detail;

    // identify dominant group name for messages
    String? topGroup;
    if (muscleLoad.isNotEmpty) {
      final top =
          muscleLoad.entries.reduce((a, b) => a.value > b.value ? a : b);
      topGroup = MuscleGroupUtils.getLabel(top.key);
    }

    if (score >= 8.5) {
      grade = 'A';
      gradeColor = const Color(0xFF1B5E20);
      gradeBgColor = const Color(0xFFE8F5E9);
      summary = 'Excellent workout!';
      detail =
          'Well-structured, balanced load across $groupCount muscle groups. Smart volume choice.';
    } else if (score >= 7) {
      grade = 'B';
      gradeColor = const Color(0xFF33691E);
      gradeBgColor = const Color(0xFFF1F8E9);
      summary = 'Good workout.';
      detail = topGroup != null
          ? 'Solid structure with emphasis on $topGroup. Minor tweaks could improve balance.'
          : 'Solid structure. Minor tweaks could improve balance.';
    } else if (score >= 5) {
      grade = 'C';
      gradeColor = const Color(0xFFE65100);
      gradeBgColor = const Color(0xFFFFF3E0);
      summary = 'Average workout.';
      detail = exerciseCount < 3
          ? 'Consider adding more exercises for better stimulus.'
          : 'Volume or muscle balance could be improved.';
    } else if (score >= 3) {
      grade = 'D';
      gradeColor = const Color(0xFFBF360C);
      gradeBgColor = const Color(0xFFFBE9E7);
      summary = 'Needs improvement.';
      detail = totalSets < 6
          ? 'Very low volume — add more sets for meaningful training stimulus.'
          : 'Heavily imbalanced load. Distribute exercises across more muscle groups.';
    } else {
      grade = 'F';
      gradeColor = const Color(0xFFB71C1C);
      gradeBgColor = const Color(0xFFFFEBEE);
      summary = 'Poor workout structure.';
      detail = 'Extreme imbalance or insufficient volume. Rebuild the plan.';
    }

    return _WorkoutAiResult(
      grade: grade,
      gradeColor: gradeColor,
      gradeBgColor: gradeBgColor,
      summary: summary,
      detail: detail,
      recoveryDays: recoveryDays,
      score: score,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _evaluate();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? result.gradeColor.withValues(alpha: 0.15)
        : result.gradeBgColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: result.gradeColor.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result.gradeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              result.grade,
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 13,
                      color: result.gradeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Evaluation',
                      style: AppTextStyles.caption.copyWith(
                        color: result.gradeColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  result.summary,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: result.gradeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.detail,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? Colors.white70
                        : result.gradeColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Recovery badge
          if (result.recoveryDays > 0)
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.gradeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: result.gradeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        size: 16,
                        color: result.gradeColor,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.recoveryDays}d',
                        style: AppTextStyles.caption.copyWith(
                          color: result.gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'rest',
                        style: AppTextStyles.caption.copyWith(
                          color: result.gradeColor,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
