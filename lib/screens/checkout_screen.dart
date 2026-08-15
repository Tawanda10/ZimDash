import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/restaurants_data.dart';
import '../state/cart_provider.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/order_lines.dart';
import '../widgets/toast.dart';

const _suburbs = ['Avondale', 'Borrowdale', 'Mount Pleasant', 'Belvedere', 'Greendale', 'CBD'];

enum PayMethod { ecocash, card, cash }

extension on PayMethod {
  String get label => switch (this) {
        PayMethod.ecocash => 'EcoCash',
        PayMethod.card => 'Card',
        PayMethod.cash => 'Cash on delivery',
      };
}

/// Preset tip percentages shown as quick-select chips, DoorDash-style.
const _tipPercents = [0.0, 0.10, 0.15, 0.20];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _promoController = TextEditingController();
  String _suburb = _suburbs.first;
  PayMethod _pay = PayMethod.ecocash;

  double? _tipPercent = 0.15;
  final _customTipController = TextEditingController();
  bool _customTip = false;

  PromoCode? _appliedPromo;
  String? _promoError;

  bool _nameError = false;
  bool _phoneError = false;
  bool _addressError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _promoController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  double _tipAmount(double subtotal) {
    if (_customTip) return double.tryParse(_customTipController.text) ?? 0;
    return subtotal * (_tipPercent ?? 0);
  }

  double _discountAmount(double subtotal) => _appliedPromo?.discountFor(subtotal) ?? 0;

  void _applyPromo(double subtotal) {
    final promo = findPromoCode(_promoController.text);
    if (promo == null) {
      setState(() {
        _appliedPromo = null;
        _promoError = 'That code isn\'t valid.';
      });
      return;
    }
    if (subtotal < promo.minSubtotal) {
      setState(() {
        _appliedPromo = null;
        _promoError = 'Spend ${money(promo.minSubtotal)} or more to use this code.';
      });
      return;
    }
    setState(() {
      _appliedPromo = promo;
      _promoError = null;
    });
    showZimToast(context, 'Promo applied — ${promo.description}');
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _phoneError = _phoneController.text.trim().isEmpty;
      _addressError = _addressController.text.trim().isEmpty;
    });
    return !_nameError && !_phoneError && !_addressError;
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (cart.isEmpty) return;
    if (!_validate()) {
      showZimToast(context, 'Please fill in the highlighted fields');
      return;
    }
    await cart.placeOrder(
      name: _nameController.text.trim(),
      suburb: _suburb,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      payMethod: _pay.label,
      promoCode: _appliedPromo?.code,
      tip: _tipAmount(cart.subtotal),
      discount: _discountAmount(cart.subtotal),
    );
    if (!mounted) return;
    context.go('/tracking');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final wide = MediaQuery.of(context).size.width >= 900;

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          step: '1',
          title: 'Delivery details',
          child: _DeliveryForm(
            nameController: _nameController,
            phoneController: _phoneController,
            addressController: _addressController,
            notesController: _notesController,
            suburb: _suburb,
            onSuburbChanged: (v) => setState(() => _suburb = v!),
            nameError: _nameError,
            phoneError: _phoneError,
            addressError: _addressError,
            onFieldChanged: () => setState(() {
              _nameError = false;
              _phoneError = false;
              _addressError = false;
            }),
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          step: '2',
          title: 'Payment method',
          child: _PaymentOptions(value: _pay, onChanged: (v) => setState(() => _pay = v!)),
        ),
        const SizedBox(height: 16),
        _Panel(
          step: '3',
          title: 'Tip your rider',
          child: _TipSelector(
            percent: _tipPercent,
            custom: _customTip,
            customController: _customTipController,
            onPercentSelected: (p) => setState(() {
              _tipPercent = p;
              _customTip = false;
            }),
            onCustomSelected: () => setState(() => _customTip = true),
            onCustomChanged: () => setState(() {}),
          ),
        ),
      ],
    );

    final tipAmount = _tipAmount(cart.subtotal);
    final discountAmount = _discountAmount(cart.subtotal);
    final grandTotal = (cart.total + tipAmount - discountAmount).clamp(0, double.infinity);

    final rightColumn = _Panel(
      step: '4',
      title: 'Your order',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MiniMap(),
          const SizedBox(height: 14),
          OrderLines(
            items: cart.items,
            showPrice: true,
            onChangeQty: cart.changeQty,
          ),
          if (cart.items.isEmpty) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => context.go('/'),
              child: const Text('Browse restaurants →', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700)),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _PromoField(
              controller: _promoController,
              applied: _appliedPromo,
              error: _promoError,
              onApply: () => _applyPromo(cart.subtotal),
              onRemove: () => setState(() {
                _appliedPromo = null;
                _promoController.clear();
                _promoError = null;
              }),
            ),
            const SizedBox(height: 6),
            OrderTotals(
              subtotal: cart.subtotal,
              deliveryFee: cart.deliveryFeeTotal,
              serviceFee: CartProvider.serviceFee,
              tip: tipAmount,
              discount: discountAmount,
              promoCode: _appliedPromo?.code,
              total: grandTotal.toDouble(),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cart.isEmpty ? null : () => _placeOrder(cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.flame,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.flame.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                elevation: 0,
              ),
              child: const Text('Place order', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide(color: context.zim.line),
                foregroundColor: context.zim.ink,
              ),
              child: const Text('← Keep browsing', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );

    return AppShell(
      currentRoute: 'checkout',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checkout', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28)),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: leftColumn),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: rightColumn),
                  ],
                )
              else
                Column(children: [leftColumn, const SizedBox(height: 16), rightColumn]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String step;
  final String title;
  final Widget child;
  const _Panel({required this.step, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: context.zim.line),
        borderRadius: BorderRadius.circular(AppRadius.rLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(color: AppColors.marigold, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(step, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final String suburb;
  final ValueChanged<String?> onSuburbChanged;
  final bool nameError;
  final bool phoneError;
  final bool addressError;
  final VoidCallback onFieldChanged;

  const _DeliveryForm({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.notesController,
    required this.suburb,
    required this.onSuburbChanged,
    required this.nameError,
    required this.phoneError,
    required this.addressError,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 560;
    InputDecoration deco(String label, {String? error}) => InputDecoration(
          labelText: label,
          errorText: error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.zim.line, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.zim.line, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.flame, width: 1.5)),
        );

    final nameField = TextField(
      controller: nameController,
      onChanged: (_) => onFieldChanged(),
      decoration: deco('Full name', error: nameError ? 'Please enter your name.' : null),
    );
    final phoneField = TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      onChanged: (_) => onFieldChanged(),
      decoration: deco('Phone', error: phoneError ? 'Please enter a phone number.' : null),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: nameField), const SizedBox(width: 14), Expanded(child: phoneField)],
          )
        else
          Column(children: [nameField, const SizedBox(height: 14), phoneField]),
        const SizedBox(height: 14),
        TextField(
          controller: addressController,
          onChanged: (_) => onFieldChanged(),
          decoration: deco('Street address', error: addressError ? 'Please enter your address.' : null),
        ),
        const SizedBox(height: 14),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: suburb,
                  decoration: deco('Suburb'),
                  items: _suburbs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: onSuburbChanged,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: notesController,
                  decoration: deco('Delivery notes (optional)'),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: suburb,
                isExpanded: true,
                decoration: deco('Suburb'),
                items: _suburbs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: onSuburbChanged,
              ),
              const SizedBox(height: 14),
              TextField(controller: notesController, decoration: deco('Delivery notes (optional)')),
            ],
          ),
      ],
    );
  }
}

class _PaymentOptions extends StatelessWidget {
  final PayMethod value;
  final ValueChanged<PayMethod?> onChanged;
  const _PaymentOptions({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget option(PayMethod m, String emoji, String label, String hint) {
      final selected = value == m;
      return InkWell(
        onTap: () => onChanged(m),
        borderRadius: BorderRadius.circular(AppRadius.r),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.forest : context.zim.line, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.r),
            color: selected ? AppColors.forestSoft : Colors.transparent,
          ),
          child: Row(
            children: [
              Radio<PayMethod>(value: m, groupValue: value, onChanged: onChanged, activeColor: AppColors.forest),
              Text('$emoji  ', style: const TextStyle(fontSize: 16)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    children: [
                      TextSpan(text: label),
                      TextSpan(text: ' — $hint', style: TextStyle(color: context.zim.inkSoft, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        option(PayMethod.ecocash, '📱', 'EcoCash', 'pay from your phone'),
        option(PayMethod.card, '💳', 'Card', 'Visa / Mastercard'),
        option(PayMethod.cash, '💵', 'Cash on delivery', ''),
      ],
    );
  }
}

class _TipSelector extends StatelessWidget {
  final double? percent;
  final bool custom;
  final TextEditingController customController;
  final ValueChanged<double> onPercentSelected;
  final VoidCallback onCustomSelected;
  final VoidCallback onCustomChanged;

  const _TipSelector({
    required this.percent,
    required this.custom,
    required this.customController,
    required this.onPercentSelected,
    required this.onCustomSelected,
    required this.onCustomChanged,
  });

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    Widget chip(String label, {required bool selected, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.forest : zim.line, width: 1.5),
            borderRadius: BorderRadius.circular(999),
            color: selected ? AppColors.forestSoft : Colors.transparent,
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? AppColors.forest : zim.ink)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('100% of your tip goes to your rider.', style: TextStyle(color: zim.inkSoft, fontSize: 12.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in _tipPercents)
              chip(p == 0 ? 'No tip' : '${(p * 100).round()}%', selected: !custom && percent == p, onTap: () => onPercentSelected(p)),
            chip('Custom', selected: custom, onTap: onCustomSelected),
          ],
        ),
        if (custom) ...[
          const SizedBox(height: 12),
          TextField(
            controller: customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onCustomChanged(),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Custom tip amount',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ],
    );
  }
}

class _PromoField extends StatelessWidget {
  final TextEditingController controller;
  final PromoCode? applied;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoField({
    required this.controller,
    required this.applied,
    required this.error,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    if (applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.forestSoft, borderRadius: BorderRadius.circular(999)),
        child: Row(
          children: [
            const Text('🏷️  ', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text('${applied!.code} applied — ${applied!.description}',
                  style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            InkWell(onTap: onRemove, child: const Icon(Icons.close_rounded, size: 18, color: AppColors.forest)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Promo code',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: zim.line, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.forest, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onApply,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: zim.line),
                foregroundColor: zim.ink,
              ),
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error!, style: const TextStyle(color: AppColors.flame, fontSize: 12.5)),
          ),
      ],
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r),
      child: Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(color: context.zim.line)),
        child: CustomPaint(painter: _MiniMapPainter(), child: const SizedBox(width: double.infinity)),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFEEF3EC);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.18
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(0, h * 0.33), Offset(w, h * 0.33), road);
    canvas.drawLine(Offset(0, h * 0.7), Offset(w, h * 0.7), road);
    canvas.drawLine(Offset(w * 0.18, 0), Offset(w * 0.18, h), road);
    canvas.drawLine(Offset(w * 0.44, 0), Offset(w * 0.44, h), road);
    canvas.drawLine(Offset(w * 0.73, 0), Offset(w * 0.73, h), road);

    final route = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.18, h * 0.7)
      ..lineTo(w * 0.44, h * 0.7)
      ..lineTo(w * 0.44, h * 0.33)
      ..lineTo(w * 0.73, h * 0.33);
    canvas.drawPath(_dashPath(path, 6, 5), route);

    canvas.drawCircle(Offset(w * 0.18, h * 0.7), 6, Paint()..color = AppColors.flame);
    canvas.drawCircle(Offset(w * 0.73, h * 0.33), 6, Paint()..color = AppColors.forest);
  }

  Path _dashPath(Path source, double dash, double gap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dash : gap;
        if (draw) dest.addPath(metric.extractPath(distance, (distance + len).clamp(0, metric.length)), Offset.zero);
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
