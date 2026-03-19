import 'package:flutter/material.dart';
import 'package:flutter_device_ring/flutter_device_ring.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Ring',
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
  double _inbound = 0.72;
  double _outbound = 0.45;
  bool _showInfo = false;
  bool _showGlow = false;
  bool _showLabels = true;
  double _ringSize = 100;
  double _strokeWidth = 6.0;
  double _glowIntensity = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = DeviceRingTheme(
      strokeWidth: _strokeWidth,
      showDirectionLabels: _showLabels,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Device Ring')),
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
                    DeviceRing(
                      inbound: _inbound,
                      outbound: _outbound,
                      size: _ringSize,
                      theme: theme,
                      showInfo: _showInfo,
                      showGlow: _showGlow,
                      glowIntensity: _glowIntensity,
                      label: 'Switch-A',
                      child: Icon(
                        Icons.router,
                        size: _ringSize * 0.4,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sliders
                    _SliderRow(
                      label: 'Inbound',
                      value: _inbound,
                      onChanged: (v) => setState(() => _inbound = v),
                    ),
                    _SliderRow(
                      label: 'Outbound',
                      value: _outbound,
                      onChanged: (v) => setState(() => _outbound = v),
                    ),
                    _SliderRow(
                      label: 'Size',
                      value: _ringSize,
                      min: 60,
                      max: 160,
                      divisions: 10,
                      displayValue: '${_ringSize.round()}px',
                      onChanged: (v) => setState(() => _ringSize = v),
                    ),
                    _SliderRow(
                      label: 'Stroke',
                      value: _strokeWidth,
                      min: 3,
                      max: 10,
                      divisions: 7,
                      displayValue: '${_strokeWidth.round()}px',
                      onChanged: (v) => setState(() => _strokeWidth = v),
                    ),
                    _SliderRow(
                      label: 'Glow',
                      value: _glowIntensity,
                      divisions: 10,
                      displayValue: _glowIntensity.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _glowIntensity = v),
                    ),
                    const SizedBox(height: 8),

                    // Toggles
                    SwitchListTile(
                      title: const Text('Info Overlay'),
                      subtitle: const Text('Swap icon for IN/OUT percentages'),
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
                      title: const Text('Direction Labels'),
                      subtitle: const Text('IN / OUT text on ring sides'),
                      value: _showLabels,
                      onChanged: (v) => setState(() => _showLabels = v),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Tier gallery ---
            Text(
              'Tier Gallery',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              children: [
                _galleryItem('LOW / LOW', 0.30, 0.20, Icons.computer, theme),
                _galleryItem('MED / LOW', 0.65, 0.35, Icons.router, theme),
                _galleryItem('HIGH / MED', 0.85, 0.60, Icons.dns, theme),
                _galleryItem('CRIT / HIGH', 0.98, 0.88, Icons.warning, theme),
              ],
            ),
            const SizedBox(height: 32),

            // --- Info overlay gallery ---
            Text(
              'Info Overlay (Spotlit)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              children: [
                _galleryItem('LOW / LOW', 0.30, 0.20, Icons.computer, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('MED / LOW', 0.65, 0.35, Icons.router, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('HIGH / MED', 0.85, 0.60, Icons.dns, theme,
                    showInfo: true, showGlow: true),
                _galleryItem('CRIT / HIGH', 0.98, 0.88, Icons.warning, theme,
                    showInfo: true, showGlow: true),
              ],
            ),
            const SizedBox(height: 32),

            // --- Size comparison ---
            Text(
              'Size Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                DeviceRing(
                  inbound: 0.72,
                  outbound: 0.45,
                  size: 60,
                  theme: theme,
                  label: '60px',
                  child: const Icon(Icons.router, size: 24, color: Colors.blueGrey),
                ),
                DeviceRing(
                  inbound: 0.72,
                  outbound: 0.45,
                  size: 100,
                  theme: theme,
                  label: '100px',
                  child: const Icon(Icons.router, size: 40, color: Colors.blueGrey),
                ),
                DeviceRing(
                  inbound: 0.72,
                  outbound: 0.45,
                  size: 140,
                  theme: theme,
                  label: '140px',
                  child: const Icon(Icons.router, size: 56, color: Colors.blueGrey),
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
    String name,
    double inbound,
    double outbound,
    IconData icon,
    DeviceRingTheme theme, {
    bool showInfo = false,
    bool showGlow = false,
  }) {
    return DeviceRing(
      inbound: inbound,
      outbound: outbound,
      size: 100,
      theme: theme,
      showInfo: showInfo,
      showGlow: showGlow,
      label: name,
      child: Icon(icon, size: 40, color: Colors.blueGrey),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String? displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions = 100,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
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
          child: Text(
            displayValue ?? '${(value * 100).round()}%',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
