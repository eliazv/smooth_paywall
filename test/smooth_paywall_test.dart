import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_paywall/smooth_paywall.dart';

void main() {
  const plans = [
    PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: '\$24.99',
      periodLabel: '/year',
      badge: 'Save 50%',
    ),
    PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: '\$4.99',
      periodLabel: '/month',
    ),
  ];

  const features = [
    PaywallFeature(title: 'No ads'),
    PaywallFeature(title: 'Priority support'),
  ];

  testWidgets('renders title, plans and CTA', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            ctaLabel: 'Start now',
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('UNLOCK PRO'), findsWidgets);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.textContaining('Start now'), findsOneWidget);
  });

  testWidgets('calls purchase handler and shows success state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            ctaLabel: 'Buy',
            embedded: true,
            onPurchase: (_) async =>
                const PaywallActionResult.success('All set!'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final buyButtonFinder = find.textContaining('Buy');
    await tester.ensureVisible(buyButtonFinder);
    await tester.tap(buyButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('All set!'), findsOneWidget);
  });
}
