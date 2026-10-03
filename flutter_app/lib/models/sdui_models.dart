import 'package:flutter/material.dart';

/// Helper to parse Hex color strings (#RRGGBB or #AARRGGBB) safely
Color parseHexColor(dynamic hexStr, {Color fallback = const Color(0xFF6366F1)}) {
  if (hexStr == null || hexStr is! String || hexStr.isEmpty) return fallback;
  try {
    String cleanHex = hexStr.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
  } catch (_) {}
  return fallback;
}

/// Helper to parse margin/padding arrays [top, right, bottom, left]
EdgeInsetsGeometry parseEdgeInsets(dynamic value, {EdgeInsetsGeometry fallback = EdgeInsets.zero}) {
  if (value == null) return fallback;
  if (value is num) return EdgeInsets.all(value.toDouble());
  if (value is List) {
    if (value.length == 4) {
      return EdgeInsets.fromLTRB(
        (value[3] as num).toDouble(), // left
        (value[0] as num).toDouble(), // top
        (value[1] as num).toDouble(), // right
        (value[2] as num).toDouble(), // bottom
      );
    } else if (value.length == 2) {
      return EdgeInsets.symmetric(
        vertical: (value[0] as num).toDouble(),
        horizontal: (value[1] as num).toDouble(),
      );
    }
  }
  return fallback;
}

/// Master SDUI Screen Model
class SDUIScreen {
  final String screenId;
  final String title;
  final String version;
  final String? updatedAt;
  final SDUITheme theme;
  final List<SDUIComponent> components;
  final bool isLiveServer;
  final String? fetchError;

  SDUIScreen({
    required this.screenId,
    required this.title,
    this.version = '1.0.0',
    this.updatedAt,
    required this.theme,
    required this.components,
    this.isLiveServer = true,
    this.fetchError,
  });

  factory SDUIScreen.fromJson(Map<String, dynamic> json, {bool isLive = true, String? error}) {
    final rawTheme = json['theme'] as Map<String, dynamic>? ?? {};
    final rawComps = json['components'] as List<dynamic>? ?? [];

    return SDUIScreen(
      screenId: json['screenId']?.toString() ?? 'home',
      title: json['title']?.toString() ?? 'SDUI Store',
      version: json['version']?.toString() ?? '1.0.0',
      updatedAt: json['updatedAt']?.toString(),
      theme: SDUITheme.fromJson(rawTheme),
      components: rawComps.map((c) => SDUIComponent.fromJson(c as Map<String, dynamic>)).toList(),
      isLiveServer: isLive,
      fetchError: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenId': screenId,
      'title': title,
      'version': version,
      'updatedAt': updatedAt,
      'theme': theme.toJson(),
      'components': components.map((c) => c.toJson()).toList(),
    };
  }
}

/// SDUI Theme Config
class SDUITheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color accentColor;

  SDUITheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.accentColor,
  });

  factory SDUITheme.fromJson(Map<String, dynamic> json) {
    return SDUITheme(
      primaryColor: parseHexColor(json['primaryColor'], fallback: const Color(0xFF6366F1)),
      backgroundColor: parseHexColor(json['backgroundColor'], fallback: const Color(0xFF0F172A)),
      surfaceColor: parseHexColor(json['surfaceColor'], fallback: const Color(0xFF1E293B)),
      textColor: parseHexColor(json['textColor'], fallback: const Color(0xFFF8FAFC)),
      accentColor: parseHexColor(json['accentColor'], fallback: const Color(0xFF10B981)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'backgroundColor': '#${backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'surfaceColor': '#${surfaceColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'textColor': '#${textColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      'accentColor': '#${accentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    };
  }
}

/// SDUI Component
class SDUIComponent {
  final String id;
  final String type;
  final Map<String, dynamic> props;
  final SDUIAction? action;
  final SDUIStyles styles;

  SDUIComponent({
    required this.id,
    required this.type,
    required this.props,
    this.action,
    required this.styles,
  });

  factory SDUIComponent.fromJson(Map<String, dynamic> json) {
    return SDUIComponent(
      id: json['id']?.toString() ?? 'comp_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type']?.toString() ?? 'unknown',
      props: json['props'] as Map<String, dynamic>? ?? {},
      action: json['action'] != null ? SDUIAction.fromJson(json['action'] as Map<String, dynamic>) : null,
      styles: SDUIStyles.fromJson(json['styles'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'props': props,
      if (action != null) 'action': action!.toJson(),
      'styles': styles.toJson(),
    };
  }
}

/// SDUI Action (Tap callbacks)
class SDUIAction {
  final String type; // toast, dialog, copy_code, navigate
  final Map<String, dynamic> payload;

  SDUIAction({
    required this.type,
    required this.payload,
  });

  factory SDUIAction.fromJson(Map<String, dynamic> json) {
    return SDUIAction(
      type: json['type']?.toString() ?? 'toast',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
    };
  }
}

/// SDUI Component Styles
class SDUIStyles {
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  SDUIStyles({
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  factory SDUIStyles.fromJson(Map<String, dynamic> json) {
    return SDUIStyles(
      backgroundColor: json['backgroundColor'] != null ? parseHexColor(json['backgroundColor']) : null,
      textColor: json['textColor'] != null ? parseHexColor(json['textColor']) : null,
      borderRadius: json['borderRadius'] != null ? (json['borderRadius'] as num).toDouble() : null,
      margin: parseEdgeInsets(json['margin']),
      padding: parseEdgeInsets(json['padding']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (backgroundColor != null) 'backgroundColor': '#${backgroundColor!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      if (textColor != null) 'textColor': '#${textColor!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      if (borderRadius != null) 'borderRadius': borderRadius,
    };
  }
}
