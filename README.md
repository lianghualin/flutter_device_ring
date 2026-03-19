# flutter_device_ring

A customizable dual-traffic utilization ring gauge widget for Flutter. Displays inbound and outbound network utilization for devices as animated arcs with tier-based coloring.

## Features

- **Dual-arc ring** — left half shows inbound traffic, right half shows outbound
- **Tier-based colors** — automatically colors arcs as low, medium, high, or critical
- **Smooth animations** — animated transitions when values change
- **Glow effect** — optional pulsing glow around the ring
- **Info overlay** — toggle to show percentage and tier badges instead of the child widget
- **Direction labels** — configurable IN/OUT labels on ring sides
- **Fully themeable** — customize all colors, stroke width, and label styles via `DeviceRingTheme`

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_device_ring: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter_device_ring/flutter_device_ring.dart';

DeviceRing(
  inbound: 0.73,
  outbound: 0.45,
  size: 100,
  child: Icon(Icons.router, size: 40),
  label: 'Switch-A',
)
```

### With custom theme

```dart
DeviceRing(
  inbound: 0.85,
  outbound: 0.60,
  size: 120,
  theme: const DeviceRingTheme(
    strokeWidth: 8.0,
    showDirectionLabels: true,
  ),
  showGlow: true,
  child: Icon(Icons.dns, size: 48),
)
```

### Show info overlay

```dart
DeviceRing(
  inbound: 0.72,
  outbound: 0.45,
  showInfo: true, // shows percentage + tier badges
)
```

## Utilization tiers

| Tier | Range | Label |
|------|-------|-------|
| Low | 0% – 49% | LOW |
| Medium | 50% – 79% | MED |
| High | 80% – 94% | HIGH |
| Critical | 95% – 100% | CRIT |

## Additional information

- [Example app](example/) — interactive demo with sliders and tier gallery
- [API reference](https://pub.dev/documentation/flutter_device_ring/latest/)
- [File issues](https://github.com/lianghualin/flutter_device_ring/issues)
