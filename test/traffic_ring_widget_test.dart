import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_ring_widget/traffic_ring_widget.dart';

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
  });
}
