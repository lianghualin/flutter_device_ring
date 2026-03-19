# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter package providing `DeviceRing`, a dual-traffic utilization ring gauge widget for network devices. It renders inbound (left half, counterclockwise) and outbound (right half, clockwise) network utilization as animated arcs with tier-based coloring.

## Commands

```bash
flutter pub get                    # Install dependencies
flutter test                       # Run all tests
flutter test test/<file>.dart      # Run a single test file
flutter analyze                    # Lint/static analysis
dart format .                      # Format code
dart fix --apply                   # Auto-fix lint issues
flutter pub publish --dry-run      # Validate package before publish
```

Example app:
```bash
cd example && flutter pub get && flutter run
```

## Architecture

The package exports two public classes from `lib/flutter_device_ring.dart`:

- **`DeviceRing`** (`lib/src/device_ring.dart`) — `StatefulWidget` that manages two `AnimationController`s: one for arc fill animations (inbound/outbound tweens with `easeOutCubic`), one for the optional pulsing glow. Painting is delegated to `_HalfAndHalfPainter` (a `CustomPainter`) which draws the background track, two directional arcs, tip dots, and optional "IN"/"OUT" direction labels. When `showInfo` is true, an `AnimatedSwitcher` swaps the child for `_DualInfoOverlay` showing percentage + tier badges.

- **`DeviceRingTheme`** (`lib/src/device_ring_theme.dart`) — Immutable config holding per-tier colors for both inbound and outbound, stroke width, track color, and direction label settings. `UtilizationTier` enum classifies values into `low`/`medium`/`high`/`critical` at thresholds 0.50, 0.80, 0.95.

Key design: the ring is split at 12 o'clock — inbound sweeps left (negative radians), outbound sweeps right (positive radians), each up to 180°. Colors converge to red/critical at high utilization regardless of direction.
