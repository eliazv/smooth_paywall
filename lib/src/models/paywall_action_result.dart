/// The state of a paywall action (e.g. purchasing, restoring).
enum PaywallActionState {
  /// No action is currently in progress.
  idle,

  /// An action is currently being processed.
  loading,

  /// The last action failed with an error.
  error,

  /// The last action completed successfully.
  success,
}

/// The result of an action performed on the paywall.
class PaywallActionResult {
  /// The resulting state of the action.
  final PaywallActionState state;

  /// An optional message describing the result (especially useful for errors).
  final String? message;

  /// Whether the user manually cancelled the action.
  final bool userCancelled;

  /// Creates a new paywall action result.
  const PaywallActionResult({
    required this.state,
    this.message,
    this.userCancelled = false,
  });

  /// Creates a success result.
  const PaywallActionResult.success([String? message])
    : this(state: PaywallActionState.success, message: message);

  /// Creates an error result with a message.
  const PaywallActionResult.error(String message)
    : this(state: PaywallActionState.error, message: message);

  /// Creates a result indicating the action was cancelled by the user.
  const PaywallActionResult.cancelled([String? message])
    : this(
        state: PaywallActionState.idle,
        message: message,
        userCancelled: true,
      );
}

/// The layout style for the paywall.
enum PaywallLayoutType {
  /// A layout optimized for subscription plans.
  subscription,

  /// A layout optimized for one-time purchases.
  oneTime,
}
