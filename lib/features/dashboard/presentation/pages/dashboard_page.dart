import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../swipe/presentation/pages/swipe_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (state.currentStreak > 0) ...[
                          _StreakCard(streak: state.currentStreak)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                          const Gap(14),
                        ],
                        _StatsRow(state: state)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 80.ms)
                            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                        const Gap(14),
                        _StartCard()
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 160.ms)
                            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                        const Gap(14),
                        if (state.isProUser)
                          _ProActiveBanner()
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 240.ms)
                              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut)
                        else
                          _ProBanner()
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 240.ms)
                              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sortly',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1800), Color(0xFF1A1200)],
        ),
        border: Border.all(color: AppColors.streakFlame.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Flame + number
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const Text(
                  'Day streak',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.streakFlame.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              streak >= 7 ? '🏆 On fire!' : 'Keep it up!',
              style: const TextStyle(
                color: AppColors.streakFlame,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardState state;

  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.storage_rounded,
            iconColor: AppColors.keep,
            value: state.storageFreeFormatted,
            label: 'Freed',
          ),
        ),
        const Gap(10),
        Expanded(
          child: _StatTile(
            icon: Icons.photo_library_rounded,
            iconColor: AppColors.accent,
            value: '${state.totalPhotosSorted}',
            label: 'Sorted',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1,
                ),
              ),
              const Gap(2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Start card ───────────────────────────────────────────────────────────────

class _StartCard extends StatelessWidget {
  const _StartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
              const Gap(10),
              const Text(
                "Today's Session",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const Gap(6),
          const Text(
            'Swipe through your camera roll.\nEvery session makes a difference.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const Gap(18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SwipePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 20),
                  Gap(6),
                  Text(
                    'Start Swiping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pro upgrade banner ───────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  const _ProBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RevenueCatUI.presentPaywall(displayCloseButton: true),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C00), Color(0xFF281E00)],
          ),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const Gap(14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Sortly Pro',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Gap(2),
                  Text(
                    'Unlimited swipes & AI-powered tools',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pro active banner (shown when user is already Pro) ───────────────────────

class _ProActiveBanner extends StatelessWidget {
  const _ProActiveBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C00), Color(0xFF281E00)],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.accent, size: 22),
          ),
          const Gap(14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sortly Pro · Active',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Gap(2),
                Text(
                  'AI grouping enabled · Unlimited swipes',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
