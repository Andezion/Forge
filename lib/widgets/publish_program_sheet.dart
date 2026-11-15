import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/public_program.dart';
import '../models/workout.dart';
import '../services/public_program_service.dart';
import '../services/settings_service.dart';
import '../utils/program_category_ui.dart';

class PublishProgramSheet extends StatefulWidget {
  final Workout workout;
  final PublicProgram? existing;

  const PublishProgramSheet({super.key, required this.workout, this.existing});

  static Future<bool> show(
    BuildContext context, {
    required Workout workout,
    PublicProgram? existing,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PublishProgramSheet(workout: workout, existing: existing),
    );
    return result ?? false;
  }

  @override
  State<PublishProgramSheet> createState() => _PublishProgramSheetState();
}

class _PublishProgramSheetState extends State<PublishProgramSheet> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late ProgramCategory _category;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: widget.existing?.name ?? widget.workout.name);
    _description =
        TextEditingController(text: widget.existing?.description ?? '');
    _category = widget.existing?.category ?? ProgramCategory.fullBody;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _snack(String text, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final settingsNick =
        Provider.of<SettingsService>(context, listen: false).nickname?.trim();
    final nickname = (settingsNick != null && settingsNick.isNotEmpty)
        ? settingsNick
        : fb_auth.FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (nickname.isEmpty) {
      _snack(l10n.publishNeedsNickname, color: AppColors.error);
      return;
    }

    setState(() => _sending = true);
    try {
      await PublicProgramService().submit(
        workout: widget.workout,
        name: name,
        description: _description.text.trim(),
        category: _category,
        authorNickname: nickname.length > 40 ? nickname.substring(0, 40) : nickname,
        language: Localizations.localeOf(context).languageCode,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StoreOfflineException {
      if (mounted) _snack(l10n.noInternetAction, color: AppColors.error);
    } on StoreNotSignedInException {
      if (mounted) _snack(l10n.storeSignInRequired, color: AppColors.error);
    } catch (e) {
      debugPrint('[PUBLISH] submit failed: $e');
      if (mounted) _snack(l10n.publishFailed, color: AppColors.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final existing = widget.existing;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.storefront, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.publishToStore, style: AppTextStyles.h4)),
              ],
            ),
            if (existing?.status == PublicProgramStatus.rejected &&
                existing?.rejectionReason != null) ...[
              const SizedBox(height: 12),
              _InfoBox(
                color: AppColors.error,
                icon: Icons.info_outline,
                text: l10n.rejectionReasonLabel(existing!.rejectionReason!),
              ),
            ],
            if (existing?.status == PublicProgramStatus.approved) ...[
              const SizedBox(height: 12),
              _InfoBox(
                color: Colors.orange,
                icon: Icons.update,
                text: l10n.publishUpdateNote,
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              maxLength: PublicProgram.maxNameLength,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.publishNameLabel,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLength: PublicProgram.maxDescriptionLength,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.publishDescriptionHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.publishCategoryLabel, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ProgramCategory.values.map((c) {
                return ChoiceChip(
                  avatar: Icon(c.icon, size: 16, color: c.color),
                  label: Text(c.label(l10n)),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _InfoBox(
              color: AppColors.primary,
              icon: Icons.verified_user_outlined,
              text: l10n.publishModerationNote,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _sending || _name.text.trim().isEmpty ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              label: Text(l10n.publishSubmit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _InfoBox({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
