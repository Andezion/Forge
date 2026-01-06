import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'services/data_manager.dart';
import 'services/theme_service.dart';
import 'services/profile_service.dart';
import 'services/wellness_service.dart';
import 'services/friends_service.dart';
import 'services/settings_service.dart';
import 'services/workout_recommendation_service.dart';
import 'models/app_settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final dataManager = DataManager();
  await dataManager.initialize();

  final appColor = AppColor();
  await appColor.load();

  final profileService = ProfileService();
  await profileService.load();

  final wellnessService = WellnessService();
  await wellnessService.load();

  final authService = AuthService();

  final friendsService = FriendsService();

  final settingsService = SettingsService();
  await settingsService.load();

  final workoutRecommendationService = WorkoutRecommendationService(
    wellnessService: wellnessService,
    dataManager: dataManager,
    profileService: profileService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dataManager),
        ChangeNotifierProvider.value(value: appColor),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: wellnessService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: friendsService),
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider.value(value: workoutRecommendationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppColor>(context);
    final settings = Provider.of<SettingsService>(context);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: appColor.getTheme(),
      locale: settings.language == AppLanguage.russian
          ? const Locale('ru')
          : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      home: const LoginScreen(),
    );
  }
}
