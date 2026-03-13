import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../domain/entities/swipe_item.dart';
import '../../domain/entities/swipe_record.dart';
import '../cubit/swipe_cubit.dart';
import '../cubit/swipe_state.dart';
import '../widgets/group_card.dart';
import '../widgets/swipe_card.dart';

class SwipePage extends StatelessWidget {
  const SwipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SwipeCubit>()..init(),
      child: const _SwipeView(),
    );
  }
}

class _SwipeView extends StatefulWidget {
  const _SwipeView();

  @override
  State<_SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<_SwipeView> {
  double _dragProgress = 0;
  bool _showUndo = false;
  Timer? _undoTimer;

  // Broadcast stream so tap buttons trigger the card's fly-off animation
  final _tapController = StreamController<SwipeAction>.broadcast();

  @override
  void dispose() {
    _undoTimer?.cancel();
    _tapController.close();
    super.dispose();
  }

  void _onDragProgress(double p) => setState(() => _dragProgress = p);

  void _onSwiped(SwipeAction action) {
    if (action == SwipeAction.delete) {
      _onDeleteSwiped();
    } else {
      context.read<SwipeCubit>().swipe(action);
      _showUndoToast();
    }
  }

  void _onDeleteSwiped() {
    // Capture photo before state advances
    final photo = context.read<SwipeCubit>().state.currentPhoto;
    if (photo == null) return;

    context.read<SwipeCubit>().swipe(SwipeAction.delete);

    // Show confirmation — card has already flown off; undo if cancelled
    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DeleteConfirmSheet(photo: photo),
    ).then((confirmed) {
      if (!mounted) return;
      if (confirmed == true) {
        context.read<SwipeCubit>().confirmDelete(photo.id);
      } else {
        // User cancelled — bring the card back
        context.read<SwipeCubit>().undo();
        setState(() => _dragProgress = 0);
      }
    });
  }

  void _onTap(SwipeAction action) => _tapController.add(action);

  void _onGroupPick(PhotoGroup group, AssetEntity kept, List<AssetEntity> toDelete) {
    context.read<SwipeCubit>().pickBest(kept);
    setState(() => _dragProgress = 0);

    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GroupDeleteConfirmSheet(count: toDelete.length),
    ).then((confirmed) {
      if (!mounted) return;
      if (confirmed == true) {
        for (final photo in toDelete) {
          context.read<SwipeCubit>().confirmDelete(photo.id);
        }
      } else {
        context.read<SwipeCubit>().undo();
      }
    });
  }

  void _showUndoToast() {
    _undoTimer?.cancel();
    setState(() => _showUndo = true);
    _undoTimer = Timer(
      Duration(seconds: context.read<SwipeCubit>().prefs.getInt('undo_secs') ?? 5),
      () {
        if (mounted) {
          setState(() => _showUndo = false);
          context.read<SwipeCubit>().clearLastSwipe();
        }
      },
    );
  }

  void _onUndo() {
    _undoTimer?.cancel();
    setState(() {
      _showUndo = false;
      _dragProgress = 0;
    });
    context.read<SwipeCubit>().undo();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocBuilder<SwipeCubit, SwipeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Stack(
                children: [
                  _mainContent(context, state),
                  _UndoToast(
                    visible: _showUndo,
                    record: state.lastSwipe,
                    onUndo: _onUndo,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mainContent(BuildContext context, SwipeState state) {
    return switch (state.status) {
      SwipeStatus.initial || SwipeStatus.loading => const _LoadingView(),
      SwipeStatus.error => _ErrorView(message: state.error ?? 'Something went wrong'),
      SwipeStatus.permissionDenied => const _PermissionDeniedView(),
      SwipeStatus.noPhotos => const _NoPhotosView(),
      SwipeStatus.sessionComplete => _SessionCompleteView(state: state),
      SwipeStatus.ready => _readyView(context, state),
    };
  }

  Widget _readyView(BuildContext context, SwipeState state) {
    final item = state.currentItem;
    if (item == null) return const _LoadingView();

    final isGroup = item is PhotoGroup;

    return Column(
      children: [
        // ── Progress bar + header ──
        _SessionHeader(
          progress: state.sessionProgress,
          current: state.currentIndex,
          goal: state.dailyGoal,
          canUndo: state.canUndo && !isGroup,
          onUndo: _onUndo,
          onClose: () => Navigator.of(context).pop(),
        ),
        const Gap(8),

        // ── Card stack ──
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background stack (only shown behind single-photo cards)
              if (!isGroup)
                ...state.upcomingPhotos.asMap().entries.map((e) {
                  return _StackBackCard(
                    key: ValueKey(e.value.id),
                    photo: e.value,
                    stackIndex: e.key + 1,
                    dragProgress: _dragProgress,
                  );
                }),

              // Front item
              if (item is SinglePhoto)
                SwipeCard(
                  key: ValueKey(item.photo.id),
                  photo: item.photo,
                  onSwiped: _onSwiped,
                  onDragProgress: _onDragProgress,
                  tapStream: _tapController.stream,
                ).animate().fadeIn(duration: 200.ms).scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    )
              else if (item is PhotoGroup)
                GroupCard(
                  key: ValueKey('group_${item.photos.first.id}'),
                  group: item,
                  onPickBest: (kept, toDelete) =>
                      _onGroupPick(item, kept, toDelete),
                ).animate().fadeIn(duration: 200.ms).scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
            ],
          ),
        ),

        const Gap(16),

        // ── Tap buttons — hidden when a group card is active ──
        if (!isGroup) _TapButtons(onAction: _onTap),
        if (isGroup)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Tap a photo to mark the best one',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ),
        const Gap(24),
      ],
    );
  }
}

// ─── Session header ───────────────────────────────────────────────────────────

class _SessionHeader extends StatelessWidget {
  final double progress;
  final int current;
  final int goal;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onClose;

  const _SessionHeader({
    required this.progress,
    required this.current,
    required this.goal,
    required this.canUndo,
    required this.onUndo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thin progress bar — flush at very top
        LinearProgressIndicator(
          value: progress,
          minHeight: 2,
          backgroundColor: AppColors.border,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
          child: Row(
            children: [
              // Close button
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Progress label — centered
              Expanded(
                child: Text(
                  '$current of $goal today',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: canUndo ? 1.0 : 0.3,
                child: GestureDetector(
                  onTap: canUndo ? onUndo : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo_rounded,
                            size: 14, color: AppColors.textSecondary),
                        Gap(4),
                        Text(
                          'Undo',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
      ],
    );
  }
}

// ─── Background stack card ────────────────────────────────────────────────────

class _StackBackCard extends StatefulWidget {
  final AssetEntity photo;
  final int stackIndex;
  final double dragProgress;

  const _StackBackCard({
    super.key,
    required this.photo,
    required this.stackIndex,
    required this.dragProgress,
  });

  @override
  State<_StackBackCard> createState() => _StackBackCardState();
}

class _StackBackCardState extends State<_StackBackCard> {
  late Future<Uint8List?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = widget.photo.thumbnailDataWithSize(
      const ThumbnailSize(400, 600),
      quality: 80,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final i = widget.stackIndex;
    final p = widget.dragProgress;

    // Animate from resting position toward "one step forward"
    final scale = lerpDouble(1.0 - i * 0.05, 1.0 - (i - 1) * 0.05, p)!;
    final offsetY = lerpDouble(i * 14.0, (i - 1) * 14.0, p)!;

    final cardWidth = size.width - 28;
    final cardHeight = size.height * 0.62;

    return Transform.scale(
      scale: scale,
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: FutureBuilder<Uint8List?>(
              future: _thumbFuture,
              builder: (context, snap) {
                if (snap.data == null) {
                  return const ColoredBox(color: AppColors.cardBackground);
                }
                return Image.memory(
                  snap.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tap action buttons ───────────────────────────────────────────────────────

class _TapButtons extends StatelessWidget {
  final Function(SwipeAction) onAction;

  const _TapButtons({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.delete_rounded,
          color: AppColors.delete,
          size: 56,
          onTap: () => onAction(SwipeAction.delete),
        ),
        const Gap(20),
        _ActionButton(
          icon: Icons.check_rounded,
          color: AppColors.keep,
          size: 68,
          onTap: () => onAction(SwipeAction.keep),
        ),
        const Gap(20),
        _ActionButton(
          icon: Icons.star_rounded,
          color: AppColors.favorite,
          size: 56,
          onTap: () => onAction(SwipeAction.favorite),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.42),
      ),
    );
  }
}

// ─── Undo toast ───────────────────────────────────────────────────────────────

class _UndoToast extends StatelessWidget {
  final bool visible;
  final SwipeRecord? record;
  final VoidCallback onUndo;

  const _UndoToast({
    required this.visible,
    required this.record,
    required this.onUndo,
  });

  String _label(SwipeAction action) => switch (action) {
        SwipeAction.delete => 'Moved to delete',
        SwipeAction.keep => 'Marked as keep',
        SwipeAction.favorite => 'Added to favorites ⭐',
      };

  Color _color(SwipeAction action) => switch (action) {
        SwipeAction.delete => AppColors.delete,
        SwipeAction.keep => AppColors.keep,
        SwipeAction.favorite => AppColors.favorite,
      };

  @override
  Widget build(BuildContext context) {
    final action = record?.action;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: visible ? 110 : -80,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: action != null
                ? _color(action).withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            if (action != null)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _color(action),
                  shape: BoxShape.circle,
                ),
              ),
            const Gap(10),
            Expanded(
              child: Text(
                action != null ? _label(action) : '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: onUndo,
              child: const Text(
                'UNDO',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Permission denied ────────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.photo_library_outlined,
                color: AppColors.textSecondary, size: 32),
          ),
          const Gap(24),
          const Text(
            'Photo access needed',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const Gap(10),
          const Text(
            'Sortlyy needs access to your photos to help you sort them. No photos are uploaded — everything stays on your device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => PhotoManager.openSetting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Open Settings',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const Gap(12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go back',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─── No photos ────────────────────────────────────────────────────────────────

class _NoPhotosView extends StatelessWidget {
  const _NoPhotosView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✨', style: TextStyle(fontSize: 64)),
          const Gap(24),
          const Text(
            'All clean!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(10),
          const Text(
            'You\'ve sorted everything in your library. Come back after taking more photos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Back to Dashboard',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.textSecondary,
        strokeWidth: 2,
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.textTertiary, size: 48),
            const Gap(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Gap(24),
            OutlinedButton(
              onPressed: () => context.read<SwipeCubit>().init(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Session complete ─────────────────────────────────────────────────────────

class _SessionCompleteView extends StatelessWidget {
  final SwipeState state;
  const _SessionCompleteView({required this.state});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final hasStorage = state.sessionStorageFreedBytes > 0;
    final hasStreak = state.currentStreak > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Celebration emoji ──
            const Text('🎉', style: TextStyle(fontSize: 72))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const Gap(20),

            // ── Title ──
            const Text(
              'Session Complete!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const Gap(8),
            Text(
              '${state.history.length} photos sorted today',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 220.ms),

            const Gap(28),

            // ── Storage freed ──
            if (hasStorage)
              _CompletionCard(
                icon: Icons.storage_rounded,
                iconColor: AppColors.keep,
                title: _formatBytes(state.sessionStorageFreedBytes),
                subtitle: 'freed this session',
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            if (hasStorage) const Gap(10),

            // ── Stats row ──
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    emoji: '🗑',
                    value: '${state.deletedCount}',
                    label: 'Deleted',
                    color: AppColors.delete,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _StatPill(
                    emoji: '✓',
                    value: '${state.keptCount}',
                    label: 'Kept',
                    color: AppColors.keep,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _StatPill(
                    emoji: '⭐',
                    value: '${state.favoritedCount}',
                    label: 'Fav',
                    color: AppColors.favorite,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 380.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const Gap(10),

            // ── Streak ──
            if (hasStreak)
              _CompletionCard(
                icon: null,
                emoji: '🔥',
                iconColor: AppColors.streakFlame,
                title: '${state.currentStreak} day streak!',
                subtitle: state.currentStreak == 1
                    ? 'First session — keep it going!'
                    : 'You\'re on a roll. Come back tomorrow!',
              )
                  .animate()
                  .fadeIn(delay: 460.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const Gap(32),

            // ── Buttons ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                    (_) => false,
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
                child: const Text(
                  'Done for today',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ).animate().fadeIn(delay: 540.ms).slideY(begin: 0.3, end: 0),

            const Gap(10),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => context.read<SwipeCubit>().keepGoing(),
                child: const Text('Keep going →'),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _CompletionCard({
    this.icon,
    this.emoji,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 28))
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
          const Gap(14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const Gap(4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Delete confirmation sheet ────────────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  final AssetEntity photo;

  const _DeleteConfirmSheet({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),

          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 88,
              child: FutureBuilder<Uint8List?>(
                future: photo.thumbnailDataWithSize(
                  const ThumbnailSize.square(88),
                ),
                builder: (_, snap) => snap.data != null
                    ? Image.memory(snap.data!, fit: BoxFit.cover)
                    : const ColoredBox(color: AppColors.cardBackground),
              ),
            ),
          ),
          const Gap(18),

          // Title
          const Text(
            'Delete this photo?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Gap(6),

          // Subtitle
          const Text(
            'It will be moved to Recently Deleted\non your device (recoverable for 30 days).',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const Gap(28),

          // Delete button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.delete,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, size: 18),
                  Gap(8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep it'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Group delete confirmation sheet ─────────────────────────────────────────

class _GroupDeleteConfirmSheet extends StatelessWidget {
  final int count;
  const _GroupDeleteConfirmSheet({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.delete.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_sweep_rounded,
                color: AppColors.delete, size: 26),
          ),
          const Gap(16),
          Text(
            'Delete $count similar photo${count == 1 ? '' : 's'}?',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Gap(6),
          const Text(
            'The best one you selected will be kept.\nThe rest go to Recently Deleted (recoverable for 30 days).',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const Gap(28),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.delete,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_sweep_rounded, size: 18),
                  const Gap(8),
                  Text('Delete $count photo${count == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Gap(10),
          SizedBox(
            width: double.infinity, height: 54,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep all'),
            ),
          ),
        ],
      ),
    );
  }
}
