import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../features/subscription/data/revenuecat_subscription_service.dart';
import '../../features/subscription/domain/subscription_service.dart';
import '../../features/swipe/data/datasources/gallery_datasource.dart';
import '../../features/swipe/data/repositories/gallery_repository_impl.dart';
import '../../features/swipe/domain/repositories/gallery_repository.dart';
import '../../features/swipe/presentation/cubit/swipe_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      // Add your iOS client ID from GoogleService-Info.plist
      // clientId: 'YOUR_IOS_CLIENT_ID',
      //
      // Web/Android client ID from Google Cloud Console
      // (needed for the idToken to be valid for Supabase)
      serverClientId: 'YOUR_WEB_CLIENT_ID',
    ),
  );

  _initAuth();
  _initSubscription();
  _initDashboard();
  _initOnboarding();
  _initSwipe();
}

void _initSubscription() {
  sl.registerLazySingleton<SubscriptionService>(
    () => RevenueCatSubscriptionService(),
  );
}

void _initAuth() {
  // BLoC
  sl.registerFactory(() => AuthBloc(
        signInWithGoogle: sl(),
        signInWithApple: sl(),
        signOut: sl(),
        getCurrentUser: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: sl(),
      googleSignIn: sl(),
    ),
  );
}

void _initDashboard() {
  sl.registerFactory(
      () => DashboardCubit(prefs: sl(), subscriptionService: sl()));
}

void _initOnboarding() {
  sl.registerFactory(() => OnboardingCubit(prefs: sl()));
}

void _initSwipe() {
  // Cubit
  sl.registerFactory(() => SwipeCubit(
        repository: sl(),
        prefs: sl(),
        subscriptionService: sl(),
      ));

  // Repository
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(dataSource: sl(), prefs: sl()),
  );

  // Data source
  sl.registerLazySingleton<GalleryDataSource>(
    () => GalleryDataSourceImpl(),
  );
}
