import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class UserDashboard extends StatelessWidget {
  final Function(String) onViewChanged;
  const UserDashboard({super.key, required this.onViewChanged});

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: isMobile ? 32 : 48),
              _buildStatsGrid(isMobile),
              SizedBox(height: isMobile ? 32 : 48),
              _buildMainContent(context, isMobile),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final welcomeText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.shieldCheck, size: 14, color: VerdTheme.primary),
            const SizedBox(width: 8),
            Text('EXCLUSIVE USER SPACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(text: 'Alex', style: TextStyle(color: Colors.white.withOpacity(0.2), fontStyle: FontStyle.normal, fontWeight: FontWeight.black)),
            ],
          ),
          style: TextStyle(fontSize: isMobile ? 40 : 56, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, letterSpacing: -2),
        ),
      ],
    );

    final seasonCard = const GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendar, color: VerdTheme.primary, size: 20),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GROWING SEASON', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x66FFFFFF), letterSpacing: 2)),
              Text('SAVANNAH BELT • Q2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          welcomeText,
          const SizedBox(height: 24),
          seasonCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        welcomeText,
        seasonCard,
      ],
    );
  }

  Widget _buildStatsGrid(bool isMobile) {
    final stats = [
      {'label': 'Field Health', 'value': '94%', 'icon': LucideIcons.activity, 'color': Colors.emeraldAccent},
      {'label': 'Active Alerts', 'value': '2', 'icon': LucideIcons.bell, 'color': Colors.amberAccent},
      {'label': 'Total Scans', 'value': '124', 'icon': LucideIcons.zap, 'color': VerdTheme.primary},
      {'label': 'Soil Hydration', 'value': '78%', 'icon': LucideIcons.droplets, 'color': Colors.blueAccent},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.4 : 1.5,
      children: stats.map((s) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((s['label'] as String).toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(s['value'] as String, style: const TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isMobile) {
    final activityList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            GestureDetector(
              onTap: () => onViewChanged('history'),
              child: const Row(
                children: [
                  Text('VIEW HISTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
                  SizedBox(width: 8),
                  Icon(LucideIcons.chevronRight, size: 12, color: VerdTheme.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ActivityCard(title: 'Maize Scan Complete', time: '2 hours ago', status: 'Healthy', type: 'scan'),
        const SizedBox(height: 12),
        _ActivityCard(title: 'New Disease Alert', time: '5 hours ago', status: 'Action Required', type: 'alert'),
        const SizedBox(height: 12),
        _ActivityCard(title: 'Soil Report Generated', time: 'Yesterday', status: 'Optimized', type: 'report'),
      ],
    );

    final yieldAndSensors = Column(
      children: [
        const GlassCard(
          padding: EdgeInsets.all(32),
          border: Border.fromBorderSide(BorderSide(color: Color(0x3300D6B1))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yield Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'Based on your current field diagnostics, we predict a 12% increase in harvest quality compared to last season.',
                style: TextStyle(fontSize: 12, color: Color(0x99FFFFFF)),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(label: 'OPTIMIZATION PLAN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LIVE SENSORS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x66FFFFFF), letterSpacing: 2)),
              const SizedBox(height: 24),
              _SensorRow(icon: LucideIcons.droplets, label: 'Moisture', value: '42%', color: Colors.blueAccent),
              const SizedBox(height: 20),
              _SensorRow(icon: LucideIcons.thermometerSun, label: 'Temp', value: '28°C', color: Colors.orangeAccent),
            ],
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          activityList,
          const SizedBox(height: 48),
          yieldAndSensors,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: activityList),
        const SizedBox(width: 32),
        Expanded(child: yieldAndSensors),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String type;

  const _ActivityCard({required this.title, required this.time, required this.status, required this.type});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: type == 'alert' ? Colors.amberAccent : Colors.emeraldAccent,
              shape: BoxType.circle,
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.seconds),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(fontSize: 10, color: Color(0x66FFFFFF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x99FFFFFF), letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
