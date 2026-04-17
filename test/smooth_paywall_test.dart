import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_paywall/smooth_paywall.dart';

void main() {
  const plans = [
    PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: r'$24.99',
      periodLabel: '/year',
      badge: 'Save 50%',
    ),
    PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: r'$4.99',
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

  testWidgets('subtitle is hidden when null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            subtitle: null,
            features: features,
            plans: plans,
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('trial'), findsNothing);
    expect(find.textContaining('prova'), findsNothing);
  });

  testWidgets('subtitle renders when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            subtitle: '7-day free trial',
            features: features,
            plans: plans,
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('7-day free trial'), findsOneWidget);
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

  testWidgets('shows subscribed banner when isSubscribed is true',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            embedded: true,
            isSubscribed: true,
            subscribedStatusLabel: 'Pro active',
            subscribedCtaLabel: 'Subscribed',
            subscriptionExpiryDate: DateTime(2025, 12, 31),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pro active'), findsOneWidget);
    expect(find.textContaining('31/12/2025'), findsOneWidget);
    expect(find.textContaining('Subscribed'), findsOneWidget);
  });
}
