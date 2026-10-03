import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sdui_models.dart';

class SDUIActionHandler {
  static void handleAction(
    BuildContext context,
    SDUIAction? action, {
    String? fallbackMessage,
    VoidCallback? onScreenChangeRequested,
  }) {
    if (action == null) {
      if (fallbackMessage != null) {
        showToast(context, fallbackMessage);
      }
      return;
    }

    final payload = action.payload;

    switch (action.type) {
      case 'toast':
        final msg = payload['message']?.toString() ?? fallbackMessage ?? 'Action triggered';
        showToast(context, msg);
        break;

      case 'dialog':
        final title = payload['title']?.toString() ?? 'SDUI Alert';
        final message = payload['message']?.toString() ?? fallbackMessage ?? '';
        showSDUIDialog(context, title, message);
        break;

      case 'copy_code':
        final code = payload['code']?.toString() ?? 'SDUI25';
        final msg = payload['message']?.toString() ?? 'Coupon code $code copied to clipboard!';
        Clipboard.setData(ClipboardData(text: code));
        showToast(context, msg, isSuccess: true, icon: Icons.content_copy_rounded);
        break;

      case 'navigate':
        final targetScreen = payload['screenId']?.toString();
        if (targetScreen != null && onScreenChangeRequested != null) {
          onScreenChangeRequested();
        } else {
          showToast(context, 'Navigating to: ${payload['screenId'] ?? payload['url'] ?? 'page'}');
        }
        break;

      default:
        showToast(context, payload['message']?.toString() ?? 'Action: ${action.type}');
        break;
    }
  }

  static void showToast(
    BuildContext context,
    String message, {
    bool isSuccess = false,
    IconData icon = Icons.info_outline_rounded,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : icon,
              color: isSuccess ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSDUIDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(25)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFF818CF8), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
