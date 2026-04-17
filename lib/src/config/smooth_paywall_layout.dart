import 'package:flutter/material.dart';

@immutable
class SmoothPaywallLayout {
  final EdgeInsetsGeometry outerPadding;
  final EdgeInsetsGeometry contentPadding;
  final double maxWidth;
  final double cornerRadius;
  final double planSpacing;
  final double featureSpacing;

  const SmoothPaywallLayout({
    this.outerPadding = const EdgeInsets.all(20),
    this.contentPadding = const EdgeInsets.all(20),
    this.maxWidth = 560,
    this.cornerRadius = 30,
    this.planSpacing = 10,
    this.featureSpacing = 10,
  });

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
