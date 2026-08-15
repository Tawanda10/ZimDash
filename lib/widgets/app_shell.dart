import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../state/cart_provider.dart';
import '../theme.dart';

/// Shared header (logo, nav links, cart badge) + footer wrapper used by
/// every screen, mirroring `site-header` / `site-footer` in the original
/// single-page app. Collapses nav into a drawer on narrow screens.
class AppShell extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 720;
    final cart = context.watch<CartProvider>();
    final app = context.watch<AppState>();

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        titleSpacing: 16,
        title: _Logo(onTap: () => context.go('/')),
        actions: wide
            ? [
                _NavLink(label: 'Restaurants', selected: currentRoute == 'home', onTap: () => context.go('/')),
                _NavLink(label: 'Track order', selected: currentRoute == 'tracking', onTap: () => context.go('/tracking')),
                _NavLink(label: 'Orders', selected: currentRoute == 'orders', onTap: () => context.go('/orders')),
                _NavLink(
                  label: app.user != null ? '👤 ${app.user!.name.split(' ').first}' : 'Sign in',
                  selected: currentRoute == 'login',
                  onTap: () => context.go('/login'),
                ),
                const SizedBox(width: 8),
                _ThemeToggle(),
                const SizedBox(width: 8),
                _CartPill(count: cart.count, onTap: () => context.go('/checkout')),
                const SizedBox(width: 16),
              ]
            : [
                _ThemeToggle(),
                _CartIconBadge(count: cart.count, onTap: () => context.go('/checkout')),
                const SizedBox(width: 4),
              ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _Logo(),
                    ),
                    _DrawerLink(icon: Icons.storefront_rounded, label: 'Restaurants', onTap: () => context.go('/')),
                    _DrawerLink(icon: Icons.pedal_bike_rounded, label: 'Track order', onTap: () => context.go('/tracking')),
                    _DrawerLink(icon: Icons.receipt_long_rounded, label: 'Orders', onTap: () => context.go('/orders')),
                    _DrawerLink(
                      icon: Icons.person_rounded,
                      label: app.user != null ? app.user!.name : 'Sign in',
                      onTap: () => context.go('/login'),
                    ),
                    _DrawerLink(icon: Icons.shopping_basket_rounded, label: 'Cart (${cart.count})', onTap: () => context.go('/checkout')),
                  ],
                ),
              ),
            ),
      body: body,
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback? onTap;
  const _Logo({this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, letterSpacing: -0.5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛵 ', style: TextStyle(fontSize: 20)),
          Text('ZimDash', style: style),
          Text('.', style: style?.copyWith(color: AppColors.flame)),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ink = context.zim.ink;
    final inkSoft = context.zim.inkSoft;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: selected ? ink : inkSoft),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.of(context).maybePop();
        onTap();
      },
    );
  }
}

class _CartPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartPill({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ink = context.zim.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧺 Cart', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            _Badge(count: count),
          ],
        ),
      ),
    );
  }
}

class _CartIconBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartIconBadge({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(onPressed: onTap, icon: const Icon(Icons.shopping_basket_rounded)),
        if (count > 0)
          Positioned(
            right: 4,
            top: 6,
            child: IgnorePointer(child: _Badge(count: count)),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: count == 0 ? context.zim.inkSoft : AppColors.flame,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Lets the customer pick Light, Dark, or System appearance — rather than
/// just toggling blindly between two states.
class _ThemeToggle extends StatelessWidget {
  static const _options = [
    (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
    (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
    (ThemeMode.system, Icons.brightness_auto_rounded, 'System'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final current = _options.firstWhere((o) => o.$1 == app.themeMode, orElse: () => _options.last);

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Appearance',
      initialValue: app.themeMode,
      onSelected: app.setThemeMode,
      icon: Icon(current.$2),
      itemBuilder: (context) => [
        for (final o in _options)
          PopupMenuItem(
            value: o.$1,
            child: Row(
              children: [
                Icon(o.$2, size: 18, color: o.$1 == app.themeMode ? AppColors.forest : null),
                const SizedBox(width: 10),
                Text(o.$3, style: TextStyle(fontWeight: o.$1 == app.themeMode ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }
}
