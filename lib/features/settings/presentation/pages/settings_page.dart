import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences _prefs;
  int _dailyGoal = AppConstants.defaultDailySwipeGoal;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    _dailyGoal =
        _prefs.getInt(AppConstants.kDailySwipeGoal) ??
        AppConstants.defaultDailySwipeGoal;
  }

  void _setDailyGoal(int value) {
    setState(() => _dailyGoal = value);
    _prefs.setInt(AppConstants.kDailySwipeGoal, value);
  }

  Future<void> _resetStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reset all stats?',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This clears your streak, storage freed, and photos sorted. Cannot be undone.',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset',
                style: TextStyle(
                    color: AppColors.delete, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _prefs.remove(AppConstants.kCurrentStreak);
      await _prefs.remove(AppConstants.kLastSwipeDate);
      await _prefs.remove(AppConstants.kTotalStorageFreedBytes);
      await _prefs.remove(AppConstants.kTotalPhotosSorted);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stats reset'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Daily goal ────────────────────────────────────
                      _SectionLabel('Daily Goal'),
                      _GoalPicker(value: _dailyGoal, onChanged: _setDailyGoal),
                      const Gap(24),

                      // ── Subscription ──────────────────────────────────
                      _SectionLabel('Subscription'),
                      _Card(children: [
                        _Row(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: AppColors.accent,
                          title: 'Manage Subscription',
                          onTap: () =>
                              RevenueCatUI.presentCustomerCenter(),
                        ),
                      ]),
                      const Gap(24),

                      // ── About ─────────────────────────────────────────
                      _SectionLabel('About'),
                      _Card(children: [
                        _Row(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.favorite,
                          title: 'Rate Sortlyy',
                          onTap: () {},
                        ),
                        _Divider(),
                        _Row(
                          icon: Icons.shield_rounded,
                          iconColor: AppColors.textSecondary,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _Divider(),
                        _InfoRow(
                          icon: Icons.info_outline_rounded,
                          iconColor: AppColors.textTertiary,
                          title: 'Version',
                          value: '1.0.0',
                        ),
                      ]),
                      const Gap(32),

                      // ── Danger zone ───────────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: _resetStats,
                          child: const Text(
                            'Reset all stats',
                            style: TextStyle(
                              color: AppColors.delete,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Goal picker ──────────────────────────────────────────────────────────────

class _GoalPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _GoalPicker({required this.value, required this.onChanged});

  static const _options = [10, 20, 30, 50, 100];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _options.map((n) {
        final selected = n == value;
        return GestureDetector(
          onTap: () => onChanged(n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.textPrimary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.textPrimary : AppColors.border,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(
                color: selected
                    ? AppColors.background
                    : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const Gap(12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const Gap(12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 46, color: AppColors.divider);
  }
}
