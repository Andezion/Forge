import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'services/data_manager.dart';
import 'services/theme_service.dart';
import 'services/profile_service.dart';
import 'services/wellness_service.dart';
import 'services/friends_service.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dataManager),
        ChangeNotifierProvider.value(value: appColor),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: wellnessService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: friendsService),
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

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColor.color,
          primary: appColor.color,
          brightness: appColor.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
        brightness: appColor.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: appColor.color,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
