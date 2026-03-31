import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'ui/neural_background.dart';
import 'ui/navbar.dart';
import 'ui/auth_modal.dart';
import 'views/home_view.dart';
import 'views/scan_view.dart';
import 'views/insights_view.dart';
import 'views/dashboard_view.dart';
import 'views/history_view.dart';
import 'views/learning_view.dart';
import 'views/profile_view.dart';

void main() {
  runApp(const VerdApp());
}

class VerdApp extends StatelessWidget {
  const VerdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VERD',
      debugShowCheckedModeBanner: false,
      theme: VerdTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _currentView = 'home';
  bool _showAuth = false;
  String _authMode = 'login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: NeuralBackground(
        child: Stack(
          children: [
            // Content View
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _getView(),
              ),
            ),
            
            // Navbar
            Navbar(
              currentView: _currentView,
              onViewChanged: (view) {
                if (view == 'profile_modal') {
                  setState(() {
                    _showAuth = true;
                    _authMode = 'login';
                  });
                } else {
                  setState(() => _currentView = view);
                }
              },
            ),

            // Auth Modal
            AuthModal(
              isOpen: _showAuth,
              onClose: () => setState(() => _showAuth = false),
              initialMode: _authMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getView() {
    switch (_currentView) {
      case 'home':
        return const HomeView(key: ValueKey('home'));
      case 'scan':
        return const DiagnosticScanner(key: ValueKey('scan'));
      case 'insights':
        return const GroundTruthInsights(key: ValueKey('insights'));
      case 'dashboard':
        return UserDashboard(
          key: const ValueKey('dashboard'),
          onViewChanged: (view) => setState(() => _currentView = view),
        );
      case 'history':
        return const ScanHistory(key: ValueKey('history'));
      case 'learning':
        return const LearningCenter(key: ValueKey('learning'));
      case 'profile':
        return const ProfileSettings(key: ValueKey('profile'));
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }
}
