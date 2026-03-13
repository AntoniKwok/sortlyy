import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../subscription/domain/subscription_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SharedPreferences prefs;
  final SubscriptionService subscriptionService;

  DashboardCubit({required this.prefs, required this.subscriptionService})
      : super(const DashboardState());

  Future<void> load() async {
    final streak = prefs.getInt(AppConstants.kCurrentStreak) ?? 0;
    final storageFreed = prefs.getInt(AppConstants.kTotalStorageFreedBytes) ?? 0;
    final photosSorted = prefs.getInt(AppConstants.kTotalPhotosSorted) ?? 0;

    // Emit immediately with cached pro status — dashboard loads instantly
    final cachedIsPro = prefs.getBool(AppConstants.kIsProUser) ?? false;
    emit(DashboardState(
      currentStreak: streak,
      totalStorageFreedBytes: storageFreed,
      totalPhotosSorted: photosSorted,
      isLoaded: true,
      isProUser: cachedIsPro,
    ));

    // Silently refresh pro status from RevenueCat in the background
    try {
      final freshIsPro = await subscriptionService.checkProStatus();
      if (freshIsPro != cachedIsPro) {
        await prefs.setBool(AppConstants.kIsProUser, freshIsPro);
        emit(state.copyWith(isProUser: freshIsPro));
      }
    } catch (_) {
      // Offline or RC unavailable — cached value is fine, no error shown
    }
  }
}
