import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Forge';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get workout => 'Workout';

  @override
  String get friends => 'Friends';

  @override
  String get calendar => 'Calendar';

  @override
  String get progress => 'Progress';

  @override
  String get workouts => 'Workouts';

  @override
  String get bodyWeight => 'Body Weight';

  @override
  String get wellness => 'Wellness';

  @override
  String get oneRepMax => '1RM Calculator';

  @override
  String get logout => 'Log Out';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String get customization => 'Customization';

  @override
  String get achievements => 'Achievements';

  @override
  String get progressCharts => 'Progress Charts';

  @override
  String get aboutMe => 'About Me';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get nickname => 'Nickname';

  @override
  String get region => 'Region';

  @override
  String get language => 'Language';

  @override
  String get unitsOfMeasurement => 'Units of Measurement';

  @override
  String get weight => 'Weight';

  @override
  String get distance => 'Distance';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get publicProfile => 'Public Profile';

  @override
  String get publicProfileDesc =>
      'Allow others to see your profile information';

  @override
  String get showWorkoutHistory => 'Show Workout History';

  @override
  String get showWorkoutHistoryDesc =>
      'Display your workout history to friends';

  @override
  String get showPersonalRecords => 'Show Personal Records';

  @override
  String get showPersonalRecordsDesc => 'Let others see your personal records';

  @override
  String get allowFriendRequests => 'Allow Friend Requests';

  @override
  String get allowFriendRequestsDesc =>
      'Enable others to send you friend requests';

  @override
  String get saveProfileInfo => 'Save Profile Info';

  @override
  String get profileInfoSaved => 'Profile information saved!';

  @override
  String get themeColorUpdated => 'Theme color updated!';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get enterNickname => 'Enter your nickname';

  @override
  String get enterRegion => 'e.g., USA, Europe, Asia';

  @override
  String get kilograms => 'Kilograms (kg)';

  @override
  String get pounds => 'Pounds (lb)';

  @override
  String get meters => 'Meters (m)';

  @override
  String get feet => 'Feet (ft)';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String workoutSaved(String name) {
    return 'Workout saved: $name';
  }

  @override
  String get deleteWorkout => 'Delete Workout';

  @override
  String deleteWorkoutConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get workoutCompleted => 'Workout completed!';

  @override
  String get createYourWorkout => 'Create Your Workout';

  @override
  String get customizeTrainingProgram => 'Customize your training program';

  @override
  String get createNewWorkout => 'Create New Workout';

  @override
  String get myWorkouts => 'My Workouts';

  @override
  String get noWorkoutsYet => 'No workouts yet. Create your first workout!';

  @override
  String get exitWorkout => 'Exit Workout?';

  @override
  String get progressWillBeLost => 'Your progress will be lost.';

  @override
  String get exit => 'Exit';

  @override
  String setComplete(int number) {
    return 'Set $number Complete';
  }

  @override
  String targetReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Target: $reps reps',
      one: 'Target: 1 rep',
    );
    return '$_temp0';
  }

  @override
  String get howWasExercise => 'How was this exercise?';

  @override
  String get workoutComplete => 'Workout Complete!';

  @override
  String duration(String time) {
    return 'Duration: $time';
  }

  @override
  String completedExercises(int count) {
    return 'Completed: $count';
  }

  @override
  String get skippedExercises => 'Skipped Exercises:';

  @override
  String get noRemainingExercises => 'No remaining exercises';

  @override
  String get total => 'Total';

  @override
  String exerciseNum(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String setNum(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get completedSets => 'Completed Sets';

  @override
  String repsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reps',
      one: '1 rep',
    );
    return '$_temp0';
  }

  @override
  String get completeSet => 'Complete Set';

  @override
  String get startSet => 'Start Set';

  @override
  String get howDoYouFeel => 'How do you feel?';

  @override
  String get energy => 'Energy';

  @override
  String get mood => 'Mood';

  @override
  String get tiredness => 'Tiredness';

  @override
  String get stress => 'Stress';

  @override
  String get muscleSoreness => 'Muscle soreness';

  @override
  String get saved => 'Saved';

  @override
  String get submit => 'Submit';

  @override
  String get submitLocked => 'Submit (locked)';

  @override
  String nextEntryIn(String time) {
    return 'Next entry in $time';
  }

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get specifyWeight => 'Specify your current weight';

  @override
  String get reset => 'Reset';

  @override
  String get challengeFeatureComingSoon => 'Challenge feature coming soon';

  @override
  String get challenge => 'Challenge';

  @override
  String get compareFeatureComingSoon => 'Compare feature coming soon';

  @override
  String get compare => 'Compare';

  @override
  String get messageFeatureComingSoon => 'Message feature coming soon';

  @override
  String get message => 'Message';

  @override
  String get rememberMe => 'Remember me';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get thirtyDays => '30 days';

  @override
  String get ninetyDays => '90 days';

  @override
  String get oneHundredEightyDays => '180 days';

  @override
  String get oneYear => '1 year';

  @override
  String get customRange => 'Custom';

  @override
  String get selectATab => 'Select a tab';

  @override
  String get noData => 'No data';

  @override
  String get information => 'Information';

  @override
  String get statistics => 'Statistics';

  @override
  String get selectExercise => 'Select Exercise';

  @override
  String get exerciseContributions => 'Exercise Contributions';

  @override
  String get noDataToDisplay => 'No data to display';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noDataAvailable => 'No data available for display';

  @override
  String get completeOneWorkout =>
      'Complete at least one workout to see progress charts';

  @override
  String get overallStrength => 'Overall Strength';

  @override
  String get bodyWeightTab => 'Body Weight';

  @override
  String get volume => 'Volume';

  @override
  String get frequency => 'Frequency';

  @override
  String get consistency => 'Consistency';

  @override
  String get exerciseProgress => 'Exercise Progress';

  @override
  String get progressionRecommendations => 'Progression Recommendations';

  @override
  String get notEnoughData => 'Not enough data for recommendations';

  @override
  String get workoutComparison => 'Workout Comparison';

  @override
  String get detailedAnalysis => 'Detailed analysis';

  @override
  String get worldRecords => 'World Records';

  @override
  String get allExercises => 'All Exercises';

  @override
  String get weightLabel => 'Weight';

  @override
  String get reps => 'Reps';

  @override
  String get date => 'Date';

  @override
  String get oneRmEstimated => '1RM (estimated)';

  @override
  String get recordHistory => 'Record History';

  @override
  String get allPersonalRecords => 'All Personal Records';

  @override
  String get federation => 'Federation';

  @override
  String get strengthCoefficients => 'Strength Coefficients';

  @override
  String get totalStrength => 'Total Strength';

  @override
  String get wilks => 'Wilks';

  @override
  String get dots => 'Dots';

  @override
  String get progressOverTime => 'Progress Over Time';

  @override
  String get passwordResetEmailSent => 'Password reset email sent.';

  @override
  String get noWorkoutsAvailable =>
      'No workouts available. Create one in Workshop!';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get workoutCalendar => 'Workout Calendar';

  @override
  String get addFriend => 'Add Friend';

  @override
  String friendRemoved(String name) {
    return '$name removed from friends';
  }

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String get requestDeclined => 'Request declined';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String get pleaseEnterEmail => 'Please enter an email address';

  @override
  String get friendRequestSent => 'Friend request sent!';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get profileSection => 'Profile';

  @override
  String get profileImage => 'Profile Image';

  @override
  String get choosePhoto => 'Choose Photo';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get profileFrame => 'Profile Frame';

  @override
  String get programs => 'Programs';

  @override
  String openProgram(String program) {
    return 'Open program: $program';
  }

  @override
  String get recentAchievements => 'Recent Achievements';

  @override
  String get personalRecords => 'Personal Records';

  @override
  String get activity => 'Activity';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'days';

  @override
  String get totalWeightLifted => 'Total Weight Lifted';

  @override
  String get wilksScore => 'Wilks Score';

  @override
  String get memberSince => 'Member Since';

  @override
  String get selectAnExercise => 'Select an exercise to view progress';

  @override
  String get polish => 'Polski';

  @override
  String get hideFromLeaderboards => 'Hide from Leaderboards';

  @override
  String get hideFromLeaderboardsDesc =>
      'Your stats will not appear in public rankings';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get age => 'Age';

  @override
  String get hintAge => 'e.g. 25';

  @override
  String get years => 'years';

  @override
  String get heightLabel => 'Height';

  @override
  String get hintHeight => 'e.g. 175';

  @override
  String get hintWeight => 'e.g. 70.5';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get location => 'Location';

  @override
  String get locationDesc =>
      'Used for country & city rankings in the community leaderboard';

  @override
  String get country => 'Country';

  @override
  String get hintCountry => 'e.g. Ukraine';

  @override
  String get city => 'City';

  @override
  String get hintCity => 'e.g. Kyiv';

  @override
  String get trainingGoals => 'Training Goals';

  @override
  String get trainingGoalsDesc => 'What are you trying to achieve?';

  @override
  String get strengthGoal => 'Strength';

  @override
  String get hypertrophyGoal => 'Hypertrophy';

  @override
  String get enduranceGoal => 'Endurance';

  @override
  String get fatLossGoal => 'Fat Loss';

  @override
  String get generalFitnessGoal => 'General Fitness';

  @override
  String get trainingSchedule => 'Training Schedule';

  @override
  String get trainingExperience => 'Training Experience';

  @override
  String get hintYearsTraining => 'e.g. 2.5';

  @override
  String get daysPerWeek => 'Days per week you can train';

  @override
  String get daysPerWeekDesc =>
      'Used to determine how often workouts are recommended';

  @override
  String get sessionDurationLabel => 'Typical session duration';

  @override
  String get sessionDurationDesc =>
      'Affects how many exercises are included per workout';

  @override
  String get trainingPreferences => 'Training Preferences';

  @override
  String get experienceLevel => 'Experience Level';

  @override
  String get preferredIntensity => 'Preferred Intensity';

  @override
  String get intensityLight => 'Easier workouts, longer recovery';

  @override
  String get intensityModerate => 'Balanced intensity and volume';

  @override
  String get intensityIntense => 'Challenging workouts, push limits';

  @override
  String get trainingFocus => 'Training Focus';

  @override
  String get trainingFocusDesc =>
      'What muscle groups or areas do you want to prioritise?';

  @override
  String get hintFocus => 'e.g. legs, upper body, core';

  @override
  String get injuriesLimitations => 'Injuries & Limitations';

  @override
  String get injuriesDesc =>
      'Any injuries or areas to avoid? Workouts will be scored away from these.';

  @override
  String get hintInjuries => 'e.g. knee, lower back, shoulder';

  @override
  String get pleaseSelectGoal => 'Please select at least one goal';

  @override
  String get profileSavedSuccessfully => 'Profile saved successfully';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get targets => 'Targets';

  @override
  String get meals => 'Meals';

  @override
  String get recalculate => 'Recalculate';

  @override
  String get setNutritionGoal => 'Set a nutrition goal to get started.';

  @override
  String get tapRefreshToCalculate =>
      'Tap the refresh button to calculate your targets.';

  @override
  String get algorithm => 'Algorithm';

  @override
  String get mifflinFormula => 'Mifflin-St Jeor formula';

  @override
  String get aiRecommendation => 'AI Recommendation';

  @override
  String get groqModel => 'Groq - GPT-OSS 120B';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get setGoalForMeals =>
      'Set a goal and calculate targets to see your meal schedule.';

  @override
  String get mealSchedule => 'Meal Schedule';

  @override
  String mealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals per day',
      one: '1 meal per day',
    );
    return '$_temp0';
  }

  @override
  String get dailyWater => 'Daily Water';

  @override
  String get nutritionGoal => 'Nutrition Goal';

  @override
  String get notSet => 'Not set';

  @override
  String get mealWaterReminders => 'Meal & Water Reminders';

  @override
  String get activeStatus => 'Active';

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get waterReminderInterval => 'Water Reminder Interval';

  @override
  String get kcalPerDay => 'kcal / day';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get waterMacro => 'Water';

  @override
  String goalBadge(String goal) {
    return 'Goal: $goal';
  }

  @override
  String get completeProfileFirst =>
      'Please complete your profile first (weight, height, age, gender).';

  @override
  String get aiUnavailable => 'AI unavailable, using algorithm only.';

  @override
  String get notificationDenied => 'Notification permission denied.';

  @override
  String get remindersScheduled => 'Reminders scheduled!';

  @override
  String get remindersCancelled => 'All reminders cancelled.';

  @override
  String get any => 'Any';

  @override
  String get primaryMuscle => 'Primary';

  @override
  String get secondaryMuscle => 'Secondary';

  @override
  String get stabilizerMuscle => 'Stabilizer';

  @override
  String configureExercise(String name) {
    return 'Configure $name';
  }

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get editExercise => 'Edit exercise';

  @override
  String get deleteExercise => 'Delete exercise';

  @override
  String get draftRestored => 'Draft restored';

  @override
  String get exerciseAlreadyInList => 'This exercise is already in the list';

  @override
  String alternativeAdded(String name) {
    return 'Alternative added: $name';
  }

  @override
  String get addAtLeastOneExercise => 'Please add at least one exercise';

  @override
  String get challenges => 'Challenges';

  @override
  String get communityRankings => 'Community Rankings';

  @override
  String get emailLabel => 'Email';

  @override
  String get friendEmailHint => 'friend@example.com';

  @override
  String get addFriendsFirst => 'Add friends first to create challenges';

  @override
  String get mustBeLoggedIn => 'You must be logged in';

  @override
  String get challengeCreated => 'Challenge created successfully!';

  @override
  String get requests => 'Requests';

  @override
  String get weekA => 'Week A (this week)';

  @override
  String get weekB => 'Week B (next week)';

  @override
  String get viewDetails => 'View details';

  @override
  String get searchWorkouts => 'Search workouts...';

  @override
  String get searchExercise => 'Search exercise...';

  @override
  String get noWorkoutsAvailableCreate =>
      'No workouts available. Create one first.';

  @override
  String get noWorkoutsAvailableWorkshop =>
      'No workouts available. Create one in Workshop first.';

  @override
  String get apiKeySaved => 'API key saved';

  @override
  String get apiKeyRemoved => 'API key removed';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get aiConfig => 'AI Config';

  @override
  String get yourGroqApiKey => 'Your Groq API Key';

  @override
  String get exerciseLibrary => 'Exercise Library';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get addFriendDesc =>
      'Enter the email address of the person you want to add as a friend.';

  @override
  String get remove => 'Remove';

  @override
  String get apiKeyConfigured => 'API key is configured';

  @override
  String get noApiKeySet => 'No API key set';

  @override
  String get aiNoKeyWarning => 'AI features will not work without a key';

  @override
  String get workshop => 'Workshop';

  @override
  String get close => 'Close';

  @override
  String get create => 'Create';

  @override
  String get refresh => 'Refresh';

  @override
  String get or => 'OR';

  @override
  String get noExercisesInWorkout =>
      'This workout has no exercises. Add exercises in Workshop!';

  @override
  String get todaysWorkout => 'Today\'s Workout';

  @override
  String get workoutsThisMonth => 'Workouts this month';

  @override
  String get dayStreak => 'Day streak';

  @override
  String get restDayToday => 'rest day today';

  @override
  String get chooseOne => 'Choose one:';

  @override
  String get noRecommendationAvailable => 'No recommendation available';

  @override
  String get createWorkoutsForRecommendations =>
      'Create workouts in Workshop to get personalized recommendations';

  @override
  String get restDayLevel => 'Rest Day';

  @override
  String get lightLevel => 'Light';

  @override
  String get moderateLevel => 'Moderate';

  @override
  String get intenseLevel => 'Intense';

  @override
  String get exercisesColonLabel => 'Exercises:';

  @override
  String get expandWorkout => 'Expand';

  @override
  String get createPlanDesc =>
      'Create a weekly training plan\nto follow a structured schedule.';

  @override
  String get noWorkoutsFound => 'No workouts found';

  @override
  String get noMuscleDataAvailable => 'No muscle data available';

  @override
  String get muscleLoad => 'Muscle Load';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String get selectTrainingProgram => 'Select a training program';

  @override
  String get aiSuggested => 'AI Suggested';

  @override
  String get personalizedProgramsDesc =>
      'Personalized programs based on your history';

  @override
  String get noSuggestionsYet =>
      'No suggestions yet. Generate one based on your workout history!';

  @override
  String get generating => 'Generating...';

  @override
  String get generateProgram => 'Generate Program';

  @override
  String workoutAddedToWorkouts(String name) {
    return '\"$name\" added to your workouts';
  }

  @override
  String get notCompletedLastTime => 'Not completed last time';

  @override
  String programSelected(String name) {
    return 'Program \"$name\" selected';
  }

  @override
  String get selectProgram => 'Select Program';

  @override
  String get customisation => 'Customisation';

  @override
  String get logWorkout => 'Log Workout';

  @override
  String logWorkoutFor(String dayLabel) {
    return 'Log workout for $dayLabel';
  }

  @override
  String get noWorkoutsOnDay => 'No workouts on this day';

  @override
  String get completed => 'Completed';

  @override
  String get expand => 'Expand';

  @override
  String get collapse => 'Collapse';

  @override
  String exerciseUpdated(String name) {
    return '$name updated';
  }

  @override
  String get exerciseInUse => 'Exercise in Use';

  @override
  String exerciseInUseConfirm(String name) {
    return 'The exercise \"$name\" is currently used in one or more workout programs. Are you sure you want to delete it?';
  }

  @override
  String get deleteExerciseTitle => 'Delete Exercise';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String exerciseDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get noFriendsDesc => 'Add friends to track their progress';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get receivedRequests => 'Received Requests';

  @override
  String get sentRequests => 'Sent Requests';

  @override
  String lastWorkoutDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Last workout: $days days ago',
      one: 'Last workout: 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get noWorkoutsYetFriend => 'No workouts yet';

  @override
  String weightKgDisplay(String weight) {
    return 'Weight: $weight';
  }

  @override
  String nowFriendsWith(String name) {
    return 'You are now friends with $name';
  }

  @override
  String get pending => 'Pending';

  @override
  String removeFriendConfirm(String name) {
    return 'Are you sure you want to remove $name from your friends?';
  }

  @override
  String get active => 'Active';

  @override
  String get errorLoadingChallenges => 'Error loading challenges';

  @override
  String get noChallengesYet => 'No challenges yet';

  @override
  String get createChallengeDesc =>
      'Create a challenge to compete with friends';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get createChallenge => 'Create Challenge';

  @override
  String get chooseChallengeType => 'Choose a challenge type';

  @override
  String get selectFriends => 'Select Friends';

  @override
  String get selectFriendsToChallenge => 'Select friends to challenge';

  @override
  String get durationDays => 'Duration (days)';

  @override
  String durationDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get pleaseEnterPlanName => 'Please enter a plan name';

  @override
  String get weeklySchedule => 'Weekly schedule';

  @override
  String get chooseOneOnDay => 'Choose one on this day:';

  @override
  String get selectWorkout => 'Select workout';

  @override
  String get startingWeek => 'Starting week:';

  @override
  String get muscleRecovery => 'Muscle Recovery';

  @override
  String get readyToTrain => 'Ready to train';

  @override
  String get inRecovery => 'In recovery';

  @override
  String get requireRest => 'Require rest';

  @override
  String get selectWorkoutForAnalytics =>
      'Select a workout to view detailed analytics';

  @override
  String get workoutProgress => 'Workout Progress';

  @override
  String get recommendedDeloadWeek => 'Recommended Deload Week';

  @override
  String get completeMoreWorkouts => 'Complete more workouts for analysis';

  @override
  String get improving => 'Improving';

  @override
  String get stable => 'Stable';

  @override
  String get declining => 'Declining';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get noPlansYet => 'No plans yet';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get trainingPlans => 'Training Plans';

  @override
  String get todayFromPlan => 'Today from plan';

  @override
  String get activatePlan => 'Activate';

  @override
  String get deactivatePlan => 'Deactivate';

  @override
  String get activeLabel => 'ACTIVE';

  @override
  String get deletePlan => 'Delete plan?';

  @override
  String deletePlanConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String moreExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count more exercises',
      one: '+ 1 more exercise',
    );
    return '$_temp0';
  }

  @override
  String get tourRestartTooltip => 'App tour';

  @override
  String get tourWelcomeTitle => 'Welcome to Forge!';

  @override
  String get tourWelcomeDesc =>
      'Here\'s a quick tour of everything the app has to offer. Follow along to discover all the features that will help you reach your fitness goals.';

  @override
  String get tourCalendarTitle => 'Workout Calendar';

  @override
  String get tourCalendarDesc =>
      'The calendar shows your workout history. Highlighted days have completed sessions. Tap any day to view or log a workout.';

  @override
  String get tourTodayWorkoutTitle => 'Today\'s Workout';

  @override
  String get tourTodayWorkoutDesc =>
      'The AI analyzes your training history and recovery to recommend the best workout for today. The confidence percentage shows how certain the recommendation is.';

  @override
  String get tourMuscleRecoveryTitle => 'Muscle Recovery';

  @override
  String get tourMuscleRecoveryDesc =>
      'This card shows the recovery status of each muscle group - which are ready to train, currently recovering, or need more rest before your next session.';

  @override
  String get tourStartWorkoutTitle => 'Start Workout';

  @override
  String get tourStartWorkoutDesc =>
      'Tap this button to begin a training session. You\'ll choose from your saved workouts or follow your active training plan.';

  @override
  String get tourStatisticsTitle => 'Statistics';

  @override
  String get tourStatisticsDesc =>
      'Track your monthly workout count and current day streak here. Keep your streak going to build long-term consistency!';

  @override
  String get tourTrainingPlansTitle => 'Training Plans';

  @override
  String get tourTrainingPlansDesc =>
      'Create structured weekly training plans by assigning workouts to specific days. Activate a plan to follow a schedule automatically.';

  @override
  String get tourProfileTitle => 'Your Profile';

  @override
  String get tourProfileDesc =>
      'This tab contains all your personal information, health metrics, progress charts, and activity summary.';

  @override
  String get tourAboutMeTitle => 'About Me';

  @override
  String get tourAboutMeDesc =>
      'Fill in your personal details - age, height, weight, training goals, and experience level. This data helps the AI personalize recommendations for you.';

  @override
  String get tourBodyWeightTitle => 'Body Weight';

  @override
  String get tourBodyWeightDesc =>
      'Log your body weight regularly to track changes over time. The chart visualizes your weight trend and helps you monitor progress.';

  @override
  String get tourWellnessTitle => 'Wellness Check-in';

  @override
  String get tourWellnessDesc =>
      'Log your daily wellness - energy level, mood, stress, and muscle soreness. This helps the AI avoid pushing you too hard on low-energy days.';

  @override
  String get tourNutritionTitle => 'Nutrition';

  @override
  String get tourNutritionDesc =>
      'Set your nutrition goal and receive personalized daily targets for calories, protein, carbs, and fat. You can also enable meal and water reminders.';

  @override
  String get tourAchievementsTitle => 'Achievements';

  @override
  String get tourAchievementsDesc =>
      'Unlock achievements by hitting milestones - completing workouts, setting personal records, and maintaining streaks. Check your progress here.';

  @override
  String get tourSettingsTitle => 'Settings';

  @override
  String get tourSettingsDesc =>
      'Configure the app to your preferences - change the language, units of measurement, privacy settings, and visual theme.';

  @override
  String get tourFriendsTitle => 'Friends';

  @override
  String get tourFriendsDesc =>
      'Connect with friends to follow each other\'s progress. Send friend requests by email, view profiles, and compare stats.';

  @override
  String get tourLeaderboardTitle => 'Leaderboard';

  @override
  String get tourLeaderboardDesc =>
      'See where you rank in global, country, and city leaderboards based on strength metrics. Compete and rise through the ranks!';

  @override
  String get tourChallengesTitle => 'Challenges';

  @override
  String get tourChallengesDesc =>
      'Create workout challenges with friends and compete over a set time period. Who can complete the most sessions?';

  @override
  String get tourProgramsTitle => 'Programs';

  @override
  String get tourProgramsDesc =>
      'Discover AI-generated training programs tailored to your workout history. Select one to get a structured training schedule.';

  @override
  String get tourCreatePlanTitle => 'Create a Plan';

  @override
  String get tourCreatePlanDesc =>
      'Build a custom weekly training plan by assigning your workouts to specific days of the week. Activate it to follow a structured routine.';

  @override
  String get tourWorkshopTitle => 'Workshop';

  @override
  String get tourWorkshopDesc =>
      'The Workshop is your personal gym - create and manage all your exercises and workouts here. Everything you build is available throughout the app.';

  @override
  String get tourExerciseLibraryTitle => 'Exercise Library';

  @override
  String get tourExerciseLibraryDesc =>
      'Browse hundreds of built-in exercises. Filter by muscle group, view detailed instructions, and add your own custom exercises.';

  @override
  String get tourCreateWorkoutTitle => 'Create a Workout';

  @override
  String get tourCreateWorkoutDesc =>
      'Build custom workouts by combining exercises from the library. Configure sets, reps, and weights for each exercise to match your training style.';

  @override
  String get tourAiConfigTitle => 'AI Configuration';

  @override
  String get tourAiConfigDesc =>
      'Enter your Groq API key here to unlock AI-powered features - personalized workout recommendations, nutrition advice, and smart training programs.';

  @override
  String get tourFinishTitle => 'You\'re All Set!';

  @override
  String get tourFinishDesc =>
      'You now know the key features of Forge. Start by completing your profile, creating your first workout in Workshop, and logging your first session. Good luck!';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitCm => 'cm';

  @override
  String get heightUnitTitle => 'Height';

  @override
  String get centimeters => 'Centimeters (cm)';

  @override
  String get feetInches => 'Feet & inches (ft/in)';

  @override
  String get unitFt => 'ft';

  @override
  String get unitIn => 'in';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get addMuscleGroup => 'Add Muscle Group';

  @override
  String get addWorkoutToDay => 'Add workout';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get armwrestling => 'Arm Wrestling';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get createExercise => 'Create Exercise';

  @override
  String get createWorkout => 'Create Workout';

  @override
  String get description => 'Description';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get email => 'Email';

  @override
  String get errorFieldRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Invalid email format';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorPasswordsDontMatch => 'Passwords do not match';

  @override
  String get everyTwoWeeks => 'Every 2 weeks';

  @override
  String get everyWeek => 'Every week';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get intensityFor => 'Intensity for';

  @override
  String get intensityPrimary => 'Primary';

  @override
  String get intensitySecondary => 'Secondary';

  @override
  String get intensityStabilizer => 'Stabilizer';

  @override
  String get login => 'Login';

  @override
  String get muscleGroupBack => 'Back';

  @override
  String get muscleGroupBiceps => 'Biceps';

  @override
  String get muscleGroupCalves => 'Calves';

  @override
  String get muscleGroupCardio => 'Cardio';

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get muscleGroupForearms => 'Forearms';

  @override
  String get muscleGroupGlutes => 'Glutes';

  @override
  String get muscleGroupLegs => 'Legs';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupTriceps => 'Triceps';

  @override
  String get muscleGroupWrists => 'Wrists';

  @override
  String get muscleGroups => 'Muscle Groups';

  @override
  String get name => 'Name';

  @override
  String get noWorkoutToday => 'Rest day';

  @override
  String get oneRepMaxFull => '1RM (One Rep Max)';

  @override
  String get password => 'Password';

  @override
  String get pickMuscleGroup => 'Pick muscle group';

  @override
  String get planName => 'Plan Name';

  @override
  String get powerlifting => 'Powerlifting';

  @override
  String get pressToAddMuscleGroups =>
      'Press the button below to add muscle groups';

  @override
  String get register => 'Register';

  @override
  String get search => 'Search';

  @override
  String get sets => 'Sets';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get streetlifting => 'Streetlifting';

  @override
  String get targetRepsLabel => 'Target Reps';

  @override
  String get trainingPlan => 'My Plan';

  @override
  String get workoutName => 'Workout Name';

  @override
  String get pleaseEnterReps => 'Please enter the number of reps';

  @override
  String get switchExercise => 'Switch Exercise';

  @override
  String currentExerciseName(String name) {
    return 'Current: $name';
  }

  @override
  String get chooseAlternative => 'Choose alternative:';

  @override
  String switchedTo(String name) {
    return 'Switched to $name';
  }

  @override
  String nextExerciseName(String name) {
    return 'Next: $name';
  }

  @override
  String get chooseNext => 'Choose next';

  @override
  String get chooseAnyExercise => 'Choose Any Exercise';

  @override
  String get declineExerciseTitle => 'Decline exercise?';

  @override
  String declineExerciseConfirm(String name) {
    return '\"$name\" will be marked as skipped for this session and won\'t appear again.';
  }

  @override
  String get chooseNextExercise => 'Choose next exercise';

  @override
  String get nextByProgram => 'Next by program';

  @override
  String get skipped => 'Skipped';

  @override
  String get aiCalorieUnavailable => 'AI calorie estimate unavailable.';

  @override
  String kcalBurned(int kcal) {
    return '~$kcal kcal burned';
  }

  @override
  String calorieEstimateUnavailable(String error) {
    return 'Calorie estimate unavailable: $error';
  }

  @override
  String get declinedLabel => 'Declined:';

  @override
  String get finishExerciseEarlyTitle => 'Finish exercise early?';

  @override
  String finishExerciseEarlyConfirm(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'You completed $done of $total sets. Finish this exercise now?',
      one: 'You completed $done of 1 set. Finish this exercise now?',
    );
    return '$_temp0';
  }

  @override
  String get finish => 'Finish';

  @override
  String get finishEarly => 'Finish Early';

  @override
  String lastTimeReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Last time: $reps reps',
      one: 'Last time: 1 rep',
    );
    return '$_temp0';
  }

  @override
  String get swap => 'Swap';

  @override
  String get addSet => 'Add Set';

  @override
  String get insertExercise => 'Insert Exercise';

  @override
  String get endWorkoutTitle => 'End workout?';

  @override
  String get endWorkoutNoExercises =>
      'You haven\'t completed any exercises. End anyway?';

  @override
  String get endAction => 'End';

  @override
  String get quickWorkout => 'Quick Workout';

  @override
  String exercisesTotal(int count) {
    return 'Exercises: $count';
  }

  @override
  String get bodyweight => 'Bodyweight';

  @override
  String targetWeight(String weight) {
    return 'Target: $weight';
  }

  @override
  String get noExercisesYet => 'No exercises yet';

  @override
  String tapAddExerciseToStart(String button) {
    return 'Tap \"$button\" to get started';
  }

  @override
  String get endWorkout => 'End Workout';

  @override
  String exerciseNumber(int number) {
    return 'Exercise $number';
  }

  @override
  String weightWithUnit(String unit) {
    return 'Weight ($unit)';
  }

  @override
  String get startExercise => 'Start Exercise';

  @override
  String fixSetTitle(int number) {
    return 'Fix set $number';
  }

  @override
  String recordedReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Recorded: $reps reps',
      one: 'Recorded: 1 rep',
    );
    return '$_temp0';
  }

  @override
  String get fix => 'Fix';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'How did it go? What to change next time?';

  @override
  String get note => 'Note';

  @override
  String get today => 'today';

  @override
  String moreItems(int count) {
    return '+$count more...';
  }

  @override
  String repsProgress(int current, int previous) {
    return '$current / $previous reps';
  }

  @override
  String get focusLegs => 'legs';

  @override
  String get focusUpperBody => 'upper body';

  @override
  String get focusCore => 'core';

  @override
  String get focusGlutes => 'glutes';

  @override
  String get focusBack => 'back';

  @override
  String get focusChest => 'chest';

  @override
  String get focusShoulders => 'shoulders';

  @override
  String get focusArms => 'arms';

  @override
  String get focusCardio => 'cardio';

  @override
  String get injuryKnee => 'knee';

  @override
  String get injuryLowerBack => 'lower back';

  @override
  String get injuryShoulder => 'shoulder';

  @override
  String get injuryWrist => 'wrist';

  @override
  String get injuryElbow => 'elbow';

  @override
  String get injuryAnkle => 'ankle';

  @override
  String get injuryHip => 'hip';

  @override
  String get injuryNeck => 'neck';

  @override
  String get injuryHamstring => 'hamstring';

  @override
  String get injuryGroin => 'groin';

  @override
  String get hintWeightLb => 'e.g. 155';

  @override
  String worldRecordMatchingUnavailable(String error) {
    return 'World-record matching unavailable: $error';
  }

  @override
  String get myRecords => 'My Records';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get worldRecordDataUnavailable =>
      'World record data unavailable — rank will update once loaded.';

  @override
  String yourBest(String weight) {
    return 'Your best: $weight';
  }

  @override
  String worldRecordFederation(String federation, String weight) {
    return 'World record ($federation): $weight';
  }

  @override
  String weightToNextRank(String weight, String rank) {
    return '+$weight to $rank';
  }

  @override
  String get maxRankAchieved => 'Maximum rank achieved!';

  @override
  String get rankSystem => 'Rank System';

  @override
  String get rankSystemDesc =>
      'Based on % of the world record in your weight class';

  @override
  String rankPercentRange(String min, String max) {
    return '$min% – $max% of world record';
  }

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get actualMax => 'Actual Max';

  @override
  String oneRepOnDate(String date) {
    return '1 rep · $date';
  }

  @override
  String get noOneRepSets => 'No 1-rep sets';

  @override
  String get estimated1RM => 'Estimated 1RM';

  @override
  String get noWorkoutsLast30Days => 'No workouts in last 30 days';

  @override
  String oneRmValue(String weight) {
    return '1RM: $weight';
  }

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get completeWorkoutsForRecords =>
      'Complete workouts to track your personal records';

  @override
  String estimatedShort(String weight) {
    return 'est. $weight';
  }

  @override
  String get yourWeightClass => 'Your Weight Class';

  @override
  String get coefficientsDesc =>
      'These coefficients normalize your strength relative to body weight for fair comparison';

  @override
  String get big3Total => 'Big 3 Total';

  @override
  String liftsOutOfThree(int count) {
    return '$count/3 lifts';
  }

  @override
  String get ratingBeginner => 'Beginner';

  @override
  String get ratingIntermediate => 'Intermediate';

  @override
  String get ratingAdvanced => 'Advanced';

  @override
  String get ratingElite => 'Elite';

  @override
  String get ratingWorldClass => 'World Class';

  @override
  String get liftSquat => 'Squat';

  @override
  String get liftBenchPress => 'Bench Press';

  @override
  String get liftDeadlift => 'Deadlift';

  @override
  String get strengthCoefficient => 'Strength Coefficient';

  @override
  String get aboutStrengthCoefficient => 'About Strength Coefficient';

  @override
  String get strengthCoefficientDesc =>
      'This coefficient is calculated based on your progress across ALL exercises. 100 = baseline (your starting weights), 150 = 50% stronger overall, 200 = 2x stronger. It tracks your long-term strength development, not just recent workouts.';

  @override
  String get strengthCoefficientProgress => 'Strength Coefficient Progress';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get startingWeight => 'Starting Weight';

  @override
  String get change => 'Change';

  @override
  String get averageWeight => 'Average Weight';

  @override
  String get weightTrackingTip => 'Weight Tracking Tip';

  @override
  String weightTrackingTipDesc(String feature) {
    return 'For detailed weight history tracking, use the \"$feature\" feature in the main menu to update your current weight regularly.';
  }

  @override
  String get periodThisWeek => 'This Week';

  @override
  String get periodLast30Days => 'Last 30 Days';

  @override
  String get periodLast90Days => 'Last 90 Days';

  @override
  String get periodLast180Days => 'Last 180 Days';

  @override
  String get periodLastYear => 'Last Year';

  @override
  String totalVolumeFor(String period) {
    return 'Total Volume ($period)';
  }

  @override
  String get avgPerWeek => 'Avg/Week';

  @override
  String get weeklyVolume => 'Weekly Volume';

  @override
  String get dailyVolume => 'Daily Volume';

  @override
  String get weightHistory => 'Weight History';

  @override
  String get workoutsPerWeek => 'Workouts/Week';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get workoutFrequencyChart => 'Workout Frequency (workouts per week)';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get setsCompleted => 'Sets Completed';

  @override
  String get setsPlanned => 'Sets Planned';

  @override
  String get workoutCompletionRate => 'Workout Completion Rate';

  @override
  String get maximumWeight => 'Maximum Weight';

  @override
  String get maximumWeightProgress => 'Maximum Weight Progress';

  @override
  String get volumeWeightReps => 'Volume (weight × repetitions)';

  @override
  String get intensityPercent => 'Intensity (%)';

  @override
  String get thousandSuffix => 'K';

  @override
  String get millionSuffix => 'M';

  @override
  String get you => 'You';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get challengeAccepted => 'Challenge accepted!';

  @override
  String get challengeDeclined => 'Challenge declined';

  @override
  String get challengeEnded => 'Ended';

  @override
  String daysLeft(int count) {
    return '${count}d left';
  }

  @override
  String hoursLeft(int count) {
    return '${count}h left';
  }

  @override
  String minutesLeft(int count) {
    return '${count}m left';
  }

  @override
  String workoutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts',
      one: '1 workout',
    );
    return '$_temp0';
  }

  @override
  String get challengeWorkoutsTitle => 'Workout Challenge';

  @override
  String get challengeWorkoutsDesc => 'Who can complete the most workouts?';

  @override
  String get challengeWeightTitle => 'Weight Challenge';

  @override
  String get challengeWeightDesc => 'Who can lift the most total weight?';

  @override
  String get challengeExerciseTitle => 'Exercise Challenge';

  @override
  String get challengeExerciseDesc =>
      'Who can lift the most in a specific exercise?';

  @override
  String get challengeStreakTitle => 'Streak Challenge';

  @override
  String get challengeStreakDesc =>
      'Who can maintain the longest training streak?';

  @override
  String get challengeConsistencyTitle => 'Consistency Challenge';

  @override
  String get challengeConsistencyDesc =>
      'Who can train the most days in a row?';

  @override
  String get scopeGlobal => 'Global';

  @override
  String get scopeMyLeague => 'My League';

  @override
  String get scopeCountry => 'Country';

  @override
  String get scopeCity => 'City';

  @override
  String get periodAllTime => 'All Time';

  @override
  String get periodThisMonth => 'This Month';

  @override
  String get tabTotalWeight => 'Total Weight';

  @override
  String get tabRecords => 'Records';

  @override
  String get setCountryForRankings =>
      'Set your country in Profile → About Me to see country rankings';

  @override
  String get setCityForRankings =>
      'Set your city in Profile → About Me to see city rankings';

  @override
  String get addFriendsForLeague => 'Add friends to see your league rankings';

  @override
  String get noDataYet => 'No data available yet';

  @override
  String get exerciseColon => 'Exercise:';

  @override
  String get selectAnExerciseShort => 'Select an exercise';

  @override
  String get noRecord => 'No record';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get matchPoor => 'Poor match';

  @override
  String get matchFair => 'Fair match';

  @override
  String get matchModerate => 'Moderate match';

  @override
  String get matchGood => 'Good match';

  @override
  String get matchGreat => 'Great match';

  @override
  String get quickWorkoutDesc =>
      'No plan? Just go — add exercises as you train';

  @override
  String get noSavedWorkoutsYet => 'No saved workouts yet';

  @override
  String get createInWorkshopOrQuick =>
      'Create one in Workshop or start a Quick Workout above';

  @override
  String get recommendedForToday => 'Recommended for Today';

  @override
  String get allWorkouts => 'All Workouts';

  @override
  String get preview => 'Preview';

  @override
  String get progressionRecommendationsTitle => 'Progression Recommendations';

  @override
  String get recommendedDeloadDesc =>
      'Recent workouts have been hard. Reduce the load for recovery.';

  @override
  String get current => 'Current';

  @override
  String get suggested => 'Suggested';

  @override
  String get reasonForChange => 'Reason for change:';

  @override
  String get completedInRecentWorkouts => 'Completed in recent workouts:';

  @override
  String get averageWeightColon => 'Average weight:';

  @override
  String get averageRepsColon => 'Average reps:';

  @override
  String get estimated1RMColon => 'Estimated 1RM:';

  @override
  String get weightTrendColon => 'Weight trend:';

  @override
  String trendRising(String delta) {
    return '↑ Rising ($delta)';
  }

  @override
  String trendFalling(String delta) {
    return '↓ Falling ($delta)';
  }

  @override
  String get trendStable => '→ Stable';

  @override
  String get daysSinceLastSession => 'Days since last session:';

  @override
  String get generateProgramFailed =>
      'Failed to generate program. Check your API key or internet connection.';

  @override
  String get bodyweightTraining => 'Bodyweight training';

  @override
  String get specializedTraining => 'Specialized training';

  @override
  String get maxStrengthPrograms => 'Programs for maximum strength';

  @override
  String get approve => 'Approve';

  @override
  String get aiEvaluation => 'AI Evaluation';

  @override
  String get evalEmptySummary => 'Empty workout';

  @override
  String get evalEmptyDetail => 'Add exercises to get an AI evaluation.';

  @override
  String get evalExcellentSummary => 'Excellent workout!';

  @override
  String evalExcellentDetail(int count) {
    return 'Well-structured, balanced load across $count muscle groups. Smart volume choice.';
  }

  @override
  String get evalGoodSummary => 'Good workout.';

  @override
  String evalGoodDetailFocus(String group) {
    return 'Solid structure with emphasis on $group. Minor tweaks could improve balance.';
  }

  @override
  String get evalGoodDetail =>
      'Solid structure. Minor tweaks could improve balance.';

  @override
  String get evalAverageSummary => 'Average workout.';

  @override
  String get evalAverageDetailFew =>
      'Consider adding more exercises for better stimulus.';

  @override
  String get evalAverageDetail => 'Volume or muscle balance could be improved.';

  @override
  String get evalWeakSummary => 'Needs improvement.';

  @override
  String get evalWeakDetailLowVolume =>
      'Very low volume — add more sets for meaningful training stimulus.';

  @override
  String get evalWeakDetailImbalanced =>
      'Heavily imbalanced load. Distribute exercises across more muscle groups.';

  @override
  String get evalPoorSummary => 'Poor workout structure.';

  @override
  String get evalPoorDetail =>
      'Extreme imbalance or insufficient volume. Rebuild the plan.';

  @override
  String daysShort(int count) {
    return '${count}d';
  }

  @override
  String exerciseUpdatedName(String name) {
    return 'Exercise updated: $name';
  }

  @override
  String exerciseAddedName(String name) {
    return 'Exercise added: $name';
  }

  @override
  String get typeWeightReps => 'Weight + Reps';

  @override
  String get typeRepsOnly => 'Reps Only';

  @override
  String get typeCardio => 'Cardio';

  @override
  String get editWorkout => 'Edit Workout';

  @override
  String get draft => 'Draft';

  @override
  String get noExercisesAddedYet => 'No exercises added yet';

  @override
  String get tapPlusToAddExercises => 'Tap the + button to add exercises';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String alternativeN(int number, String name) {
    return 'Alt $number: $name';
  }

  @override
  String get addAlternative => 'Add Alternative';

  @override
  String get completeWellnessForRecommendation =>
      'Complete wellness check to get workout recommendation';

  @override
  String wellnessAverage(String avg, String answers) {
    return 'Avg: $avg — $answers';
  }

  @override
  String get todaysRecommendation => 'Today\'s Recommendation';

  @override
  String exercisesWithCount(int count) {
    return 'Exercises ($count)';
  }

  @override
  String overallConfidence(String percent) {
    return 'Overall Confidence: $percent%';
  }

  @override
  String get privateProfile => 'Private Profile';

  @override
  String privateProfileDesc(String name) {
    return '$name has a private profile.\nOnly their username and avatar are visible.';
  }

  @override
  String get rank => 'Rank';

  @override
  String get totalVolume => 'Total Volume';

  @override
  String tonnesShort(String value) {
    return '$value t';
  }

  @override
  String get compareStats => 'Compare Stats';

  @override
  String challengeFriend(String name) {
    return 'Challenge $name';
  }

  @override
  String challengeSentTo(String name) {
    return 'Challenge sent to $name!';
  }

  @override
  String get statsComparison => 'Stats Comparison';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get youInParens => '(You)';

  @override
  String aheadBy(String diff, String percent) {
    return 'You\'re ahead by $diff ($percent%)';
  }

  @override
  String behindBy(String diff, String percent) {
    return 'Behind by $diff ($percent%)';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String unlockedOfTotal(int unlocked, int total) {
    return '$unlocked / $total Unlocked';
  }

  @override
  String get tabAll => 'All';

  @override
  String get tabStrength => 'Strength';

  @override
  String get tabSocial => 'Social';

  @override
  String get tabSpecial => 'Special';

  @override
  String get noAchievementsInCategory => 'No achievements in this category';

  @override
  String unlockedOn(String date) {
    return 'Unlocked $date';
  }

  @override
  String get unlocked => 'Unlocked';

  @override
  String get userNamePlaceholder => 'User Name';

  @override
  String get selectWorkoutForAnalyticsHint =>
      'Select a workout to view detailed analytics';

  @override
  String kcalValue(String value) {
    return '$value kcal';
  }

  @override
  String get nutritionGoalQuestion => 'What is your nutrition goal?';

  @override
  String get nutritionGoalDesc =>
      'This determines your daily calorie target and macro split.';

  @override
  String get confirmGoal => 'Confirm Goal';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get choosePrimaryColor => 'Choose the primary app color';

  @override
  String get exerciseType => 'Exercise Type';

  @override
  String get exerciseTypeDesc =>
      'Determines what metrics are tracked during workout';

  @override
  String get typeWeightRepsDesc => 'Sets, reps & weight';

  @override
  String get typeRepsOnlyDesc => 'Sets & reps, no weight';

  @override
  String get typeCardioDesc => 'Duration only';

  @override
  String get chooseTrainingDirection => 'Choose Training Direction';

  @override
  String get aiProgramGeneration => 'AI Program Generation';

  @override
  String get aiProgramGenerationDesc =>
      'AI will tailor the program to your goals and workout history';

  @override
  String get selectDirection => 'Select direction';

  @override
  String get directionFullBody => 'Full Body';

  @override
  String get directionFullBodyDesc =>
      'Balanced development of all muscle groups';

  @override
  String get directionPowerliftingDesc =>
      'Max strength: squat, bench, deadlift';

  @override
  String get directionArmWrestlingDesc =>
      'Forearms, wrists, grip & pulling strength';

  @override
  String get directionStreetliftingDesc =>
      'Weighted calisthenics & bodyweight skills';

  @override
  String get testing => 'Testing...';

  @override
  String get testKey => 'Test key';

  @override
  String get howToGetApiKey => 'How to get a free API key';

  @override
  String get apiKeyStep1 => 'Go to console.groq.com and sign up (it\'s free)';

  @override
  String get apiKeyStep2 => 'Open \"API Keys\" in the left menu';

  @override
  String get apiKeyStep3 => 'Click \"Create API Key\", give it a name';

  @override
  String get apiKeyStep4 => 'Copy the key and paste it here';

  @override
  String get apiKeyFreeTier =>
      'The free tier is generous — plenty for personal use.';

  @override
  String get readyToTrainColon => 'Ready to train:';

  @override
  String get chooseAWorkout => 'Choose a workout:';

  @override
  String macroProteinShort(String grams) {
    return 'P: ${grams}g';
  }

  @override
  String macroCarbsShort(String grams) {
    return 'C: ${grams}g';
  }

  @override
  String macroFatShort(String grams) {
    return 'F: ${grams}g';
  }

  @override
  String waterAmount(String liters, String ml) {
    return '$liters L  ($ml ml)';
  }

  @override
  String confidencePercent(int percent) {
    return '$percent% confidence';
  }

  @override
  String withWeight(String weight) {
    return ' with $weight';
  }

  @override
  String topPercentOfAthletes(String percent) {
    return 'Top $percent% of athletes';
  }

  @override
  String get nice => 'Nice!';

  @override
  String get rankWooden => 'Wooden';

  @override
  String get rankStone => 'Stone';

  @override
  String get rankIron => 'Iron';

  @override
  String get rankBronze => 'Bronze';

  @override
  String get rankSilver => 'Silver';

  @override
  String get rankGold => 'Gold';

  @override
  String get rankDiamond => 'Diamond';

  @override
  String get goalAggressiveFatLoss => 'Aggressive Fat Loss';

  @override
  String get goalFatLoss => 'Fat Loss';

  @override
  String get goalMaintain => 'Maintain Weight';

  @override
  String get goalLeanBulk => 'Lean Bulk';

  @override
  String get goalBulk => 'Bulk';

  @override
  String get goalAggressiveFatLossDesc =>
      'Aggressive deficit for fast fat loss. -500 kcal/day.';

  @override
  String get goalFatLossDesc =>
      'Moderate deficit for steady fat loss. -300 kcal/day.';

  @override
  String get goalMaintainDesc =>
      'Eat at maintenance to preserve current weight.';

  @override
  String get goalLeanBulkDesc =>
      'Small surplus for muscle gain with minimal fat. +250 kcal/day.';

  @override
  String get goalBulkDesc =>
      'Significant surplus for maximum muscle growth. +500 kcal/day.';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealAfternoonSnack => 'Afternoon Snack';

  @override
  String get mealMidMorningSnack => 'Mid-Morning Snack';

  @override
  String notifMealTitle(String meal) {
    return '🍽 Time for $meal';
  }

  @override
  String notifMealBody(String kcal, String protein) {
    return '$kcal kcal · ${protein}g protein';
  }

  @override
  String get notifMealChannel => 'Meal Reminders';

  @override
  String get notifWaterTitle => '💧 Time to drink water';

  @override
  String get notifWaterBody => 'Stay hydrated — your body will thank you!';

  @override
  String get notifWaterChannel => 'Water Reminders';

  @override
  String get recoveryReallyNeedTrain => 'Really need to train!';

  @override
  String get recoveryDefinitelyTime => 'Definitely time to train';

  @override
  String get recoveryTrainedToday => 'Trained today - rest';

  @override
  String recoveryProgress(int days, int optimal) {
    return 'Recovery ($days/$optimal days)';
  }

  @override
  String get recoveryGoodTime => 'Good time to train';

  @override
  String recoveryLongTime(int days) {
    return 'Long time no train ($days days)';
  }

  @override
  String get standardProgression => 'Standard progression';

  @override
  String get reasonDeloadRecommended => 'Deload week recommended for recovery';

  @override
  String get reasonRestTrainedYesterday => 'Rest day - you trained yesterday';

  @override
  String get reasonRestWellness =>
      'Rest day - wellness indicators suggest recovery needed';

  @override
  String get reasonRestOverall =>
      'Rest day recommended based on overall condition';

  @override
  String get reasonHighReadiness => 'High readiness - great day for training';

  @override
  String get reasonGoodReadiness => 'Good readiness for a moderate workout';

  @override
  String get reasonLightTraining => 'Light training recommended today';

  @override
  String reasonDaysSinceWorkout(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days since last workout - good recovery time',
      one: '1 day since last workout - good recovery time',
    );
    return '$_temp0';
  }

  @override
  String get reasonWellRecovered => 'Well-recovered from last session';

  @override
  String get reasonOneDayRecovery =>
      'One day recovery - intensity adjusted accordingly';

  @override
  String reasonReadyToTrain(String muscles) {
    return 'Ready to train: $muscles';
  }

  @override
  String reasonRequireRest(String muscles) {
    return 'Require rest: $muscles';
  }

  @override
  String get reasonHighSoreness =>
      'High muscle soreness noted - weights adjusted';

  @override
  String get reasonLowEnergy => 'Low energy - consider lighter intensity';

  @override
  String get reasonGoodEnergy => 'Good energy levels detected';

  @override
  String get progNoHistory => 'No history — using programmed parameters';

  @override
  String get progNewExercise =>
      'New exercise — parameters tailored to your goals';

  @override
  String get progDeload =>
      'Deload week — recovering at 90% of your last weight';

  @override
  String progExcellentReps(String reps) {
    return 'Excellent performance — +$reps rep target';
  }

  @override
  String get progAddingSet => 'Good progress — adding a set';

  @override
  String get progMaintainReps =>
      'Challenging workout — maintaining last session reps';

  @override
  String get progBodyweightMaintain =>
      'Bodyweight exercise — maintaining level';

  @override
  String get progWellnessReduced =>
      'Reduced load — wellness adjustment applied';

  @override
  String get progLimitedRecovery =>
      'Limited recovery — maintaining last session weight';

  @override
  String progTrendingUp(String delta) {
    return 'Trending up — $delta based on your last month';
  }

  @override
  String get progLoadReduced =>
      'Load reduced — easing off based on your recent trend';

  @override
  String get progStable => 'Stable — maintaining your last session weight';

  @override
  String get progWellnessConsidered => ' (wellness considered)';

  @override
  String get popupRankUpTitle => 'Rank Up!';

  @override
  String popupRankUpMessage(String rank) {
    return 'You\'ve reached $rank rank.';
  }

  @override
  String get popupGreatProgressTitle => 'Great Progress!';

  @override
  String get popupGreatProgressMessage =>
      'Your overall rank score is climbing fast.';

  @override
  String get popupNewRecordTitle => 'New Personal Record!';

  @override
  String get popupFirstWorkoutTitle => 'First Workout Complete!';

  @override
  String get popupFirstWorkoutMessage => 'Welcome to your strength journey.';

  @override
  String get rankReasonConsistency =>
      'your training consistency and achievements';

  @override
  String rankReasonLifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracked lifts measured against world-record benchmarks',
      one: '1 tracked lift measured against world-record benchmarks',
    );
    return '$_temp0';
  }

  @override
  String rankReasonSummary(String basis, int workouts, int streak) {
    return 'Based on $basis, $workouts logged workouts and a $streak-day streak.';
  }

  @override
  String get rankReasonNotEnough =>
      'Not enough workout history yet — rank will refine as you log more sessions.';

  @override
  String get errMustBeLoggedInFriends =>
      'You must be logged in to send friend requests';

  @override
  String get errCannotAddYourself => 'You cannot add yourself as a friend';

  @override
  String get errNoUserWithEmail => 'No user found with this email address';

  @override
  String get errAlreadyFriends => 'You are already friends with this user';

  @override
  String get errRequestAlreadySent => 'Friend request already sent';

  @override
  String get errSendRequestFailed =>
      'Failed to send friend request. Please try again.';

  @override
  String get errUserDataNotFound => 'User data not found';

  @override
  String get errAcceptRequestFailed =>
      'Failed to accept friend request. Please try again.';

  @override
  String get errRejectRequestFailed =>
      'Failed to reject friend request. Please try again.';

  @override
  String get errRemoveFriendFailed =>
      'Failed to remove friend. Please try again.';

  @override
  String get errCancelRequestFailed =>
      'Failed to cancel request. Please try again.';

  @override
  String get errCreateChallengeFailed =>
      'Failed to create challenge. Please try again.';

  @override
  String get errAcceptChallengeFailed => 'Failed to accept challenge';

  @override
  String get errDeclineChallengeFailed => 'Failed to decline challenge';

  @override
  String get errRegistrationFailed => 'Registration failed.';

  @override
  String get errWeakPassword => 'The password is too weak.';

  @override
  String get errEmailInUse => 'The email address is already in use.';

  @override
  String get errInvalidEmailAuth => 'The email address is invalid.';

  @override
  String get errSignInFailed => 'Sign in failed.';

  @override
  String get errUserNotFound => 'No user found for that email.';

  @override
  String get errWrongPassword => 'Incorrect password.';

  @override
  String get errUserDisabled => 'This user has been disabled.';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String get achFirstWorkoutTitle => 'First Steps';

  @override
  String get achFirstWorkoutDesc => 'Complete your first workout';

  @override
  String get achWorkout10Title => 'Getting Started';

  @override
  String get achWorkout50Title => 'Dedicated';

  @override
  String get achWorkout100Title => 'Century';

  @override
  String get achWorkout500Title => 'Legend';

  @override
  String achCompleteWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complete $count workouts',
      one: 'Complete 1 workout',
    );
    return '$_temp0';
  }

  @override
  String get achWeight1000Title => 'Lightweight';

  @override
  String get achWeight10000Title => 'Heavy Lifter';

  @override
  String get achWeight100000Title => 'Iron Warrior';

  @override
  String achLiftTotal(String weight) {
    return 'Lift $weight total';
  }

  @override
  String get achWilks300Title => 'Strong';

  @override
  String get achWilks400Title => 'Elite Strength';

  @override
  String achReachWilks(int value) {
    return 'Reach $value Wilks coefficient';
  }

  @override
  String get achStreak7Title => 'Week Warrior';

  @override
  String get achStreak30Title => 'Monthly Master';

  @override
  String get achStreak100Title => 'Unstoppable';

  @override
  String achTrainDaysInRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Train $count days in a row',
      one: 'Train 1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get achEarlyBirdTitle => 'Early Bird';

  @override
  String get achEarlyBirdDesc => 'Complete 10 workouts before 8 AM';

  @override
  String get achNightOwlTitle => 'Night Owl';

  @override
  String get achNightOwlDesc => 'Complete 10 workouts after 8 PM';

  @override
  String get achFirstFriendTitle => 'Social';

  @override
  String get achFirstFriendDesc => 'Add your first friend';

  @override
  String get achFriends10Title => 'Popular';

  @override
  String get achFriends10Desc => 'Have 10 friends';

  @override
  String get achChallengeWinnerTitle => 'Champion';

  @override
  String get achChallengeWinnerDesc => 'Win your first challenge';

  @override
  String get achChallenge5Title => 'Competitor';

  @override
  String get achChallenge5Desc => 'Complete 5 challenges';

  @override
  String get achNewYearTitle => 'New Year, New Me';

  @override
  String get achNewYearDesc => 'Train on New Year\'s Day';

  @override
  String get achBirthdayTitle => 'Birthday Gains';

  @override
  String get achBirthdayDesc => 'Train on your birthday';

  @override
  String get achPerfectWeekTitle => 'Perfect Week';

  @override
  String get achPerfectWeekDesc => 'Complete all planned workouts in a week';

  @override
  String get measurements => 'Measurements';

  @override
  String get measurementShoulders => 'Shoulders';

  @override
  String get measurementChest => 'Chest';

  @override
  String get measurementBicepsRight => 'Right biceps';

  @override
  String get measurementBicepsLeft => 'Left biceps';

  @override
  String get measurementForearmRight => 'Right forearm';

  @override
  String get measurementForearmLeft => 'Left forearm';

  @override
  String get measurementThighRight => 'Right thigh';

  @override
  String get measurementThighLeft => 'Left thigh';

  @override
  String get measurementCalfRight => 'Right calf';

  @override
  String get measurementCalfLeft => 'Left calf';

  @override
  String get measurementsHint =>
      'Tap a ring around the body to enter its circumference';

  @override
  String get measurementCircumference => 'Circumference';

  @override
  String measurementInvalid(String min, String max) {
    return 'Enter a value between $min and $max';
  }

  @override
  String measurementUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get challengesSocial => 'Social';

  @override
  String get challengesPersonal => 'Personal';

  @override
  String get challengeYourself => 'Challenge yourself';

  @override
  String get challengeYourselfHint =>
      'Leave everyone unselected to challenge only yourself.';

  @override
  String get personalChallengesIntro =>
      'System challenges verified by the camera. Put your phone so that your whole body is visible.';

  @override
  String get exercisePushUps => 'Push-ups';

  @override
  String personalBest(int count) {
    return 'Best: $count';
  }

  @override
  String get personalChallengeDone => 'Done';

  @override
  String get startAttempt => 'Start';

  @override
  String get poseCameraTitle => 'Pose tracking';

  @override
  String get poseSwitchCamera => 'Switch camera';

  @override
  String get poseStartRecording => 'Start recording';

  @override
  String get poseStopRecording => 'Stop recording';

  @override
  String get poseLoadingModel => 'Loading pose model…';

  @override
  String get poseNoPerson => 'Step back so your whole body is in the frame';

  @override
  String poseLandmarksVisible(int count) {
    return 'Points: $count/33';
  }

  @override
  String poseCameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String get poseNoCamera => 'No camera available on this device';

  @override
  String get poseCameraPermissionDenied =>
      'Camera access denied. Allow it in system settings.';

  @override
  String get poseRepCounterSoon => 'Automatic rep counting is coming soon';

  @override
  String poseTarget(int count) {
    return 'Goal: $count';
  }

  @override
  String get poseRecordingSaved => 'Recording saved';

  @override
  String get poseDeleteRecording => 'Delete';

  @override
  String get poseKeepRecording => 'Keep';
}
