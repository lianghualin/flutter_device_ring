import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_device_ring/flutter_device_ring.dart';

void main() {
  group('UtilizationTier', () {
    test('classifies LOW correctly', () {
      expect(UtilizationTier.fromValue(0.0), UtilizationTier.low);
      expect(UtilizationTier.fromValue(0.3), UtilizationTier.low);
      expect(UtilizationTier.fromValue(0.49), UtilizationTier.low);
    });

    test('classifies MED correctly', () {
      expect(UtilizationTier.fromValue(0.5), UtilizationTier.medium);
      expect(UtilizationTier.fromValue(0.65), UtilizationTier.medium);
      expect(UtilizationTier.fromValue(0.79), UtilizationTier.medium);
    });

    test('classifies HIGH correctly', () {
      expect(UtilizationTier.fromValue(0.8), UtilizationTier.high);
      expect(UtilizationTier.fromValue(0.9), UtilizationTier.high);
      expect(UtilizationTier.fromValue(0.94), UtilizationTier.high);
    });

    test('classifies CRIT correctly', () {
      expect(UtilizationTier.fromValue(0.95), UtilizationTier.critical);
      expect(UtilizationTier.fromValue(1.0), UtilizationTier.critical);
    });

    test('tier labels are correct', () {
      expect(UtilizationTier.low.label, 'LOW');
      expect(UtilizationTier.medium.label, 'MED');
      expect(UtilizationTier.high.label, 'HIGH');
      expect(UtilizationTier.critical.label, 'CRIT');
    });
  });

  group('DeviceRingTheme', () {
    test('default theme has distinct inbound/outbound colors', () {
      const theme = DeviceRingTheme();
      expect(
        theme.inboundColorForTier(UtilizationTier.low),
        isNot(equals(theme.outboundColorForTier(UtilizationTier.low))),
      );
    });

    test('showDirectionLabels defaults to true', () {
      const theme = DeviceRingTheme();
      expect(theme.showDirectionLabels, true);
    });
  });

  group('DeviceRing widget', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceRing(
              inbound: 0.5,
              outbound: 0.3,
              label: 'Switch-A',
            ),
          ),
        ),
      );
      expect(find.text('Switch-A'), findsOneWidget);
    });

    testWidgets('constrains child within ring arcs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceRing(
              inbound: 0.5,
              outbound: 0.3,
              size: 100,
              child: SizedBox(width: 200, height: 200), // oversized child
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The child should be wrapped in a FittedBox inside a constrained SizedBox.
      // With size=100 and default strokeWidth=6: childMax = 100 - 12 - 8 = 80
      final fittedBox = find.byType(FittedBox);
      expect(fittedBox, findsOneWidget);

      // The constraining SizedBox should limit the area
      final constrainingSizedBox = find.ancestor(
        of: fittedBox,
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 80 && w.height == 80,
        ),
      );
      expect(constrainingSizedBox, findsOneWidget);
    });

    testWidgets('accepts glowIntensity parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceRing(
              inbound: 0.5,
              outbound: 0.3,
              showGlow: true,
              glowIntensity: 1.0,
            ),
          ),
        ),
      );
      // Should build without error
      expect(find.byType(DeviceRing), findsOneWidget);
    });

    testWidgets('glowIntensity defaults to 0.5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceRing(
              inbound: 0.5,
              outbound: 0.3,
            ),
          ),
        ),
      );
      final widget = tester.widget<DeviceRing>(find.byType(DeviceRing));
      expect(widget.glowIntensity, 0.5);
    });

    testWidgets('shows info overlay when showInfo is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeviceRing(
              inbound: 0.72,
              outbound: 0.45,
              showInfo: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
    });
  });
}
