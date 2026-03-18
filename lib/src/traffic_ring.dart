import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'traffic_ring_theme.dart';

/// A traffic utilization ring gauge widget.
///
/// Wraps a [child] widget with a circular arc that fills proportionally
/// to [utilization] (0.0–1.0). Supports animated transitions, tier-based
/// coloring, gradient arcs, glow effects, and an optional info overlay.
///
/// ```dart
/// TrafficRing(
///   utilization: 0.73,
///   size: 80,
///   child: Icon(Icons.router, size: 40),
/// )
/// ```
class TrafficRing extends StatefulWidget {
  /// Utilization value from 0.0 to 1.0.
  final double utilization;

  /// Outer diameter of the ring widget.
  final double size;

  /// The content displayed inside the ring (e.g., device icon).
  final Widget? child;

  /// Theme controlling colors, stroke width, gradients.
  final TrafficRingTheme theme;

  /// Duration for the arc fill animation.
  final Duration animationDuration;

  /// Whether to show the info overlay (percentage + tier label)
  /// in place of the child.
  final bool showInfo;

  /// Whether to show a glow effect around the ring.
  final bool showGlow;

  /// Optional label displayed below the ring.
  final String? label;

  /// Style for the label text.
  final TextStyle? labelStyle;

  const TrafficRing({
    super.key,
    required this.utilization,
    this.size = 80,
    this.child,
    this.theme = const TrafficRingTheme(),
    this.animationDuration = const Duration(milliseconds: 600),
    this.showInfo = false,
    this.showGlow = false,
    this.label,
    this.labelStyle,
  });

  @override
  State<TrafficRing> createState() => _TrafficRingState();
}

class _TrafficRingState extends State<TrafficRing>
    with TickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _arcAnimation = Tween<double>(begin: 0, end: widget.utilization).animate(
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
  void didUpdateWidget(TrafficRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.utilization != widget.utilization) {
      _arcAnimation = Tween<double>(
        begin: _arcAnimation.value,
        end: widget.utilization,
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
    final tier = UtilizationTier.fromValue(widget.utilization);
    final tierColor = widget.theme.colorForTier(tier);
    final totalSize = widget.label != null ? widget.size + 20 : widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_arcController, _glowController]),
      builder: (context, _) {
        // Glow shadow
        final List<BoxShadow> shadows = [];
        if (widget.showGlow) {
          final glowAlpha = 0.15 + 0.35 * _glowController.value;
          final glowSpread = 3.0 + 6.0 * _glowController.value;
          shadows.add(BoxShadow(
            color: tierColor.withValues(alpha: glowAlpha),
            blurRadius: glowSpread * 2,
            spreadRadius: glowSpread * 0.5,
          ));
        }

        return SizedBox(
          width: widget.size,
          height: totalSize,
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
                child: CustomPaint(
                  painter: _TrafficRingPainter(
                    utilization: _arcAnimation.value,
                    theme: widget.theme,
                    tier: tier,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: widget.showInfo
                          ? _InfoOverlay(
                              key: const ValueKey('info'),
                              utilization: widget.utilization,
                              tier: tier,
                              color: tierColor,
                              size: widget.size,
                            )
                          : SizedBox(
                              key: const ValueKey('child'),
                              child: widget.child,
                            ),
                    ),
                  ),
                ),
              ),
              if (widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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

/// The info overlay showing percentage and tier label.
class _InfoOverlay extends StatelessWidget {
  final double utilization;
  final UtilizationTier tier;
  final Color color;
  final double size;

  const _InfoOverlay({
    super.key,
    required this.utilization,
    required this.tier,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(utilization * 100).round()}%',
          style: TextStyle(
            color: color,
            fontSize: size * 0.28,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tier.label,
            style: TextStyle(
              color: color,
              fontSize: size * 0.13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the traffic ring arc.
class _TrafficRingPainter extends CustomPainter {
  final double utilization;
  final TrafficRingTheme theme;
  final UtilizationTier tier;

  _TrafficRingPainter({
    required this.utilization,
    required this.theme,
    required this.tier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - theme.strokeWidth) / 2 - 2;

    // Background track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth
      ..color = theme.trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (utilization <= 0) return;

    final sweepAngle = 2 * math.pi * utilization.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (theme.useGradient && utilization > 0.01) {
      // Gradient arc: from start color to tier color
      final tierColor = theme.colorForTier(tier);
      final startColor = _gradientStartColor(tier);

      final gradientPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweepAngle,
          colors: [startColor, tierColor],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect);

      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, gradientPaint);

      // Bright tip dot at the arc end
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      final tipPaint = Paint()
        ..color = tierColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(tipX, tipY),
        theme.strokeWidth / 2 + 1,
        tipPaint,
      );

      // Inner glow along the arc
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..color = tierColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
    } else {
      // Flat arc
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = theme.colorForTier(tier);
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
    }
  }

  Color _gradientStartColor(UtilizationTier tier) {
    switch (tier) {
      case UtilizationTier.low:
        return const Color(0xFF81C784); // lighter green
      case UtilizationTier.medium:
        return const Color(0xFFFFCC80); // lighter orange
      case UtilizationTier.high:
        return const Color(0xFFFF8A65); // lighter red-orange
      case UtilizationTier.critical:
        return const Color(0xFFEF9A9A); // lighter red
    }
  }

  @override
  bool shouldRepaint(_TrafficRingPainter oldDelegate) {
    return oldDelegate.utilization != utilization ||
        oldDelegate.tier != tier;
  }
}
