class CartItem {
  final String restaurantId;
  final String restaurantName;
  final String itemId;
  final String name;
  final double price;
  final String emoji;
  final String? notes;
  int qty;

  CartItem({
    required this.restaurantId,
    required this.restaurantName,
    required this.itemId,
    required this.name,
    required this.price,
    required this.emoji,
    this.notes,
    this.qty = 1,
  });

  double get lineTotal => price * qty;

  Map<String, dynamic> toJson() => {
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'itemId': itemId,
        'name': name,
        'price': price,
        'emoji': emoji,
        'notes': notes,
        'qty': qty,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        restaurantId: json['restaurantId'] as String,
        restaurantName: json['restaurantName'] as String? ?? '',
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        emoji: json['emoji'] as String,
        notes: json['notes'] as String?,
        qty: json['qty'] as int,
      );
}

/// A completed order, snapshotted with its line items so it can be shown
/// in order history and re-ordered later — mirrors DoorDash's "Orders" tab.
class PlacedOrder {
  final String id;
  final String name;
  final String suburb;
  final String address;
  final String phone;
  final String payMethod;
  final String? promoCode;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tip;
  final double discount;
  final double total;
  final List<CartItem> items;
  final DateTime placedAt;

  PlacedOrder({
    required this.id,
    required this.name,
    required this.suburb,
    required this.address,
    required this.phone,
    required this.payMethod,
    this.promoCode,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.tip,
    required this.discount,
    required this.total,
    required this.items,
    required this.placedAt,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  List<String> get restaurantNames => items.map((i) => i.restaurantName).toSet().toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'suburb': suburb,
        'address': address,
        'phone': phone,
        'payMethod': payMethod,
        'promoCode': promoCode,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'tip': tip,
        'discount': discount,
        'total': total,
        'items': items.map((i) => i.toJson()).toList(),
        'placedAt': placedAt.toIso8601String(),
      };

  factory PlacedOrder.fromJson(Map<String, dynamic> json) => PlacedOrder(
        id: json['id'] as String,
        name: json['name'] as String,
        suburb: json['suburb'] as String,
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        payMethod: json['payMethod'] as String? ?? 'Cash on delivery',
        promoCode: json['promoCode'] as String?,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
        serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
        tip: (json['tip'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num).toDouble(),
        items: (json['items'] as List? ?? [])
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        placedAt: DateTime.parse(json['placedAt'] as String),
      );
}
