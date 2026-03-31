import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class LearningCenter extends StatelessWidget {
  const LearningCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'VERD Fundamentals', 'count': 6, 'icon': LucideIcons.sprout, 'progress': 1.0},
      {'title': 'Drone Pathology', 'count': 4, 'icon': LucideIcons.plane, 'progress': 0.3},
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
              _buildHeader(isMobile),
              const SizedBox(height: 60),
              if (isMobile) ...[
                _buildFeaturedModule(isMobile),
                const SizedBox(height: 32),
                ...modules.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _ModuleCard(
                    title: m['title'] as String,
                    count: m['count'] as int,
                    icon: m['icon'] as IconData,
                    progress: m['progress'] as double,
                    idx: modules.indexOf(m),
                  ),
                )),
                const SizedBox(height: 32),
                _buildSidebar(),
                const SizedBox(height: 24),
                _buildDailyTip(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildFeaturedModule(isMobile),
                          const SizedBox(height: 32),
                          Row(
                            children: modules.map((m) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: m == modules.last ? 0 : 24),
                                child: _ModuleCard(
                                  title: m['title'] as String,
                                  count: m['count'] as int,
                                  icon: m['icon'] as IconData,
                                  progress: m['progress'] as double,
                                  idx: modules.indexOf(m),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          _buildSidebar(),
                          const SizedBox(height: 24),
                          _buildDailyTip(),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Learning '),
              TextSpan(text: 'CENTER', style: TextStyle(color: VerdTheme.primary, fontWeight: FontWeight.black, fontStyle: FontStyle.normal)),
            ],
          ),
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text('Expand your expertise in AI-driven agronomy and drone tech.', style: TextStyle(color: VerdTheme.textDim, fontSize: 14)),
      ],
    );

    final pointsCard = GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.award, color: VerdTheme.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('YOUR POINTS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
              const Text('1,240 XP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          const SizedBox(height: 24),
          pointsCard,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        titleSection,
        pointsCard,
      ],
    );
  }

  Widget _buildFeaturedModule(bool isMobile) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      border: const Border.fromBorderSide(BorderSide(color: Color(0x3300D6B1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: VerdTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
            child: const Text('FEATURED MODULE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
          ),
          const SizedBox(height: 32),
          Text('Precision Spraying with Drones', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'Learn how to calibrate your VERD-enabled drones for precision application of organic pesticides.',
            style: TextStyle(color: VerdTheme.textDim, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _MetaLabel(icon: LucideIcons.playCircle, label: '15 MIN VIDEO'),
              const SizedBox(width: 24),
              _MetaLabel(icon: LucideIcons.award, label: 'ADVANCED'),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: isMobile ? double.infinity : 200,
            child: const _PrimaryButton(label: 'START LEARNING'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.compass, size: 14, color: VerdTheme.primary),
              const SizedBox(width: 12),
              Text('CURATED PATHS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 32),
          _PathItem(title: 'Digital Soil Profiling', desc: 'Master the art of reading soil health from spectral imagery.'),
          const SizedBox(height: 24),
          _PathItem(title: 'Pest Management 2.0', desc: 'Integrated pest control in the AI era.'),
          const SizedBox(height: 24),
          _PathItem(title: 'Economic Agronomy', desc: 'Maximizing ROI through precision technology.'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('BROWSE ALL PATHS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DAILY TIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
          const SizedBox(height: 16),
          const Text(
            '"Did you know? Morning scans often yield 15% higher spectral accuracy due to lower atmospheric turbulence."',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xCCFFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final double progress;
  final int idx;

  const _ModuleCard({required this.title, required this.count, required this.icon, required this.progress, required this.idx});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: VerdTheme.glassDecoration(opacity: 0.1),
                child: Icon(icon, color: VerdTheme.primary, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$count LESSONS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
                  Text('MODULE ${idx + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: VerdTheme.primary,
            minHeight: 4,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text('${(progress * 100).round()}% COMPLETE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
              const Row(
                children: [
                  Text('CONTINUE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
                  SizedBox(width: 4),
                  Icon(LucideIcons.chevronRight, size: 10, color: VerdTheme.primary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: VerdTheme.primary),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.textDim, letterSpacing: 2)),
      ],
    );
  }
}

class _PathItem extends StatelessWidget {
  final String title;
  final String desc;

  const _PathItem({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(fontSize: 10, color: VerdTheme.textDim)),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  const _PrimaryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: VerdTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: VerdTheme.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}
