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

/// Theme data for [DeviceRing] appearance.
class DeviceRingTheme {
  /// Inbound color per tier.
  final Color inboundLowColor;
  final Color inboundMediumColor;
  final Color inboundHighColor;
  final Color inboundCriticalColor;

  /// Outbound color per tier.
  final Color outboundLowColor;
  final Color outboundMediumColor;
  final Color outboundHighColor;
  final Color outboundCriticalColor;

  /// Background track color.
  final Color trackColor;

  /// Arc stroke width.
  final double strokeWidth;

  /// Whether to paint IN/OUT labels on the ring sides.
  final bool showDirectionLabels;

  /// Color of the direction labels.
  final Color directionLabelColor;

  /// Font size of the direction labels.
  final double directionLabelFontSize;

  const DeviceRingTheme({
    this.inboundLowColor = const Color(0xFF42A5F5),
    this.inboundMediumColor = const Color(0xFF1976D2),
    this.inboundHighColor = const Color(0xFFE64A19),
    this.inboundCriticalColor = const Color(0xFFD32F2F),
    this.outboundLowColor = const Color(0xFFFFA726),
    this.outboundMediumColor = const Color(0xFFEF6C00),
    this.outboundHighColor = const Color(0xFFE64A19),
    this.outboundCriticalColor = const Color(0xFFD32F2F),
    this.trackColor = const Color(0x26757575),
    this.strokeWidth = 6.0,
    this.showDirectionLabels = true,
    this.directionLabelColor = const Color(0x99757575),
    this.directionLabelFontSize = 8.0,
  });

  /// Get the inbound color for a given tier.
  Color inboundColorForTier(UtilizationTier tier) {
    switch (tier) {
      case UtilizationTier.low:
        return inboundLowColor;
      case UtilizationTier.medium:
        return inboundMediumColor;
      case UtilizationTier.high:
        return inboundHighColor;
      case UtilizationTier.critical:
        return inboundCriticalColor;
    }
  }

  /// Get the outbound color for a given tier.
  Color outboundColorForTier(UtilizationTier tier) {
    switch (tier) {
      case UtilizationTier.low:
        return outboundLowColor;
      case UtilizationTier.medium:
        return outboundMediumColor;
      case UtilizationTier.high:
        return outboundHighColor;
      case UtilizationTier.critical:
        return outboundCriticalColor;
    }
  }
}
