import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/onboarding_preference.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences prefs;

  OnboardingCubit({required this.prefs}) : super(const OnboardingState());

  void nextPage() {
    if (state.currentPage < 2) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void goToPage(int page) => emit(state.copyWith(currentPage: page));

  // ── Gallery scan ──────────────────────────────────────────────────────────

  Future<void> requestGalleryPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      await startGalleryScan();
    } else {
      emit(state.copyWith(
        galleryScanStatus: GalleryScanStatus.permissionDenied,
      ));
    }
  }

  Future<void> startGalleryScan() async {
    emit(state.copyWith(
      galleryScanStatus: GalleryScanStatus.scanning,
      scanProgress: 0,
    ));

    // Animate progress bar for UX
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!isClosed) {
        emit(state.copyWith(scanProgress: i / 20));
      }
    }

    // Fetch actual photo count + size
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(),
    );

    int totalCount = 0;
    double totalSize = 0;

    for (final album in albums) {
      final count = await album.assetCountAsync;
      totalCount += count;
    }

    // Estimate size (photo_manager doesn't expose total size easily;
    // sample first 50 assets for average, then extrapolate)
    if (albums.isNotEmpty) {
      final allPhotos = await albums.first.getAssetListRange(
        start: 0,
        end: totalCount.clamp(0, 50),
      );
      for (final asset in allPhotos) {
        final file = await asset.file;
        if (file != null) {
          totalSize += await file.length();
        }
      }
      if (allPhotos.isNotEmpty) {
        final avgSize = totalSize / allPhotos.length;
        totalSize = avgSize * totalCount;
      }
    }

    emit(state.copyWith(
      galleryScanStatus: GalleryScanStatus.complete,
      scanProgress: 1.0,
      photoCount: totalCount,
      storageSizeBytes: totalSize,
    ));
  }

  // ── Preferences ───────────────────────────────────────────────────────────

  void togglePreference(OnboardingPreference preference) {
    final current = Set<OnboardingPreference>.from(state.selectedPreferences);

    if (preference == OnboardingPreference.allOfTheAbove) {
      if (current.contains(preference)) {
        current.clear();
      } else {
        current
          ..clear()
          ..addAll(OnboardingPreference.values);
      }
    } else {
      if (current.contains(preference)) {
        current.remove(preference);
        current.remove(OnboardingPreference.allOfTheAbove);
      } else {
        current.add(preference);
        // Auto-select "all" when all individual options chosen
        final individuals = OnboardingPreference.values
            .where((p) => p != OnboardingPreference.allOfTheAbove);
        if (individuals.every(current.contains)) {
          current.add(OnboardingPreference.allOfTheAbove);
        }
      }
    }

    emit(state.copyWith(selectedPreferences: current));
  }

  // ── Complete ──────────────────────────────────────────────────────────────

  Future<void> completeOnboarding() async {
    await prefs.setBool(AppConstants.kOnboardingComplete, true);
    final prefKeys =
        state.selectedPreferences.map((p) => p.name).toList();
    await prefs.setStringList(AppConstants.kSelectedPreferences, prefKeys);
    emit(state.copyWith(isComplete: true));
  }
}
