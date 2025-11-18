import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User Name',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user@example.com',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8),
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
                          '75 kg',
                          Icons.monitor_weight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Workouts',
                          '42',
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
                      // TODO: Navigate to progress charts
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.oneRepMax,
                    Icons.fitness_center,
                    () {
                      // TODO: Navigate to 1RM tracker
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.wellness,
                    Icons.favorite,
                    () {
                      // TODO: Navigate to wellness tracking
                    },
                  ),
                  _buildMenuItem(
                    context,
                    AppStrings.bodyWeight,
                    Icons.monitor_weight,
                    () {
                      // TODO: Navigate to body weight tracking
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
