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
  final Widget? headerLogo;
  final String? headerImagePath;
  final bool isSubscribed;
  final DateTime? subscriptionExpiryDate;
  final String? subscribedCtaLabel;
  final String? subscribedStatusLabel;

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
    this.headerImagePath,
    this.isSubscribed = false,
    this.subscriptionExpiryDate,
    this.subscribedCtaLabel,
    this.subscribedStatusLabel,
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
      children: [
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 280),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeaderIllustration(theme),
              _buildPremiumTitle(theme),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.subtitle!,
                  style: theme.subtitleStyle,
                  textAlign: TextAlign.center,
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.bodyStyle.color?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: theme.bodyStyle.color, size: 20),
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

  Widget _buildHeaderIllustration(SmoothPaywallTheme theme) {
    if (widget.headerLogo != null) {
      return SizedBox(width: 150, height: 150, child: widget.headerLogo!);
    }
    if (widget.headerImagePath != null) {
      return Image.asset(
        widget.headerImagePath!,
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 120,
      height: 120,
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
        size: 60,
        color: Color(0xFFFFD700),
      ),
    );
  }

  Widget _buildPremiumTitle(SmoothPaywallTheme theme) {
    const fontSize = 28.0;
    final text = widget.title.toUpperCase();

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black.withValues(alpha: 0.45),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.titleGradientColors ?? [const Color(0xFFFFD700), theme.accentColor],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          blendMode: BlendMode.srcIn,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: theme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSubscribed) _buildSubscribedBanner(theme),
          if (!widget.isSubscribed &&
              widget.layoutType == PaywallLayoutType.subscription)
            _buildSubscriptionPlans(theme),
          if (!widget.isSubscribed &&
              widget.layoutType == PaywallLayoutType.subscription)
            const SizedBox(height: 20),
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
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: theme.bodyStyle.color,
            size: 20,
          ),
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
    return Row(
      children: widget.plans.map((plan) {
        final isSelected = plan.id == _selectedPlan.id;
        final index = widget.plans.indexOf(plan);

        return Expanded(
          child: GestureDetector(
            onTap: () => _controller.selectPlan(plan.id),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == widget.plans.length - 1 ? 0 : 8,
              ),
              child: _SubscriptionPlanCard(
                plan: plan,
                isSelected: isSelected,
                primaryColor: theme.primaryColor,
                accentColor: theme.accentColor,
                cardColor: theme.cardColor,
                borderColor: theme.borderColor,
                textColor: theme.bodyStyle.color ?? Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
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
                    Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
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
  final Color primaryColor;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;

  const _SubscriptionPlanCard({
    required this.plan,
    required this.isSelected,
    required this.primaryColor,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : cardColor,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: isSelected ? textColor : textColor.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? primaryColor : textColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: plan.priceLabel,
                      style: TextStyle(
                        color: isSelected ? textColor : textColor.withValues(alpha: 0.6),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.periodLabel != null)
                      TextSpan(
                        text: plan.periodLabel!,
                        style: TextStyle(
                          color: isSelected
                              ? textColor.withValues(alpha: 0.7)
                              : textColor.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (plan.badge != null)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
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
