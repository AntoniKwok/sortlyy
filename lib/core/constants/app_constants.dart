class AppConstants {
  AppConstants._();

  // Session defaults
  static const int defaultDailySwipeGoal = 30;
  static const int undoToastDurationSeconds = 5;

  // Card physics
  static const double cardRotationFactor = 0.04;
  static const double actionThreshold = 0.35; // fraction of screen width

  // Onboarding preferences (keys for SharedPreferences)
  static const String kOnboardingComplete = 'onboarding_complete';
  static const String kSelectedPreferences = 'selected_preferences';
  static const String kDailySwipeGoal = 'daily_swipe_goal';

  // Stats keys
  static const String kTotalStorageFreedBytes = 'total_storage_freed_bytes';
  static const String kTotalPhotosSorted = 'total_photos_sorted';
  static const String kCurrentStreak = 'current_streak';
  static const String kLastSwipeDate = 'last_swipe_date';

  // Subscription
  static const String kIsProUser = 'is_pro_user';

  // Card stack
  static const int cardStackSize = 3;
}
