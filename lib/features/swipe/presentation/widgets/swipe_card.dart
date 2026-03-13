import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/swipe_record.dart';

class SwipeCard extends StatefulWidget {
  final AssetEntity photo;
  final Function(SwipeAction) onSwiped;
  final ValueChanged<double>? onDragProgress;

  /// Feed a SwipeAction here to trigger a programmatic swipe (tap buttons).
  final Stream<SwipeAction>? tapStream;

  const SwipeCard({
    super.key,
    required this.photo,
    required this.onSwiped,
    this.onDragProgress,
    this.tapStream,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _isBusy = false;

  late final AnimationController _controller;
  Animation<Offset>? _anim;
  StreamSubscription<SwipeAction>? _tapSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_onAnimTick);

    _tapSub = widget.tapStream?.listen(_performExternalSwipe);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onAnimTick)
      ..dispose();
    _tapSub?.cancel();
    super.dispose();
  }

  // ── Animation tick ────────────────────────────────────────────────────────

  void _onAnimTick() {
    if (_anim == null) return;
    setState(() => _offset = _anim!.value);
    _reportProgress();
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails d) {
    if (_isBusy) return;
    setState(() => _offset += d.delta);
    _reportProgress();
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isBusy) return;
    final size = MediaQuery.of(context).size;
    final vel = d.velocity.pixelsPerSecond;
    final th = size.width * AppConstants.actionThreshold;
    final vertTh = size.height * 0.22;

    SwipeAction? action;
    if (_offset.dy < -vertTh && _offset.dy.abs() > _offset.dx.abs()) {
      action = SwipeAction.favorite;
    } else if (_offset.dx < -th || vel.dx < -900) {
      action = SwipeAction.delete;
    } else if (_offset.dx > th || vel.dx > 900) {
      action = SwipeAction.keep;
    }

    if (action != null) {
      _flyOff(action);
    } else {
      _snapBack();
    }
  }

  void _performExternalSwipe(SwipeAction action) {
    if (_isBusy) return;
    // Give the card a slight nudge in the right direction first for feel
    final size = MediaQuery.of(context).size;
    setState(() {
      _offset = switch (action) {
        SwipeAction.delete => Offset(-size.width * 0.05, 0),
        SwipeAction.keep => Offset(size.width * 0.05, 0),
        SwipeAction.favorite => Offset(0, -size.height * 0.04),
      };
    });
    Future.delayed(const Duration(milliseconds: 60), () => _flyOff(action));
  }

  // ── Physics ───────────────────────────────────────────────────────────────

  void _flyOff(SwipeAction action) {
    if (_isBusy) return;
    _isBusy = true;
    final size = MediaQuery.of(context).size;

    final target = switch (action) {
      SwipeAction.delete => Offset(-size.width * 2.2, _offset.dy * 1.5),
      SwipeAction.keep => Offset(size.width * 2.2, _offset.dy * 1.5),
      SwipeAction.favorite => Offset(_offset.dx * 1.5, -size.height * 2.2),
    };

    _controller.duration = const Duration(milliseconds: 380);
    _anim = Tween(begin: _offset, end: target)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(from: 0).then((_) {
      if (mounted) widget.onSwiped(action);
    });
  }

  void _snapBack() {
    _controller.duration = const Duration(milliseconds: 550);
    _anim = Tween(begin: _offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward(from: 0).then((_) {
      if (mounted) widget.onDragProgress?.call(0);
    });
  }

  void _reportProgress() {
    final size = MediaQuery.of(context).size;
    final maxDist = size.width * 0.4;
    widget.onDragProgress
        ?.call((_offset.distance / maxDist).clamp(0.0, 1.0));
  }

  // ── Computed visuals ──────────────────────────────────────────────────────

  double get _rotationAngle {
    // Upward swipe → no rotation; left/right → tilt
    if (_offset.dy.abs() > _offset.dx.abs() * 1.4 && _offset.dy < 0) {
      return 0;
    }
    return (_offset.dx / 320) * 0.28;
  }

  double get _overlayOpacity =>
      (_offset.distance / 130).clamp(0.0, 0.92);

  SwipeAction? get _dragDirection {
    if (_offset.distance < 12) return null;
    if (_offset.dy < -50 && _offset.dy.abs() > _offset.dx.abs() * 1.2) {
      return SwipeAction.favorite;
    }
    if (_offset.dx < -30) return SwipeAction.delete;
    if (_offset.dx > 30) return SwipeAction.keep;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final direction = _dragDirection;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: Transform.rotate(
          angle: _rotationAngle,
          alignment: Alignment.bottomCenter,
          child: _CardContent(
            photo: widget.photo,
            overlayOpacity: _overlayOpacity,
            direction: direction,
          ),
        ),
      ),
    );
  }
}

// ─── Card content ─────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  final AssetEntity photo;
  final double overlayOpacity;
  final SwipeAction? direction;

  const _CardContent({
    required this.photo,
    required this.overlayOpacity,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Card fills most of the screen leaving room for progress bar + buttons
    final cardWidth = size.width - 28;
    final cardHeight = size.height * 0.62;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            _PhotoView(photo: photo),

            // Bottom gradient (depth)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x88000000)],
                  ),
                ),
              ),
            ),

            // Color tint overlay
            if (direction != null)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 30),
                  color: _actionColor(direction!)
                      .withValues(alpha: overlayOpacity * 0.30),
                ),
              ),

            // Action label badges
            if (direction != null && overlayOpacity > 0.08)
              _BadgePositioned(
                direction: direction!,
                opacity: (overlayOpacity * 1.4).clamp(0.0, 1.0),
              ),
          ],
        ),
      ),
    );
  }

  static Color _actionColor(SwipeAction action) => switch (action) {
        SwipeAction.delete => AppColors.delete,
        SwipeAction.keep => AppColors.keep,
        SwipeAction.favorite => AppColors.favorite,
      };
}

class _PhotoView extends StatefulWidget {
  final AssetEntity photo;
  const _PhotoView({required this.photo});

  @override
  State<_PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<_PhotoView> {
  late Future<Uint8List?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = widget.photo.thumbnailDataWithSize(
      const ThumbnailSize(700, 1100),
      quality: 92,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbFuture,
      builder: (context, snap) {
        if (snap.data == null) {
          return const ColoredBox(
            color: AppColors.cardBackground,
            child: Center(
              child: Icon(
                Icons.photo_rounded,
                color: AppColors.textTertiary,
                size: 40,
              ),
            ),
          );
        }
        return Image.memory(
          snap.data!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      },
    );
  }
}

// ─── Action badge (DELETE / KEEP / FAVORITE stamp) ───────────────────────────

class _BadgePositioned extends StatelessWidget {
  final SwipeAction direction;
  final double opacity;

  const _BadgePositioned({required this.direction, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final isFavorite = direction == SwipeAction.favorite;

    if (isFavorite) {
      return Positioned(
        top: 22,
        left: 0,
        right: 0,
        child: Center(child: _Badge(action: direction, opacity: opacity)),
      );
    }

    return Positioned(
      top: 22,
      left: direction == SwipeAction.delete ? 18 : null,
      right: direction == SwipeAction.keep ? 18 : null,
      child: _Badge(action: direction, opacity: opacity),
    );
  }
}

class _Badge extends StatelessWidget {
  final SwipeAction action;
  final double opacity;

  const _Badge({required this.action, required this.opacity});

  String get _label => switch (action) {
        SwipeAction.delete => 'DELETE',
        SwipeAction.keep => 'KEEP',
        SwipeAction.favorite => 'FAVORITE',
      };

  Color get _color => switch (action) {
        SwipeAction.delete => AppColors.delete,
        SwipeAction.keep => AppColors.keep,
        SwipeAction.favorite => AppColors.favorite,
      };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: _color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
          ),
        ),
      ),
    );
  }
}

