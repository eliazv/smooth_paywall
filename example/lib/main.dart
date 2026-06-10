import 'package:flutter/material.dart';
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
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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

enum _PlanPreset { twoPlans, threePlans }

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
  PaywallLayoutType _layoutType = PaywallLayoutType.subscription;
  _PlanPreset _planPreset = _PlanPreset.threePlans;
  bool _showHeaderIcon = false;
  bool _useFloatingSheet = true;
  bool _showDiscount = true;

  static const List<PaywallFeature> _features = [
    PaywallFeature(title: 'No ads', icon: Icons.block),
    PaywallFeature(title: 'Priority support', icon: Icons.support_agent),
    PaywallFeature(title: 'Unlimited exports', icon: Icons.all_inclusive),
  ];

  List<PaywallPlan> get _plans {
    if (_layoutType == PaywallLayoutType.oneTime) {
      return [
        PaywallPlan(
          id: 'lifetime',
          title: 'Lifetime',
          priceLabel: _showDiscount ? '€49.99' : '€69.99',
          originalPrice: _showDiscount ? '€69.99' : null,
        ),
      ];
    }

    final yearlyPlan = PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: _showDiscount ? '€24.99' : '€39.99',
      originalPrice: _showDiscount ? '€39.99' : null,
      periodLabel: '/year',
      badge: 'Best value',
      isRecommended: true,
    );

    const monthlyPlan = PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: '€4.99',
      periodLabel: '/month',
    );

    if (_planPreset == _PlanPreset.twoPlans) {
      return [yearlyPlan, monthlyPlan];
    }

    return [
      yearlyPlan,
      monthlyPlan,
      PaywallPlan(
        id: 'lifetime',
        title: 'Lifetime',
        priceLabel: _showDiscount ? '€49.99' : '€69.99',
        originalPrice: _showDiscount ? '€69.99' : null,
      ),
    ];
  }

  bool get _isLight => widget.themeMode == ThemeMode.light;

  SmoothPaywall _buildPaywall({required bool embedded}) {
    return SmoothPaywall(
      embedded: embedded,
      title: 'Upgrade to Pro',
      subtitle: 'All premium tools in one place.',
      ctaLabel: 'Continue',
      restoreLabel: 'Restore',
      termsLabel: 'Terms',
      privacyLabel: 'Privacy',
      showDefaultHeaderIcon: _showHeaderIcon,
      useFloatingPlanSheet: _useFloatingSheet,
      features: _features,
      plans: _plans,
      layoutType: _layoutType,
      theme: _isLight ? SmoothPaywallTheme.light() : SmoothPaywallTheme.dark(),
      onPurchase: (selectedPlan) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return PaywallActionResult.success('Selected ${selectedPlan.title}');
      },
      onRestore: () async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      onTermsTap: () => _showSnack('Terms tapped'),
      onPrivacyTap: () => _showSnack('Privacy tapped'),
    );
  }

  void _openPaywall() {
    showSmoothPaywallPage<void>(
      context: context,
      builder: (_) => _buildPaywall(embedded: false),
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
                Card.outlined(
                  child: Column(
                    children: [
                      _SegmentedRow<PaywallLayoutType>(
                        label: 'Paywall type',
                        value: _layoutType,
                        options: const {
                          PaywallLayoutType.subscription: 'Subscription',
                          PaywallLayoutType.oneTime: 'One-time',
                        },
                        onChanged: (value) =>
                            setState(() => _layoutType = value),
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      if (_layoutType == PaywallLayoutType.subscription) ...[
                        _SegmentedRow<_PlanPreset>(
                          label: 'Plan options',
                          value: _planPreset,
                          options: const {
                            _PlanPreset.twoPlans: '2 plans',
                            _PlanPreset.threePlans: '3 plans',
                          },
                          onChanged: (value) =>
                              setState(() => _planPreset = value),
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ],
                      SwitchListTile.adaptive(
                        title: const Text('Show header icon'),
                        subtitle: const Text(
                          'Hide it to move title and content higher',
                        ),
                        value: _showHeaderIcon,
                        onChanged: (value) =>
                            setState(() => _showHeaderIcon = value),
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      SwitchListTile.adaptive(
                        title: const Text('Show discount'),
                        subtitle: const Text(
                          'Strikes the old price and shows the discounted one',
                        ),
                        value: _showDiscount,
                        onChanged: (value) =>
                            setState(() => _showDiscount = value),
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      SwitchListTile.adaptive(
                        title: const Text('Floating bottom card'),
                        subtitle: const Text(
                          'Disable it for a full-width bottom-sheet style',
                        ),
                        value: _useFloatingSheet,
                        onChanged: (value) =>
                            setState(() => _useFloatingSheet = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openPaywall,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open paywall'),
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildPaywall(embedded: true),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  (entry) => ButtonSegment<T>(
                    value: entry.key,
                    label: Text(entry.value),
                  ),
                )
                .toList(),
            selected: {value},
            onSelectionChanged: (selection) => onChanged(selection.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}
