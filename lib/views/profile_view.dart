import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../ui/glass_card.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  String _activeTab = 'info';
  bool _isFarmer = true;
  bool _showCurrentPass = false;
  bool _showNewPass = false;

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
              _buildHeader(isMobile),
              const SizedBox(height: 60),
              if (isMobile) ...[
                _buildSidebar(isMobile),
                const SizedBox(height: 32),
                _buildActiveTab(isMobile),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildSidebar(isMobile)),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildActiveTab(isMobile)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Account '),
              TextSpan(text: 'SETTINGS', style: TextStyle(color: VerdTheme.primary, fontWeight: FontWeight.black, fontStyle: FontStyle.normal)),
            ],
          ),
          style: TextStyle(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text('Manage your agricultural profile and platform preferences.', style: TextStyle(color: VerdTheme.textDim, fontSize: 14)),
      ],
    );
  }

  Widget _buildSidebar(bool isMobile) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: isMobile 
        ? Column(
            children: [
              _buildUserAvatar(),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SidebarTab(label: 'INFO', icon: LucideIcons.user, isActive: _activeTab == 'info', onTap: () => setState(() => _activeTab = 'info')),
                    const SizedBox(width: 8),
                    _SidebarTab(label: 'NOTIFS', icon: LucideIcons.bell, isActive: _activeTab == 'notifications', onTap: () => setState(() => _activeTab = 'notifications')),
                    const SizedBox(width: 8),
                    _SidebarTab(label: 'LOCK', icon: LucideIcons.lock, isActive: _activeTab == 'security', onTap: () => setState(() => _activeTab = 'security')),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              _buildUserAvatar(),
              const SizedBox(height: 32),
              _SidebarTab(label: 'PERSONAL INFO', icon: LucideIcons.user, isActive: _activeTab == 'info', onTap: () => setState(() => _activeTab = 'info')),
              const SizedBox(height: 12),
              _SidebarTab(label: 'NOTIFICATIONS', icon: LucideIcons.bell, isActive: _activeTab == 'notifications', onTap: () => setState(() => _activeTab = 'notifications')),
              const SizedBox(height: 12),
              _SidebarTab(label: 'SECURITY', icon: LucideIcons.lock, isActive: _activeTab == 'security', onTap: () => setState(() => _activeTab = 'security')),
            ],
          ),
    );
  }

  Widget _buildUserAvatar() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: VerdTheme.primary.withOpacity(0.1),
                border: Border.all(color: VerdTheme.primary, width: 2),
                shape: BoxType.circle,
              ),
              child: const Center(child: Icon(LucideIcons.user, size: 40, color: VerdTheme.primary)),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: VerdTheme.primary, shape: BoxType.circle),
              child: const Icon(LucideIcons.shieldCheck, size: 12, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Alex', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('PREMIUM FARMER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
      ],
    );
  }

  Widget _buildActiveTab(bool isMobile) {
    switch (_activeTab) {
      case 'info': return _buildPersonalInfo(isMobile);
      case 'security': return _buildSecurity(isMobile);
      default: return const GlassCard(child: Center(child: Text('Coming Soon')));
    }
  }

  Widget _buildPersonalInfo(bool isMobile) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PERSONAL INFORMATION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          const SizedBox(height: 48),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: isMobile ? 4.0 : 2.5,
            children: [
              _Field(label: 'FULL NAME', value: 'Alex', icon: LucideIcons.user),
              _Field(label: 'EMAIL ADDRESS', value: 'alex@farm.tech', icon: LucideIcons.mail),
              _Field(label: 'LOCATION', value: 'Savannah Belt Region', icon: LucideIcons.mapPin),
              _Field(label: 'PHONE NUMBER', value: '+1 234 567 8900', icon: LucideIcons.phone),
            ],
          ),
          const SizedBox(height: 48),
          _FarmerStatusToggle(isFarmer: _isFarmer, onToggle: (v) => setState(() => _isFarmer = v)),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_PrimaryButton(label: isMobile ? 'SAVE' : 'SAVE CHANGES', icon: LucideIcons.save)],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity(bool isMobile) {
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SECURITY SETTINGS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          const SizedBox(height: 48),
          _PasswordField(label: 'CHANGE PASSWORD', hint: 'Current Password', show: _showCurrentPass, onToggle: () => setState(() => _showCurrentPass = !_showCurrentPass)),
          const SizedBox(height: 24),
          if (isMobile) ...[
            _PasswordField(label: '', hint: 'New Password', show: _showNewPass, onToggle: () => setState(() => _showNewPass = !_showNewPass)),
            const SizedBox(height: 24),
            _PasswordField(label: '', hint: 'Confirm New Password', show: _showNewPass, hideLabel: true),
          ] else
            Row(
              children: [
                Expanded(child: _PasswordField(label: '', hint: 'New Password', show: _showNewPass, onToggle: () => setState(() => _showNewPass = !_showNewPass))),
                const SizedBox(width: 24),
                Expanded(child: _PasswordField(label: '', hint: 'Confirm New Password', show: _showNewPass, hideLabel: true)),
              ],
            ),
          const SizedBox(height: 48),
          _SecurityItem(title: 'Two-Factor Authentication', desc: 'Add a second layer of security to your account.', action: 'CONFIGURE', isMobile: isMobile),
          const SizedBox(height: 24),
          _SecurityItem(title: 'Delete Account', desc: 'Permanently remove your account and data.', action: 'DELETE', isDanger: true, isMobile: isMobile),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_PrimaryButton(label: isMobile ? 'UPDATE' : 'UPDATE SECURITY', icon: LucideIcons.save)],
          ),
        ],
      ),
    );
  }
}

class _SidebarTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarTab({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? VerdTheme.primary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.black : Colors.white.withOpacity(0.4)),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.white.withOpacity(0.4), letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Field({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: VerdTheme.glassDecoration(opacity: 0.1),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 16),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FarmerStatusToggle extends StatelessWidget {
  final bool isFarmer;
  final Function(bool) onToggle;

  const _FarmerStatusToggle({required this.isFarmer, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: VerdTheme.primary.withOpacity(0.05), border: Border.all(color: VerdTheme.primary.withOpacity(0.1)), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Professional Farmer Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Enable specialized agronomy tools and personalized advice.', style: TextStyle(fontSize: 10, color: VerdTheme.textDim)),
            ],
          ),
          Switch(value: isFarmer, onChanged: onToggle, activeColor: VerdTheme.primary),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final bool show;
  final VoidCallback? onToggle;
  final bool hideLabel;

  const _PasswordField({required this.label, required this.hint, required this.show, this.onToggle, this.hideLabel = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideLabel && label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0x33FFFFFF), letterSpacing: 2)),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: VerdTheme.glassDecoration(opacity: 0.1),
          child: TextField(
            obscureText: !show,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.1), fontFamily: 'monospace'),
              border: InputBorder.none,
              suffixIcon: onToggle != null ? IconButton(onPressed: onToggle, icon: Icon(show ? LucideIcons.eyeOff : LucideIcons.eye, size: 16, color: Colors.white24)) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final String title;
  final String desc;
  final String action;
  final bool isDanger;
  final bool isMobile;

  const _SecurityItem({required this.title, required this.desc, required this.action, this.isDanger = false, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDanger ? Colors.redAccent : Colors.white)),
        Text(desc, style: TextStyle(fontSize: 10, color: VerdTheme.textDim)),
      ],
    );

    final button = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isDanger ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        foregroundColor: isDanger ? Colors.redAccent : Colors.white60,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDanger ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1))),
        elevation: 0,
      ),
      child: Text(action, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: VerdTheme.glassDecoration(opacity: 0.05),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: button),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              content,
              button,
            ],
          ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PrimaryButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: VerdTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: VerdTheme.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }
}
