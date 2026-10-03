import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sdui_models.dart';

class ConnectionTestResult {
  final bool success;
  final int latencyMs;
  final String message;
  final List<String> localIps;

  ConnectionTestResult({
    required this.success,
    required this.latencyMs,
    required this.message,
    this.localIps = const [],
  });
}

class SDUIService {
  static final SDUIService _instance = SDUIService._internal();
  factory SDUIService() => _instance;
  SDUIService._internal();

  static const String keyBaseUrl = 'sdui_base_url';
  static const String keyActiveScreenId = 'sdui_active_screen_id';
  static const String keyCachedPrefix = 'sdui_cached_screen_';

  // Smart default URL based on execution platform
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 is default for Android emulator to reach host machine
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://localhost:5000';
  }

  String _baseUrl = defaultBaseUrl;
  String _activeScreenId = 'home';
  SharedPreferences? _prefs;

  String get baseUrl => _baseUrl;
  String get activeScreenId => _activeScreenId;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _baseUrl = _prefs?.getString(keyBaseUrl) ?? defaultBaseUrl;
    _activeScreenId = _prefs?.getString(keyActiveScreenId) ?? 'home';
  }

  Future<void> setBaseUrl(String url) async {
    String clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _baseUrl = clean;
    await _prefs?.setString(keyBaseUrl, _baseUrl);
  }

  Future<void> setActiveScreenId(String screenId) async {
    _activeScreenId = screenId;
    await _prefs?.setString(keyActiveScreenId, _activeScreenId);
  }

  /// Fetches screen schema from backend REST endpoint
  /// If offline or server error, falls back gracefully to local cache or embedded default
  Future<SDUIScreen> fetchScreen({String? screenId}) async {
    final targetId = screenId ?? _activeScreenId;
    final endpoint = '$_baseUrl/api/v1/screen/$targetId';

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          // Cache locally
          await _prefs?.setString('$keyCachedPrefix$targetId', jsonEncode(data));
          return SDUIScreen.fromJson(data, isLive: true);
        }
      }
      throw HttpException('Server returned HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('[SDUIService] Network fetch failed: $e. Falling back to cache...');
      // Fallback 1: Local cache
      final cachedStr = _prefs?.getString('$keyCachedPrefix$targetId');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        try {
          final cachedData = jsonDecode(cachedStr) as Map<String, dynamic>;
          return SDUIScreen.fromJson(
            cachedData,
            isLive: false,
            error: 'Network unreachable ($e). Showing locally cached layout.',
          );
        } catch (_) {}
      }

      // Fallback 2: Factory embedded template
      return SDUIScreen.fromJson(
        getEmbeddedDefaultSchema(targetId),
        isLive: false,
        error: 'Backend offline: $e. Showing offline fallback UI.',
      );
    }
  }

  /// Test connection with latency measurement
  Future<ConnectionTestResult> testConnection(String targetUrl) async {
    String clean = targetUrl.trim();
    if (clean.endsWith('/')) clean = clean.substring(0, clean.length - 1);
    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.get(
        Uri.parse('$clean/api/v1/status'),
      ).timeout(const Duration(seconds: 4));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ips = (data['localIps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        return ConnectionTestResult(
          success: true,
          latencyMs: stopwatch.elapsedMilliseconds,
          message: 'Connected to SDUI Server (${stopwatch.elapsedMilliseconds}ms)',
          localIps: ips,
        );
      } else {
        return ConnectionTestResult(
          success: false,
          latencyMs: stopwatch.elapsedMilliseconds,
          message: 'Server error: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ConnectionTestResult(
        success: false,
        latencyMs: stopwatch.elapsedMilliseconds,
        message: 'Cannot reach server: $e',
      );
    }
  }

  /// Directly applies raw JSON schema on the fly (for mobile in-app testing)
  SDUIScreen parseRawJson(String rawJson) {
    final Map<String, dynamic> data = jsonDecode(rawJson);
    return SDUIScreen.fromJson(data, isLive: false);
  }

  /// Embedded fallback template so app always has rich content even completely offline
  static Map<String, dynamic> getEmbeddedDefaultSchema(String screenId) {
    return {
      "screenId": screenId,
      "title": "SDUI Offline Dynamic Store",
      "version": "1.0.0",
      "theme": {
        "primaryColor": "#6366F1",
        "backgroundColor": "#0F172A",
        "surfaceColor": "#1E293B",
        "textColor": "#F8FAFC",
        "accentColor": "#10B981"
      },
      "components": [
        {
          "id": "comp_search_1",
          "type": "search_bar",
          "props": {
            "placeholder": "Search 10,000+ products & services...",
            "showFilter": true
          },
          "action": {
            "type": "toast",
            "payload": { "message": "Search filter tapped" }
          },
          "styles": { "margin": [12, 16, 8, 16] }
        },
        {
          "id": "comp_banner_1",
          "type": "banner",
          "props": {
            "badge": "⚡ LIMITED TIME OFFER",
            "title": "Weekend Flash Super Sale",
            "subtitle": "Get up to 50% discount on all wireless electronics and audio gear today.",
            "imageUrl": "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80",
            "ctaText": "Claim 50% OFF"
          },
          "action": {
            "type": "dialog",
            "payload": {
              "title": "Promo Claimed 🎉",
              "message": "Coupon code FLASH50 applied to your account."
            }
          },
          "styles": {
            "backgroundColor": "#4F46E5",
            "textColor": "#FFFFFF",
            "borderRadius": 16,
            "margin": [8, 16, 12, 16]
          }
        },
        {
          "id": "comp_chips_1",
          "type": "category_chips",
          "props": {
            "selectedIndex": 0,
            "items": ["🔥 All Deals", "💻 Electronics", "🛠️ Services", "👟 Fashion", "🛋️ Home"]
          },
          "action": {
            "type": "toast",
            "payload": { "message": "Category chip selected" }
          },
          "styles": { "margin": [4, 16, 12, 16] }
        },
        {
          "id": "comp_section_services",
          "type": "section_title",
          "props": {
            "title": "Quick Services",
            "subtitle": "Instant on-demand assistance in 30 mins",
            "actionText": "See All (12)"
          },
          "action": {
            "type": "toast",
            "payload": { "message": "Opening all services catalog..." }
          },
          "styles": { "margin": [8, 16, 8, 16] }
        },
        {
          "id": "comp_grid_1",
          "type": "service_grid",
          "props": {
            "columns": 4,
            "items": [
              {
                "title": "Repairs",
                "icon": "build",
                "badge": "Top",
                "action": { "type": "toast", "payload": { "message": "Gadget Repair chosen" } }
              },
              {
                "title": "Cleaning",
                "icon": "cleaning_services",
                "badge": "20% OFF",
                "action": { "type": "toast", "payload": { "message": "Home Cleaning chosen" } }
              },
              {
                "title": "Plumbing",
                "icon": "plumbing",
                "badge": null,
                "action": { "type": "toast", "payload": { "message": "Plumbing chosen" } }
              },
              {
                "title": "Electric",
                "icon": "bolt",
                "badge": "Express",
                "action": { "type": "toast", "payload": { "message": "Electrician chosen" } }
              }
            ]
          },
          "styles": { "margin": [0, 16, 12, 16] }
        },
        {
          "id": "comp_promo_1",
          "type": "promo_card",
          "props": {
            "title": "Community Voucher",
            "discount": r"FLAT $25 OFF",
            "code": "SDUI25",
            "description": r"On orders over $50. Tap copy code to apply instantly.",
            "expires": "Valid until Midnight"
          },
          "action": {
            "type": "copy_code",
            "payload": {
              "code": "SDUI25",
              "message": "Coupon code 'SDUI25' copied to clipboard!"
            }
          },
          "styles": {
            "backgroundColor": "#059669",
            "textColor": "#FFFFFF",
            "margin": [4, 16, 16, 16]
          }
        },
        {
          "id": "comp_section_trending",
          "type": "section_title",
          "props": {
            "title": "Spotlight Product",
            "subtitle": "Best rated by verified buyers",
            "actionText": "More Deals"
          },
          "action": {
            "type": "toast",
            "payload": { "message": "Opening trending collections..." }
          },
          "styles": { "margin": [4, 16, 8, 16] }
        },
        {
          "id": "comp_product_1",
          "type": "product_card",
          "props": {
            "title": "Studio Pro ANC Wireless Headphones",
            "description": "Active Noise Cancellation with 40-hour battery life and spatial audio support.",
            "price": r"$129.99",
            "originalPrice": r"$219.00",
            "rating": "4.9 ★",
            "reviews": "(1,450)",
            "tag": "TOP CHOICE",
            "imageUrl": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700&q=80"
          },
          "action": {
            "type": "dialog",
            "payload": {
              "title": "Item Added to Cart! 🛒",
              "message": r"Studio Pro ANC Headphones ($129.99) added to your cart!"
            }
          },
          "styles": { "margin": [0, 16, 16, 16] }
        },
        {
          "id": "comp_section_carousel",
          "type": "section_title",
          "props": {
            "title": "Curated Collections",
            "subtitle": "Swipe horizontally to explore"
          },
          "styles": { "margin": [4, 16, 8, 16] }
        },
        {
          "id": "comp_carousel_1",
          "type": "carousel",
          "props": {
            "items": [
              {
                "title": "Smart Home",
                "subtitle": "Automate living",
                "imageUrl": "https://images.unsplash.com/photo-1558002038-1055907df827?w=600&q=80",
                "tag": "NEW",
                "action": { "type": "toast", "payload": { "message": "Smart Home collection" } }
              },
              {
                "title": "Studio Audio",
                "subtitle": "Acoustic fidelity",
                "imageUrl": "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80",
                "tag": "TRENDING",
                "action": { "type": "toast", "payload": { "message": "Studio Audio collection" } }
              },
              {
                "title": "Fitness Gear",
                "subtitle": "Heart rate tracking",
                "imageUrl": "https://images.unsplash.com/photo-1510519138161-58474ebf8463?w=600&q=80",
                "tag": "HOT",
                "action": { "type": "toast", "payload": { "message": "Fitness Gear collection" } }
              }
            ]
          },
          "styles": { "margin": [0, 0, 16, 0] }
        },
        {
          "id": "comp_spacer_1",
          "type": "spacer",
          "props": { "height": 12 }
        },
        {
          "id": "comp_button_1",
          "type": "button_action",
          "props": {
            "text": "Browse All Categories & Stores ➔",
            "variant": "primary"
          },
          "action": {
            "type": "toast",
            "payload": { "message": "Opening full directory..." }
          },
          "styles": {
            "backgroundColor": "#6366F1",
            "textColor": "#FFFFFF",
            "margin": [0, 16, 32, 16]
          }
        }
      ]
    };
  }
}
