import 'package:flutter/material.dart';

import '../config/smooth_paywall_animation.dart';
import '../config/smooth_paywall_layout.dart';
import '../config/smooth_paywall_theme.dart';
import '../controller/smooth_paywall_controller.dart';
import '../models/paywall_action_result.dart';
import '../models/paywall_feature.dart';
import '../models/paywall_plan.dart';

typedef PaywallPurchaseHandler =
    Future<PaywallActionResult> Function(PaywallPlan selectedPlan);

/// A premium, highly customizable paywall widget for Flutter.
///
/// It supports features like list of benefits, multiple subscription plans,
/// custom theme and layout, and integrated state management via [SmoothPaywallController].
class SmoothPaywall extends StatefulWidget {
  /// The main title of the paywall.
  final String title;

  /// A subtitle displayed below the title.
  final String? subtitle;

  /// The list of features/benefits to display.
  final List<PaywallFeature> features;

  /// The list of purchase plans available.
  final List<PaywallPlan> plans;

  /// The label for the primary call-to-action button.
  final String ctaLabel;

  /// The label for the restore purchases action.
  final String restoreLabel;

  /// The label for the terms of service link.
  final String termsLabel;

  /// The label for the privacy policy link.
  final String privacyLabel;

  /// Custom label for the active status (e.g. "Subscribed").
  final String? statusActiveLabel;

  /// Custom label for error fallback messages.
  final String? statusErrorFallbackLabel;

  /// Whether to show the close button in the top corner.
  final bool showCloseButton;

  /// Whether to show the restore action button.
  final bool showRestoreAction;

  /// Whether to show the legal actions (terms, privacy).
  final bool showLegalActions;

  /// Whether the paywall is embedded in another view (e.g. not a full-screen scaffold).
  final bool embedded;

  /// The layout style (subscription or one-time).
  final PaywallLayoutType layoutType;

  /// The theme configuration.
  final SmoothPaywallTheme? theme;

  /// The layout configuration.
  final SmoothPaywallLayout layout;

  /// The entrance animation configuration.
  final SmoothPaywallAnimation animation;

  /// The controller for managing the paywall state.
  final SmoothPaywallController? controller;

  /// Callback triggered when the primary CTA is pressed to perform a purchase.
  final PaywallPurchaseHandler? onPurchase;

  /// Callback triggered when the restore button is pressed.
  final Future<void> Function()? onRestore;

  /// Callback triggered when the terms of service link is pressed.
  final VoidCallback? onTermsTap;

  /// Callback triggered when the privacy policy link is pressed.
  final VoidCallback? onPrivacyTap;

  /// Callback triggered when the close button is pressed.
  final VoidCallback? onClose;

  /// Callback triggered after a successful purchase.
  final void Function(PaywallPlan plan)? onSuccess;

  /// Callback triggered when an error occurs.
  final void Function(String message)? onError;

  /// An optional widget to display as a logo in the header.
  final Widget? headerLogo;

  /// Whether to show the default premium icon when no custom header media is provided.
  final bool showDefaultHeaderIcon;

  /// Whether to show the background gradient.
  /// When false, uses solid background color from theme.
  final bool showGradientBackground;

  /// Whether the bottom purchase panel should float above the edges.
  /// When false, it behaves like an attached bottom sheet.
  final bool useFloatingPlanSheet;

  /// An optional asset path for a header illustration.
  final String? headerImagePath;

  /// Whether the user is currently subscribed.
  final bool isSubscribed;

  /// The expiry date of the current subscription.
  final DateTime? subscriptionExpiryDate;

  /// CTA label to show when the user is already subscribed.
  final String? subscribedCtaLabel;

  /// Status label to show when the user is already subscribed.
  final String? subscribedStatusLabel;

  /// Creates a [SmoothPaywall].
  const SmoothPaywall({
    super.key,
    required this.features,
    required this.plans,
    this.title = 'Go Premium',
    this.subtitle,
    this.ctaLabel = 'Get Started',
    this.restoreLabel = 'Ripristina',
    this.termsLabel = 'Termini',
    this.privacyLabel = 'Privacy',
    this.statusActiveLabel,
    this.statusErrorFallbackLabel,
    this.showCloseButton = true,
    this.showRestoreAction = true,
    this.showLegalActions = true,
    this.embedded = false,
    this.layoutType = PaywallLayoutType.subscription,
    this.theme,
    this.layout = const SmoothPaywallLayout(),
    this.animation = const SmoothPaywallAnimation(),
    this.controller,
    this.onPurchase,
    this.onRestore,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onClose,
    this.onSuccess,
    this.onError,
    this.headerLogo,
    this.showDefaultHeaderIcon = true,
    this.headerImagePath,
    this.isSubscribed = false,
    this.subscriptionExpiryDate,
    this.subscribedCtaLabel,
    this.subscribedStatusLabel,
    this.showGradientBackground = true,
    this.useFloatingPlanSheet = true,
  }) : assert(plans.length > 0, 'plans cannot be empty');

  @override
  State<SmoothPaywall> createState() => _SmoothPaywallState();
}

class _SmoothPaywallState extends State<SmoothPaywall> {
  late SmoothPaywallController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SmoothPaywallController();
    _controller.setInitialPlan(widget.plans.first.id);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SmoothPaywall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? SmoothPaywallController();
      _controller.setInitialPlan(widget.plans.first.id);
      _controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  PaywallPlan get _selectedPlan {
    final selectedId = _controller.selectedPlanId;
    return widget.plans.firstWhere(
      (plan) => plan.id == selectedId,
      orElse: () => widget.plans.first,
    );
  }

  Future<void> _handlePurchase() async {
    if (_controller.state == PaywallActionState.loading) {
      return;
    }

    _controller.setState(PaywallActionState.loading);

    try {
      final result = widget.onPurchase != null
          ? await widget.onPurchase!(_selectedPlan)
          : const PaywallActionResult.success();

      if (result.userCancelled) {
        _controller.resetStatus();
        return;
      }

      if (result.state == PaywallActionState.success) {
        _controller.setState(
          PaywallActionState.success,
          message:
              result.message ??
              widget.statusActiveLabel ??
              'Abbonamento attivo',
        );
        widget.onSuccess?.call(_selectedPlan);
        return;
      }

      if (result.state == PaywallActionState.error) {
        final message =
            result.message ??
            widget.statusErrorFallbackLabel ??
            'Errore durante l\'acquisto';
        _controller.setState(PaywallActionState.error, message: message);
        widget.onError?.call(message);
        return;
      }

      _controller.resetStatus();
    } catch (error) {
      final message = error.toString();
      _controller.setState(PaywallActionState.error, message: message);
      widget.onError?.call(message);
    }
  }

  Future<void> _handleRestore() async {
    if (widget.onRestore == null) {
      return;
    }
    _controller.setState(PaywallActionState.loading, message: 'Ripristino...');
    try {
      await widget.onRestore!.call();
      _controller.setState(
        PaywallActionState.success,
        message: 'Acquisti ripristinati',
      );
    } catch (error) {
      final message = error.toString();
      _controller.setState(PaywallActionState.error, message: message);
      widget.onError?.call(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? SmoothPaywallTheme.adaptive(context);

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        if (widget.showGradientBackground)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.15),
                    theme.backgroundBottom,
                    theme.backgroundBottom,
                  ],
                  stops: const [0, 0.3, 1],
                ),
              ),
            ),
          ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 248),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (_shouldShowHeaderIllustration) ...[
                _buildHeaderIllustration(theme),
                const SizedBox(height: 12),
              ],
              _buildPremiumTitle(theme),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.subtitle!,
                  style: theme.subtitleStyle,
                  textAlign: TextAlign.left,
                ),
              ],
              const SizedBox(height: 14),
              _buildFeaturesList(theme),
              const SizedBox(height: 14),
              if (widget.showRestoreAction || widget.showLegalActions)
                _buildBottomActions(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildFixedSheet(theme),
        ),
        if (widget.showCloseButton)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed:
                  widget.onClose ?? () => Navigator.of(context).maybePop(),
              splashRadius: 18,
              icon: Icon(Icons.close, color: theme.bodyStyle.color, size: 20),
            ),
          ),
      ],
    );

    final animated = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: widget.animation.entranceDuration,
      curve: widget.animation.curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: FractionalTranslation(
            translation: Offset(
              0,
              (1 - value) * widget.animation.beginOffset.dy,
            ),
            child: child,
          ),
        );
      },
      child: stack,
    );

    if (widget.embedded) {
      return SizedBox(height: 720, child: animated);
    }

    return Scaffold(
      backgroundColor: theme.backgroundBottom,
      body: SafeArea(child: animated),
    );
  }

  bool get _shouldShowHeaderIllustration =>
      widget.headerLogo != null ||
      widget.headerImagePath != null ||
      widget.showDefaultHeaderIcon;

  Widget _buildHeaderIllustration(SmoothPaywallTheme theme) {
    if (widget.headerLogo != null) {
      return SizedBox(width: 112, height: 112, child: widget.headerLogo!);
    }
    if (widget.headerImagePath != null) {
      return Image.asset(
        widget.headerImagePath!,
        width: 112,
        height: 112,
        fit: BoxFit.contain,
      );
    }
    if (!widget.showDefaultHeaderIcon) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.3),
            theme.accentColor.withValues(alpha: 0.2),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium,
        size: 46,
        color: Color(0xFFFFD700),
      ),
    );
  }

  Widget _buildPremiumTitle(SmoothPaywallTheme theme) {
    const fontSize = 28.0;
    return Text(
      widget.title,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: theme.titleStyle.color ?? theme.bodyStyle.color ?? Colors.white,
      ),
    );
  }

  Widget _buildFeaturesList(SmoothPaywallTheme theme) {
    return Column(
      children: widget.features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: feature.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        if (feature.emoji != null)
                          Text(
                            feature.emoji!,
                            style: const TextStyle(fontSize: 22),
                          )
                        else
                          Icon(
                            feature.icon ?? Icons.check,
                            size: 22,
                            color: theme.primaryColor,
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(feature.title, style: theme.bodyStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomActions(SmoothPaywallTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.showRestoreAction)
          _BottomActionButton(
            icon: Icons.restore,
            label: widget.restoreLabel,
            onTap: _handleRestore,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
          ),
        if (widget.showLegalActions)
          _BottomActionButton(
            icon: Icons.privacy_tip,
            label: widget.privacyLabel,
            onTap: widget.onPrivacyTap,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
          ),
        if (widget.showLegalActions)
          _BottomActionButton(
            icon: Icons.article,
            label: widget.termsLabel,
            onTap: widget.onTermsTap,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
          ),
      ],
    );
  }

  Widget _buildFixedSheet(SmoothPaywallTheme theme) {
    final floating = widget.useFloatingPlanSheet;

    return Container(
      margin: floating
          ? const EdgeInsets.fromLTRB(12, 8, 12, 12)
          : EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: floating
            ? BorderRadius.circular(40)
            : const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: theme.borderColor),
        boxShadow: floating
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSubscribed) _buildSubscribedBanner(theme),
          if (!widget.isSubscribed) _buildSubscriptionPlans(theme),
          if (!widget.isSubscribed) const SizedBox(height: 16),
          if (!widget.isSubscribed) _buildStatusBanner(theme),
          _buildCtaButton(theme),
        ],
      ),
    );
  }

  Widget _buildSubscribedBanner(SmoothPaywallTheme theme) {
    final expiryDate = widget.subscriptionExpiryDate;
    final expiryText = expiryDate != null
        ? 'Rinnovo il ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
        : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: theme.bodyStyle.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subscribedStatusLabel ?? 'Active subscription',
                  style: TextStyle(
                    color: theme.bodyStyle.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (expiryText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    expiryText,
                    style: TextStyle(
                      color: theme.bodyStyle.color?.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(SmoothPaywallTheme theme) {
    final useCompactStack = widget.plans.length >= 3;
    final planCards = widget.plans.map((plan) {
      final isSelected = plan.id == _selectedPlan.id;
      final isLifetimePlan = plan.id.toLowerCase() == 'lifetime';
      final periodLabel =
          plan.periodLabel ??
          (widget.layoutType == PaywallLayoutType.oneTime || isLifetimePlan
              ? ' for life'
              : null);

      return GestureDetector(
        onTap: () => _controller.selectPlan(plan.id),
        child: _SubscriptionPlanCard(
          plan: plan,
          isSelected: isSelected,
          compact: useCompactStack,
          layoutType: widget.layoutType,
          isLifetimePlan: isLifetimePlan,
          periodLabel: periodLabel,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          cardColor: theme.cardColor,
          borderColor: theme.borderColor,
          textColor: theme.bodyStyle.color ?? Colors.white,
        ),
      );
    }).toList();

    if (widget.plans.length >= 3) {
      return Column(
        children: [
          for (var i = 0; i < planCards.length; i++) ...[
            if (i > 0) SizedBox(height: widget.layout.planSpacing),
            SizedBox(width: double.infinity, child: planCards[i]),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < planCards.length; i++) ...[
          if (i > 0) SizedBox(width: widget.layout.planSpacing),
          Expanded(child: planCards[i]),
        ],
      ],
    );
  }

  Widget _buildStatusBanner(SmoothPaywallTheme theme) {
    final state = _controller.state;
    if (state == PaywallActionState.idle) {
      return const SizedBox.shrink();
    }

    final isError = state == PaywallActionState.error;
    final color = isError ? theme.errorColor : theme.primaryColor;
    final text =
        _controller.message ??
        (isError ? 'Errore durante l\'acquisto' : 'Operazione completata');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(SmoothPaywallTheme theme) {
    final loading = _controller.state == PaywallActionState.loading;
    final subscribed = widget.isSubscribed;
    final label = subscribed
        ? (widget.subscribedCtaLabel ?? 'Abbonato')
        : widget.ctaLabel;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (loading || subscribed) ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: subscribed ? 0 : 8,
          shadowColor: theme.primaryColor.withValues(alpha: 0.5),
          disabledBackgroundColor: subscribed
              ? theme.primaryColor.withValues(alpha: 0.15)
              : null,
        ),
        child: subscribed
            ? Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: theme.ctaTextStyle.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              )
            : Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(label, style: theme.ctaTextStyle),
                ),
              ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color labelColor;

  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primaryColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: labelColor.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final PaywallPlan plan;
  final bool isSelected;
  final bool compact;
  final PaywallLayoutType layoutType;
  final bool isLifetimePlan;
  final String? periodLabel;
  final Color primaryColor;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;

  const _SubscriptionPlanCard({
    required this.plan,
    required this.isSelected,
    required this.compact,
    required this.layoutType,
    required this.isLifetimePlan,
    required this.periodLabel,
    required this.primaryColor,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge =
        layoutType != PaywallLayoutType.oneTime &&
        !isLifetimePlan &&
        plan.badge != null;
    final titleColor = isSelected
        ? textColor
        : textColor.withValues(alpha: 0.6);
    final secondaryColor = isSelected
        ? textColor.withValues(alpha: 0.72)
        : textColor.withValues(alpha: 0.44);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryColor : borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: compact ? 20 : 24,
                    height: compact ? 20 : 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : textColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: compact ? 13 : 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              RichText(
                text: TextSpan(
                  children: [
                    if (plan.originalPrice != null) ...[
                      TextSpan(
                        text: plan.originalPrice!,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: '  '),
                    ],
                    TextSpan(
                      text: plan.priceLabel,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: compact ? 17 : 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (periodLabel != null)
                      TextSpan(
                        text: periodLabel!,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showBadge)
          Positioned(
            top: -10,
            left: compact ? null : 0,
            right: compact ? 12 : 0,
            child: Align(
              alignment: compact ? Alignment.topRight : Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, accentColor]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  plan.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
