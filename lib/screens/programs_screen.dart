import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../services/data_manager.dart';
import '../services/groq_service.dart';
import '../services/settings_service.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/ai_suggested_workout.dart';
import 'ai_direction_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  bool _isGenerating = false;

  Future<void> _generateAiProgram() async {
    final direction = await Navigator.of(context).push<TrainingDirection>(
      MaterialPageRoute(builder: (_) => const AiDirectionScreen()),
    );
    if (direction == null) return;

    if (!mounted) return;
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final apiKey = Provider.of<SettingsService>(context, listen: false).groqApiKey;
    final groqService = GroqService(apiKey: apiKey);

    setState(() => _isGenerating = true);

    final suggestion = await groqService.generateProgram(
      history: dataManager.workoutHistory,
      exercises: dataManager.exercises,
      direction: direction,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (suggestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate program. Check your API key or internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    dataManager.addAiSuggestedWorkout(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final dataManager = Provider.of<DataManager>(context);

    final armwrestlingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('armwrestling_'))
        .toList();
    final streetliftingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('streetlifting_'))
        .toList();
    final powerliftingWorkouts = dataManager.workouts
        .where((w) => w.id.startsWith('powerlifting_'))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.programs,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select a training program',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),
          _buildAiSuggestedSection(context, dataManager),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.streetlifting,
            'Bodyweight training',
            Icons.sports_gymnastics,
            AppColors.streetlifting,
            streetliftingWorkouts,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.armwrestling,
            'Specialized training',
            Icons.back_hand,
            AppColors.armwrestling,
            armwrestlingWorkouts,
          ),
          const SizedBox(height: 16),
          _buildProgramCategory(
            context,
            AppStrings.powerlifting,
            'Programs for maximum strength',
            Icons.fitness_center,
            AppColors.powerlifting,
            powerliftingWorkouts,
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestedSection(
      BuildContext context, DataManager dataManager) {
    final suggestions = dataManager.aiSuggestedWorkouts;
    const aiColor = Color(0xFF6C63FF);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: suggestions.isNotEmpty,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: aiColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: aiColor, size: 28),
          ),
          title: Text(
            'AI Suggested',
            style: AppTextStyles.h4.copyWith(color: aiColor),
          ),
          subtitle: Text(
            'Personalized programs based on your history',
            style: AppTextStyles.caption,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Column(
                children: [
                  if (suggestions.isEmpty && !_isGenerating)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No suggestions yet. Generate one based on your workout history!',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSuggestionCard(context, s, aiColor, dataManager),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateAiProgram,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(
                          _isGenerating ? 'Generating...' : 'Generate Program'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: aiColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, AiSuggestedWorkout suggestion,
      Color color, DataManager dataManager) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.smart_toy, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.workout.name,
                        style: AppTextStyles.body1
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${suggestion.workout.exercises.length} exercises',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  onPressed: () =>
                      _showSuggestionDetails(context, suggestion, color),
                  tooltip: 'View details',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                suggestion.reasoning,
                style: AppTextStyles.caption.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        dataManager.rejectAiSuggestedWorkout(suggestion.id),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      dataManager.approveAiSuggestedWorkout(suggestion.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '"${suggestion.workout.name}" added to your workouts'),
                          backgroundColor: color,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuggestionDetails(
      BuildContext context, AiSuggestedWorkout suggestion, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(suggestion.workout.name,
                          style: AppTextStyles.h4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    suggestion.reasoning,
                    style: AppTextStyles.caption
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Exercises:',
                    style: AppTextStyles.body1
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: suggestion.workout.exercises.map((we) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.fitness_center,
                                    color: color, size: 14),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(we.exercise.name,
                                        style: AppTextStyles.body2.copyWith(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                      '${we.sets} sets × ${we.targetReps} reps'
                                      '${we.weight > 0 ? ' @ ${we.weight}kg' : ''}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  WorkoutSession? _findLastSessionForWorkout(
      DataManager dataManager, String workoutId) {
    final history = dataManager.workoutHistory;
    for (var i = history.length - 1; i >= 0; i--) {
      if (history[i].session.workoutId == workoutId) {
        return history[i].session;
      }
    }
    return null;
  }

  Widget _buildProgramCategory(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<Workout> workouts,
  ) {
    if (workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: color),
          ),
          subtitle: Text(
            description,
            style: AppTextStyles.caption,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: workouts.map((workout) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      _showWorkoutDetails(context, workout, color);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fitness_center, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.name,
                                    style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${workout.exercises.length} exercises',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, Workout workout, Color color) {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final lastSession = _findLastSessionForWorkout(dataManager, workout.id);
    final completedExerciseIds = lastSession != null
        ? lastSession.exerciseResults.map((r) => r.exercise.id).toSet()
        : <String>{};
    final hasHistory = lastSession != null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  workout.name,
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercises:',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...workout.exercises.map((we) {
                          final wasCompleted = !hasHistory ||
                              completedExerciseIds.contains(we.exercise.id);
                          final exerciseColor =
                              wasCompleted ? color : AppColors.error;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: exerciseColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    wasCompleted ? Icons.check : Icons.close,
                                    color: exerciseColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        we.exercise.name,
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: wasCompleted
                                              ? null
                                              : AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        '${we.sets} sets × ${we.targetReps} reps${we.weight > 0 ? ' @ ${we.weight}kg' : ''}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: wasCompleted
                                              ? null
                                              : AppColors.error
                                                  .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      if (!wasCompleted)
                                        Text(
                                          'Not completed last time',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.error,
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Program "${workout.name}" selected'),
                              backgroundColor: color,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Select Program'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
