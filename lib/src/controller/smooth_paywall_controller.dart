import 'package:flutter/foundation.dart';

import '../models/paywall_action_result.dart';

class SmoothPaywallController extends ChangeNotifier {
  String? _selectedPlanId;
  PaywallActionState _state = PaywallActionState.idle;
  String? _message;

  String? get selectedPlanId => _selectedPlanId;
  PaywallActionState get state => _state;
  String? get message => _message;

  void setInitialPlan(String planId) {
    _selectedPlanId ??= planId;
    notifyListeners();
  }

  void selectPlan(String planId) {
    _selectedPlanId = planId;
    notifyListeners();
  }

  void setState(PaywallActionState state, {String? message}) {
    _state = state;
    _message = message;
    notifyListeners();
  }

  void resetStatus() {
    _state = PaywallActionState.idle;
    _message = null;
    notifyListeners();
  }
}
