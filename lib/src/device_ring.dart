import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'device_ring_theme.dart';

/// A dual-traffic utilization ring gauge widget (half-and-half).
///
/// Left half = inbound, right half = outbound. Each arc sweeps downward
/// from 12 o'clock on its side (180° max). Supports animated transitions,
/// tier-based coloring, glow effects, and an info overlay.
///
/// ```dart
/// DeviceRing(
///   inbound: 0.73,
///   outbound: 0.45,
///   size: 100,
///   child: Icon(Icons.router, size: 40),
///   label: 'Switch-A',
/// )
/// ```
class DeviceRing extends StatefulWidget {
  /// Inbound utilization value from 0.0 to 1.0.
  final double inbound;

  /// Outbound utilization value from 0.0 to 1.0.
  final double outbound;

  /// Outer diameter of the ring widget.
  final double size;

  /// The content displayed inside the ring (e.g., device icon).
  final Widget? child;

  /// Theme controlling colors, stroke width, labels.
  final DeviceRingTheme theme;

  /// Duration for the arc fill animation.
  final Duration animationDuration;

  /// Whether to show the info overlay (percentage + tier label)
  /// in place of the child.
  final bool showInfo;

  /// Whether to show a glow effect around the ring.
  final bool showGlow;

  /// Glow intensity multiplier from 0.0 (subtle) to 1.0 (prominent).
  /// Only applies when [showGlow] is true.
  final double glowIntensity;

  /// Optional label displayed below the ring.
  final String? label;

  /// Style for the label text.
  final TextStyle? labelStyle;

  const DeviceRing({
    super.key,
    required this.inbound,
    required this.outbound,
    this.size = 100,
    this.child,
    this.theme = const DeviceRingTheme(),
    this.animationDuration = const Duration(milliseconds: 600),
    this.showInfo = false,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.label,
    this.labelStyle,
  });

  @override
  State<DeviceRing> createState() => _DeviceRingState();
}

class _DeviceRingState extends State<DeviceRing>
    with TickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _inAnimation;
  late Animation<double> _outAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _inAnimation = Tween<double>(begin: 0, end: widget.inbound).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
    );
    _outAnimation = Tween<double>(begin: 0, end: widget.outbound).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
    );
    _arcController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateGlow();
  }

  @override
  void didUpdateWidget(DeviceRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.inbound != widget.inbound ||
        oldWidget.outbound != widget.outbound) {
      _inAnimation = Tween<double>(
        begin: _inAnimation.value,
        end: widget.inbound,
      ).animate(
        CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
      );
      _outAnimation = Tween<double>(
        begin: _outAnimation.value,
        end: widget.outbound,
      ).animate(
        CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
      );
      _arcController
        ..reset()
        ..forward();
    }

    _updateGlow();
  }

  void _updateGlow() {
    if (widget.showGlow && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.showGlow && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _arcController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inTier = UtilizationTier.fromValue(widget.inbound);
    final outTier = UtilizationTier.fromValue(widget.outbound);
    final totalHeight = widget.label != null ? widget.size + 20 : widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_arcController, _glowController]),
      builder: (context, _) {
        // Glow shadow — use the higher-tier color
        final List<BoxShadow> shadows = [];
        if (widget.showGlow) {
          final glowTier = widget.inbound >= widget.outbound ? inTier : outTier;
          final glowColor = widget.inbound >= widget.outbound
              ? widget.theme.inboundColorForTier(glowTier)
              : widget.theme.outboundColorForTier(glowTier);
          final intensity = widget.glowIntensity.clamp(0.0, 1.0);
          final glowAlpha =
              (0.12 + 0.28 * _glowController.value) * (0.4 + intensity * 1.2);
          final glowSpread =
              (3.0 + 5.0 * _glowController.value) * (0.5 + intensity);
          shadows.add(BoxShadow(
            color: glowColor.withValues(alpha: glowAlpha),
            blurRadius: glowSpread * 2,
            spreadRadius: glowSpread * 0.4,
          ));
        }

        return SizedBox(
          width: widget.size + 20, // extra width for direction labels
          height: totalHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: shadows.isNotEmpty ? shadows : null,
                ),
                child: Builder(builder: (context) {
                  // Constrain the child to fit inside the ring arcs.
                  // The ring is inset by strokeWidth on each side plus a
                  // gap for the arc glow, so the child must be smaller.
                  final childMaxSize =
                      widget.size - (widget.theme.strokeWidth * 2) - 8;

                  return CustomPaint(
                    painter: _HalfAndHalfPainter(
                      inbound: _inAnimation.value,
                      outbound: _outAnimation.value,
                      theme: widget.theme,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: widget.showInfo
                            ? SizedBox(
                                key: const ValueKey('info'),
                                width: childMaxSize,
                                height: childMaxSize,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _DualInfoOverlay(
                                    inbound: widget.inbound,
                                    outbound: widget.outbound,
                                    theme: widget.theme,
                                    size: widget.size,
                                  ),
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('child'),
                                width: childMaxSize,
                                height: childMaxSize,
                                child: widget.child != null
                                    ? FittedBox(
                                        fit: BoxFit.contain,
                                        child: widget.child,
                                      )
                                    : null,
                              ),
                      ),
                    ),
                  );
                }),
              ),
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Info overlay: dual inbound/outbound with arrows and tier badges
// ---------------------------------------------------------------------------

class _DualInfoOverlay extends StatelessWidget {
  final double inbound;
  final double outbound;
  final DeviceRingTheme theme;
  final double size;

  const _DualInfoOverlay({
    required this.inbound,
    required this.outbound,
    required this.theme,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final inTier = UtilizationTier.fromValue(inbound);
    final outTier = UtilizationTier.fromValue(outbound);
    final inColor = theme.inboundColorForTier(inTier);
    final outColor = theme.outboundColorForTier(outTier);
    final fontSize = size * 0.14;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _infoRow(
          icon: Icons.arrow_downward,
          value: inbound,
          tier: inTier,
          color: inColor,
          fontSize: fontSize,
        ),
        const SizedBox(height: 2),
        _infoRow(
          icon: Icons.arrow_upward,
          value: outbound,
          tier: outTier,
          color: outColor,
          fontSize: fontSize,
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required double value,
    required UtilizationTier tier,
    required Color color,
    required double fontSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize, color: color),
        const SizedBox(width: 2),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            tier.label,
            style: TextStyle(
              color: color,
              fontSize: fontSize * 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Half-and-half painter
// ---------------------------------------------------------------------------

class _HalfAndHalfPainter extends CustomPainter {
  final double inbound;
  final double outbound;
  final DeviceRingTheme theme;

  _HalfAndHalfPainter({
    required this.inbound,
    required this.outbound,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = theme.strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = theme.trackColor,
    );

    // Left half — Inbound (counterclockwise from top, max 180°)
    if (inbound > 0) {
      final sweep = -math.pi * inbound.clamp(0.0, 1.0);
      final inTier = UtilizationTier.fromValue(inbound);
      final color = theme.inboundColorForTier(inTier);

      // Glow
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Arc
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );

      // Tip dot
      final tipAngle = -math.pi / 2 + sweep;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(tipAngle),
          center.dy + radius * math.sin(tipAngle),
        ),
        strokeWidth / 2 + 1,
        Paint()..color = color,
      );
    }

    // Right half — Outbound (clockwise from top, max 180°)
    if (outbound > 0) {
      final sweep = math.pi * outbound.clamp(0.0, 1.0);
      final outTier = UtilizationTier.fromValue(outbound);
      final color = theme.outboundColorForTier(outTier);

      // Glow
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Arc
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );

      // Tip dot
      final tipAngle = -math.pi / 2 + sweep;
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(tipAngle),
          center.dy + radius * math.sin(tipAngle),
        ),
        strokeWidth / 2 + 1,
        Paint()..color = color,
      );
    }

    // Divider tick at top (12 o'clock)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 4),
      Offset(center.dx, center.dy - radius + 4),
      Paint()
        ..color = theme.trackColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Direction labels
    if (theme.showDirectionLabels) {
      final labelStyle = TextStyle(
        fontSize: theme.directionLabelFontSize,
        color: theme.directionLabelColor,
        fontWeight: FontWeight.w600,
      );

      final inTp = TextPainter(
        text: TextSpan(text: 'IN', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      inTp.paint(
        canvas,
        Offset(
          center.dx - radius - inTp.width - 2,
          center.dy - inTp.height / 2,
        ),
      );

      final outTp = TextPainter(
        text: TextSpan(text: 'OUT', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      outTp.paint(
        canvas,
        Offset(
          center.dx + radius + 3,
          center.dy - outTp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_HalfAndHalfPainter old) =>
      old.inbound != inbound || old.outbound != outbound;
}
