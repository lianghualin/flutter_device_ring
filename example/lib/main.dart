import 'package:flutter/material.dart';
import 'package:traffic_ring_widget/traffic_ring_widget.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Ring Widget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  double _utilization = 0.65;
  bool _showInfo = false;
  bool _showGlow = false;
  bool _useGradient = true;
  double _ringSize = 80;
  double _strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    final theme = TrafficRingTheme(
      strokeWidth: _strokeWidth,
      useGradient: _useGradient,
    );
    final tier = UtilizationTier.fromValue(_utilization);

    return Scaffold(
      appBar: AppBar(title: const Text('Traffic Ring Widget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Interactive demo ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Interactive Demo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    TrafficRing(
                      utilization: _utilization,
                      size: _ringSize,
                      theme: theme,
                      showInfo: _showInfo,
                      showGlow: _showGlow,
                      label: 'eth0',
                      child: Icon(
                        Icons.router,
                        size: _ringSize * 0.45,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_utilization * 100).round()}% — ${tier.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: theme.colorForTier(tier),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Utilization slider
                    _SliderRow(
                      label: 'Utilization',
                      value: _utilization,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      displayValue: '${(_utilization * 100).round()}%',
                      onChanged: (v) => setState(() => _utilization = v),
                    ),

                    // Size slider
                    _SliderRow(
                      label: 'Ring Size',
                      value: _ringSize,
                      min: 40,
                      max: 160,
                      divisions: 12,
                      displayValue: '${_ringSize.round()}px',
                      onChanged: (v) => setState(() => _ringSize = v),
                    ),

                    // Stroke width slider
                    _SliderRow(
                      label: 'Stroke Width',
                      value: _strokeWidth,
                      min: 2,
                      max: 10,
                      divisions: 8,
                      displayValue: '${_strokeWidth.toStringAsFixed(0)}px',
                      onChanged: (v) => setState(() => _strokeWidth = v),
                    ),

                    // Toggles
                    SwitchListTile(
                      title: const Text('Show Info Overlay'),
                      subtitle: const Text('Swap icon for percentage + tier'),
                      value: _showInfo,
                      onChanged: (v) => setState(() => _showInfo = v),
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Glow Effect'),
                      subtitle: const Text('Pulsing glow around ring'),
                      value: _showGlow,
                      onChanged: (v) => setState(() => _showGlow = v),
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Gradient Arc'),
                      subtitle: const Text('Gradient vs flat color'),
                      value: _useGradient,
                      onChanged: (v) => setState(() => _useGradient = v),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Tier gallery ---
            Text(
              'Tier Gallery',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _galleryItem('LOW', 0.30, Icons.computer, theme),
                _galleryItem('MED', 0.65, Icons.router, theme),
                _galleryItem('HIGH', 0.85, Icons.dns, theme),
                _galleryItem('CRIT', 0.98, Icons.warning, theme),
              ],
            ),
            const SizedBox(height: 24),

            // --- Info overlay gallery ---
            Text(
              'Info Overlay (Spotlit State)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _galleryItem('LOW', 0.30, Icons.computer, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('MED', 0.65, Icons.router, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('HIGH', 0.85, Icons.dns, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('CRIT', 0.98, Icons.warning, theme,
                    showInfo: true, showGlow: true),
              ],
            ),
            const SizedBox(height: 24),

            // --- Size comparison ---
            Text(
              'Size Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                TrafficRing(
                  utilization: 0.72,
                  size: 50,
                  theme: theme,
                  label: '50px',
                  child: const Icon(Icons.router, size: 22, color: Colors.blueGrey),
                ),
                TrafficRing(
                  utilization: 0.72,
                  size: 80,
                  theme: theme,
                  label: '80px',
                  child: const Icon(Icons.router, size: 36, color: Colors.blueGrey),
                ),
                TrafficRing(
                  utilization: 0.72,
                  size: 120,
                  theme: theme,
                  label: '120px',
                  child: const Icon(Icons.router, size: 54, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _galleryItem(
    String label,
    double util,
    IconData icon,
    TrafficRingTheme theme, {
    bool showInfo = false,
    bool showGlow = false,
  }) {
    return TrafficRing(
      utilization: util,
      size: 80,
      theme: theme,
      showInfo: showInfo,
      showGlow: showGlow,
      label: label,
      child: Icon(icon, size: 36, color: Colors.blueGrey),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(displayValue, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
