class RevenueCatConstants {
  RevenueCatConstants._();

  // Injected at build time via --dart-define-from-file=.env.json
  // Never hardcode values here — keep this file committed to git.
  // Get your keys from: https://app.revenuecat.com → Project → API Keys
  static const String iosKey =
      String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String androidKey =
      String.fromEnvironment('REVENUECAT_ANDROID_KEY');
}
