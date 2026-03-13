import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../domain/subscription_service.dart';

/// Development-only implementation.
/// Stores the Pro flag locally — NOT safe across reinstalls.
///
/// Replace with RevenueCatSubscriptionService once you have:
///   1. RevenueCat project + API key
///   2. App Store / Play Store products configured
///   3. `purchases_flutter` added to pubspec.yaml
class MockSubscriptionService implements SubscriptionService {
  final SharedPreferences prefs;

  MockSubscriptionService({required this.prefs});

  @override
  Future<bool> checkProStatus() async {
    return prefs.getBool(AppConstants.kIsProUser) ?? false;
  }

  @override
  Future<SubscriptionResult> purchase(SubscriptionPlan plan) async {
    await prefs.setBool(AppConstants.kIsProUser, true);
    return SubscriptionResult.success;
  }

  @override
  Future<SubscriptionResult> restorePurchases() async {
    // Nothing to restore in mock — real implementation queries the platform
    final alreadyPro = prefs.getBool(AppConstants.kIsProUser) ?? false;
    return alreadyPro
        ? SubscriptionResult.alreadyOwned
        : SubscriptionResult.error;
  }
}

/// ---------- PRODUCTION TEMPLATE (requires purchases_flutter) ----------
///
/// class RevenueCatSubscriptionService implements SubscriptionService {
///   @override
///   Future<bool> checkProStatus() async {
///     final info = await Purchases.getCustomerInfo();
///     return info.entitlements.active.containsKey('pro');
///   }
///
///   @override
///   Future<SubscriptionResult> purchase(SubscriptionPlan plan) async {
///     try {
///       final offerings = await Purchases.getOfferings();
///       final package = plan == SubscriptionPlan.annual
///           ? offerings.current?.annual
///           : offerings.current?.monthly;
///       if (package == null) return SubscriptionResult.error;
///       await Purchases.purchasePackage(package);
///       return SubscriptionResult.success;
///     } on PurchasesErrorCode catch (e) {
///       if (e == PurchasesErrorCode.purchaseCancelledError) {
///         return SubscriptionResult.cancelled;
///       }
///       return SubscriptionResult.error;
///     }
///   }
///
///   @override
///   Future<SubscriptionResult> restorePurchases() async {
///     final info = await Purchases.restorePurchases();
///     return info.entitlements.active.containsKey('pro')
///         ? SubscriptionResult.alreadyOwned
///         : SubscriptionResult.error;
///   }
/// }
