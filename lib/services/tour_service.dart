import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TourStep {
  final int tabIndex;
  const TourStep({required this.tabIndex});
}

class TourService extends ChangeNotifier {
  static const _shouldStartTourKey = 'should_start_tour';

  bool _isActive = false;
  int _currentStepIndex = 0;

  bool get isActive => _isActive;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _steps.length;
  TourStep get currentStep => _steps[_currentStepIndex];
  bool get isFirstStep => _currentStepIndex == 0;
  bool get isLastStep => _currentStepIndex == _steps.length - 1;

  static const List<TourStep> _steps = [
    TourStep(tabIndex: 0), 
    TourStep(tabIndex: 0),
    TourStep(tabIndex: 0), 
    TourStep(tabIndex: 0),
    TourStep(tabIndex: 0), 
    TourStep(tabIndex: 0), 
    TourStep(tabIndex: 0),
    TourStep(tabIndex: 1),
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 1), 
    TourStep(tabIndex: 2),
    TourStep(tabIndex: 2), 
    TourStep(tabIndex: 2), 
    TourStep(tabIndex: 3),
    TourStep(tabIndex: 3),
    TourStep(tabIndex: 4), 
    TourStep(tabIndex: 4), 
    TourStep(tabIndex: 4),
    TourStep(tabIndex: 4), 
    TourStep(tabIndex: 0), 
  ];

  static String stepTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0: return l10n.tourWelcomeTitle;
      case 1: return l10n.tourCalendarTitle;
      case 2: return l10n.tourTodayWorkoutTitle;
      case 3: return l10n.tourMuscleRecoveryTitle;
      case 4: return l10n.tourStartWorkoutTitle;
      case 5: return l10n.tourStatisticsTitle;
      case 6: return l10n.tourTrainingPlansTitle;
      case 7: return l10n.tourProfileTitle;
      case 8: return l10n.tourAboutMeTitle;
      case 9: return l10n.tourBodyWeightTitle;
      case 10: return l10n.tourWellnessTitle;
      case 11: return l10n.tourNutritionTitle;
      case 12: return l10n.tourAchievementsTitle;
      case 13: return l10n.tourSettingsTitle;
      case 14: return l10n.tourFriendsTitle;
      case 15: return l10n.tourLeaderboardTitle;
      case 16: return l10n.tourChallengesTitle;
      case 17: return l10n.tourProgramsTitle;
      case 18: return l10n.tourCreatePlanTitle;
      case 19: return l10n.tourWorkshopTitle;
      case 20: return l10n.tourExerciseLibraryTitle;
      case 21: return l10n.tourCreateWorkoutTitle;
      case 22: return l10n.tourAiConfigTitle;
      case 23: return l10n.tourFinishTitle;
      default: return '';
    }
  }

  static String stepDescription(int index, AppLocalizations l10n) {
    switch (index) {
      case 0: return l10n.tourWelcomeDesc;
      case 1: return l10n.tourCalendarDesc;
      case 2: return l10n.tourTodayWorkoutDesc;
      case 3: return l10n.tourMuscleRecoveryDesc;
      case 4: return l10n.tourStartWorkoutDesc;
      case 5: return l10n.tourStatisticsDesc;
      case 6: return l10n.tourTrainingPlansDesc;
      case 7: return l10n.tourProfileDesc;
      case 8: return l10n.tourAboutMeDesc;
      case 9: return l10n.tourBodyWeightDesc;
      case 10: return l10n.tourWellnessDesc;
      case 11: return l10n.tourNutritionDesc;
      case 12: return l10n.tourAchievementsDesc;
      case 13: return l10n.tourSettingsDesc;
      case 14: return l10n.tourFriendsDesc;
      case 15: return l10n.tourLeaderboardDesc;
      case 16: return l10n.tourChallengesDesc;
      case 17: return l10n.tourProgramsDesc;
      case 18: return l10n.tourCreatePlanDesc;
      case 19: return l10n.tourWorkshopDesc;
      case 20: return l10n.tourExerciseLibraryDesc;
      case 21: return l10n.tourCreateWorkoutDesc;
      case 22: return l10n.tourAiConfigDesc;
      case 23: return l10n.tourFinishDesc;
      default: return '';
    }
  }

  Future<void> checkAndStartTour() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shouldStartTourKey) == true) {
      await prefs.remove(_shouldStartTourKey);
      startTour();
    }
  }

  void startTour() {
    _currentStepIndex = 0;
    _isActive = true;
    notifyListeners();
  }

  void nextStep() {
    if (!isLastStep) {
      _currentStepIndex++;
      notifyListeners();
    } else {
      closeTour();
    }
  }

  void previousStep() {
    if (!isFirstStep) {
      _currentStepIndex--;
      notifyListeners();
    }
  }

  void closeTour() {
    _isActive = false;
    notifyListeners();
  }

  static Future<void> scheduleForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shouldStartTourKey, true);
  }
}
