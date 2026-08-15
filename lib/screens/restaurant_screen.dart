import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/restaurants_data.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../state/cart_provider.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/menu_item_sheet.dart';
import '../widgets/order_lines.dart';
import '../widgets/toast.dart';

class RestaurantScreen extends StatelessWidget {
  final String id;
  const RestaurantScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final restaurant = restaurantById(id);
    final wide = MediaQuery.of(context).size.width >= 900;
    final cart = context.watch<CartProvider>();
    final mixedKitchens = cart.restaurantIds.isNotEmpty &&
        !(cart.restaurantIds.length == 1 && cart.restaurantIds.contains(restaurant.id));

    return AppShell(
      currentRoute: 'restaurant',
      body: SafeArea(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 12, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Banner(restaurant: restaurant),
                          const SizedBox(height: 20),
                          _MenuList(restaurant: restaurant),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                      child: _OrderPanel(restaurant: restaurant, mixedKitchens: mixedKitchens),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Banner(restaurant: restaurant),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _MenuList(restaurant: restaurant),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: wide || cart.isEmpty
          ? null
          : _MobileOrderBar(restaurant: restaurant, mixedKitchens: mixedKitchens),
    );
  }
}

class _Banner extends StatelessWidget {
  final Restaurant restaurant;
  const _Banner({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: restaurant.color,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: const Text('← All restaurants', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Text(
            '${restaurant.emoji} ${restaurant.name}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 30),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text('★ ${restaurant.rating} (${restaurant.reviews} reviews)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(restaurant.cuisine, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('🕐 ${restaurant.deliveryTime}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('🛵 ${money(restaurant.deliveryFee)} delivery', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuList extends StatefulWidget {
  final Restaurant restaurant;
  const _MenuList({required this.restaurant});

  @override
  State<_MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<_MenuList> {
  final Map<String, GlobalKey> _sectionKeys = {};

  List<String> get _categories {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in widget.restaurant.menu) {
      if (seen.add(item.category)) ordered.add(item.category);
    }
    return ordered;
  }

  bool get _hasPopular => widget.restaurant.menu.any((i) => i.popular);

  void _jumpTo(String section) {
    final key = _sectionKeys[section];
    final ctx = key?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.06);
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final categories = _categories;
    final jumpTargets = [if (_hasPopular) 'Popular', ...categories];
    for (final c in jumpTargets) {
      _sectionKeys.putIfAbsent(c, () => GlobalKey());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.isSupermarket ? 'Products' : 'Menu',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 12),
        if (jumpTargets.length > 1) _CategoryJumpBar(sections: jumpTargets, onSelect: _jumpTo),
        const SizedBox(height: 4),
        if (_hasPopular)
          _MenuSection(
            key: _sectionKeys['Popular'],
            title: '⭐ Popular',
            items: restaurant.menu.where((i) => i.popular).toList(),
            restaurant: restaurant,
          ),
        for (final category in categories)
          _MenuSection(
            key: _sectionKeys[category],
            title: category,
            items: restaurant.menu.where((i) => i.category == category).toList(),
            restaurant: restaurant,
          ),
      ],
    );
  }
}

class _CategoryJumpBar extends StatelessWidget {
  final List<String> sections;
  final ValueChanged<String> onSelect;
  const _CategoryJumpBar({required this.sections, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = sections[i];
          return InkWell(
            onTap: () => onSelect(s),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: zim.line),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<MenuItem> items;
  final Restaurant restaurant;
  const _MenuSection({super.key, required this.title, required this.items, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          ),
          ...items.map((item) => _MenuItemTile(restaurant: restaurant, item: item)),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final Restaurant restaurant;
  final MenuItem item;
  const _MenuItemTile({required this.restaurant, required this.item});

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.r),
      onTap: () => showMenuItemSheet(context, restaurant: restaurant, item: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: zim.line),
          borderRadius: BorderRadius.circular(AppRadius.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: zim.mist, borderRadius: BorderRadius.circular(AppRadius.r)),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(item.desc, style: TextStyle(color: zim.inkSoft, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(money(item.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                context.read<CartProvider>().addItem(restaurantId: restaurant.id, restaurantName: restaurant.name, item: item);
                showZimToast(context, 'Added ${item.name} to your order');
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.forestSoft,
                foregroundColor: AppColors.forest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MixedKitchenWarning extends StatelessWidget {
  const _MixedKitchenWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.marigold.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Text('⚠️ ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              'Your basket has items from another kitchen too — they\'ll arrive as separate deliveries.',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  final Restaurant restaurant;
  final bool mixedKitchens;
  const _OrderPanel({required this.restaurant, required this.mixedKitchens});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final zim = context.zim;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: zim.line),
        borderRadius: BorderRadius.circular(AppRadius.rLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your order', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          if (mixedKitchens) const _MixedKitchenWarning(),
          OrderLines(
            items: cart.items,
            onChangeQty: cart.changeQty,
          ),
          if (cart.items.isNotEmpty) ...[
            const SizedBox(height: 4),
            OrderTotals(subtotal: cart.subtotal, deliveryFee: restaurant.deliveryFee, total: cart.subtotal + restaurant.deliveryFee),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flame,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  elevation: 0,
                ),
                child: const Text('Go to checkout', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileOrderBar extends StatelessWidget {
  final Restaurant restaurant;
  final bool mixedKitchens;
  const _MobileOrderBar({required this.restaurant, required this.mixedKitchens});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return SafeArea(
      child: Material(
        color: AppColors.flame,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => context.go('/checkout'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🧺 ${cart.count} item${cart.count == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(width: 14),
                Text('Checkout · ${money(cart.subtotal + restaurant.deliveryFee)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
