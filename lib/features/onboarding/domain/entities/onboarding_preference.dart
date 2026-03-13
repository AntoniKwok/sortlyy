enum OnboardingPreference {
  freeUpSpace(label: 'Free up space', emoji: '💾'),
  removeDuplicates(label: 'Remove duplicates', emoji: '📋'),
  deleteBlurry(label: 'Delete blurry photos', emoji: '🌫️'),
  clearScreenshots(label: 'Clear screenshots', emoji: '📱'),
  organizeMemories(label: 'Organize memories', emoji: '❤️'),
  allOfTheAbove(label: 'All of the above', emoji: '✨');

  const OnboardingPreference({required this.label, required this.emoji});

  final String label;
  final String emoji;
}
