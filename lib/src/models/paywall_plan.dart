import 'package:flutter/foundation.dart';

@immutable
class PaywallPlan {
  final String id;
  final String title;
  final String priceLabel;
  final String? periodLabel;
  final String? badge;
  final String? description;
  final bool isRecommended;

  const PaywallPlan({
    required this.id,
    required this.title,
    required this.priceLabel,
    this.periodLabel,
    this.badge,
    this.description,
    this.isRecommended = false,
  });
}
