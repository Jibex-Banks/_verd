import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class GroundTruthInsights extends StatelessWidget {
  const GroundTruthInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final horizontalPadding = isMobile ? 20.0 : 40.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              const SizedBox(height: 60),
              _buildPulseMetric(context, isMobile),
              const SizedBox(height: 48),
              _buildMetricCards(isMobile),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Ground-Truth '),
              TextSpan(text: 'INSIGHTS', style: TextStyle(color: VerdTheme.primary, fontWeight: FontWeight.black, fontStyle: FontStyle.normal)),
            ],
          ),
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text('Real-time biometric data translated into actionable agricultural interventions.', style: TextStyle(color: VerdTheme.textDim, fontSize: 14)),
      ],
    );
  }

  Widget _buildPulseMetric(BuildContext context, bool isMobile) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: VerdTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
          child: const Text('REGIONAL HEALTH PULSE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
        ),
        const SizedBox(height: 24),
        Text('Optimal Harvest Window', style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Based on current soil moisture and spectral indices, the southern region of your maize field will reach peak maturity in approximately 8 days.',
          style: TextStyle(color: VerdTheme.textDim, fontSize: 14),
        ),
        const SizedBox(height: 32),
        const Row(
          children: [
            _MetricChip(label: '8 DAYS REMAINING', color: VerdTheme.primary),
            SizedBox(width: 12),
            _MetricChip(label: 'STABLE GROWTH', color: Colors.blueAccent),
          ],
        ),
      ],
    );

    final progress = _buildCircleProgress('92%', 'CONFIDENCE');

    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: isMobile 
        ? Column(
            children: [
              content,
              const SizedBox(height: 48),
              progress,
            ],
          )
        : Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 80),
              progress,
            ],
          ),
    );
  }

  Widget _buildCircleProgress(String value, String label) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CircularProgressIndicator(
            value: 0.92,
            strokeWidth: 12,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: VerdTheme.primary,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.black)),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCards(bool isMobile) {
    final metrics = [
      {'title': 'EVI Index', 'value': '0.78', 'trend': '+12%', 'desc': 'Enhanced Vegetation Index is trending upward across all quadrants.'},
      {'title': 'Nitrogen Ppb', 'value': '440', 'trend': 'STABLE', 'desc': 'Optimal nitrogen levels detected in the upper soil profile.'},
      {'title': 'Pest Pressure', 'value': 'LOW', 'trend': '-4%', 'desc': 'Spodoptera presence has decreased significantly since the last scan.'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isMobile ? 1.5 : 1.2,
      children: metrics.map((m) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(m['title']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
                Text(m['trend']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white24)),
              ],
            ),
            Text(m['value']!, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, italic: true)),
            Text(m['desc']!, style: TextStyle(fontSize: 10, color: VerdTheme.textDim, fontWeight: FontWeight.w300)),
          ],
        ),
      )).toList(),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetricChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
    );
  }
}
