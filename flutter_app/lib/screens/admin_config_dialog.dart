import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/sdui_models.dart';
import '../services/sdui_service.dart';

class AdminConfigDialog extends StatefulWidget {
  final SDUIScreen currentScreen;
  final Function(SDUIScreen updatedScreen) onScreenUpdated;
  final VoidCallback onReloadRequested;

  const AdminConfigDialog({
    super.key,
    required this.currentScreen,
    required this.onScreenUpdated,
    required this.onReloadRequested,
  });

  @override
  State<AdminConfigDialog> createState() => _AdminConfigDialogState();
}

class _AdminConfigDialogState extends State<AdminConfigDialog> {
  final SDUIService _sduiService = SDUIService();
  late TextEditingController _urlController;
  late TextEditingController _jsonEditorController;

  bool _isTesting = false;
  String? _testMessage;
  bool _testSuccess = false;
  List<String> _detectedIps = [];

  String _selectedScreenId = 'home';
  bool _showRawJsonEditor = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _sduiService.baseUrl);
    _selectedScreenId = _sduiService.activeScreenId;
    _jsonEditorController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(widget.currentScreen.toJson()),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _jsonEditorController.dispose();
    super.dispose();
  }

  Future<void> _runConnectionTest() async {
    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    final res = await _sduiService.testConnection(_urlController.text);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = res.success;
        _testMessage = res.message;
        _detectedIps = res.localIps;
      });
    }
  }

  Future<void> _saveAndReload() async {
    await _sduiService.setBaseUrl(_urlController.text);
    await _sduiService.setActiveScreenId(_selectedScreenId);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onReloadRequested();
    }
  }

  void _applyDirectJson() {
    try {
      final raw = _jsonEditorController.text.trim();
      final updated = _sduiService.parseRawJson(raw);
      widget.onScreenUpdated(updated);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Live JSON applied and rendered directly on device!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON Syntax Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withAlpha(25)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF818CF8), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SDUI In-App Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Local Server & Schema Configuration',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E293B), height: 24),

              // Scrollable Settings Content
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Backend URL Field
                    const Text(
                      'Backend Server API URL',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        hintText: 'http://10.0.2.2:5000',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.wifi_tethering_rounded, color: Color(0xFF818CF8)),
                          tooltip: 'Test Connection',
                          onPressed: _isTesting ? null : _runConnectionTest,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Host Presets
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildPresetChip('Emulator (10.0.2.2)', 'http://10.0.2.2:5000'),
                        _buildPresetChip('WiFi IP (10.129.222.211)', 'http://10.129.222.211:5000'),
                        _buildPresetChip('Localhost', 'http://localhost:5000'),
                      ],
                    ),

                    // Detected IPs from server ping
                    if (_detectedIps.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Detected Backend IPs (tap to select):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _detectedIps
                            .map((ip) => _buildPresetChip('http://$ip:5000', 'http://$ip:5000'))
                            .toList(),
                      ),
                    ],

                    // Test Status Result Banner
                    if (_testMessage != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _testSuccess ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _testSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testMessage!,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Active Screen Selector
                    const Text(
                      'Target Screen',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildScreenOption('home', '🏠 Home Screen'),
                        const SizedBox(width: 10),
                        _buildScreenOption('explore', '🧭 Explore Screen'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // In-App Direct JSON Schema Editor Toggle
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showRawJsonEditor = !_showRawJsonEditor;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.code_rounded, color: Color(0xFF38BDF8), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'In-App Raw JSON Schema Editor',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Icon(
                              _showRawJsonEditor ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showRawJsonEditor) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Edit or paste JSON schema directly on your mobile device to test live instant rendering:',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _jsonEditorController,
                        maxLines: 8,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF070B14),
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _applyDirectJson,
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('Apply Schema Live', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(color: Color(0xFF1E293B), height: 24),

              // Dialog Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _urlController.text = SDUIService.defaultBaseUrl;
                      _selectedScreenId = 'home';
                      setState(() {});
                    },
                    child: const Text('Reset Defaults', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _saveAndReload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save & Fetch Screen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String url) {
    final isSelected = _urlController.text.trim() == url;
    return InkWell(
      onTap: () {
        setState(() {
          _urlController.text = url;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withAlpha(40) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white.withAlpha(15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF818CF8) : const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScreenOption(String id, String label) {
    final isSelected = _selectedScreenId == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedScreenId = id;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : Colors.white.withAlpha(15),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
