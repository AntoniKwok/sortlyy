import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/subscription_service.dart';

class RevenueCatSubscriptionService implements SubscriptionService {
  static const _entitlementId = 'Sortlyy Pro';

  @override
  Future<bool> checkProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SubscriptionResult> purchase(SubscriptionPlan plan) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return SubscriptionResult.error;

      final package = plan == SubscriptionPlan.annual
          ? current.annual
          : current.monthly;
      if (package == null) return SubscriptionResult.error;

      final result = await Purchases.purchasePackage(package);
      final isActive =
          result.customerInfo.entitlements.active.containsKey(_entitlementId);
      return isActive ? SubscriptionResult.success : SubscriptionResult.error;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return SubscriptionResult.cancelled;
      }
      return SubscriptionResult.error;
    }
  }

  @override
  Future<SubscriptionResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive =
          customerInfo.entitlements.active.containsKey(_entitlementId);
      return isActive ? SubscriptionResult.success : SubscriptionResult.error;
    } catch (_) {
      return SubscriptionResult.error;
    }
  }

  /// Call after Supabase sign-in so purchases sync across devices.
  static Future<void> logIn(String userId) async {
    await Purchases.logIn(userId);
  }

  /// Call after sign-out.
  static Future<void> logOut() async {
    await Purchases.logOut();
  }
}
