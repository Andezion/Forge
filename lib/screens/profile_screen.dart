import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';
import '../services/data_manager.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'login_screen.dart';
import 'customization_screen.dart';
import 'weight_screen.dart';
import 'wellness_screen.dart';
import 'about_me_screen.dart';
import 'progress_charts_screen.dart';
import 'personal_records_screen.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  app_user.User? _cachedUser;
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_isLoadingUser) return;

    final auth = Provider.of<AuthService>(context, listen: false);
    final firebaseUser = auth.firebaseUser;

    if (firebaseUser != null &&
        (firebaseUser.displayName == null ||
            firebaseUser.displayName!.trim().isEmpty)) {
      setState(() => _isLoadingUser = true);
      try {
        final user = await auth.getUserProfile(firebaseUser.uid);
        if (mounted) {
          setState(() {
            _cachedUser = user;
            _isLoadingUser = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingUser = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileService>(context);
    final auth = Provider.of<AuthService>(context);
    final firebaseUser = auth.firebaseUser;
    final dataManager = Provider.of<DataManager>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          AppStrings.profile,
          style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              child: Column(
                children: [
                  _buildFramedAvatar(profile),
                  const SizedBox(height: 16),
                  if (firebaseUser?.displayName != null &&
                      (firebaseUser!.displayName ?? '').trim().isNotEmpty)
                    Text(
                      firebaseUser.displayName!,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  else if (_isLoadingUser)
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  else
                    Text(
                      _cachedUser?.name ?? 'User Name',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    firebaseUser?.email ?? '—',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.progress,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Body Weight',
                          profile.weightKg != null
                              ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                              : '—',
                          Icons.monitor_weight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Workouts',
                          dataManager.totalWorkouts().toString(),
                          Icons.fitness_center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuItem(
                    context,
                    'Progress Charts',
                    Icons.show_chart,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProgressChartsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'About Me',
                    Icons.fitness_center,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutMeScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.oneRepMax,
                    Icons.fitness_center,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PersonalRecordsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.wellness,
                    Icons.favorite,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WellnessScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Customisation',
                    Icons.color_lens,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CustomizationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Achievements',
                    Icons.emoji_events,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.bodyWeight,
                    Icons.monitor_weight,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WeightScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final authService =
                            Provider.of<AuthService>(context, listen: false);
                        await authService.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.logout,
                        style: AppTextStyles.button,
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFramedAvatar(ProfileService profile) {
    final imagePath = profile.imagePath;
    final idx = profile.frameIndex;

    Widget content;
    if (imagePath != null) {
      content = ClipOval(
        child: Image.file(
          File(imagePath),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      content = CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.surface,
        child: Icon(
          Icons.person,
          size: 50,
          color: AppColors.primary,
        ),
      );
    }

    if (idx == 1) {
      return AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final rotation = _animController.value * 2 * math.pi;
          return Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [AppColors.primary, Colors.pink, AppColors.primary],
                transform: GradientRotation(rotation),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                  child: SizedBox(width: 100, height: 100, child: content)),
            ),
          );
        },
      );
    }

    final decor = _avatarFrameDecoration(idx, AppColors.primary);
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(4),
      decoration: decor,
      child: ClipOval(child: SizedBox(width: 100, height: 100, child: content)),
    );
  }

  BoxDecoration _avatarFrameDecoration(int idx, Color primary) {
    switch (idx) {
      case 0:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.85),
        );
      case 2:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          border: Border.all(color: primary, width: 4),
        );
      case 3:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: primary.withValues(alpha: 0.6),
        );
      default:
        return BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            primary.withValues(alpha: 0.8),
            primary.withValues(alpha: 0.4)
          ]),
        );
    }
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body1),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
