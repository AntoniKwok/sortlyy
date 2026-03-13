class SupabaseConstants {
  SupabaseConstants._();

  // Injected at build time via --dart-define-from-file=.env.json
  // Never hardcode values here — keep this file committed to git.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
}
