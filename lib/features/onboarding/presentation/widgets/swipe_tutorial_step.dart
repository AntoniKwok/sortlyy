import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/constants/app_colors.dart';
import '../cubit/onboarding_cubit.dart';

class SwipeTutorialStep extends StatefulWidget {
  const SwipeTutorialStep({super.key});

  @override
  State<SwipeTutorialStep> createState() => _SwipeTutorialStepState();
}

class _SwipeTutorialStepState extends State<SwipeTutorialStep>
    with TickerProviderStateMixin {
  late final AnimationController _demoController;
  int _demoStep = 0; // 0=idle, 1=left(delete), 2=right(keep), 3=up(favorite)

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startDemoLoop();
  }

  Future<void> _startDemoLoop() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    while (mounted) {
      for (int step = 1; step <= 3; step++) {
        if (!mounted) return;
        setState(() => _demoStep = step);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        setState(() => _demoStep = 0);
        await Future.delayed(const Duration(milliseconds: 600));
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  double get _cardOffsetX {
    return switch (_demoStep) {
      1 => -40,
      2 => 40,
      _ => 0,
    };
  }

  double get _cardOffsetY => _demoStep == 3 ? -40 : 0;

  double get _cardRotation {
    return switch (_demoStep) {
      1 => -0.12,
      2 => 0.12,
      _ => 0,
    };
  }

  Color get _overlayColor {
    return switch (_demoStep) {
      1 => AppColors.deleteOverlay,
      2 => AppColors.keepOverlay,
      3 => AppColors.favoriteOverlay,
      _ => Colors.transparent,
    };
  }

  IconData get _overlayIcon {
    return switch (_demoStep) {
      1 => Icons.delete_rounded,
      2 => Icons.check_circle_rounded,
      3 => Icons.star_rounded,
      _ => Icons.photo_rounded,
    };
  }

  String get _overlayLabel {
    return switch (_demoStep) {
      1 => 'DELETE',
      2 => 'KEEP',
      3 => 'FAVORITE',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Here\'s how\nit works',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              height: 1.15,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const Gap(40),
          // Demo card with hint arrows
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hint arrows around card
                _HintArrow(
                  direction: _ArrowDirection.left,
                  isActive: _demoStep == 1,
                  color: AppColors.delete,
                  label: 'Delete',
                ),
                _HintArrow(
                  direction: _ArrowDirection.right,
                  isActive: _demoStep == 2,
                  color: AppColors.keep,
                  label: 'Keep',
                ),
                _HintArrow(
                  direction: _ArrowDirection.up,
                  isActive: _demoStep == 3,
                  color: AppColors.favorite,
                  label: 'Favorite',
                ),
                // Animated demo card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  transform: Matrix4.identity()
                    ..translateByDouble(_cardOffsetX, _cardOffsetY, 0, 1)
                    ..rotateZ(_cardRotation),
                  transformAlignment: Alignment.center,
                  child: _DemoCard(
                    overlayColor: _overlayColor,
                    overlayIcon: _overlayIcon,
                    overlayLabel: _overlayLabel,
                    showOverlay: _demoStep != 0,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                  icon: Icons.chevron_left_rounded,
                  color: AppColors.delete,
                  label: 'Delete'),
              const Gap(20),
              _LegendItem(
                  icon: Icons.chevron_right_rounded,
                  color: AppColors.keep,
                  label: 'Keep'),
              const Gap(20),
              _LegendItem(
                  icon: Icons.keyboard_arrow_up_rounded,
                  color: AppColors.favorite,
                  label: 'Favorite'),
            ],
          ),
          const Gap(40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () =>
                  context.read<OnboardingCubit>().completeOnboarding(),
              child: const Text("Let's go →"),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final Color overlayColor;
  final IconData overlayIcon;
  final String overlayLabel;
  final bool showOverlay;

  const _DemoCard({
    required this.overlayColor,
    required this.overlayIcon,
    required this.overlayLabel,
    required this.showOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Photo placeholder
            Center(
              child: Icon(
                Icons.photo_rounded,
                color: AppColors.textTertiary,
                size: 40,
              ),
            ),
            // Action overlay
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showOverlay ? 1.0 : 0.0,
              child: Container(
                color: overlayColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(overlayIcon, color: Colors.white, size: 36),
                      const SizedBox(height: 4),
                      Text(
                        overlayLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ArrowDirection { left, right, up }

class _HintArrow extends StatelessWidget {
  final _ArrowDirection direction;
  final bool isActive;
  final Color color;
  final String label;

  const _HintArrow({
    required this.direction,
    required this.isActive,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final (left, top, right, bottom, rotation) = switch (direction) {
      _ArrowDirection.left => (
          0.0,
          null,
          null,
          null,
          math.pi,
        ),
      _ArrowDirection.right => (
          null,
          null,
          0.0,
          null,
          0.0,
        ),
      _ArrowDirection.up => (
          null,
          0.0,
          null,
          null,
          -math.pi / 2,
        ),
    };

    return Positioned(
      left: left != null ? left + 4 : null,
      right: right != null ? right + 4 : null,
      top: top != null ? top + 8 : null,
      bottom: bottom,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.25,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isActive ? 1.1 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (direction != _ArrowDirection.up) ...[
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 20,
                )
                    .animate(target: isActive ? 1 : 0)
                    .custom(builder: (context, value, child) {
                  return Transform.rotate(
                    angle: rotation,
                    child: child,
                  );
                }),
                const Gap(4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ] else ...[
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Gap(4),
                Icon(
                  Icons.arrow_upward_rounded,
                  color: color,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
