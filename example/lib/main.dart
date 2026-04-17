import 'package:flutter/material.dart';
import 'package:smooth_bottom_sheet/smooth_bottom_sheet.dart';
import 'package:smooth_paywall/smooth_paywall.dart';

void main() {
  runApp(const SmoothPaywallExampleApp());
}

class SmoothPaywallExampleApp extends StatelessWidget {
  const SmoothPaywallExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'smooth_paywall example',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0EA5E9),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF22D3EE),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const _ExampleHomePage(),
    );
  }
}

class _ExampleHomePage extends StatefulWidget {
  const _ExampleHomePage();

  @override
  State<_ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<_ExampleHomePage> {
  bool _useBottomSheetWrapper = false;
  bool _simulateError = false;

  List<PaywallFeature> get _features => const [
    PaywallFeature(
      title: 'No ads and faster UX',
      description: 'Remove interruptions and keep users focused.',
      icon: Icons.block,
    ),
    PaywallFeature(
      title: 'Priority support',
      description: 'Get answers faster for your customers.',
      icon: Icons.support_agent,
    ),
    PaywallFeature(
      title: 'Exclusive content',
      description: 'Unlock premium sections and templates.',
      icon: Icons.auto_awesome,
    ),
  ];

  List<PaywallPlan> get _plans => const [
    PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: 'EUR 24.99',
      periodLabel: '/year',
      badge: 'Best value',
      description: '2 months free compared to monthly',
      isRecommended: true,
    ),
    PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: 'EUR 4.99',
      periodLabel: '/month',
    ),
  ];

  SmoothPaywall _buildPaywall({required bool embedded}) {
    return SmoothPaywall(
      embedded: embedded,
      title: 'Upgrade to Pro',
      subtitle: 'Beautiful monetization UI with clean architecture.',
      ctaLabel: 'Start trial',
      features: _features,
      plans: _plans,
      layoutType: PaywallLayoutType.subscription,
      onPurchase: (selectedPlan) async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (_simulateError) {
          return const PaywallActionResult.error(
            'Payment failed. Please try again.',
          );
        }
        return PaywallActionResult.success(
          'You are now subscribed to ${selectedPlan.title}.',
        );
      },
      onRestore: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      onClose: () => Navigator.of(context).maybePop(),
      onTermsTap: () => _showInfo(context, 'Terms tapped'),
      onPrivacyTap: () => _showInfo(context, 'Privacy tapped'),
    );
  }

  void _openPaywall() {
    if (_useBottomSheetWrapper) {
      showSmoothBottomSheet<void>(
        context: context,
        title: 'Premium',
        subtitle: 'Paywall inside smooth_bottom_sheet',
        child: _buildPaywall(embedded: true),
      );
      return;
    }

    showSmoothPaywallPage<void>(
      context: context,
      builder: (_) => _buildPaywall(embedded: false),
    );
  }

  void _showInfo(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('smooth_paywall example')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Use smooth_bottom_sheet wrapper'),
                  value: _useBottomSheetWrapper,
                  onChanged: (value) {
                    setState(() {
                      _useBottomSheetWrapper = value;
                    });
                  },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Simulate purchase error'),
                  value: _simulateError,
                  onChanged: (value) {
                    setState(() {
                      _simulateError = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _openPaywall,
                  child: const Text('Open paywall'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
