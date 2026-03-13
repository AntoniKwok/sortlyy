import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/swipe_item.dart';
import '../../domain/entities/swipe_record.dart';

export '../../domain/entities/swipe_item.dart';

enum SwipeStatus { initial, loading, ready, sessionComplete, error, permissionDenied, noPhotos }

class SwipeState {
  final SwipeStatus status;

  /// Raw photo list — used only by SwipeCubit for pagination (keepGoing).
  final List<AssetEntity> photos;

  /// Processed queue: single photos + group cards injected by the AI grouper.
  final List<SwipeItem> queue;

  final int currentIndex;
  final int dailyGoal;
  final List<SwipeRecord> history;
  final SwipeRecord? lastSwipe;
  final String? error;
  final int sessionStorageFreedBytes;
  final int currentStreak;

  const SwipeState({
    this.status = SwipeStatus.initial,
    this.photos = const [],
    this.queue = const [],
    this.currentIndex = 0,
    this.dailyGoal = 30,
    this.history = const [],
    this.lastSwipe,
    this.error,
    this.sessionStorageFreedBytes = 0,
    this.currentStreak = 0,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  SwipeItem? get currentItem =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  /// The primary photo for the current item (first photo of a group).
  AssetEntity? get currentPhoto => switch (currentItem) {
        SinglePhoto(:final photo) => photo,
        PhotoGroup(:final photos) => photos.first,
        null => null,
      };

  /// Next 1-2 photos to show in the background stack.
  List<AssetEntity> get upcomingPhotos {
    final result = <AssetEntity>[];
    for (int i = currentIndex + 1;
        i < queue.length && result.length < 2;
        i++) {
      switch (queue[i]) {
        case SinglePhoto(:final photo):
          result.add(photo);
        case PhotoGroup(:final photos):
          result.add(photos.first);
      }
    }
    return result;
  }

  double get sessionProgress =>
      dailyGoal > 0 ? (currentIndex / dailyGoal).clamp(0.0, 1.0) : 0.0;

  int get deletedCount =>
      history.where((r) => r.action == SwipeAction.delete).length;
  int get keptCount =>
      history.where((r) => r.action == SwipeAction.keep).length;
  int get favoritedCount =>
      history.where((r) => r.action == SwipeAction.favorite).length;

  bool get canUndo => history.isNotEmpty && status == SwipeStatus.ready;

  // ── Copy ──────────────────────────────────────────────────────────────────

  SwipeState copyWith({
    SwipeStatus? status,
    List<AssetEntity>? photos,
    List<SwipeItem>? queue,
    int? currentIndex,
    int? dailyGoal,
    List<SwipeRecord>? history,
    SwipeRecord? lastSwipe,
    bool clearLastSwipe = false,
    String? error,
    int? sessionStorageFreedBytes,
    int? currentStreak,
  }) {
    return SwipeState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      history: history ?? this.history,
      lastSwipe: clearLastSwipe ? null : (lastSwipe ?? this.lastSwipe),
      error: error ?? this.error,
      sessionStorageFreedBytes:
          sessionStorageFreedBytes ?? this.sessionStorageFreedBytes,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
