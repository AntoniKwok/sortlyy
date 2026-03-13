class DashboardState {
  final int currentStreak;
  final int totalStorageFreedBytes;
  final int totalPhotosSorted;
  final bool isLoaded;
  final bool isProUser;

  const DashboardState({
    this.currentStreak = 0,
    this.totalStorageFreedBytes = 0,
    this.totalPhotosSorted = 0,
    this.isLoaded = false,
    this.isProUser = false,
  });

  DashboardState copyWith({
    int? currentStreak,
    int? totalStorageFreedBytes,
    int? totalPhotosSorted,
    bool? isLoaded,
    bool? isProUser,
  }) {
    return DashboardState(
      currentStreak: currentStreak ?? this.currentStreak,
      totalStorageFreedBytes:
          totalStorageFreedBytes ?? this.totalStorageFreedBytes,
      totalPhotosSorted: totalPhotosSorted ?? this.totalPhotosSorted,
      isLoaded: isLoaded ?? this.isLoaded,
      isProUser: isProUser ?? this.isProUser,
    );
  }

  /// Storage freed formatted as "X B", "X KB", "X.X MB", or "X.X GB"
  String get storageFreeFormatted => _formatBytes(totalStorageFreedBytes);

  static String formatBytes(int bytes) => _formatBytes(bytes);

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
