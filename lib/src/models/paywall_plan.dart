import 'package:flutter/foundation.dart';

/// Represents a purchase plan (subscription or one-time purchase) on the paywall.
@immutable
class PaywallPlan {
  /// The unique identifier for this plan (e.g. the product ID from App Store/Play Store).
  final String id;

  /// The title of the plan (e.g. "Monthly", "Annual").
  final String title;

  /// The price label to display (e.g. "$4.99", "Free").
  final String priceLabel;

  /// The billing period label (e.g. "per month", "/ year").
  final String? periodLabel;

  /// An optional badge to display (e.g. "Most Popular", "-20%").
  final String? badge;

  /// An optional original price label (displayed as strike-through).
  /// Useful for showing discounts (e.g. "$9.99" when current price is "$4.99").
  final String? originalPrice;

  /// A description of the plan.
  final String? description;

  /// Whether this plan should be highlighted as the recommended option.
  final bool isRecommended;

  /// Creates a new paywall plan.
  const PaywallPlan({
    required this.id,
    required this.title,
    required this.priceLabel,
    this.periodLabel,
    this.badge,
    this.originalPrice,
    this.description,
    this.isRecommended = false,
  });
}
