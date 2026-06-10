## 0.0.5

- Added automatic plan layout switching: 1-2 plans stay side by side, 3+ plans stack vertically.
- Added `lifetime`-friendly rendering with `for life` suffix support and cleaner one-time plan cards.
- Added `showDefaultHeaderIcon` to hide the default top icon and compact the header.
- Added `useFloatingPlanSheet` to switch between floating and attached bottom-sheet purchase panels.
- Simplified title styling, close button styling, plan selection borders, and plan card spacing.
- Improved example app with focused controls for plan count, one-time/subscription mode, discounts, header icon, and floating sheet.

## 0.0.4

- Refined README cross-links to published smooth packages only.
- Aligned release documentation with the new package version.

## 0.0.3

- Fixed README GIF previews for pub.dev by using absolute GitHub URLs.
- Removed legacy "Cashew" references from documentation and assets.

## 0.0.2

- `subtitle` is now nullable — omit it entirely for paywalls without trial text.
- Default `ctaLabel` changed from trial-specific text to generic `'Get Started'`.
- Default `title` changed to `'Go Premium'`.
- Fixed `SmoothPaywallTheme.light()` — now returns real light palette (white/gray background, dark text).
- Fixed `SmoothPaywallTheme.dark()` — separated from light, proper dark palette.
- Fixed `SmoothPaywallTheme.adaptive()` — now reads brightness correctly.
- Feature icons no longer have a background circle — cleaner look.
- Active subscription banner: text is now white (uses `bodyStyle.color`), icon has no background.
- `_SubscriptionPlanCard` text colors now use `textColor` from theme instead of hardcoded white.
- Close button and bottom action labels use theme colors — compatible with both light and dark mode.
- Added `isSubscribed`, `subscriptionExpiryDate`, `subscribedCtaLabel`, `subscribedStatusLabel` params.
- CTA button disabled (not hidden) when `isSubscribed` is true.
- Updated example app: toggle trial text, active subscription, error simulation, embedded mode, layout type.

## 0.0.1

- First public release of `smooth_paywall`.
- Added configurable `SmoothPaywall` widget with modern production UI.
- Added support for subscription and one-time paywall layouts.
- Added built-in status handling (`loading`, `error`, `success`).
- Added `SmoothPaywallController` for selection/status state orchestration.
- Added optional presentation helpers for sheet/page display.
- Added complete example app and widget tests.
