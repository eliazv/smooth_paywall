# smooth_paywall

[![pub package](https://img.shields.io/pub/v/smooth_paywall.svg)](https://pub.dev/packages/smooth_paywall)
[![likes](https://img.shields.io/pub/likes/smooth_paywall)](https://pub.dev/packages/smooth_paywall)
[![Live demo](https://img.shields.io/badge/Live-demo-2ea44f?logo=flutter&logoColor=white)](https://eliazv.github.io/smooth_paywall/)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-support-FFDD00?logo=buymeacoffee&logoColor=000)](https://buymeacoffee.com/elizavatta)

A smooth, production-ready paywall UI for Flutter apps.

Build elegant monetization screens with configurable themes, layouts, and interaction states.

👉 **[Try the live demo](https://eliazv.github.io/smooth_paywall/)** — interact with every layout and state in your browser.

<p align="center">
  <img src="https://raw.githubusercontent.com/eliazv/smooth_paywall/master/assets/readme/white.gif" width="30%" alt="Smooth Paywall White" />
  <img src="https://raw.githubusercontent.com/eliazv/smooth_paywall/master/assets/readme/black.gif" width="30%" alt="Smooth Paywall Black" />
  <img src="https://raw.githubusercontent.com/eliazv/smooth_paywall/master/assets/readme/lifetime.png" width="30%" alt="Smooth Paywall Lifetime" />
</p>

## Why this package

Most paywall implementations are tightly coupled to billing SDK details or hardcoded designs.

`smooth_paywall` focuses on:

- Reusable UI for real products
- Clear separation between UI, logic, and configuration
- Flexibility for subscriptions and one-time purchase layouts

## Features

- Modern paywall UI with dark mode support
- Subscription and one-time layouts
- Built-in states: `idle`, `loading`, `error`, `success`
- Automatic plan layout switching for `1`, `2`, or `3+` plans
- Optional floating or attached bottom purchase panel
- Optional default header icon
- Discount-ready plan cards via `originalPrice`
- Can run standalone or be embedded in custom containers
- Optional integration with `smooth_bottom_sheet` without package dependency

## Installation

```yaml
dependencies:
  smooth_paywall: ^0.0.7
```

## Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:smooth_paywall/smooth_paywall.dart';

SmoothPaywall(
  title: 'Unlock Premium',
  subtitle: 'Choose the best plan for you.',
  showDefaultHeaderIcon: false,
  useFloatingPlanSheet: false,
  features: const [
    PaywallFeature(title: 'No ads', icon: Icons.block),
    PaywallFeature(title: 'Priority support', icon: Icons.support_agent),
  ],
  plans: const [
    PaywallPlan(
      id: 'yearly',
      title: 'Yearly',
      priceLabel: '\$24.99',
      originalPrice: '\$39.99',
      periodLabel: '/year',
      badge: 'Best value',
    ),
    PaywallPlan(
      id: 'monthly',
      title: 'Monthly',
      priceLabel: '\$4.99',
      periodLabel: '/month',
    ),
    PaywallPlan(
      id: 'lifetime',
      title: 'Lifetime',
      priceLabel: '\$49.99',
    ),
  ],
  onPurchase: (selectedPlan) async {
    return const PaywallActionResult.success();
  },
)
```

## Plan configuration

Use `plans` and `layoutType` together:

- `PaywallLayoutType.subscription` is for recurring plans like `monthly` and `yearly`.
- `PaywallLayoutType.oneTime` is for permanent unlocks like `lifetime`.
- With `1` or `2` plans, cards stay side by side.
- With `3` or more plans, cards automatically switch to one card per row.

Recommended plan setup:

- `monthly`: set `priceLabel` and `periodLabel: '/month'`
- `yearly`: set `priceLabel`, optional `originalPrice`, and `periodLabel: '/year'`
- `lifetime`: set `priceLabel` only; the widget automatically shows `for life`

Discount setup:

- Use `priceLabel` for the current price.
- Use `originalPrice` for the old price shown struck through.
- `originalPrice` works for both subscription and lifetime plans.

One-time behavior:

- In `PaywallLayoutType.oneTime`, the plan chip is hidden.
- In `PaywallLayoutType.oneTime`, plan descriptions are hidden inside the price card.
- If a plan has no `periodLabel` and is `lifetime` or `oneTime`, the widget shows `for life`.

## Layout options

- `showDefaultHeaderIcon: false` removes the built-in top icon and pulls content higher.
- `useFloatingPlanSheet: true` keeps the lower purchase area as a floating card.
- `useFloatingPlanSheet: false` makes the lower purchase area attached to the edges like a bottom sheet.
- The title is left-aligned and rendered as plain bold text.
- Selected plans use a colored border without a filled background.

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
- Sizes, spacing, and structure via `SmoothPaywallLayout`
- Motion timings and transitions via `SmoothPaywallAnimation`
- Text labels, legal actions, restore flow, and close behavior

## Example app

See `example/lib/main.dart` for a complete demo with:

- Subscription vs one-time mode
- Two plans vs three plans
- Discount on/off
- Header icon on/off
- Floating vs attached bottom panel

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
- [smooth_onboarding](https://pub.dev/packages/smooth_onboarding)
- [smooth_auth_sheet](https://pub.dev/packages/smooth_auth_sheet)
- [smooth_toast](https://pub.dev/packages/smooth_toast)

## LLM and SEO keywords

Flutter paywall, subscription screen, in-app purchase UI, monetization UI,
trial offer screen, premium plans widget, reusable paywall component.

## License

MIT
