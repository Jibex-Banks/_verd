import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import 'glass_card.dart';

class AuthModal extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String initialMode;

  const AuthModal({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.initialMode = 'login',
  });

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  late String _mode;
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.4),
      child: BackdropFilter(
        filter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 32),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: widget.onClose,
              icon: Icon(LucideIcons.x, color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
        Text(
          _mode == 'login' ? 'Welcome back!' : 'Create your account',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure your account and keep your harvest results with you on any device.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: VerdTheme.textDim),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mode == 'signup') ...[
          _buildField(label: 'FULL NAME', icon: LucideIcons.user, hint: 'Dr. Savannah'),
          const SizedBox(height: 20),
        ],
        _buildField(label: 'EMAIL ADDRESS', icon: LucideIcons.mail, hint: 'hello@yourfarm.com'),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 32),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildField({required String label, required IconData icon, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white.withOpacity(0.2), size: 18),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text('YOUR PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VerdTheme.primary, letterSpacing: 2)),
            if (_mode == 'login')
              Text('FORGOT?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.2), letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            obscureText: !_showPassword,
            decoration: InputDecoration(
              icon: Icon(LucideIcons.lock, color: Colors.white.withOpacity(0.2), size: 18),
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 14),
              border: InputBorder.none,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye, color: Colors.white.withOpacity(0.2), size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: VerdTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              shadowColor: VerdTheme.primary.withOpacity(0.3),
              elevation: 20,
            ),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_mode == 'login' ? 'SIGN IN' : 'CREATE ACCOUNT', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.arrowRight, size: 18),
                  ],
                ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.1))),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.05))),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => setState(() => _mode = _mode == 'login' ? 'signup' : 'login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.4),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _mode == 'login' ? 'NEW HERE? CREATE ACCOUNT' : 'ALREADY HAVE AN ACCOUNT? SIGN IN',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'POWERED BY WHITE WALKERS',
      style: TextStyle(fontSize: 8, fontWeight: FontWeight.black, color: Colors.white.withOpacity(0.1), letterSpacing: 4),
    );
  }
}
