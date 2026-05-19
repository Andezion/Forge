import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/tour_service.dart';

class TourOverlay extends StatelessWidget {
  const TourOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final tour = Provider.of<TourService>(context);
    final l10n = AppLocalizations.of(context)!;
    final stepIndex = tour.currentStepIndex;
    final title = TourService.stepTitle(stepIndex, l10n);
    final description = TourService.stepDescription(stepIndex, l10n);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _TourCardContent(
                    key: ValueKey(stepIndex),
                    tour: tour,
                    title: title,
                    description: description,
                    l10n: l10n,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TourCardContent extends StatelessWidget {
  final TourService tour;
  final String title;
  final String description;
  final AppLocalizations l10n;

  const _TourCardContent({
    super.key,
    required this.tour,
    required this.title,
    required this.description,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.getDivider(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${tour.currentStepIndex + 1} / ${tour.totalSteps}',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: tour.closeTour,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.getTextSecondary(context),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.skip),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (tour.currentStepIndex + 1) / tour.totalSteps,
            backgroundColor: AppColors.getDivider(context),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 20),
        // Step title
        Text(title, style: AppTextStyles.h4),
        const SizedBox(height: 8),
        // Step description
        Text(
          description,
          style: AppTextStyles.body2,
        ),
        const SizedBox(height: 24),
        // Navigation buttons
        Row(
          children: [
            if (!tour.isFirstStep)
              OutlinedButton.icon(
                onPressed: tour.previousStep,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(l10n.back),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: tour.isLastStep ? tour.closeTour : tour.nextStep,
              icon: Icon(
                tour.isLastStep ? Icons.check : Icons.arrow_forward,
                size: 16,
              ),
              label: Text(tour.isLastStep ? l10n.done : l10n.next),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
