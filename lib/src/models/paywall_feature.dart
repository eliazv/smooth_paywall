import 'package:flutter/widgets.dart';

/// Represents a feature or benefit shown on the paywall.
@immutable
class PaywallFeature {
  /// The title of the feature.
  final String title;

  /// A longer description of the feature.
  final String? description;

  /// An icon to display next to the feature.
  final IconData? icon;

  /// An emoji to display next to the feature (used as an alternative to [icon]).
  final String? emoji;

  /// Optional callback when the feature item is tapped.
  final VoidCallback? onTap;

  /// Creates a new paywall feature.
  const PaywallFeature({
    required this.title,
    this.description,
    this.icon,
    this.emoji,
    this.onTap,
  });
}
