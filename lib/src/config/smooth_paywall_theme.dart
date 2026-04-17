import 'package:flutter/material.dart';

@immutable
class SmoothPaywallTheme {
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color cardColor;
  final Color borderColor;
  final Color primaryColor;
  final Color accentColor;
  final Color featureIconBackground;
  final Color errorColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle bodyStyle;
  final TextStyle ctaTextStyle;
  /// Gradient colors for the title text. Null = default gold/accent gradient.
  final List<Color>? titleGradientColors;

  const SmoothPaywallTheme({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.cardColor,
    required this.borderColor,
    required this.primaryColor,
    required this.accentColor,
    required this.featureIconBackground,
    required this.errorColor,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.bodyStyle,
    required this.ctaTextStyle,
    this.titleGradientColors,
  });

  factory SmoothPaywallTheme.light() {
    return const SmoothPaywallTheme(
      backgroundTop: Color(0xFFF2F2F7),
      backgroundBottom: Color(0xFFFFFFFF),
      cardColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE5E5EA),
      primaryColor: Color(0xFF6F3DFF),
      accentColor: Color(0xFF875CFF),
      featureIconBackground: Color(0x1F6F3DFF),
      errorColor: Color(0xFFEF4444),
      titleStyle: TextStyle(
        color: Color(0xFF1C1C1E),
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      subtitleStyle: TextStyle(
        color: Color(0xFF3C3C43),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyStyle: TextStyle(
        color: Color(0xFF1C1C1E),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      ctaTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  factory SmoothPaywallTheme.dark() {
    return const SmoothPaywallTheme(
      backgroundTop: Color(0xFF0D1117),
      backgroundBottom: Color(0xFF0D1117),
      cardColor: Color(0xFF161B22),
      borderColor: Color(0xFF30363D),
      primaryColor: Color(0xFF6F3DFF),
      accentColor: Color(0xFF875CFF),
      featureIconBackground: Color(0x1F6F3DFF),
      errorColor: Color(0xFFEF4444),
      titleStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      subtitleStyle: TextStyle(
        color: Color(0xCCFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      ctaTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  factory SmoothPaywallTheme.adaptive(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? SmoothPaywallTheme.dark()
        : SmoothPaywallTheme.light();
  }

  SmoothPaywallTheme copyWith({
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? cardColor,
    Color? borderColor,
    Color? primaryColor,
    Color? accentColor,
    Color? featureIconBackground,
    Color? errorColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? bodyStyle,
    TextStyle? ctaTextStyle,
    List<Color>? titleGradientColors,
  }) {
    return SmoothPaywallTheme(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      featureIconBackground:
          featureIconBackground ?? this.featureIconBackground,
      errorColor: errorColor ?? this.errorColor,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      ctaTextStyle: ctaTextStyle ?? this.ctaTextStyle,
      titleGradientColors: titleGradientColors ?? this.titleGradientColors,
    );
  }
}
