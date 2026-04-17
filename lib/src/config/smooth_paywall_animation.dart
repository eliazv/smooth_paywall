import 'package:flutter/material.dart';

@immutable
class SmoothPaywallAnimation {
  final Duration entranceDuration;
  final Duration statusTransitionDuration;
  final Curve curve;
  final Offset beginOffset;

  const SmoothPaywallAnimation({
    this.entranceDuration = const Duration(milliseconds: 420),
    this.statusTransitionDuration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 0.06),
  });

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
