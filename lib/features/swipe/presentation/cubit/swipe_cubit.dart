import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../subscription/domain/subscription_service.dart';
import '../../data/services/perceptual_hash_service.dart';
import '../../domain/entities/swipe_item.dart';
import '../../domain/entities/swipe_record.dart';
import '../../domain/repositories/gallery_repository.dart';
import 'swipe_state.dart';

class SwipeCubit extends Cubit<SwipeState> {
  final GalleryRepository repository;
  final SharedPreferences prefs;
  final SubscriptionService subscriptionService;

  SwipeCubit({
    required this.repository,
    required this.prefs,
    required this.subscriptionService,
  }) : super(const SwipeState());

  Future<void> init() async {
    emit(state.copyWith(status: SwipeStatus.loading));
    try {
      // Check gallery permission first
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        emit(state.copyWith(status: SwipeStatus.permissionDenied));
        return;
      }

      final goal = prefs.getInt(AppConstants.kDailySwipeGoal) ??
          AppConstants.defaultDailySwipeGoal;
      final streak = prefs.getInt(AppConstants.kCurrentStreak) ?? 0;

      final photos = await repository.loadPhotos(
        pageSize: max(goal * 3, 90).toInt(),
      );

      if (photos.isEmpty) {
        emit(state.copyWith(
          status: SwipeStatus.noPhotos,
          currentStreak: streak,
        ));
        return;
      }

      // Build queue with on-device AI grouping
      final queue = await _buildQueue(photos);
      final effectiveGoal = min(goal, queue.length);

      emit(state.copyWith(
        status: SwipeStatus.ready,
        photos: photos,
        queue: queue,
        dailyGoal: effectiveGoal,
        currentStreak: streak,
      ));
    } catch (e) {
      emit(state.copyWith(status: SwipeStatus.error, error: e.toString()));
    }
  }

  /// Swipe action for a [SinglePhoto] item.
  Future<void> swipe(SwipeAction action) async {
    final photo = state.currentPhoto;
    if (photo == null) return;

    final record = SwipeRecord(photo: photo, action: action);
    final newIndex = state.currentIndex + 1;
    final newHistory = [...state.history, record];
    final isComplete =
        newIndex >= state.dailyGoal || newIndex >= state.queue.length;

    emit(state.copyWith(
      currentIndex: newIndex,
      history: newHistory,
      lastSwipe: record,
      status: isComplete ? SwipeStatus.sessionComplete : SwipeStatus.ready,
    ));

    if (isComplete) {
      await _saveSessionStats(newHistory.length);
      await _updateStreak();
    }

    if (action == SwipeAction.favorite) repository.favoritePhoto(photo.id);
  }

  /// Pick the best photo from a [PhotoGroup] and advance the queue.
  /// The page layer is responsible for showing the delete confirmation for
  /// the non-kept photos and calling [confirmDelete] on each.
  Future<void> pickBest(AssetEntity kept) async {
    final record = SwipeRecord(photo: kept, action: SwipeAction.keep);
    final newIndex = state.currentIndex + 1;
    final newHistory = [...state.history, record];
    final isComplete =
        newIndex >= state.dailyGoal || newIndex >= state.queue.length;

    emit(state.copyWith(
      currentIndex: newIndex,
      history: newHistory,
      lastSwipe: record,
      status: isComplete ? SwipeStatus.sessionComplete : SwipeStatus.ready,
    ));

    if (isComplete) {
      await _saveSessionStats(newHistory.length);
      await _updateStreak();
    }
  }

  /// Called after the user confirms deletion in the bottom sheet.
  Future<void> confirmDelete(String photoId) async {
    final record = state.history.lastWhere(
      (r) => r.photo.id == photoId,
      orElse: () => state.history.last,
    );
    repository.deletePhoto(photoId);
    await _addStorageFreed(record.photo);
  }

  void undo() {
    if (!state.canUndo) return;
    final newHistory = state.history.sublist(0, state.history.length - 1);
    emit(state.copyWith(
      currentIndex: state.currentIndex - 1,
      history: newHistory,
      clearLastSwipe: true,
      status: SwipeStatus.ready,
    ));
  }

  Future<void> keepGoing() async {
    emit(state.copyWith(status: SwipeStatus.loading));
    try {
      final nextPage = (state.photos.length / 90).floor();
      final more = await repository.loadPhotos(page: nextPage, pageSize: 30);
      final allPhotos = [...state.photos, ...more];
      final newQueueItems = more.map<SwipeItem>((p) => SinglePhoto(p)).toList();
      final newQueue = [...state.queue, ...newQueueItems];
      final newGoal = state.currentIndex + 30;
      emit(state.copyWith(
        status: newQueue.length > state.currentIndex
            ? SwipeStatus.ready
            : SwipeStatus.sessionComplete,
        photos: allPhotos,
        queue: newQueue,
        dailyGoal: newGoal,
        clearLastSwipe: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: SwipeStatus.error, error: e.toString()));
    }
  }

  void clearLastSwipe() => emit(state.copyWith(clearLastSwipe: true));

  // ── Private ────────────────────────────────────────────────────────────────

  /// Runs on-device perceptual hashing and returns an ordered queue where
  /// near-duplicate clusters are replaced by a single [PhotoGroup] item.
  /// Grouping is a Pro-only feature — free users receive all single photos.
  Future<List<SwipeItem>> _buildQueue(List<AssetEntity> photos) async {
    final isPro = await subscriptionService.checkProStatus();
    await prefs.setBool(AppConstants.kIsProUser, isPro);
    if (!isPro) {
      return photos.map<SwipeItem>((p) => SinglePhoto(p)).toList();
    }

    final groups = await PerceptualHashService.findGroups(photos);
    final groupedIds = <String, PhotoGroup>{};
    for (final g in groups) {
      for (final p in g.photos) {
        groupedIds[p.id] = g;
      }
    }

    final addedGroupLeaders = <String>{};
    final queue = <SwipeItem>[];

    for (final photo in photos) {
      final group = groupedIds[photo.id];
      if (group == null) {
        queue.add(SinglePhoto(photo));
      } else {
        final leaderId = group.photos.first.id;
        if (!addedGroupLeaders.contains(leaderId)) {
          queue.add(group);
          addedGroupLeaders.add(leaderId);
        }
        // Non-leader photos in a group are skipped — handled via group card
      }
    }

    return queue;
  }

  Future<void> _saveSessionStats(int sessionPhotoCount) async {
    final total = prefs.getInt(AppConstants.kTotalPhotosSorted) ?? 0;
    await prefs.setInt(
        AppConstants.kTotalPhotosSorted, total + sessionPhotoCount);
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastDate = prefs.getString(AppConstants.kLastSwipeDate);
    if (lastDate == todayStr) return;

    int streak = prefs.getInt(AppConstants.kCurrentStreak) ?? 0;
    if (lastDate != null) {
      final diff = today.difference(DateTime.parse(lastDate)).inDays;
      streak = diff == 1 ? streak + 1 : 1;
    } else {
      streak = 1;
    }

    await prefs.setInt(AppConstants.kCurrentStreak, streak);
    await prefs.setString(AppConstants.kLastSwipeDate, todayStr);
    emit(state.copyWith(currentStreak: streak));
  }

  Future<void> _addStorageFreed(AssetEntity photo) async {
    try {
      final file = await photo.file;
      if (file == null) return;
      final bytes = await file.length();
      final total = prefs.getInt(AppConstants.kTotalStorageFreedBytes) ?? 0;
      await prefs.setInt(AppConstants.kTotalStorageFreedBytes, total + bytes);
      emit(state.copyWith(
        sessionStorageFreedBytes: state.sessionStorageFreedBytes + bytes,
      ));
    } catch (_) {}
  }
}
