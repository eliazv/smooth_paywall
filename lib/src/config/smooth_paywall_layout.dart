import 'package:flutter/material.dart';

/// Layout configuration for [SmoothPaywall].
@immutable
class SmoothPaywallLayout {
  /// The padding around the outside of the paywall container.
  final EdgeInsetsGeometry outerPadding;

  /// The padding for the main content area.
  final EdgeInsetsGeometry contentPadding;

  /// The maximum width of the paywall.
  final double maxWidth;

  /// The corner radius of cards and buttons.
  final double cornerRadius;

  /// The spacing between purchase plans.
  final double planSpacing;

  /// The vertical spacing between feature items.
  final double featureSpacing;

  /// Creates a [SmoothPaywallLayout] with optional default values.
  const SmoothPaywallLayout({
    this.outerPadding = const EdgeInsets.all(20),
    this.contentPadding = const EdgeInsets.all(20),
    this.maxWidth = 560,
    this.cornerRadius = 30,
    this.planSpacing = 10,
    this.featureSpacing = 10,
  });

  /// Creates a copy of this layout configuration with the given fields replaced.
  SmoothPaywallLayout copyWith({
    EdgeInsetsGeometry? outerPadding,
    EdgeInsetsGeometry? contentPadding,
    double? maxWidth,
    double? cornerRadius,
    double? planSpacing,
    double? featureSpacing,
  }) {
    return SmoothPaywallLayout(
      outerPadding: outerPadding ?? this.outerPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      maxWidth: maxWidth ?? this.maxWidth,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      planSpacing: planSpacing ?? this.planSpacing,
      featureSpacing: featureSpacing ?? this.featureSpacing,
    );
  }
}
