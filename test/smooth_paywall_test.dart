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
    PaywallPlan(
      id: 'lifetime',
      title: 'Lifetime',
      priceLabel: r'$49.99',
      badge: 'One-time',
      description: 'Pay once, keep access forever.',
    ),
  ];

  const twoPlanLayout = [
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

    expect(find.text('Unlock Pro'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.text('One-time'), findsNothing);
    expect(find.textContaining('Start now'), findsOneWidget);
  });

  testWidgets('uses a vertical layout when showing three plans', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final yearlyTopLeft = tester.getTopLeft(find.text('Yearly'));
    final monthlyTopLeft = tester.getTopLeft(find.text('Monthly'));
    final lifetimeTopLeft = tester.getTopLeft(find.text('Lifetime'));

    expect(monthlyTopLeft.dy, greaterThan(yearlyTopLeft.dy));
    expect(lifetimeTopLeft.dy, greaterThan(monthlyTopLeft.dy));
  });

  testWidgets('keeps a horizontal layout when showing two plans', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: twoPlanLayout,
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final yearlyTopLeft = tester.getTopLeft(find.text('Yearly'));
    final monthlyTopLeft = tester.getTopLeft(find.text('Monthly'));

    expect((monthlyTopLeft.dy - yearlyTopLeft.dy).abs(), lessThan(4));
    expect(monthlyTopLeft.dx, greaterThan(yearlyTopLeft.dx));
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

  testWidgets('renders original price when a discount is configured', (
    tester,
  ) async {
    const discountedPlans = [
      PaywallPlan(
        id: 'yearly',
        title: 'Yearly',
        priceLabel: r'$24.99',
        originalPrice: r'$39.99',
        periodLabel: '/year',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: discountedPlans,
            embedded: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(r'$39.99') &&
            widget.text.toPlainText().contains(r'$24.99'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('can hide the default header icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            embedded: true,
            showDefaultHeaderIcon: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.workspace_premium), findsNothing);
  });

  testWidgets('can use an attached bottom-sheet style purchase panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothPaywall(
            title: 'Unlock Pro',
            features: features,
            plans: plans,
            embedded: true,
            useFloatingPlanSheet: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final attachedSheetFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container) {
        return false;
      }

      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) {
        return false;
      }

      return decoration.borderRadius ==
          const BorderRadius.vertical(top: Radius.circular(32));
    });

    expect(attachedSheetFinder, findsOneWidget);
  });

  testWidgets(
    'one-time layout hides badge and description, and shows for life',
    (tester) async {
      const oneTimePlans = [
        PaywallPlan(
          id: 'lifetime',
          title: 'Lifetime',
          priceLabel: r'$49.99',
          badge: 'One-time',
          description: 'Pay once, keep access forever.',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmoothPaywall(
              title: 'Unlock Pro',
              features: features,
              plans: oneTimePlans,
              embedded: true,
              layoutType: PaywallLayoutType.oneTime,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('One-time'), findsNothing);
      expect(find.text('Pay once, keep access forever.'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('for life'),
        ),
        findsOneWidget,
      );
    },
  );

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

  testWidgets('shows subscribed banner when isSubscribed is true', (
    tester,
  ) async {
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
