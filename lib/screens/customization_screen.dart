import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/theme_service.dart';
import '../services/profile_service.dart';
import '../constants/app_text_styles.dart';

class CustomizationScreen extends StatelessWidget {
  const CustomizationScreen({super.key});

  static const List<Color> _presetColors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.pink,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppColor>(
      builder: (context, appColor, _) => Scaffold(
        appBar: AppBar(
          title: Text('Customization', style: AppTextStyles.h4),
          backgroundColor: appColor.color,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            appColor.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: appColor.color,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dark Theme', style: AppTextStyles.h4),
                              Text(
                                appColor.isDarkMode ? 'Enabled' : 'Disabled',
                                style: AppTextStyles.caption.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: appColor.isDarkMode,
                        onChanged: (value) async {
                          await appColor.setDarkMode(value);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value
                                    ? l10n.darkThemeEnabled
                                    : l10n.lightThemeEnabled),
                                duration: const Duration(seconds: 1),
                                backgroundColor: appColor.color,
                              ),
                            );
                          }
                        },
                        activeColor: appColor.color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Profile', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final file = await picker.pickImage(
                            source: ImageSource.gallery, maxWidth: 1200);
                        if (file != null) {
                          final profile = Provider.of<ProfileService>(context,
                              listen: false);
                          await profile.setImagePath(file.path);
                        }
                      },
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: appColor.color, width: 3),
                        ),
                        child: ClipOval(
                          child: Consumer<ProfileService>(
                            builder: (context, profile, _) {
                              if (profile.imagePath != null) {
                                return Image.file(File(profile.imagePath!),
                                    fit: BoxFit.cover);
                              }
                              return Icon(Icons.person,
                                  size: 56, color: appColor.color);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profile Image', style: AppTextStyles.body1),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                  source: ImageSource.gallery, maxWidth: 1200);
                              if (file != null) {
                                final profile = Provider.of<ProfileService>(
                                    context,
                                    listen: false);
                                await profile.setImagePath(file.path);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor.color,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Choose Photo'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () async {
                              final profile = Provider.of<ProfileService>(
                                  context,
                                  listen: false);
                              await profile.setImagePath(null);
                            },
                            child: const Text('Delete Photo'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Profile Frame', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                SizedBox(
                  height: 88,
                  child: Consumer<ProfileService>(
                    builder: (context, profile, _) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final selected = profile.frameIndex == idx;
                        final decor = _frameDecoration(idx, appColor.color);
                        return GestureDetector(
                          onTap: () async => await profile.setFrameIndex(idx),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: decor.copyWith(
                                border: selected
                                    ? Border.all(color: Colors.black, width: 3)
                                    : decor.border),
                            child: Center(
                              child: Text('F${idx + 1}',
                                  style: AppTextStyles.body1
                                      .copyWith(color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Choose the primary app color', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetColors
                      .map((c) => _buildColorTile(context, c))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTile(BuildContext context, Color color) {
    final appColor = Provider.of<AppColor>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final isSelected = appColor.color == color;

    return GestureDetector(
      onTap: () async {
        await appColor.setColor(color);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.themeColorUpdated),
              duration: const Duration(seconds: 1),
              backgroundColor: color,
            ),
          );
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
      ),
    );
  }

  BoxDecoration _frameDecoration(int idx, Color primary) {
    switch (idx) {
      case 0:
        return BoxDecoration(
          color: primary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        );
      case 1:
        return BoxDecoration(
          gradient: LinearGradient(colors: [primary, Colors.deepPurple]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white38, width: 2),
        );
      case 2:
        return BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary, width: 4),
        );
      default:
        return BoxDecoration(
          color: primary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        );
    }
  }
}
