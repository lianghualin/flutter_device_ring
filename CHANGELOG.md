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
