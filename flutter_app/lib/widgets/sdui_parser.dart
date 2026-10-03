import 'package:flutter/material.dart';
import '../models/sdui_models.dart';
import 'sdui_action_handler.dart';

class SDUIParser {
  /// Routes component to corresponding Flutter widget
  static Widget buildWidget(
    BuildContext context,
    SDUIComponent component, {
    VoidCallback? onScreenChangeRequested,
  }) {
    switch (component.type) {
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

  // 1. Search Bar Widget
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
                    fallbackMessage: 'Search filters opened',
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF818CF8), size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Banner Widget
  static Widget _buildBanner(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final styles = comp.styles;
    final title = props['title']?.toString() ?? '';
    final subtitle = props['subtitle']?.toString() ?? '';
    final badge = props['badge']?.toString();
    final ctaText = props['ctaText']?.toString();
    final imageUrl = props['imageUrl']?.toString();

    final bgColor = styles.backgroundColor ?? const Color(0xFF4F46E5);
    final borderRadius = styles.borderRadius ?? 16.0;

    return Padding(
      padding: (styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: title),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: bgColor.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
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
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null && badge.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withAlpha(80)),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              if (ctaText != null && ctaText.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ctaText,
                    style: TextStyle(
                      color: bgColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 3. Category Chips Widget
  static Widget _buildCategoryChips(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final items = (props['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final selectedIndex = (props['selectedIndex'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (ctx, index) {
            final isSelected = index == selectedIndex;
            return InkWell(
              onTap: () {
                SDUIActionHandler.handleAction(
                  context,
                  comp.action,
                  fallbackMessage: 'Selected: ${items[index]}',
                );
              },
              borderRadius: BorderRadius.circular(19),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.white.withAlpha(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    items[index],
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

  // 4. Section Title Widget
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && actionText.isNotEmpty)
            GestureDetector(
              onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: actionText),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Color(0xFF818CF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 5. Service Grid Widget
  static Widget _buildServiceGrid(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final columns = (props['columns'] as num?)?.toInt() ?? 4;
    final items = (props['items'] as List<dynamic>?) ?? [];

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, idx) {
          final item = items[idx] as Map<String, dynamic>;
          final itemTitle = item['title']?.toString() ?? '';
          final itemIcon = item['icon']?.toString() ?? 'star';
          final badge = item['badge']?.toString();
          final actionJson = item['action'] as Map<String, dynamic>?;
          final action = actionJson != null ? SDUIAction.fromJson(actionJson) : comp.action;

          return InkWell(
            onTap: () => SDUIActionHandler.handleAction(context, action, fallbackMessage: itemTitle),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getMaterialIcon(itemIcon), color: const Color(0xFF818CF8), size: 26),
                        const SizedBox(height: 8),
                        Text(
                          itemTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (badge != null && badge.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 6. Promo Card Widget
  static Widget _buildPromoCard(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final styles = comp.styles;
    final title = props['title']?.toString() ?? 'Promo Voucher';
    final discount = props['discount']?.toString() ?? 'DISCOUNT';
    final code = props['code']?.toString() ?? 'CODE';
    final description = props['description']?.toString() ?? '';
    final expires = props['expires']?.toString();

    final bgColor = styles.backgroundColor ?? const Color(0xFF059669);

    return Padding(
      padding: (styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(
          context,
          comp.action,
          fallbackMessage: 'Coupon code $code copied!',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(60), style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (expires != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '⏳ $expires',
                        style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.content_copy_rounded, color: Color(0xFF065F46), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      code,
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

  // 7. Product Card Widget
  static Widget _buildProductCard(BuildContext context, SDUIComponent comp) {
    final props = comp.props;
    final title = props['title']?.toString() ?? '';
    final description = props['description']?.toString() ?? '';
    final price = props['price']?.toString() ?? '';
    final originalPrice = props['originalPrice']?.toString();
    final rating = props['rating']?.toString() ?? '5.0 ★';
    final reviews = props['reviews']?.toString() ?? '';
    final tag = props['tag']?.toString();
    final imageUrl = props['imageUrl']?.toString();

    return Padding(
      padding: (comp.styles.margin as EdgeInsets?) ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => SDUIActionHandler.handleAction(context, comp.action, fallbackMessage: 'Product: $title'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 150,
                        color: const Color(0xFF334155),
                        child: const Center(child: Icon(Icons.image, color: Colors.white54)),
                      ),
                    ),
                    if (tag != null && tag.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          rating,
                          style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        if (reviews.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(reviews, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
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

  // 8. Carousel Widget
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
                        style: TextStyle(
                          color: Colors.white,
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

  // 9. Button Action Widget
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

  // 10. Spacer Widget
  static Widget _buildSpacer(SDUIComponent comp) {
    final height = (comp.props['height'] as num?)?.toDouble() ?? 16.0;
    return SizedBox(height: height);
  }

  // 11. Unknown Widget Fallback
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

  static IconData _getMaterialIcon(String name) {
    switch (name) {
      case 'build':
        return Icons.build_rounded;
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}
