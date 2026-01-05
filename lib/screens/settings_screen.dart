import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nicknameController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsService>(context, listen: false);
    _nicknameController.text = settings.nickname ?? '';
    _regionController.text = settings.region ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<SettingsService, AppColor>(
      builder: (context, settings, appColor, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: appColor.color,
          foregroundColor: AppColors.textOnPrimary,
          title: Text(
            l10n.settings,
            style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.profileInformation),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        labelText: l10n.nickname,
                        hintText: l10n.enterNickname,
                        prefixIcon: Icon(Icons.person, color: appColor.color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) {
                        settings.setNickname(value.isEmpty ? null : value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: l10n.region,
                        hintText: l10n.enterRegion,
                        prefixIcon:
                            Icon(Icons.location_on, color: appColor.color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) {
                        settings.setRegion(value.isEmpty ? null : value);
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        settings.setNickname(_nicknameController.text.isEmpty
                            ? null
                            : _nicknameController.text);
                        settings.setRegion(_regionController.text.isEmpty
                            ? null
                            : _regionController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.profileInfoSaved),
                            backgroundColor: appColor.color,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor.color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.saveProfileInfo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.language),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildRadioTile<AppLanguage>(
                      title: l10n.english,
                      value: AppLanguage.english,
                      groupValue: settings.language,
                      icon: Icons.language,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setLanguage(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildRadioTile<AppLanguage>(
                      title: l10n.russian,
                      value: AppLanguage.russian,
                      groupValue: settings.language,
                      icon: Icons.language,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setLanguage(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.unitsOfMeasurement),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weight,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRadioTile<WeightUnit>(
                      title: l10n.kilograms,
                      value: WeightUnit.kg,
                      groupValue: settings.weightUnit,
                      icon: Icons.monitor_weight,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setWeightUnit(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildRadioTile<WeightUnit>(
                      title: l10n.pounds,
                      value: WeightUnit.lb,
                      groupValue: settings.weightUnit,
                      icon: Icons.monitor_weight,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setWeightUnit(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.distance,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRadioTile<DistanceUnit>(
                      title: l10n.meters,
                      value: DistanceUnit.meters,
                      groupValue: settings.distanceUnit,
                      icon: Icons.straighten,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setDistanceUnit(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildRadioTile<DistanceUnit>(
                      title: l10n.feet,
                      value: DistanceUnit.feet,
                      groupValue: settings.distanceUnit,
                      icon: Icons.straighten,
                      iconColor: appColor.color,
                      onChanged: (value) {
                        if (value != null) settings.setDistanceUnit(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.privacySettings),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: l10n.publicProfile,
                      subtitle: l10n.publicProfileDesc,
                      value: settings.isProfilePublic,
                      icon: Icons.public,
                      iconColor: appColor.color,
                      activeColor: appColor.color,
                      onChanged: (value) {
                        settings.setProfilePublic(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: l10n.showWorkoutHistory,
                      subtitle: l10n.showWorkoutHistoryDesc,
                      value: settings.showWorkoutHistory,
                      icon: Icons.history,
                      iconColor: appColor.color,
                      activeColor: appColor.color,
                      onChanged: (value) {
                        settings.setShowWorkoutHistory(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: l10n.showPersonalRecords,
                      subtitle: l10n.showPersonalRecordsDesc,
                      value: settings.showPersonalRecords,
                      icon: Icons.emoji_events,
                      iconColor: appColor.color,
                      activeColor: appColor.color,
                      onChanged: (value) {
                        settings.setShowPersonalRecords(value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: l10n.allowFriendRequests,
                      subtitle: l10n.allowFriendRequestsDesc,
                      value: settings.allowFriendRequests,
                      icon: Icons.person_add,
                      iconColor: appColor.color,
                      activeColor: appColor.color,
                      onChanged: (value) {
                        settings.setAllowFriendRequests(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3,
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(title, style: AppTextStyles.body1),
        ],
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: iconColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color iconColor,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: AppTextStyles.body1),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}
