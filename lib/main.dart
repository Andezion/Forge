import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'services/data_manager.dart';
import 'services/theme_service.dart';
import 'services/profile_service.dart';
import 'services/wellness_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dataManager = DataManager();
  await dataManager.initialize();

  final appColor = AppColor();
  await appColor.load();

  final profileService = ProfileService();
  await profileService.load();

  final wellnessService = WellnessService();
  await wellnessService.load();

  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dataManager),
        ChangeNotifierProvider.value(value: appColor),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: wellnessService),
        ChangeNotifierProvider.value(value: authService),
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
        ),
        useMaterial3: true,
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
      ),
      home: const LoginScreen(),
    );
  }
}
