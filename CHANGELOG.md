## 0.2.1

* **New:** `labelBackgroundDecoration` parameter — add a background (color, border, shadow) behind the label for readability over overlapping elements like connection lines.
* **New:** `labelBackgroundPadding` parameter — inner padding when background decoration is set.
* Updated example app with label background decoration demos.

## 0.2.0

* **New:** `labelWidget` parameter — display any custom widget below the ring (multi-line text, IP addresses, port counts, status badges, etc.). Takes precedence over `label`.
* **New:** `labelMaxWidth` parameter — constrain the label area width (defaults to ring size).
* **New:** `labelPadding` parameter — control spacing between ring and label area.
* Label area height is now dynamic instead of fixed at 20px, supporting multi-line content.
* Updated example app with "Custom Label Widgets" gallery section.

## 0.1.1

* **Fix:** Child widget (images, SVGs) no longer overflows and covers ring arcs — automatically constrained to fit inside the ring with `FittedBox` scaling.
* **New:** `glowIntensity` parameter (0.0–1.0) to control the prominence of the outer glow halo.
* Updated example app with glow intensity slider.
* Updated README with custom image and glow intensity usage examples.

## 0.1.0

* Initial release of `flutter_device_ring`.
* `DeviceRing` widget with dual inbound/outbound traffic arcs.
* Tier-based coloring (low, medium, high, critical).
* Animated arc transitions with configurable duration.
* Optional pulsing glow effect.
* Info overlay showing percentage and tier badges.
* `DeviceRingTheme` for full color and style customization.
* Direction labels (IN/OUT) on ring sides.
