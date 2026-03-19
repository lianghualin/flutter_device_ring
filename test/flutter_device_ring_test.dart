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
