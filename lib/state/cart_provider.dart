import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/restaurants_data.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

/// Holds the shopping cart, persisted to disk so it survives app restarts —
/// the same role localStorage played in the original web app.
class CartProvider extends ChangeNotifier {
  static const _cartKey = 'zimdash_cart';
  static const _ordersKey = 'zimdash_orders';

  final List<CartItem> _items = [];
  final List<PlacedOrder> _orders = [];
  bool _loaded = false;

  List<CartItem> get items => List.unmodifiable(_items);

  /// Most recent order first.
  List<PlacedOrder> get orders => List.unmodifiable(_orders.reversed);
  PlacedOrder? get lastOrder => _orders.isEmpty ? null : _orders.last;
  bool get isEmpty => _items.isEmpty;

  int get count => _items.fold(0, (sum, i) => sum + i.qty);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  /// The set of restaurant ids currently represented in the cart.
  Set<String> get restaurantIds => _items.map((i) => i.restaurantId).toSet();

  /// We charge the delivery fee of each restaurant that appears in the
  /// cart — you might have ordered from more than one kitchen.
  double get deliveryFeeTotal {
    return restaurantIds.fold(0, (sum, id) {
      final r = restaurants.where((r) => r.id == id);
      return sum + (r.isEmpty ? 0 : r.first.deliveryFee);
    });
  }

  static const serviceFee = 0.5;

  double get total => subtotal + deliveryFeeTotal + (isEmpty ? 0 : serviceFee);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // corrupt data — start fresh
      }
    }
    final ordersRaw = prefs.getStringList(_ordersKey);
    if (ordersRaw != null) {
      try {
        _orders
          ..clear()
          ..addAll(ordersRaw.map((e) => PlacedOrder.fromJson(jsonDecode(e) as Map<String, dynamic>)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ordersKey, _orders.map((o) => jsonEncode(o.toJson())).toList());
  }

  /// Adds [qty] of [item] to the cart. Lines with the same special
  /// instructions merge (quantity adds up); different notes create a
  /// separate line, the way DoorDash treats customised items.
  void addItem({
    required String restaurantId,
    required String restaurantName,
    required MenuItem item,
    int qty = 1,
    String? notes,
  }) {
    final normalizedNotes = (notes == null || notes.trim().isEmpty) ? null : notes.trim();
    final existing = _items.where(
      (c) => c.restaurantId == restaurantId && c.itemId == item.id && c.notes == normalizedNotes,
    );
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      _items.add(CartItem(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        itemId: item.id,
        name: item.name,
        price: item.price,
        emoji: item.emoji,
        notes: normalizedNotes,
        qty: qty,
      ));
    }
    _persist();
    notifyListeners();
  }

  /// Mutates the given cart line directly — callers pass the actual
  /// [CartItem] instance from [items], so identity is preserved even when
  /// multiple lines share the same item id with different notes.
  void changeQty(CartItem item, int delta) {
    if (!_items.contains(item)) return;
    item.qty += delta;
    if (item.qty <= 0) {
      _items.remove(item);
    }
    _persist();
    notifyListeners();
  }

  Future<PlacedOrder> placeOrder({
    required String name,
    required String suburb,
    required String address,
    required String phone,
    required String payMethod,
    String? promoCode,
    double tip = 0,
    double discount = 0,
  }) async {
    final order = PlacedOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      suburb: suburb,
      address: address,
      phone: phone,
      payMethod: payMethod,
      promoCode: promoCode,
      subtotal: subtotal,
      deliveryFee: deliveryFeeTotal,
      serviceFee: isEmpty ? 0 : serviceFee,
      tip: tip,
      discount: discount,
      total: total + tip - discount,
      items: _items.map((c) => CartItem(
            restaurantId: c.restaurantId,
            restaurantName: c.restaurantName,
            itemId: c.itemId,
            name: c.name,
            price: c.price,
            emoji: c.emoji,
            notes: c.notes,
            qty: c.qty,
          )).toList(),
      placedAt: DateTime.now(),
    );
    _orders.add(order);
    _items.clear();
    await _persistOrders();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    notifyListeners();
    return order;
  }

  /// Re-adds every line from a past order to the current cart — DoorDash's
  /// "reorder" action. Existing cart contents are replaced.
  void reorder(PlacedOrder order) {
    _items.clear();
    for (final line in order.items) {
      addItem(
        restaurantId: line.restaurantId,
        restaurantName: line.restaurantName,
        item: MenuItem(id: line.itemId, name: line.name, desc: '', price: line.price, emoji: line.emoji, category: ''),
        qty: line.qty,
        notes: line.notes,
      );
    }
  }
}
