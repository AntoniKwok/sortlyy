import '../../domain/entities/onboarding_preference.dart';

enum GalleryScanStatus { idle, scanning, complete, permissionDenied }

class OnboardingState {
  final int currentPage;
  final GalleryScanStatus galleryScanStatus;
  final double scanProgress;
  final int photoCount;
  final double storageSizeBytes;
  final Set<OnboardingPreference> selectedPreferences;
  final bool isComplete;

  const OnboardingState({
    this.currentPage = 0,
    this.galleryScanStatus = GalleryScanStatus.idle,
    this.scanProgress = 0,
    this.photoCount = 0,
    this.storageSizeBytes = 0,
    this.selectedPreferences = const {},
    this.isComplete = false,
  });

  String get formattedStorage {
    if (storageSizeBytes >= 1e9) {
      return '${(storageSizeBytes / 1e9).toStringAsFixed(1)} GB';
    }
    return '${(storageSizeBytes / 1e6).toStringAsFixed(0)} MB';
  }

  OnboardingState copyWith({
    int? currentPage,
    GalleryScanStatus? galleryScanStatus,
    double? scanProgress,
    int? photoCount,
    double? storageSizeBytes,
    Set<OnboardingPreference>? selectedPreferences,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      galleryScanStatus: galleryScanStatus ?? this.galleryScanStatus,
      scanProgress: scanProgress ?? this.scanProgress,
      photoCount: photoCount ?? this.photoCount,
      storageSizeBytes: storageSizeBytes ?? this.storageSizeBytes,
      selectedPreferences: selectedPreferences ?? this.selectedPreferences,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
