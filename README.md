# smooth_paywall

[![pub package](https://img.shields.io/pub/v/smooth_paywall.svg)](https://pub.dev/packages/smooth_paywall)
[![likes](https://img.shields.io/pub/likes/smooth_paywall)](https://pub.dev/packages/smooth_paywall)

A smooth, production-ready paywall UI for Flutter apps.

Build elegant monetization screens with configurable themes, layouts and interaction states.

<p align="center">
  <img src="https://raw.githubusercontent.com/eliazv/smooth_paywall/main/assets/readme/white.gif" width="45%" alt="Smooth Paywall White" />
  <img src="https://raw.githubusercontent.com/eliazv/smooth_paywall/main/assets/readme/black.gif" width="45%" alt="Smooth Paywall Black" />
</p>

Demo GIFs are included in `assets/readme`.

## Why this package

Most paywall implementations are tightly coupled to billing SDK details or hardcoded designs.

`smooth_paywall` focuses on:

- Reusable UI for real products
- Clear separation between UI, logic and configuration
- Flexibility for subscriptions and one-time purchase layouts

## Features

- Modern paywall UI with dark mode support
- Subscription and one-time layouts
- Built-in states: `idle`, `loading`, `error`, `success`
- Accessibility-ready semantics on plans, features and CTA
- Configurable theme, spacing, typography and animation behavior
- Can run standalone or be embedded in custom containers
- Optional integration with `smooth_bottom_sheet` (without package dependency)

## Installation

```yaml
dependencies:
	smooth_paywall: ^0.0.1
```

## Usage

```dart
import 'package:smooth_paywall/smooth_paywall.dart';

SmoothPaywall(
	title: 'Unlock Premium',
	subtitle: 'Choose the best plan for you.',
	features: const [
		PaywallFeature(title: 'No ads', icon: Icons.block),
		PaywallFeature(title: 'Priority support', icon: Icons.support_agent),
	],
	plans: const [
		PaywallPlan(
			id: 'yearly',
			title: 'Yearly',
			priceLabel: '\$24.99',
			periodLabel: '/year',
			badge: 'Best value',
		),
		PaywallPlan(
			id: 'monthly',
			title: 'Monthly',
			priceLabel: '\$4.99',
			periodLabel: '/month',
		),
	],
	onPurchase: (selectedPlan) async {
		// Connect your billing flow and return action status.
		return const PaywallActionResult.success();
	},
)
```

## Optional integration with smooth_bottom_sheet

`smooth_paywall` does not require `smooth_bottom_sheet`, but you can combine both:

```dart
showSmoothBottomSheet(
	context: context,
	title: 'Premium',
	child: SmoothPaywall(
		embedded: true,
		features: features,
		plans: plans,
	),
);
```

## Personalization

You can customize:

- Complete color system via `SmoothPaywallTheme`
- Sizes, spacing and structure via `SmoothPaywallLayout`
- Motion timings and transitions via `SmoothPaywallAnimation`
- Text labels, legal actions, restore flow and close behavior

## Example app

See `example/lib/main.dart` for a complete demo with:

- Standalone full-screen paywall presentation
- Optional `smooth_bottom_sheet` wrapper
- Simulated success and error purchase states

## Author

Created by **Elia Zavatta**.

I build production-ready Flutter apps and reusable UI components.

- GitHub: [github.com/eliazv](https://github.com/eliazv)
- LinkedIn: [linkedin.com/in/eliazavatta](https://www.linkedin.com/in/eliazavatta/)
- Email: [info@eliazavatta.it](mailto:info@eliazavatta.it)

## Related smooth packages

- [smooth_bottom_sheet](https://pub.dev/packages/smooth_bottom_sheet)
- [smooth_charts](https://pub.dev/packages/smooth_charts)
- [smooth_infinite_tab_bar](https://pub.dev/packages/smooth_infinite_tab_bar)

## License

MIT
