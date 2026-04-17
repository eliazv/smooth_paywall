enum PaywallActionState { idle, loading, error, success }

class PaywallActionResult {
  final PaywallActionState state;
  final String? message;
  final bool userCancelled;

  const PaywallActionResult({
    required this.state,
    this.message,
    this.userCancelled = false,
  });

  const PaywallActionResult.success([String? message])
    : this(state: PaywallActionState.success, message: message);

  const PaywallActionResult.error(String message)
    : this(state: PaywallActionState.error, message: message);

  const PaywallActionResult.cancelled([String? message])
    : this(
        state: PaywallActionState.idle,
        message: message,
        userCancelled: true,
      );
}

enum PaywallLayoutType { subscription, oneTime }
