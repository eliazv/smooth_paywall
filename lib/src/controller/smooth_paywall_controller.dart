import 'package:flutter/foundation.dart';

import '../models/paywall_action_result.dart';

/// A controller to manage the state of the [SmoothPaywall].
class SmoothPaywallController extends ChangeNotifier {
  String? _selectedPlanId;
  PaywallActionState _state = PaywallActionState.idle;
  String? _message;

  /// The ID of the currently selected plan.
  String? get selectedPlanId => _selectedPlanId;

  /// The current action state (e.g. idle, loading, error).
  PaywallActionState get state => _state;

  /// An optional message related to the current state (e.g. an error message).
  String? get message => _message;

  /// Sets the initial plan ID if one hasn't been selected yet.
  void setInitialPlan(String planId) {
    _selectedPlanId ??= planId;
    notifyListeners();
  }

  /// Updates the currently selected plan.
  void selectPlan(String planId) {
    _selectedPlanId = planId;
    notifyListeners();
  }

  /// Sets the current action state and message.
  void setState(PaywallActionState state, {String? message}) {
    _state = state;
    _message = message;
    notifyListeners();
  }

  /// Resets the action state to idle.
  void resetStatus() {
    _state = PaywallActionState.idle;
    _message = null;
    notifyListeners();
  }
}
