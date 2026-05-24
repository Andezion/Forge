import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../services/tour_service.dart';
import '../services/leaderboard_service.dart';
import '../services/data_manager.dart';
import '../services/settings_service.dart';
import '../services/profile_service.dart';
import '../widgets/tour_overlay.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'friends_screen.dart';
import 'programs_screen.dart';
import 'workshop_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
    const FriendsScreen(),
    const ProgramsScreen(),
    const WorkshopScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final tourService = Provider.of<TourService>(context, listen: false);
      tourService.addListener(_onTourChanged);
      await tourService.checkAndStartTour();

      if (!mounted) return;
      _syncStatsOnStartup();
    });
  }

  @override
  void dispose() {
    final tourService = Provider.of<TourService>(context, listen: false);
    tourService.removeListener(_onTourChanged);
    super.dispose();
  }

  Future<void> _syncStatsOnStartup() async {
    if (!mounted) return;
    try {
      final leaderboardService =
          Provider.of<LeaderboardService>(context, listen: false);
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);
      final profileService =
          Provider.of<ProfileService>(context, listen: false);
      final dataManager = DataManager();

      await leaderboardService.syncUserStats(
        workoutHistory: dataManager.workoutHistory,
        isProfileHidden: settingsService.isProfileHidden,
        userBodyWeight: profileService.weightKg,
        country: profileService.country,
        city: profileService.city,
        displayName: settingsService.nickname,
      );
    } catch (e) {
      debugPrint('[MAIN] Error syncing stats on startup: $e');
    }
  }

  void _onTourChanged() {
    if (!mounted) return;
    final tourService = Provider.of<TourService>(context, listen: false);
    if (tourService.isActive) {
      final targetTab = tourService.currentStep.tabIndex;
      if (targetTab != _currentIndex) {
        setState(() => _currentIndex = targetTab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourService = Provider.of<TourService>(context);
    return Stack(
      children: [
        Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outlined),
                activeIcon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.profile,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outlined),
                activeIcon: const Icon(Icons.people),
                label: AppLocalizations.of(context)!.friends,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_outlined),
                activeIcon: const Icon(Icons.fitness_center),
                label: AppLocalizations.of(context)!.programs,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.build_outlined),
                activeIcon: const Icon(Icons.build),
                label: AppLocalizations.of(context)!.workshop,
              ),
            ],
          ),
        ),
        if (tourService.isActive) const TourOverlay(),
      ],
    );
  }
}
