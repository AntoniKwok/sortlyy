import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/swipe_item.dart';

/// Shown instead of [SwipeCard] when the AI grouper detects near-duplicate
/// photos. The user taps the best photo; the rest are queued for deletion.
class GroupCard extends StatefulWidget {
  final PhotoGroup group;
  final void Function(AssetEntity kept, List<AssetEntity> toDelete) onPickBest;

  const GroupCard({
    super.key,
    required this.group,
    required this.onPickBest,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  AssetEntity? _selected;

  List<AssetEntity> get _photos => widget.group.photos;

  void _confirm() {
    if (_selected == null) return;
    final toDelete = _photos.where((p) => p.id != _selected!.id).toList();
    widget.onPickBest(_selected!, toDelete);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            // ── Header badge ──
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 13, color: AppColors.accent),
                        Gap(5),
                        Text(
                          'Similar photos',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Pick the best one',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Photo grid ──
            Expanded(
              child: _PhotoGrid(
                photos: _photos,
                selected: _selected,
                onSelect: (p) => setState(() => _selected = p),
              ),
            ),

            // ── Confirm button ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: _selected != null ? 72 : 0,
              child: _selected != null
                  ? Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.keep,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Keep best · Delete ${_photos.length - 1} other${_photos.length - 1 == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 150.ms).slideY(
                        begin: 0.3, end: 0, duration: 200.ms)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo grid ─────────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final List<AssetEntity> photos;
  final AssetEntity? selected;
  final ValueChanged<AssetEntity> onSelect;

  const _PhotoGrid({
    required this.photos,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: photos.length == 2 ? 2 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: photos.length <= 2 ? 0.85 : 0.72,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final photo = photos[i];
        final isSelected = selected?.id == photo.id;
        return _PhotoTile(
          photo: photo,
          isSelected: isSelected,
          onTap: () => onSelect(photo),
        );
      },
    );
  }
}

class _PhotoTile extends StatefulWidget {
  final AssetEntity photo;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.photo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  late Future<Uint8List?> _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = widget.photo.thumbnailDataWithSize(
      const ThumbnailSize(300, 400),
      quality: 75,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected ? AppColors.keep : Colors.transparent,
            width: 3,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.keep.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<Uint8List?>(
                future: _thumbFuture,
                builder: (_, snap) => snap.data != null
                    ? Image.memory(snap.data!, fit: BoxFit.cover,
                        gaplessPlayback: true)
                    : const ColoredBox(color: AppColors.cardBackground),
              ),
              // Dimming overlay for unselected photos
              if (!widget.isSelected)
                const ColoredBox(
                    color: Color(0x33000000)), // 20% black tint
              // Selected checkmark
              if (widget.isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.keep,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
