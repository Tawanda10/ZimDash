import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../state/cart_provider.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/toast.dart';

/// Order history — DoorDash's "Orders" tab. Lets you glance at past orders
/// and reorder with one tap.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = cart.orders;

    return AppShell(
      currentRoute: 'orders',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your orders', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28)),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  _EmptyOrders(context: context)
                else
                  ...orders.map((o) => _OrderCard(order: o)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final BuildContext context;
  const _EmptyOrders({required this.context});

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(border: Border.all(color: context.zim.line), borderRadius: BorderRadius.circular(AppRadius.rLg)),
      child: Column(
        children: [
          const Text('🧾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text("You haven't ordered yet.", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text('Your past orders will show up here.', style: TextStyle(color: context.zim.inkSoft, fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.flame,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              elevation: 0,
            ),
            child: const Text('Browse restaurants', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PlacedOrder order;
  const _OrderCard({required this.order});

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day} · $hh:$mm $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: zim.line), borderRadius: BorderRadius.circular(AppRadius.rLg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurantNames.join(' + '), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(_formatDate(order.placedAt), style: TextStyle(color: zim.inkSoft, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(999)),
                child: const Text('Delivered', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.items.map((i) => '${i.qty}× ${i.name}').join(', '),
            style: TextStyle(color: zim.inkSoft, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(money(order.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  context.read<CartProvider>().reorder(order);
                  showZimToast(context, 'Added ${order.itemCount} item${order.itemCount == 1 ? '' : 's'} to your cart');
                  context.go('/checkout');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  side: const BorderSide(color: AppColors.forest),
                  foregroundColor: AppColors.forest,
                ),
                child: const Text('Reorder', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
