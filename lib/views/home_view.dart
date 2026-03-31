import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final horizontalPadding = isMobile ? 20.0 : 40.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHero(context, isMobile),
              SizedBox(height: isMobile ? 60 : 120),
              
              // Tech Hub
              _buildTechHub(context, isMobile),
              SizedBox(height: isMobile ? 60 : 120),
              
              // Onboarding Section
              _buildOnboarding(context, isMobile),
              const SizedBox(height: 120),
              
              // Footer
              _buildFooter(context),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile) {
    final heroContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: VerdTheme.primary.withOpacity(0.1),
            border: Border.all(color: VerdTheme.primary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.arrowRight, size: 14, color: VerdTheme.primary),
              const SizedBox(width: 10),
              Text('SEE HOW IT WORKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),
        
        const SizedBox(height: 40),
        
        // Headline
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'GROWING\n', style: isMobile ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.displayLarge),
              TextSpan(text: 'SMARTER', style: (isMobile ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.displayLarge)!.copyWith(fontStyle: FontStyle.normal, color: Colors.white.withOpacity(0.2))),
              TextSpan(text: ' TOGETHER', style: (isMobile ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.displayLarge)!.copyWith(color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).moveY(begin: 30, end: 0),
        
        const SizedBox(height: 40),
        
        Text(
          "Think of VERD as your digital field-hand. We're here to help you spot crop issues early, so you can focus on what you do best: farming.",
          style: TextStyle(fontSize: isMobile ? 16 : 20, color: VerdTheme.textDim, fontWeight: FontWeight.w300),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );

    final asideContent = const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: VerdTheme.primary),
              SizedBox(width: 12),
              Text('YOUR SOIL, YOUR DATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "We believe in agrarian sovereignty. That means your data serves your harvest, first and foremost. We provide the ground-truth insights to help you grow with confidence and security.",
            style: TextStyle(fontSize: 14, color: Color(0x99FFFFFF)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).moveX(begin: 20, end: 0);

    if (isMobile) {
      return Column(
        children: [
          heroContent,
          const SizedBox(height: 40),
          asideContent,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 3, child: heroContent),
        const SizedBox(width: 60),
        Expanded(flex: 2, child: asideContent),
      ],
    );
  }

  Widget _buildTechHub(BuildContext context, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 1 : 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: isMobile ? 1.2 : 0.8,
      children: [
        _TechCard(
          icon: LucideIcons.plane,
          title: 'VERD Aerial',
          description: 'Autonomous field monitoring with high-precision drone integration. Track crop health across hectares in minutes.',
          tags: ['RTK GPS', 'Multi-Spectral', 'Payload'],
        ),
        _TechCard(
          icon: LucideIcons.globe,
          title: 'VERD Hub',
          description: 'The VERD network belongs to the community. Participate in the future of decentralized agricultural AI.',
          tags: ['MIT Licensed', '40k+ Datasets', 'Community'],
        ),
        _TechCard(
          icon: LucideIcons.code2,
          title: 'Dev-First Design',
          description: 'Built by designers, for developers. Our headless API allows for infinite customization and integration.',
          tags: ['REST & gRPC', 'Webhooks', 'SDKs (Go, TS)'],
        ),
      ],
    );
  }

  Widget _buildOnboarding(BuildContext context, bool isMobile) {
    final steps = [
      {'step': '01', 'title': 'Create Account', 'desc': 'Securely create your profile so your scan history stays private.'},
      {'step': '02', 'title': 'Explore Dashboard', 'desc': 'Get familiar with your custom field insights and recent pathological trends.'},
      {'step': '03', 'title': 'Connect Sensors', 'desc': 'Link your field hardware or drone suite for real-time biometric data.'},
      {'step': '04', 'title': 'Capture Sample', 'desc': 'Snap a clear photo of any crop issue. Our AI spots pathology markers instantly.'},
      {'step': '05', 'title': 'Review Diagnosis', 'desc': 'Follow suggested steps from our neural models to protect your field.'},
      {'step': '06', 'title': 'Share & Grow', 'desc': 'Contribute to the open pathology library and learn from the community.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Getting started with ', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              TextSpan(text: 'VERD', style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.black, color: VerdTheme.primary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text("It only takes a few steps to start making your harvest smarter.", style: TextStyle(color: VerdTheme.textDim, fontSize: 14)),
        const SizedBox(height: 48),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 2.0 : 1.5,
          children: steps.map((s) => GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['step']!, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.02))),
                const Spacer(),
                Text(s['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(s['desc']!, style: TextStyle(fontSize: 10, color: VerdTheme.textDim, fontWeight: FontWeight.w300)),
              ],
            )).animate().fadeIn(delay: 200.ms)).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('© 2026 VERD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('ENGINEERED BY WHITE WALKERS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.black, color: VerdTheme.primary.withOpacity(0.2), letterSpacing: 4)),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;

  const _TechCard({required this.icon, required this.title, required this.description, required this.tags});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: VerdTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: VerdTheme.primary, size: 28),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(fontSize: 12, color: VerdTheme.textDim)),
          const Spacer(),
          Wrap(
            spacing: 12,
            children: tags.map((t) => Text(t.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 1))).toList(),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text('EXPLORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              SizedBox(width: 8),
              Icon(LucideIcons.arrowRight, size: 12),
            ],
          ),
        ],
      ),
    );
  }
}
