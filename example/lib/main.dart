import 'package:flutter/material.dart';
import 'package:smooth_bottom_sheet/smooth_bottom_sheet.dart';
import 'package:smooth_paywall/smooth_paywall.dart';

void main() {
  runApp(const SmoothPaywallExampleApp());
}

class SmoothPaywallExampleApp extends StatefulWidget {
  const SmoothPaywallExampleApp({super.key});

  @override
  State<SmoothPaywallExampleApp> createState() =>
      _SmoothPaywallExampleAppState();
}

class _SmoothPaywallExampleAppState extends State<SmoothPaywallExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'smooth_paywall example',
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6F3DFF),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6F3DFF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: _ExampleHomePage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}

class _ExampleHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const _ExampleHomePage({
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<_ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<_ExampleHomePage> {
  bool _simulateError = false;
  bool _simulateSubscribed = false;
  bool _showTrial = true;
  bool _showEmbedded = false;
  PaywallLayoutType _layoutType = PaywallLayoutType.subscription;

  static final List<PaywallFeature> _features = [
    PaywallFeature(
      title: 'No ads',
      description: 'Browse without interruptions.',
      icon: Icons.block,
      onTap: null,
    ),
    PaywallFeature(
      title: 'Priority support',
      description: 'Get help faster than free users.',
      emoji: '🎯',
      onTap: null,
    ),
    PaywallFeature(
      title: 'Exclusive content',
      description: 'Unlock premium sections and templates.',
      icon: Icons.auto_awesome,
      onTap: null,
    ),
    PaywallFeature(
      title: 'Unlimited exports',
      description: 'No daily limits on any plan.',
      emoji: '📦',
      onTap: null,
    ),
  ];

  static const List<PaywallPlan> _subscriptionPlans = [
    PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: 'EUR 24.99',
      periodLabel: '/year',
      badge: 'Best value',
      isRecommended: true,
    ),
    PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: 'EUR 4.99',
      periodLabel: '/month',
    ),
  ];

  static const List<PaywallPlan> _oneTimePlans = [
    PaywallPlan(
      id: 'lifetime',
      title: 'Lifetime',
      priceLabel: 'EUR 49.99',
      badge: 'One-time',
      isRecommended: true,
    ),
  ];

  List<PaywallPlan> get _plans =>
      _layoutType == PaywallLayoutType.subscription
          ? _subscriptionPlans
          : _oneTimePlans;

  bool get _isLight => widget.themeMode == ThemeMode.light;

  SmoothPaywall _buildPaywall({required bool embedded}) {
    return SmoothPaywall(
      embedded: embedded,
      title: 'Upgrade to Pro',
      subtitle: _showTrial ? '7-day free trial, cancel anytime.' : null,
      ctaLabel: _showTrial ? 'Start free trial' : 'Subscribe now',
      restoreLabel: 'Restore',
      termsLabel: 'Terms',
      privacyLabel: 'Privacy',
      features: _features,
      plans: _plans,
      layoutType: _layoutType,
      theme: _isLight ? SmoothPaywallTheme.light() : SmoothPaywallTheme.dark(),
      isSubscribed: _simulateSubscribed,
      subscriptionExpiryDate:
          _simulateSubscribed ? DateTime(2025, 12, 31) : null,
      subscribedStatusLabel: 'Pro plan active',
      subscribedCtaLabel: 'Subscribed',
      onPurchase: (selectedPlan) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (_simulateError) {
          return const PaywallActionResult.error(
            'Payment failed. Please try again.',
          );
        }
        return PaywallActionResult.success(
          'Subscribed to ${selectedPlan.title}!',
        );
      },
      onRestore: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      onClose: () => Navigator.of(context).maybePop(),
      onTermsTap: () => _showSnack('Terms tapped'),
      onPrivacyTap: () => _showSnack('Privacy tapped'),
      onSuccess: (plan) => _showSnack('Success: ${plan.title}'),
      onError: (msg) => _showSnack('Error: $msg'),
    );
  }

  void _openPaywall() {
    showSmoothPaywallPage<void>(
      context: context,
      builder: (_) => _buildPaywall(embedded: false),
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('smooth_paywall'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeader('Layout'),
                _OptionCard(
                  children: [
                    _SegmentedRow<PaywallLayoutType>(
                      label: 'Layout type',
                      value: _layoutType,
                      options: const {
                        PaywallLayoutType.subscription: 'Subscription',
                        PaywallLayoutType.oneTime: 'One-time',
                      },
                      onChanged: (v) => setState(() => _layoutType = v),
                    ),
                    _ToggleTile(
                      title: 'Show trial text',
                      subtitle: 'subtitle + CTA mention free trial',
                      value: _showTrial,
                      onChanged: (v) => setState(() => _showTrial = v),
                    ),
                    _ToggleTile(
                      title: 'Embedded mode',
                      subtitle: 'Fixed height, no scaffold',
                      value: _showEmbedded,
                      onChanged: (v) => setState(() => _showEmbedded = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader('Subscription state'),
                _OptionCard(
                  children: [
                    _ToggleTile(
                      title: 'Active subscription',
                      subtitle: 'Shows subscribed UI with expiry date',
                      value: _simulateSubscribed,
                      onChanged: (v) =>
                          setState(() => _simulateSubscribed = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader('Purchase behavior'),
                _OptionCard(
                  children: [
                    _ToggleTile(
                      title: 'Simulate purchase error',
                      subtitle: 'onPurchase returns PaywallActionResult.error',
                      value: _simulateError,
                      onChanged: (v) => setState(() => _simulateError = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openPaywall,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open paywall'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showSmoothBottomSheet<void>(
                      context: context,
                      title: 'Feature detail',
                      subtitle: 'smooth_bottom_sheet integration example',
                      scrollable: true,
                      child: Column(
                        children: [
                          const Icon(Icons.block, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No ads',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enjoy a completely ad-free experience across all screens. No banners, no interstitials, no interruptions.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.layers_outlined),
                  label: const Text('Feature detail sheet (smooth_bottom_sheet)'),
                ),
                if (_showEmbedded) ...[
                  const SizedBox(height: 24),
                  _SectionHeader('Embedded preview'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildPaywall(embedded: true),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final List<Widget> children;
  const _OptionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: children
            .expand(
              (child) => [
                child,
                if (child != children.last)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            )
            .toList(),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const _SegmentedRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SegmentedButton<T>(
            segments: options.entries
                .map(
                  (e) => ButtonSegment<T>(value: e.key, label: Text(e.value)),
                )
                .toList(),
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}
