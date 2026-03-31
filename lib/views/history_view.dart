import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class ScanHistory extends StatelessWidget {
  const ScanHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = [
      {'id': '1', 'crop': 'Maize', 'disease': 'Healthy', 'date': 'Oct 12, 2026', 'confidence': '98%', 'status': 'success'},
      {'id': '2', 'crop': 'Wheat', 'disease': 'Leaf Rust', 'date': 'Oct 10, 2026', 'confidence': '92%', 'status': 'alert'},
      {'id': '3', 'crop': 'Soybean', 'disease': 'Blight', 'date': 'Oct 05, 2026', 'confidence': '89%', 'status': 'alert'},
      {'id': '4', 'crop': 'Rice', 'disease': 'Healthy', 'date': 'Sep 28, 2026', 'confidence': '99%', 'status': 'success'},
      {'id': '5', 'crop': 'Maize', 'disease': 'Stem Borer', 'date': 'Sep 20, 2026', 'confidence': '94%', 'status': 'alert'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        final horizontalPadding = isMobile ? 20.0 : 40.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              const SizedBox(height: 48),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scans.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final scan = scans[index];
                  return _buildHistoryItem(scan, isMobile, index);
                },
              ),
              const SizedBox(height: 48),
              Center(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('LOAD MORE HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Scan '),
              TextSpan(text: 'HISTORY', style: TextStyle(color: VerdTheme.primary, fontWeight: FontWeight.black, fontStyle: FontStyle.normal)),
            ],
          ),
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text('Review your past field diagnostics and health trends.', style: TextStyle(color: VerdTheme.textDim, fontSize: 14)),
      ],
    );

    final searchSection = Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: VerdTheme.glassDecoration(opacity: 0.05),
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(LucideIcons.search, size: 14, color: Colors.white.withOpacity(0.2)),
                hintText: 'Search crops...',
                hintStyle: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.2)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _IconButton(icon: LucideIcons.filter),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 32),
          searchSection,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        titleSection,
        SizedBox(width: 300, child: searchSection),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, String> scan, bool isMobile, int index) {
    if (isMobile) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: VerdTheme.glassDecoration(opacity: 0.1),
                  child: const Icon(LucideIcons.history, color: VerdTheme.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan['crop']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(scan['date']!, style: TextStyle(fontSize: 10, color: VerdTheme.textDim)),
                    ],
                  ),
                ),
                _ActionBtn(label: 'REPORT'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ScanInfoCol(label: 'DIAGNOSIS', value: scan['disease']!, isAlert: scan['status'] == 'alert'),
                _ScanInfoCol(label: 'CONFIDENCE', value: scan['confidence']!, isMono: true),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).moveX(begin: -20, end: 0);
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: VerdTheme.glassDecoration(opacity: 0.1),
            child: const Icon(LucideIcons.history, color: VerdTheme.primary, size: 24),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              children: [
                _ScanInfoCol(label: 'CROP', value: scan['crop']!),
                _ScanInfoCol(label: 'DIAGNOSIS', value: scan['disease']!, isAlert: scan['status'] == 'alert'),
                _ScanInfoCol(label: 'DATE', value: scan['date']!),
                _ScanInfoCol(label: 'CONFIDENCE', value: scan['confidence']!, isMono: true),
              ],
            ),
          ),
          Row(
            children: [
              _IconButton(icon: LucideIcons.download),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.white.withOpacity(0.05)),
              const SizedBox(width: 12),
              _ActionBtn(label: 'VIEW REPORT'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).moveX(begin: -20, end: 0);
  }
}

class _ScanInfoCol extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;
  final bool isMono;

  const _ScanInfoCol({required this.label, required this.value, this.isAlert = false, this.isMono = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.amberAccent : Colors.white,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: VerdTheme.glassDecoration(opacity: 0.05),
      child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  const _ActionBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: VerdTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 1.5)),
          const SizedBox(width: 8),
          const Icon(LucideIcons.arrowUpRight, size: 14, color: VerdTheme.primary),
        ],
      ),
    );
  }
}
