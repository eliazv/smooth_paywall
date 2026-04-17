import 'package:flutter/material.dart';

@immutable
class PaywallFeature {
  final String title;
  final String? description;
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onTap;

  const PaywallFeature({
    required this.title,
    this.description,
    this.icon,
    this.emoji,
    this.onTap,
  });
}
