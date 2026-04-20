import 'package:flutter/material.dart';

/// Animation configuration for [SmoothPaywall].
@immutable
class SmoothPaywallAnimation {
  /// The duration of the entrance animation.
  final Duration entranceDuration;

  /// The duration of the transition between action states (e.g. loading to success).
  final Duration statusTransitionDuration;

  /// The curve used for animations.
  final Curve curve;

  /// The starting offset for the entrance animation.
  final Offset beginOffset;

  /// Creates a [SmoothPaywallAnimation] with optional default values.
  const SmoothPaywallAnimation({
    this.entranceDuration = const Duration(milliseconds: 420),
    this.statusTransitionDuration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 0.06),
  });

  /// Creates a copy of this animation configuration with the given fields replaced.
  SmoothPaywallAnimation copyWith({
    Duration? entranceDuration,
    Duration? statusTransitionDuration,
    Curve? curve,
    Offset? beginOffset,
  }) {
    return SmoothPaywallAnimation(
      entranceDuration: entranceDuration ?? this.entranceDuration,
      statusTransitionDuration:
          statusTransitionDuration ?? this.statusTransitionDuration,
      curve: curve ?? this.curve,
      beginOffset: beginOffset ?? this.beginOffset,
    );
  }
}
