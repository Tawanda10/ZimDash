import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../theme.dart';

/// Renders the list of cart lines with qty +/- controls, shared by the
/// restaurant order panel and the checkout summary.
class OrderLines extends StatelessWidget {
  final List<CartItem> items;
  final void Function(CartItem item, int delta) onChangeQty;
  final bool showPrice;

  const OrderLines({super.key, required this.items, required this.onChangeQty, this.showPrice = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('🧺 Your basket is empty.', style: TextStyle(color: context.zim.inkSoft), textAlign: TextAlign.center),
        ),
      );
    }
    return Column(
      children: items
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                              children: [
                                TextSpan(text: '${c.emoji} ${c.name}'),
                                if (showPrice) TextSpan(text: ' · ${money(c.price)}', style: TextStyle(color: context.zim.inkSoft)),
                              ],
                            ),
                          ),
                          if (c.notes != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '📝 ${c.notes}',
                                style: TextStyle(color: context.zim.inkSoft, fontSize: 12, fontStyle: FontStyle.italic),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _QtyControl(qty: c.qty, onMinus: () => onChangeQty(c, -1), onPlus: () => onChangeQty(c, 1)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _QtyControl({required this.qty, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(icon: Icons.remove_rounded, onTap: onMinus),
        SizedBox(width: 24, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
        _QtyButton(icon: Icons.add_rounded, onTap: onPlus),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(side: BorderSide(color: context.zim.line, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 28, height: 28, child: Icon(icon, size: 15)),
      ),
    );
  }
}

class OrderTotals extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double? serviceFee;
  final double? tip;
  final double? discount;
  final String? promoCode;
  final double total;

  const OrderTotals({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.serviceFee,
    this.tip,
    this.discount,
    this.promoCode,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final inkSoft = context.zim.inkSoft;
    TextStyle rowStyle = const TextStyle(fontSize: 14);
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.zim.line, width: 1.5))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Subtotal', style: rowStyle.copyWith(color: inkSoft)),
            Text(money(subtotal), style: rowStyle),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Delivery', style: rowStyle.copyWith(color: inkSoft)),
            Text(money(deliveryFee), style: rowStyle),
          ]),
          if (serviceFee != null) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Service fee', style: rowStyle.copyWith(color: inkSoft)),
              Text(money(serviceFee!), style: rowStyle),
            ]),
          ],
          if (tip != null && tip! > 0) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Rider tip', style: rowStyle.copyWith(color: inkSoft)),
              Text(money(tip!), style: rowStyle),
            ]),
          ],
          if (discount != null && discount! > 0) ...[
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(promoCode != null ? 'Promo · $promoCode' : 'Discount', style: rowStyle.copyWith(color: inkSoft)),
              Text('-${money(discount!)}', style: rowStyle.copyWith(color: AppColors.forest, fontWeight: FontWeight.w700)),
            ]),
          ],
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            Text(money(total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ]),
        ],
      ),
    );
  }
}
