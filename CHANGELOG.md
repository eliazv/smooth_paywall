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
