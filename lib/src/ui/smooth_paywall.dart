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
typedef PaywallSubscribedAction = Future<void> Function();
typedef PaywallSubscribedSecondaryTextBuilder =
    String Function(DateTime? subscriptionExpiryDate);

/// A premium, highly customizable paywall widget for Flutter.
class SmoothPaywall extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<PaywallFeature> features;
  final List<PaywallPlan> plans;
  final String ctaLabel;
  final String restoreLabel;
  final String termsLabel;
  final String privacyLabel;
  final String? statusActiveLabel;
  final String? statusErrorFallbackLabel;
  final bool showCloseButton;
  final bool showRestoreAction;
  final bool showLegalActions;
  final bool embedded;
  final PaywallLayoutType layoutType;
  final SmoothPaywallTheme? theme;
  final SmoothPaywallLayout layout;
  final SmoothPaywallAnimation animation;
  final SmoothPaywallController? controller;
  final PaywallPurchaseHandler? onPurchase;
  final Future<void> Function()? onRestore;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onClose;
  final void Function(PaywallPlan plan)? onSuccess;
  final void Function(String message)? onError;
  final PaywallSubscribedAction? onSubscribedAction;
  final Widget? headerLogo;
  final bool showDefaultHeaderIcon;
  final bool showGradientBackground;
  final bool useFloatingPlanSheet;
  final String? headerImagePath;
  final bool isSubscribed;
  final DateTime? subscriptionExpiryDate;
  final String? subscribedCtaLabel;
  final String? subscribedStatusLabel;
  final String? subscribedSecondaryLabel;
  final PaywallSubscribedSecondaryTextBuilder? subscribedSecondaryTextBuilder;
  final String restoringStatusLabel;
  final String restoreSuccessLabel;
  final String purchaseSuccessLabel;
  final String purchaseErrorLabel;
  final String genericSuccessLabel;
  final String genericErrorLabel;
  final String subscribedDefaultStatusLabel;
  final String subscribedDefaultCtaLabel;
  final String lifetimePeriodLabel;

  const SmoothPaywall({
    super.key,
    required this.features,
    required this.plans,
    this.title = 'Go Premium',
    this.subtitle,
    this.ctaLabel = 'Continue',
    this.restoreLabel = 'Restore',
    this.termsLabel = 'Terms',
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
    this.onSubscribedAction,
    this.headerLogo,
    this.showDefaultHeaderIcon = true,
    this.headerImagePath,
    this.isSubscribed = false,
    this.subscriptionExpiryDate,
    this.subscribedCtaLabel,
    this.subscribedStatusLabel,
    this.subscribedSecondaryLabel,
    this.subscribedSecondaryTextBuilder,
    this.restoringStatusLabel = 'Restoring...',
    this.restoreSuccessLabel = 'Purchases restored',
    this.purchaseSuccessLabel = 'Purchase successful',
    this.purchaseErrorLabel = 'Purchase failed',
    this.genericSuccessLabel = 'Operation completed',
    this.genericErrorLabel = 'Something went wrong',
    this.subscribedDefaultStatusLabel = 'Active subscription',
    this.subscribedDefaultCtaLabel = 'Manage subscription',
    this.lifetimePeriodLabel = ' for life',
    this.showGradientBackground = true,
    this.useFloatingPlanSheet = true,
  }) : assert(plans.length > 0, 'plans cannot be empty');

  @override
  State<SmoothPaywall> createState() => _SmoothPaywallState();
}

class _SmoothPaywallState extends State<SmoothPaywall> {
  late SmoothPaywallController _controller;
  bool _ownsController = false;
  final GlobalKey _sheetKey = GlobalKey();
  double _sheetHeight = 248;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SmoothPaywallController();
    _controller.addListener(_onControllerChanged);
    _syncSelectedPlanWithWidget();
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
      _controller.addListener(_onControllerChanged);
    }
    _syncSelectedPlanWithWidget();
  }

  void _syncSelectedPlanWithWidget() {
    if (widget.plans.isEmpty) return;
    final selectedId = _controller.selectedPlanId;
    final hasSelectedPlan = widget.plans.any((plan) => plan.id == selectedId);
    if (hasSelectedPlan) return;

    final recommendedPlan = widget.plans.where((plan) => plan.isRecommended);
    final fallbackPlan = recommendedPlan.isNotEmpty
        ? recommendedPlan.first
        : widget.plans.first;
    _controller.selectPlan(fallbackPlan.id);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncSheetHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _sheetKey.currentContext;
      final box = context?.findRenderObject() as RenderBox?;
      final nextHeight = box?.size.height;
      if (nextHeight == null) return;
      if ((_sheetHeight - nextHeight).abs() < 1) return;
      setState(() {
        _sheetHeight = nextHeight;
      });
    });
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
              widget.purchaseSuccessLabel,
        );
        widget.onSuccess?.call(_selectedPlan);
        return;
      }

      if (result.state == PaywallActionState.error) {
        final message =
            result.message ??
            widget.statusErrorFallbackLabel ??
            widget.purchaseErrorLabel;
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
    _controller.setState(
      PaywallActionState.loading,
      message: widget.restoringStatusLabel,
    );
    try {
      await widget.onRestore!.call();
      _controller.setState(
        PaywallActionState.success,
        message: widget.restoreSuccessLabel,
      );
    } catch (error) {
      final message = error.toString();
      _controller.setState(PaywallActionState.error, message: message);
      widget.onError?.call(message);
    }
  }

  Future<void> _handleSubscribedAction() async {
    if (widget.onSubscribedAction == null ||
        _controller.state == PaywallActionState.loading) {
      return;
    }

    _controller.setState(PaywallActionState.loading);
    try {
      await widget.onSubscribedAction!.call();
      _controller.resetStatus();
    } catch (error) {
      final message = error.toString();
      _controller.setState(PaywallActionState.error, message: message);
      widget.onError?.call(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? SmoothPaywallTheme.adaptive(context);
    _syncSheetHeight();

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        if (widget.showGradientBackground)
          Positioned.fill(child: _buildSoftBackground(theme)),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, _sheetHeight + 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (_shouldShowHeaderIllustration) ...[
                _buildHeaderIllustration(theme),
                const SizedBox(height: 12),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 52),
                child: _buildPremiumTitle(theme),
              ),
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
            child: Material(
              color: theme.cardColor.withValues(alpha: 0.64),
              shape: const CircleBorder(),
              elevation: 0,
              child: IconButton(
                onPressed:
                    widget.onClose ?? () => Navigator.of(context).maybePop(),
                splashRadius: 16,
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.close,
                  color: theme.bodyStyle.color,
                  size: 20,
                ),
              ),
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

  Widget _buildSoftBackground(SmoothPaywallTheme theme) {
    return Container(
      color: theme.backgroundBottom,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: _BackgroundGlow(
              size: 280,
              color: theme.primaryColor.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 140,
            right: -110,
            child: _BackgroundGlow(
              size: 260,
              color: theme.accentColor.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 20,
            child: _BackgroundGlow(
              size: 220,
              color: theme.primaryColor.withValues(alpha: 0.08),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.backgroundTop.withValues(alpha: 0.78),
                    theme.backgroundBottom.withValues(alpha: 0.88),
                    theme.backgroundBottom,
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    return Text(
      widget.title,
      textAlign: TextAlign.left,
      style: theme.titleStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 0.95,
        color: theme.titleStyle.color ?? theme.bodyStyle.color ?? Colors.white,
      ),
    );
  }

  Widget _buildFeaturesList(SmoothPaywallTheme theme) {
    return Column(
      children: widget.features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: feature.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
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
                            size: 26,
                            color: theme.primaryColor,
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            feature.title,
                            style: theme.bodyStyle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
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
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 12,
      children: [
        if (widget.showRestoreAction)
          _BottomActionButton(
            label: widget.restoreLabel,
            onTap: _handleRestore,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
            showIcon: false,
          ),
        if (widget.showLegalActions)
          _BottomActionButton(
            label: widget.privacyLabel,
            onTap: widget.onPrivacyTap,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
            showIcon: false,
          ),
        if (widget.showLegalActions)
          _BottomActionButton(
            label: widget.termsLabel,
            onTap: widget.onTermsTap,
            primaryColor: theme.primaryColor,
            labelColor: theme.bodyStyle.color ?? Colors.white,
            showIcon: false,
          ),
      ],
    );
  }

  Widget _buildFixedSheet(SmoothPaywallTheme theme) {
    final floating = widget.useFloatingPlanSheet;

    return Container(
      key: _sheetKey,
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
          _buildStatusBanner(theme),
          _buildCtaButton(theme),
        ],
      ),
    );
  }

  Widget _buildSubscribedBanner(SmoothPaywallTheme theme) {
    final expiryText =
        widget.subscribedSecondaryLabel ??
        widget.subscribedSecondaryTextBuilder?.call(
          widget.subscriptionExpiryDate,
        );

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
                  widget.subscribedStatusLabel ??
                      widget.subscribedDefaultStatusLabel,
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
              ? widget.lifetimePeriodLabel
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
        (isError ? widget.genericErrorLabel : widget.genericSuccessLabel);

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
        ? (widget.subscribedCtaLabel ?? widget.subscribedDefaultCtaLabel)
        : widget.ctaLabel;
    final canTapSubscribed =
        subscribed && widget.onSubscribedAction != null && !loading;
    final onPressed = subscribed
        ? (canTapSubscribed ? _handleSubscribedAction : null)
        : (loading ? null : _handlePurchase);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: subscribed && !canTapSubscribed ? 0 : 8,
          shadowColor: theme.primaryColor.withValues(alpha: 0.5),
          disabledBackgroundColor: subscribed && !canTapSubscribed
              ? theme.primaryColor.withValues(alpha: 0.15)
              : null,
        ),
        child: subscribed
            ? canTapSubscribed
                  ? Ink(
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(label, style: theme.ctaTextStyle),
                                ],
                              ),
                      ),
                    )
                  : Container(
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
  final String label;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color labelColor;
  final bool showIcon;

  const _BottomActionButton({
    required this.label,
    required this.onTap,
    required this.primaryColor,
    required this.labelColor,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.circle, color: primaryColor, size: 22),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: showIcon
                    ? labelColor.withValues(alpha: 0.85)
                    : primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                decoration: showIcon ? null : TextDecoration.underline,
                decorationColor: primaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
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
