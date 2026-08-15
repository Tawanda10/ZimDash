import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../state/cart_provider.dart';
import '../theme.dart';

/// Opens a DoorDash-style item detail sheet where the customer sets a
/// quantity and optional special instructions before adding to cart.
Future<void> showMenuItemSheet(BuildContext context, {required Restaurant restaurant, required MenuItem item}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MenuItemSheet(restaurant: restaurant, item: item),
  );
}

class _MenuItemSheet extends StatefulWidget {
  final Restaurant restaurant;
  final MenuItem item;
  const _MenuItemSheet({required this.restaurant, required this.item});

  @override
  State<_MenuItemSheet> createState() => _MenuItemSheetState();
}

class _MenuItemSheetState extends State<_MenuItemSheet> {
  int _qty = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    final item = widget.item;
    final total = item.price * _qty;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.rLg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: zim.line, borderRadius: BorderRadius.circular(999))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(color: zim.mist, borderRadius: BorderRadius.circular(AppRadius.rLg)),
                        alignment: Alignment.center,
                        child: Text(item.emoji, style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(item.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 6),
                    Text(item.desc, style: TextStyle(color: zim.inkSoft, fontSize: 14, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(money(item.price), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 20),
                    Text('Special instructions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. no onions, extra sauce…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  _StepperButton(icon: Icons.remove_rounded, onTap: _qty > 1 ? () => setState(() => _qty--) : null),
                  SizedBox(
                    width: 40,
                    child: Text('$_qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  _StepperButton(icon: Icons.add_rounded, onTap: () => setState(() => _qty++)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartProvider>().addItem(
                              restaurantId: widget.restaurant.id,
                              restaurantName: widget.restaurant.name,
                              item: item,
                              qty: _qty,
                              notes: _notesController.text,
                            );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.flame,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: Text('Add to order · ${money(total)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: zim.line, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: disabled ? zim.inkSoft.withValues(alpha: 0.4) : null),
        ),
      ),
    );
  }
}
