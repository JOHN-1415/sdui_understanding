import 'package:flutter/material.dart';
import '../models/sdui_models.dart';
import 'sdui_action_handler.dart';

/// Lightweight custom dashed divider widget
class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1.0,
    this.color = const Color(0xFFCBD5E1),
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        if (boxWidth <= 0 || boxWidth.isInfinite) {
          return Divider(height: height, thickness: height, color: color);
        }
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return SizedBox(
          width: boxWidth,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount > 0 ? dashCount : 1, (_) {
              return SizedBox(
                width: dashWidth,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class SDUIParser {
  /// Routes component to corresponding Flutter widget (supports recursive Approach 1 Primitives)
  static Widget buildWidget(
    BuildContext context,
    SDUIComponent component, {
    VoidCallback? onScreenChangeRequested,
  }) {
    switch (component.type) {
      // Approach 1 Atomic Primitives
      case 'container':
      case 'card':
        return _buildContainer(context, component, onScreenChangeRequested);
      case 'column':
        return _buildColumn(context, component, onScreenChangeRequested);
      case 'row':
        return _buildRow(context, component, onScreenChangeRequested);
      case 'stack':
        return _buildStack(context, component, onScreenChangeRequested);
      case 'image':
        return _buildImage(context, component);
      case 'text':
        return _buildText(context, component);
      case 'badge':
        return _buildBadge(context, component);
      case 'icon':
        return _buildIcon(context, component);
      case 'divider':
        return _buildDivider(context, component);
      case 'button':
        return _buildButton(context, component);

      // Pre-existing templates (fully backward-compatible)
      case 'search_bar':
        return _buildSearchBar(context, component);
      case 'banner':
        return _buildBanner(context, component);
      case 'category_chips':
        return _buildCategoryChips(context, component);
      case 'section_title':
        return _buildSectionTitle(context, component);
      case 'service_grid':
        return _buildServiceGrid(context, component);
      case 'promo_card':
        return _buildPromoCard(context, component);
      case 'product_card':
        return _buildProductCard(context, component);
      case 'carousel':
        return _buildCarousel(context, component);
      case 'button_action':
        return _buildButtonAction(context, component);
      case 'spacer':
        return _buildSpacer(component);
      default:
        return _buildUnknownWidget(component);
    }
  }

  // =========================================================================
  // HELPER PARSERS
  // =========================================================================

  static Alignment _parseAlignment(dynamic val) {
    switch (val?.toString()) {
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'topLeft':
      default:
        return Alignment.topLeft;
    }
  }

  static MainAxisAlignment _parseMainAxisAlignment(dynamic val) {
    switch (val?.toString()) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      case 'start':
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(dynamic val) {
    switch (val?.toString()) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      case 'start':
      default:
        return CrossAxisAlignment.start;
    }
  }

  static FontWeight _parseFontWeight(dynamic val) {
    switch (val?.toString()) {
      case 'bold':
      case '700':
        return FontWeight.w700;
      case '800':
      case 'extraBold':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      case '600':
      case 'semiBold':
        return FontWeight.w600;
      case '500':
      case 'medium':
        return FontWeight.w500;
      case '300':
      case 'light':
        return FontWeight.w300;
      case '400':
      case 'normal':
      default:
        return FontWeight.w400;
    }
  }

  static IconData _getMaterialIcon(String name) {
    switch (name) {
      case 'star':
        return Icons.star_rounded;
      case 'add':
      case 'plus':
        return Icons.add_rounded;
      case 'bolt':
      case 'flash':
        return Icons.bolt_rounded;
      case 'location_on':
      case 'pin':
        return Icons.location_on_rounded;
      case 'percent':
      case 'discount':
      case 'local_offer':
        return Icons.discount_rounded;
      case 'shopping_bag':
      case 'cart':
        return Icons.shopping_bag_rounded;
      case 'schedule':
      case 'timer':
        return Icons.schedule_rounded;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'check':
        return Icons.check_rounded;
      case 'arrow_forward':
        return Icons.arrow_forward_rounded;
      case 'build':
        return Icons.build_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'tune':
      case 'filter':
        return Icons.tune_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  // =========================================================================
  // APPROACH 1: ATOMIC COMPOSABLE PRIMITIVES
  // =========================================================================

  // 1. Container Primitive
  static Widget _buildContainer(
    BuildContext context,
    SDUIComponent comp,
    VoidCallback? onScreenChangeRequested,
  ) {
    final styles = comp.styles;
    final props = comp.props;

    Widget? childWidget;
    if (comp.children.length == 1) {
      childWidget = buildWidget(context, comp.children.first, onScreenChangeRequested: onScreenChangeRequested);
    } else if (comp.children.length > 1) {
      final layout = props['layout']?.toString() ?? 'column';
      if (layout == 'row') {
        childWidget = Row(
          mainAxisAlignment: _parseMainAxisAlignment(props['mainAxisAlignment']),
          crossAxisAlignment: _parseCrossAxisAlignment(props['crossAxisAlignment']),
          children: comp.children.map((c) {
            Widget item = buildWidget(context, c, onScreenChangeRequested: onScreenChangeRequested);
            if (c.props['expanded'] == true || c.props['flex'] != null) {
              item = Expanded(flex: c.props['flex'] is int ? c.props['flex'] as int : 1, child: item);
            }
            return item;
          }).toList(),
        );
      } else {
        childWidget = Column(
          mainAxisAlignment: _parseMainAxisAlignment(props['mainAxisAlignment']),
          crossAxisAlignment: _parseCrossAxisAlignment(props['crossAxisAlignment']),
          mainAxisSize: props['mainAxisSize'] == 'max' ? MainAxisSize.max : MainAxisSize.min,
          children: comp.children.map((c) => buildWidget(context, c, onScreenChangeRequested: onScreenChangeRequested)).toList(),
        );
      }
    }

    BoxBorder? border;
    if (styles.borderColor != null) {
      border = Border.all(
        color: styles.borderColor!,
        width: styles.borderWidth ?? 1.0,
      );
    }

    final borderRadius = styles.borderRadius != null ? BorderRadius.circular(styles.borderRadius!) : null;

    Widget container = Container(
      width: styles.width,
      height: styles.height,
      margin: styles.margin,
      padding: styles.padding,
      decoration: BoxDecoration(
        color: styles.backgroundColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: props['elevation'] != null
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: (props['elevation'] as num).toDouble(),
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: childWidget,
    );

    if (comp.action != null) {
      container = InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Card tapped'),
        borderRadius: borderRadius,
        child: container,
      );
    }

    return container;
  }

  // 2. Column Primitive
  static Widget _buildColumn(
    BuildContext context,
    SDUIComponent comp,
    VoidCallback? onScreenChangeRequested,
  ) {
    final props = comp.props;
    final spacing = (props['spacing'] as num?)?.toDouble() ?? 0.0;
    final children = <Widget>[];

    for (int i = 0; i < comp.children.length; i++) {
      if (i > 0 && spacing > 0) {
        children.add(SizedBox(height: spacing));
      }
      children.add(buildWidget(context, comp.children[i], onScreenChangeRequested: onScreenChangeRequested));
    }

    Widget col = Column(
      mainAxisAlignment: _parseMainAxisAlignment(props['mainAxisAlignment']),
      crossAxisAlignment: _parseCrossAxisAlignment(props['crossAxisAlignment'] ?? 'start'),
      mainAxisSize: props['mainAxisSize'] == 'max' ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );

    if (comp.styles.margin != null || comp.styles.padding != null) {
      col = Container(
        margin: comp.styles.margin,
        padding: comp.styles.padding,
        child: col,
      );
    }

    return col;
  }

  // 3. Row Primitive
  static Widget _buildRow(
    BuildContext context,
    SDUIComponent comp,
    VoidCallback? onScreenChangeRequested,
  ) {
    final props = comp.props;
    final spacing = (props['spacing'] as num?)?.toDouble() ?? 0.0;
    final children = <Widget>[];

    for (int i = 0; i < comp.children.length; i++) {
      if (i > 0 && spacing > 0) {
        children.add(SizedBox(width: spacing));
      }
      final childComp = comp.children[i];
      Widget item = buildWidget(context, childComp, onScreenChangeRequested: onScreenChangeRequested);
      if (childComp.props['expanded'] == true || childComp.props['flex'] != null) {
        item = Expanded(
          flex: childComp.props['flex'] is int ? childComp.props['flex'] as int : 1,
          child: item,
        );
      }
      children.add(item);
    }

    Widget row = Row(
      mainAxisAlignment: _parseMainAxisAlignment(props['mainAxisAlignment'] ?? 'spaceBetween'),
      crossAxisAlignment: _parseCrossAxisAlignment(props['crossAxisAlignment'] ?? 'center'),
      mainAxisSize: props['mainAxisSize'] == 'min' ? MainAxisSize.min : MainAxisSize.max,
      children: children,
    );

    if (comp.styles.margin != null || comp.styles.padding != null) {
      row = Container(
        margin: comp.styles.margin,
        padding: comp.styles.padding,
        child: row,
      );
    }

    return row;
  }

  // 4. Stack Primitive (Absolute / Overlapping Layout)
  static Widget _buildStack(
    BuildContext context,
    SDUIComponent comp,
    VoidCallback? onScreenChangeRequested,
  ) {
    final props = comp.props;
    final stackChildren = <Widget>[];

    for (final child in comp.children) {
      final pos = child.props['position'] as Map<String, dynamic>?;
      final childWidget = buildWidget(context, child, onScreenChangeRequested: onScreenChangeRequested);

      if (pos != null) {
        stackChildren.add(
          Positioned(
            top: pos['top'] != null ? (pos['top'] as num).toDouble() : null,
            bottom: pos['bottom'] != null ? (pos['bottom'] as num).toDouble() : null,
            left: pos['left'] != null ? (pos['left'] as num).toDouble() : null,
            right: pos['right'] != null ? (pos['right'] as num).toDouble() : null,
            child: childWidget,
          ),
        );
      } else {
        stackChildren.add(childWidget);
      }
    }

    Widget stack = Stack(
      clipBehavior: Clip.antiAlias,
      alignment: _parseAlignment(props['alignment']),
      children: stackChildren,
    );

    if (comp.styles.borderRadius != null) {
      stack = ClipRRect(
        borderRadius: BorderRadius.circular(comp.styles.borderRadius!),
        child: stack,
      );
    }

    if (comp.styles.margin != null || comp.styles.padding != null) {
      stack = Container(
        margin: comp.styles.margin,
        padding: comp.styles.padding,
        child: stack,
      );
    }

    return stack;
  }

  // 5. Image Primitive (with fit, aspect ratio & optional bottom gradient overlay)
  static Widget _buildImage(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final styles = comp.styles;
    final url = props['url']?.toString() ?? props['imageUrl']?.toString() ?? '';
    final width = styles.width ?? (props['width'] as num?)?.toDouble();
    final height = styles.height ?? (props['height'] as num?)?.toDouble();
    final fitStr = props['fit']?.toString() ?? 'cover';
    final borderRadius = styles.borderRadius ?? (props['borderRadius'] as num?)?.toDouble();

    BoxFit fit;
    switch (fitStr) {
      case 'contain':
        fit = BoxFit.contain;
        break;
      case 'fill':
        fit = BoxFit.fill;
        break;
      case 'fitWidth':
        fit = BoxFit.fitWidth;
        break;
      case 'fitHeight':
        fit = BoxFit.fitHeight;
        break;
      default:
        fit = BoxFit.cover;
    }

    Widget imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (ctx, err, stack) => Container(
        width: width ?? double.infinity,
        height: height ?? 160,
        color: const Color(0xFF1E293B),
        child: const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 36),
      ),
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width ?? double.infinity,
          height: height ?? 160,
          color: const Color(0xFF1E293B),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
            ),
          ),
        );
      },
    );

    // Optional gradient overlay
    final gradientOverlay = props['gradientOverlay'] as Map<String, dynamic>?;
    if (gradientOverlay != null) {
      final rawColors = gradientOverlay['colors'] as List<dynamic>? ?? ['#00000000', '#CC000000'];
      final colors = rawColors.map((c) => parseHexColor(c.toString())).toList();
      imageWidget = Stack(
        children: [
          imageWidget,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    if (styles.margin != null) {
      imageWidget = Padding(
        padding: styles.margin!,
        child: imageWidget,
      );
    }

    if (comp.action != null) {
      imageWidget = InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Image tapped'),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // 6. Text Primitive
  static Widget _buildText(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final text = props['text']?.toString() ?? props['content']?.toString() ?? '';
    final fontSize = (props['fontSize'] as num?)?.toDouble() ?? 14.0;
    final fontWeight = _parseFontWeight(props['fontWeight']);
    final color = parseHexColor(props['color'] ?? comp.styles.textColor, fallback: Colors.black87);
    final maxLines = props['maxLines'] as int?;
    final overflow = props['overflow'] == 'clip' ? TextOverflow.clip : TextOverflow.ellipsis;

    TextDecoration? decoration;
    if (props['decoration'] == 'lineThrough') {
      decoration = TextDecoration.lineThrough;
    } else if (props['decoration'] == 'underline') {
      decoration = TextDecoration.underline;
    }

    TextAlign textAlign = TextAlign.start;
    if (props['textAlign'] == 'center') {
      textAlign = TextAlign.center;
    } else if (props['textAlign'] == 'right' || props['textAlign'] == 'end') {
      textAlign = TextAlign.end;
    }

    Widget textWidget = Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? overflow : null,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
      ),
    );

    if (comp.styles.margin != null || comp.styles.padding != null) {
      textWidget = Container(
        margin: comp.styles.margin,
        padding: comp.styles.padding,
        child: textWidget,
      );
    }

    if (comp.action != null) {
      textWidget = GestureDetector(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: text),
        child: textWidget,
      );
    }

    return textWidget;
  }

  // 7. Badge / Pill Primitive
  static Widget _buildBadge(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final text = props['text']?.toString() ?? '';
    final iconName = props['icon']?.toString();
    final bgColor = parseHexColor(comp.styles.backgroundColor ?? props['backgroundColor'], fallback: const Color(0xFF10B981));
    final textColor = parseHexColor(comp.styles.textColor ?? props['textColor'], fallback: Colors.white);
    final iconColor = parseHexColor(props['iconColor'], fallback: textColor);
    final borderRadius = (comp.styles.borderRadius ?? (props['borderRadius'] as num?)?.toDouble()) ?? 12.0;
    final padding = comp.styles.padding ?? parseEdgeInsets(props['padding'], fallback: const EdgeInsets.symmetric(horizontal: 8, vertical: 4));
    final fontSize = (props['fontSize'] as num?)?.toDouble() ?? 12.0;

    Widget badge = Container(
      margin: comp.styles.margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconName != null && iconName.isNotEmpty) ...[
            Icon(_getMaterialIcon(iconName), size: fontSize + 2, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: _parseFontWeight(props['fontWeight'] ?? 'bold'),
            ),
          ),
        ],
      ),
    );

    if (comp.action != null) {
      badge = InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: text),
        borderRadius: BorderRadius.circular(borderRadius),
        child: badge,
      );
    }

    return badge;
  }

  // 8. Icon Primitive
  static Widget _buildIcon(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final name = props['name']?.toString() ?? 'widgets';
    final size = (props['size'] as num?)?.toDouble() ?? 20.0;
    final color = parseHexColor(props['color'] ?? comp.styles.textColor, fallback: Colors.white);

    Widget iconWidget = Icon(
      _getMaterialIcon(name),
      size: size,
      color: color,
    );

    if (comp.styles.margin != null || comp.styles.padding != null) {
      iconWidget = Container(
        margin: comp.styles.margin,
        padding: comp.styles.padding,
        child: iconWidget,
      );
    }

    if (comp.action != null) {
      iconWidget = GestureDetector(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Icon tapped'),
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  // 9. Divider Primitive
  static Widget _buildDivider(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final dashed = props['dashed'] == true;
    final color = parseHexColor(props['color'] ?? comp.styles.borderColor, fallback: const Color(0xFFCBD5E1));
    final thickness = (props['thickness'] as num?)?.toDouble() ?? 1.0;

    Widget div;
    if (dashed) {
      div = DashedDivider(
        height: thickness,
        color: color,
        dashWidth: (props['dashWidth'] as num?)?.toDouble() ?? 4.0,
        dashSpace: (props['dashSpace'] as num?)?.toDouble() ?? 3.0,
      );
    } else {
      div = Divider(
        color: color,
        thickness: thickness,
        height: thickness,
        indent: (props['indent'] as num?)?.toDouble(),
        endIndent: (props['endIndent'] as num?)?.toDouble(),
      );
    }

    if (comp.styles.margin != null) {
      div = Padding(
        padding: comp.styles.margin!,
        child: div,
      );
    }

    return div;
  }

  // 10. Button Primitive
  static Widget _buildButton(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final text = props['text']?.toString() ?? 'Button';
    final iconName = props['icon']?.toString();
    final bgColor = parseHexColor(comp.styles.backgroundColor, fallback: const Color(0xFF6366F1));
    final textColor = parseHexColor(comp.styles.textColor, fallback: Colors.white);
    final borderRadius = (comp.styles.borderRadius ?? 8.0);
    final variant = props['variant']?.toString() ?? 'filled';

    Widget btn;
    if (variant == 'outline') {
      btn = OutlinedButton(
        onPressed: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: text),
        style: OutlinedButton.styleFrom(
          foregroundColor: bgColor,
          side: BorderSide(color: bgColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: (comp.styles.padding as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null) ...[
              Icon(_getMaterialIcon(iconName), size: 16),
              const SizedBox(width: 6),
            ],
            Text(text, style: TextStyle(fontWeight: _parseFontWeight(props['fontWeight'] ?? 'bold'))),
          ],
        ),
      );
    } else {
      btn = ElevatedButton(
        onPressed: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: text),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: (comp.styles.padding as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconName != null) ...[
              Icon(_getMaterialIcon(iconName), size: 16),
              const SizedBox(width: 6),
            ],
            Text(text, style: TextStyle(fontWeight: _parseFontWeight(props['fontWeight'] ?? 'bold'))),
          ],
        ),
      );
    }

    if (comp.styles.margin != null) {
      btn = Padding(padding: comp.styles.margin!, child: btn);
    }

    return btn;
  }

  // Pre-existing templates (preserved exact functionality)
  static Widget _buildSearchBar(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final placeholder = props['placeholder']?.toString() ?? 'Search...';
    final showFilter = props['showFilter'] == true;

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Search focused'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  placeholder,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showFilter)
                GestureDetector(
                  onTap: () => SDUIActionHandler.handleAction(
                    context,
                    comp.action,
                    fallbackMessage: 'Filter menu clicked',
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF6366F1), size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBanner(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final badge = props['badge']?.toString();
    final title = props['title']?.toString() ?? '';
    final subtitle = props['subtitle']?.toString() ?? '';
    final ctaText = props['ctaText']?.toString();
    final imageUrl = props['imageUrl']?.toString();

    final bgColor = comp.styles.backgroundColor ?? const Color(0xFF4F46E5);
    final textColor = comp.styles.textColor ?? Colors.white;
    final borderRadius = comp.styles.borderRadius ?? 16.0;

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: title),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            image: imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withAlpha(140),
                      BlendMode.darken,
                    ),
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: bgColor.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null && badge.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withAlpha(200),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
              if (ctaText != null && ctaText.isNotEmpty) ...[
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => SDUIActionHandler.handleAction(
                    context,
                    comp.action,
                    fallbackMessage: 'Claimed: $title',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(ctaText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCategoryChips(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final items = (props['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final selectedIdx = props['selectedIndex'] as int? ?? 0;

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (ctx, idx) {
            final isSelected = idx == selectedIdx;
            return InkWell(
              onTap: () {
                SDUIActionHandler.handleAction(
                  context,
                  comp.action,
                  fallbackMessage: 'Selected: ${items[idx]}',
                );
              },
              borderRadius: BorderRadius.circular(19),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withAlpha(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    items[idx],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildSectionTitle(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final title = props['title']?.toString() ?? '';
    final subtitle = props['subtitle']?.toString();
    final actionText = props['actionText']?.toString();

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && actionText.isNotEmpty)
            GestureDetector(
              onTap: () => SDUIActionHandler.handleAction(
                context,
                comp.action,
                fallbackMessage: 'View all clicked',
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildServiceGrid(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final columns = props['columns'] as int? ?? 4;
    final items = (props['items'] as List<dynamic>?) ?? [];

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (ctx, idx) {
          final item = items[idx] as Map<String, dynamic>;
          final title = item['title']?.toString() ?? '';
          final icon = item['icon']?.toString() ?? 'build';
          final badge = item['badge']?.toString();
          final actionJson = item['action'] as Map<String, dynamic>?;
          final action = actionJson != null ? SDUIAction.fromJson(actionJson) : comp.action;

          return InkWell(
            onTap: () => SDUIActionHandler.handleAction(context, action, fallbackMessage: title),
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(15)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getMaterialIcon(icon), color: const Color(0xFF818CF8), size: 22),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (badge != null && badge.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildPromoCard(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final title = props['title']?.toString() ?? 'Promo Voucher';
    final discount = props['discount']?.toString() ?? '';
    final code = props['code']?.toString();
    final description = props['description']?.toString() ?? '';
    final expires = props['expires']?.toString();

    final bgColor = comp.styles.backgroundColor ?? const Color(0xFF059669);
    final textColor = comp.styles.textColor ?? Colors.white;

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: bgColor.withAlpha(50),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  discount,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                if (code != null && code.isNotEmpty)
                  InkWell(
                    onTap: () => SDUIActionHandler.handleAction(
                      context,
                      comp.action,
                      fallbackMessage: 'Copied code $code',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, color: Color(0xFF059669), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            code,
                            style: const TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: textColor.withAlpha(220),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
            if (expires != null && expires.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, color: textColor.withAlpha(180), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    expires,
                    style: TextStyle(
                      color: textColor.withAlpha(180),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildProductCard(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final title = props['title']?.toString() ?? 'Product';
    final description = props['description']?.toString() ?? '';
    final price = props['price']?.toString() ?? r'\$0.00';
    final originalPrice = props['originalPrice']?.toString();
    final rating = props['rating']?.toString();
    final reviews = props['reviews']?.toString();
    final tag = props['tag']?.toString();
    final imageUrl = props['imageUrl']?.toString();

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Selected: $title'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 150,
                          color: const Color(0xFF334155),
                          child: const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                        ),
                      ),
                      if (tag != null && tag.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (rating != null) ...[
                          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        if (reviews != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            reviews,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (originalPrice != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                originalPrice,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => SDUIActionHandler.handleAction(
                            context,
                            comp.action,
                            fallbackMessage: 'Added to cart: $title',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildCarousel(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final items = (props['items'] as List<dynamic>?) ?? [];

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (ctx, idx) {
            final item = items[idx] as Map<String, dynamic>;
            final itemTitle = item['title']?.toString() ?? '';
            final itemSubtitle = item['subtitle']?.toString() ?? '';
            final imageUrl = item['imageUrl']?.toString();
            final actionJson = item['action'] as Map<String, dynamic>?;
            final action = actionJson != null ? SDUIAction.fromJson(actionJson) : comp.action;

            return InkWell(
              onTap: () => SDUIActionHandler.handleAction(context, action, fallbackMessage: itemTitle),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withAlpha(120),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (itemSubtitle.isNotEmpty)
                      Text(
                        itemSubtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildButtonAction(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final text = props['text']?.toString() ?? 'Action Button';
    final bgColor = comp.styles.backgroundColor ?? const Color(0xFF6366F1);

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: text),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static Widget _buildSpacer(SDUIComponent comp) {
    final height = (comp.props['height'] as num?)?.toDouble() ?? 16.0;
    return SizedBox(height: height);
  }

  static Widget _buildUnknownWidget(SDUIComponent comp) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unsupported SDUI Component: "${comp.type}"',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
