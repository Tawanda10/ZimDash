import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../state/cart_provider.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/toast.dart';

class _Stage {
  final String icon;
  final String title;
  final String detail;
  final int seconds;
  const _Stage(this.icon, this.title, this.detail, this.seconds);
}

const _stages = [
  _Stage('✅', 'Order confirmed', 'The kitchen received your order.', 3),
  _Stage('🍳', 'Cooking', 'Your food is being prepared fresh.', 6),
  _Stage('🛵', 'Rider on the way', 'Your rider has picked up the order.', 12),
  _Stage('🏡', 'Delivered', 'Enjoy your meal! Rate your order in the app.', 0),
];

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  int _currentStage = 0;
  Timer? _timer;
  late final DateTime _eta;
  late final AnimationController _riderController;

  @override
  void initState() {
    super.initState();
    final totalSeconds = _stages.fold(0, (s, st) => s + st.seconds);
    _eta = DateTime.now().add(Duration(seconds: totalSeconds + 8 * 60));

    final rideMs = _stages[2].seconds * 1000;
    final cookMs = (_stages[0].seconds + _stages[1].seconds) * 1000;
    _riderController = AnimationController(vsync: this, duration: Duration(milliseconds: cookMs + rideMs))..forward();

    _scheduleNext();
  }

  void _scheduleNext() {
    final stage = _stages[_currentStage];
    if (stage.seconds == 0) return;
    _timer = Timer(Duration(seconds: stage.seconds), () {
      if (!mounted) return;
      setState(() => _currentStage += 1);
      if (_currentStage == _stages.length - 1) {
        showZimToast(context, '🎉 Order delivered — enjoy!');
      }
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _riderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final order = cart.lastOrder;
    final title = order != null ? 'On the way, ${order.name.split(' ').first}!' : 'Track your order';
    final wide = MediaQuery.of(context).size.width >= 900;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EtaBanner(eta: _eta),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(border: Border.all(color: context.zim.line), borderRadius: BorderRadius.circular(AppRadius.rLg)),
          child: Column(
            children: List.generate(_stages.length, (i) {
              final done = i < _currentStage;
              final current = i == _currentStage;
              return _StatusStep(stage: _stages[i], done: done, current: current, isLast: i == _stages.length - 1);
            }),
          ),
        ),
        if (order != null) ...[
          const SizedBox(height: 16),
          _OrderSummaryCard(order: order),
        ],
      ],
    );

    final right = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.rLg),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: context.zim.line), color: const Color(0xFFEAF1E6)),
        height: 420,
        child: AnimatedBuilder(
          animation: _riderController,
          builder: (context, _) => CustomPaint(
            painter: _MapPainter(progress: _riderController.value, cookFraction: (_stages[0].seconds + _stages[1].seconds) / (_stages[0].seconds + _stages[1].seconds + _stages[2].seconds)),
            child: const SizedBox(width: double.infinity, height: double.infinity),
          ),
        ),
      ),
    );

    return AppShell(
      currentRoute: 'tracking',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26)),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: left),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: right),
                  ],
                )
              else
                Column(children: [left, const SizedBox(height: 20), right]),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final PlacedOrder order;
  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 90, child: Text(label, style: TextStyle(color: zim.inkSoft, fontSize: 13))),
              Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(border: Border.all(color: zim.line), borderRadius: BorderRadius.circular(AppRadius.rLg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          row('Delivering to', '${order.address}, ${order.suburb}'),
          row('Payment', order.payMethod),
          if (order.promoCode != null) row('Promo', '${order.promoCode} · -${money(order.discount)}'),
          if (order.tip > 0) row('Rider tip', money(order.tip)),
          row('Total', money(order.total)),
        ],
      ),
    );
  }
}

class _EtaBanner extends StatelessWidget {
  final DateTime eta;
  const _EtaBanner({required this.eta});

  @override
  Widget build(BuildContext context) {
    final hh = eta.hour % 12 == 0 ? 12 : eta.hour % 12;
    final mm = eta.minute.toString().padLeft(2, '0');
    final ampm = eta.hour >= 12 ? 'PM' : 'AM';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(color: context.zim.ink, borderRadius: BorderRadius.circular(AppRadius.rLg)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated arrival', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.75), fontSize: 13)),
              Text('$hh:$mm $ampm',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 26)),
            ],
          ),
          const Text('🛵', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final _Stage stage;
  final bool done;
  final bool current;
  final bool isLast;
  const _StatusStep({required this.stage, required this.done, required this.current, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _PulsingDot(active: done, current: current, icon: done ? '✓' : stage.icon),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: done ? AppColors.forest : zim.line),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(stage.detail, style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final bool active;
  final bool current;
  final String icon;
  const _PulsingDot({required this.active, required this.current, required this.icon});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zim = context.zim;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.current)
                Container(
                  width: 34 + 20 * _controller.value,
                  height: 34 + 20 * _controller.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forest.withValues(alpha: (1 - _controller.value) * 0.35),
                  ),
                ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.active ? AppColors.forest : Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: widget.active || widget.current ? AppColors.forest : zim.line, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(widget.icon, style: TextStyle(fontSize: 13, color: widget.active ? Colors.white : null)),
      ),
    );
  }
}

/// Draws a stylised map (roads, park, buildings) with a dashed route and an
/// animated rider marker — a Canvas re-implementation of the original SVG.
class _MapPainter extends CustomPainter {
  final double progress; // 0..1 over the whole cook+ride duration
  final double cookFraction; // fraction of that duration spent "cooking" (rider stays put)

  _MapPainter({required this.progress, required this.cookFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final sx = w / 500, sy = h / 420;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEAF1E6));

    // park
    final parkRect = Rect.fromLTWH(310 * sx, 250 * sy, 150 * sx, 130 * sy);
    canvas.drawRRect(RRect.fromRectAndRadius(parkRect, Radius.circular(14 * sx)), Paint()..color = const Color(0xFFCFE3C4));
    _text(canvas, '🌳', p(385, 320), 22);

    // water
    final waterPath = Path()
      ..moveTo(0, 330 * sy)
      ..quadraticBezierTo(70 * sx, 300 * sy, 90 * sx, 360 * sy)
      ..quadraticBezierTo(150 * sx, 420 * sy, 200 * sx, 420 * sy)
      ..lineTo(0, 420 * sy)
      ..close();
    canvas.drawPath(waterPath, Paint()..color = const Color(0xFFBCD7E3));

    // roads
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 22 * sx
      ..strokeCap = StrokeCap.round;
    void line(double x1, double y1, double x2, double y2) => canvas.drawLine(p(x1, y1), p(x2, y2), road);
    line(60, 40, 60, 380);
    line(60, 90, 440, 90);
    line(250, 90, 250, 300);
    line(250, 300, 440, 300);
    line(440, 90, 440, 300);
    line(140, 200, 250, 200);

    // buildings
    _text(canvas, '🏠', p(110, 70), 18);
    _text(canvas, '🏢', p(330, 70), 18);
    _text(canvas, '🏪', p(180, 160), 18);
    _text(canvas, '🏥', p(330, 180), 18);
    _text(canvas, '🏘️', p(120, 300), 18);

    // route: M60 90 H 250 V 300 H 440
    final routePath = Path()
      ..moveTo(60 * sx, 90 * sy)
      ..lineTo(250 * sx, 90 * sy)
      ..lineTo(250 * sx, 300 * sy)
      ..lineTo(440 * sx, 300 * sy);
    final routePaint = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_dashPath(routePath, 9, 7), routePaint);

    // start / end markers
    canvas.drawCircle(p(60, 90), 11, Paint()..color = AppColors.flame);
    _text(canvas, '🍲', p(60, 90), 12, center: true);
    canvas.drawCircle(p(440, 300), 11, Paint()..color = AppColors.forest);
    _text(canvas, '🏡', p(440, 300), 12, center: true);

    // rider position
    final rideProgress = ((progress - cookFraction) / (1 - cookFraction)).clamp(0.0, 1.0);
    final riderPoint = _pointAtFraction(routePath, rideProgress);
    canvas.drawCircle(riderPoint, 14, Paint()..color = Colors.white);
    canvas.drawCircle(riderPoint, 14, Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    _text(canvas, '🛵', riderPoint, 15, center: true);
  }

  Offset _pointAtFraction(Path path, double fraction) {
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold<double>(0, (s, m) => s + m.length);
    var target = totalLength * fraction;
    for (final metric in metrics) {
      if (target <= metric.length) {
        final tangent = metric.getTangentForOffset(target);
        return tangent?.position ?? Offset.zero;
      }
      target -= metric.length;
    }
    final last = metrics.last;
    return last.getTangentForOffset(last.length)?.position ?? Offset.zero;
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

  void _text(Canvas canvas, String text, Offset offset, double size, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    final o = center ? offset - Offset(tp.width / 2, tp.height / 2) : offset - Offset(tp.width / 2, tp.height);
    tp.paint(canvas, o);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => oldDelegate.progress != progress;
}
