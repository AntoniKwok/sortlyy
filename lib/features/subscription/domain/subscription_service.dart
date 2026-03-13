/// Contract for subscription status checks and purchases.
///
/// Current implementation: [MockSubscriptionService] — stores flag locally,
/// useful only for development and UI testing.
///
/// Production implementation: replace with RevenueCat via `purchases_flutter`.
/// The rest of the app references only this interface, so the swap is a
/// single-line change in injection_container.dart.
abstract class SubscriptionService {
  /// Returns true if the current user has an active Pro entitlement.
  /// Should always query the platform/server — not a local cache.
  Future<bool> checkProStatus();

  /// Initiates a purchase flow for the given plan.
  Future<SubscriptionResult> purchase(SubscriptionPlan plan);

  /// Asks the platform to restore any previous purchases tied to this
  /// Apple ID / Google account. Must be called from a "Restore Purchases" UI.
  Future<SubscriptionResult> restorePurchases();
}

enum SubscriptionPlan { monthly, annual }

enum SubscriptionResult { success, cancelled, error, alreadyOwned }
