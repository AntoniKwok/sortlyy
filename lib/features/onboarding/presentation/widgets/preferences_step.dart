import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/onboarding_preference.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class PreferencesStep extends StatelessWidget {
  const PreferencesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What's your\ngoal?",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0),
              const Gap(8),
              const Text(
                "We'll personalize your experience.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
              const Gap(32),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: OnboardingPreference.values.indexed.map((entry) {
                  final (index, pref) = entry;
                  final isSelected = state.selectedPreferences.contains(pref);
                  return _PreferenceChip(
                    preference: pref,
                    isSelected: isSelected,
                    onTap: () => context
                        .read<OnboardingCubit>()
                        .togglePreference(pref),
                    animationDelay: Duration(milliseconds: 100 + index * 50),
                  );
                }).toList(),
              ),
              const Gap(40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: state.selectedPreferences.isNotEmpty
                      ? () => context.read<OnboardingCubit>().nextPage()
                      : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor:
                        AppColors.surfaceElevated,
                    disabledForegroundColor: AppColors.textTertiary,
                  ),
                  child: const Text('Continue →'),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const Gap(12),
              Center(
                child: TextButton(
                  onPressed: () => context.read<OnboardingCubit>().nextPage(),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ],
          ),
        );
      },
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  final OnboardingPreference preference;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _PreferenceChip({
    required this.preference,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentMuted : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? AppColors.favorite : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(preference.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              preference.label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.favorite
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: animationDelay)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: animationDelay,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}
