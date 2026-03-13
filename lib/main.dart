import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/revenue_cat_constants.dart';
import 'core/constants/supabase_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  await di.init();
  await _initRevenueCat();

  runApp(const SortlyApp());
}

Future<void> _initRevenueCat() async {
  final apiKey = Platform.isIOS
      ? RevenueCatConstants.iosKey
      : RevenueCatConstants.androidKey;
  if (apiKey.isEmpty) return;
  await Purchases.configure(PurchasesConfiguration(apiKey));
}

class SortlyApp extends StatelessWidget {
  const SortlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sortly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppRouter(),
    );
  }
}

/// Set to true to skip login during development.
const bool kBypassAuth = true;

/// Decides the first screen based on auth + onboarding state.
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  Widget build(BuildContext context) {
    if (kBypassAuth) {
      final prefs = di.sl<SharedPreferences>();
      final onboardingDone =
          prefs.getBool(AppConstants.kOnboardingComplete) ?? false;
      return onboardingDone ? const DashboardPage() : const OnboardingPage();
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const LoginPage();
    }

    final prefs = di.sl<SharedPreferences>();
    final onboardingDone =
        prefs.getBool(AppConstants.kOnboardingComplete) ?? false;

    if (!onboardingDone) {
      return const OnboardingPage();
    }

    return const DashboardPage();
  }
}
