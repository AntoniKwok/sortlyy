import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

class GalleryScanStep extends StatelessWidget {
  const GalleryScanStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GalleryIcon(status: state.galleryScanStatus),
              const Gap(36),
              _title(state),
              const Gap(10),
              _subtitle(state),
              const Gap(48),
              _actionArea(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _title(OnboardingState state) {
    final text = switch (state.galleryScanStatus) {
      GalleryScanStatus.idle => 'Your photos are\nwaiting',
      GalleryScanStatus.scanning => 'Scanning your\ngallery…',
      GalleryScanStatus.complete => '${state.photoCount} photos found',
      GalleryScanStatus.permissionDenied => 'Gallery access\nneeded',
    };

    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
      ),
    );
  }

  Widget _subtitle(OnboardingState state) {
    final text = switch (state.galleryScanStatus) {
      GalleryScanStatus.idle =>
        "Let's see what we're working with.",
      GalleryScanStatus.scanning => 'Counting photos and estimating storage…',
      GalleryScanStatus.complete =>
        'Potential to free up ${state.formattedStorage} of storage.',
      GalleryScanStatus.permissionDenied =>
        'Grant gallery access to get started.\nYour photos never leave your device.',
    };

    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.55,
      ),
    );
  }

  Widget _actionArea(BuildContext context, OnboardingState state) {
    switch (state.galleryScanStatus) {
      case GalleryScanStatus.idle:
        return _ScanButton(
          label: 'Allow Gallery Access',
          onPressed: () =>
              context.read<OnboardingCubit>().requestGalleryPermission(),
        );

      case GalleryScanStatus.scanning:
        return _ProgressBar(progress: state.scanProgress);

      case GalleryScanStatus.complete:
        return Column(
          children: [
            _StatCard(
              photoCount: state.photoCount,
              storage: state.formattedStorage,
            ),
            const Gap(24),
            _ScanButton(
              label: "Let's start sorting →",
              onPressed: () => context.read<OnboardingCubit>().nextPage(),
            ),
          ],
        );

      case GalleryScanStatus.permissionDenied:
        return Column(
          children: [
            _ScanButton(
              label: 'Try Again',
              onPressed: () =>
                  context.read<OnboardingCubit>().requestGalleryPermission(),
            ),
            const Gap(12),
            TextButton(
              onPressed: () => context.read<OnboardingCubit>().nextPage(),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
              ),
            ),
          ],
        );
    }
  }
}

class _GalleryIcon extends StatelessWidget {
  final GalleryScanStatus status;

  const _GalleryIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final isScanning = status == GalleryScanStatus.scanning;

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              status == GalleryScanStatus.complete
                  ? Icons.check_circle_rounded
                  : Icons.photo_library_rounded,
              color: status == GalleryScanStatus.complete
                  ? AppColors.keep
                  : AppColors.textTertiary,
              size: 40,
            ),
          ),
          if (isScanning)
            SizedBox(
              width: 96,
              height: 96,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.favorite.withValues(alpha: 0.6),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 1200.ms, curve: Curves.linear),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.favorite),
          ),
        ),
        const Gap(8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int photoCount;
  final String storage;

  const _StatCard({required this.photoCount, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(value: '$photoCount', label: 'photos'),
          Container(width: 1, height: 32, color: AppColors.divider),
          _stat(value: storage, label: 'to free'),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _stat({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ScanButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
