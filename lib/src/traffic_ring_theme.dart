import 'package:flutter/material.dart';

/// Utilization tier classification.
enum UtilizationTier {
  low,
  medium,
  high,
  critical;

  /// Classify a utilization value (0.0–1.0) into a tier.
  static UtilizationTier fromValue(double utilization) {
    if (utilization >= 0.95) return critical;
    if (utilization >= 0.80) return high;
    if (utilization >= 0.50) return medium;
    return low;
  }

  /// Human-readable short label.
  String get label {
    switch (this) {
      case low:
        return 'LOW';
      case medium:
        return 'MED';
      case high:
        return 'HIGH';
      case critical:
        return 'CRIT';
    }
  }
}

/// Theme data for [TrafficRing] appearance.
class TrafficRingTheme {
  /// Color for each utilization tier.
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;
  final Color criticalColor;

  /// Background track color.
  final Color trackColor;

  /// Arc stroke width.
  final double strokeWidth;

  /// Whether to use gradient on the arc.
  final bool useGradient;

  const TrafficRingTheme({
    this.lowColor = const Color(0xFF4CAF50),
    this.mediumColor = const Color(0xFFFF9800),
    this.highColor = const Color(0xFFFF5722),
    this.criticalColor = const Color(0xFFF44336),
    this.trackColor = const Color(0x33757575),
    this.strokeWidth = 5.0,
    this.useGradient = true,
  });

  /// Get the color for a given tier.
  Color colorForTier(UtilizationTier tier) {
    switch (tier) {
      case UtilizationTier.low:
        return lowColor;
      case UtilizationTier.medium:
        return mediumColor;
      case UtilizationTier.high:
        return highColor;
      case UtilizationTier.critical:
        return criticalColor;
    }
  }

  /// Get the glow color (slightly transparent version of tier color).
  Color glowColorForTier(UtilizationTier tier) {
    return colorForTier(tier).withValues(alpha: 0.4);
  }
}
