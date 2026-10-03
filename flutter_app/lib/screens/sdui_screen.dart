import 'package:flutter/material.dart';
import '../models/sdui_models.dart';
import '../services/sdui_service.dart';
import '../widgets/sdui_parser.dart';
import 'admin_config_dialog.dart';

class SDUIScreenWidget extends StatefulWidget {
  const SDUIScreenWidget({super.key});

  @override
  State<SDUIScreenWidget> createState() => _SDUIScreenWidgetState();
}

class _SDUIScreenWidgetState extends State<SDUIScreenWidget> {
  final SDUIService _sduiService = SDUIService();
  SDUIScreen? _currentScreen;
  bool _isLoading = true;
  String? _bannerError;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    setState(() {
      _isLoading = true;
      _bannerError = null;
    });

    final screen = await _sduiService.fetchScreen();

    if (mounted) {
      setState(() {
        _currentScreen = screen;
        _isLoading = false;
        if (!screen.isLiveServer && screen.fetchError != null) {
          _bannerError = screen.fetchError;
        }
      });
    }
  }

  void _openAdminConfig() {
    if (_currentScreen == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminConfigDialog(
        currentScreen: _currentScreen!,
        onScreenUpdated: (updatedScreen) {
          setState(() {
            _currentScreen = updatedScreen;
            _bannerError = 'Rendering custom in-app schema override.';
          });
        },
        onReloadRequested: () {
          _loadScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _currentScreen?.theme.backgroundColor ?? const Color(0xFF0F172A);
    final primaryColor = _currentScreen?.theme.primaryColor ?? const Color(0xFF6366F1);
    final isLive = _currentScreen?.isLiveServer ?? false;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withAlpha(240),
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _currentScreen?.title ?? 'SDUI Dynamic App',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Live Status Indicator Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLive ? const Color(0xFF064E3B) : const Color(0xFF78350F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isLive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLive ? 'LIVE SERVER' : 'OFFLINE',
                    style: TextStyle(
                      color: isLive ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Pull latest schema',
            onPressed: _loadScreen,
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF818CF8)),
            tooltip: 'Admin Settings',
            onPressed: _openAdminConfig,
          ),
        ],
      ),
      body: _isLoading && _currentScreen == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Parsing Server-Driven UI Layout...',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              backgroundColor: const Color(0xFF1E293B),
              onRefresh: _loadScreen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  // Offline or Error Notice Banner
                  if (_bannerError != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(100)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Offline Cache Mode Active',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _bannerError!,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _openAdminConfig,
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                            child: const Text('Configure IP', style: TextStyle(color: Color(0xFF818CF8), fontSize: 11)),
                          ),
                        ],
                      ),
                    ),

                  // Dynamically Rendered SDUI Components
                  if (_currentScreen != null)
                    ..._currentScreen!.components.map(
                      (comp) => SDUIParser.buildWidget(
                        context,
                        comp,
                        onScreenChangeRequested: _loadScreen,
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdminConfig,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.tune_rounded, size: 18),
        label: const Text('Admin Config', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        elevation: 6,
      ),
    );
  }
}
