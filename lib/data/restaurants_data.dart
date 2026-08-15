import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';

/// All restaurant + menu data for the app. In a real app this would come
/// from a server API — here it's a plain in-memory list.
final List<Restaurant> restaurants = [
  Restaurant(
    id: 'gogos-kitchen',
    name: "Gogo's Kitchen",
    emoji: '🍲',
    cuisine: 'Traditional Zimbabwean',
    rating: 4.8,
    reviews: 812,
    deliveryTime: '25–35 min',
    deliveryFee: 1.50,
    tags: const ['sadza', 'family', 'popular'],
    color: const Color(0xFF2F6B3C),
    menu: const [
      MenuItem(id: 'sadza-beef', name: 'Sadza neNyama', desc: 'Thick white sadza with slow-cooked beef stew and covo greens.', price: 6.50, emoji: '🥘', category: 'Mains', popular: true),
      MenuItem(id: 'sadza-huku', name: 'Sadza neHuku', desc: 'Road-runner chicken simmered in tomato and onion gravy.', price: 7.00, emoji: '🍗', category: 'Mains', popular: true),
      MenuItem(id: 'muriwo', name: 'Muriwo unedovi', desc: 'Leafy greens cooked in rich peanut butter sauce.', price: 3.50, emoji: '🥬', category: 'Sides'),
      MenuItem(id: 'matemba', name: 'Matemba Special', desc: 'Crispy fried kapenta with sadza and fresh tomato relish.', price: 5.00, emoji: '🐟', category: 'Mains'),
      MenuItem(id: 'mazondo', name: 'Mazondo', desc: 'Slow-braised beef trotters, rich and sticky. Weekend favourite.', price: 8.00, emoji: '🍖', category: 'Mains'),
      MenuItem(id: 'maheu', name: 'Maheu (500ml)', desc: 'Traditional fermented mealie drink, chilled.', price: 1.50, emoji: '🥤', category: 'Drinks'),
    ],
  ),
  Restaurant(
    id: 'piri-piri-palace',
    name: 'Piri Piri Palace',
    emoji: '🔥',
    cuisine: 'Grilled Chicken',
    rating: 4.6,
    reviews: 1204,
    deliveryTime: '20–30 min',
    deliveryFee: 2.00,
    tags: const ['spicy', 'grill', 'popular'],
    color: const Color(0xFFC23A22),
    menu: const [
      MenuItem(id: 'full-chicken', name: 'Full Flame-Grilled Chicken', desc: 'Whole chicken basted in piri piri, grilled over open flame.', price: 12.00, emoji: '🍗', category: 'Mains', popular: true),
      MenuItem(id: 'half-chicken', name: 'Half Chicken & Chips', desc: 'Half piri piri chicken with a mountain of hand-cut chips.', price: 7.50, emoji: '🍟', category: 'Mains', popular: true),
      MenuItem(id: 'wings', name: 'Piri Wings (8pc)', desc: 'Eight wings, extra hot rub, cooling ranch on the side.', price: 6.00, emoji: '🍖', category: 'Sides'),
      MenuItem(id: 'chicken-burger', name: 'Grilled Chicken Burger', desc: 'Chicken fillet, lettuce, tomato and piri mayo on a toasted bun.', price: 5.50, emoji: '🍔', category: 'Mains'),
      MenuItem(id: 'corn', name: 'Roast Mealie', desc: 'Charred corn on the cob with salted butter.', price: 2.00, emoji: '🌽', category: 'Sides'),
    ],
  ),
  Restaurant(
    id: 'avondale-pizza',
    name: 'Avondale Pizza Co.',
    emoji: '🍕',
    cuisine: 'Pizza & Italian',
    rating: 4.5,
    reviews: 655,
    deliveryTime: '30–45 min',
    deliveryFee: 2.50,
    tags: const ['pizza', 'cheesy'],
    color: const Color(0xFFB8860B),
    menu: const [
      MenuItem(id: 'margherita', name: 'Margherita', desc: 'Tomato base, mozzarella, fresh basil. The classic.', price: 8.00, emoji: '🍕', category: 'Pizza', popular: true),
      MenuItem(id: 'peri-chicken-pizza', name: 'Peri Chicken Pizza', desc: 'Spicy chicken strips, peppers, red onion, mozzarella.', price: 10.50, emoji: '🍕', category: 'Pizza', popular: true),
      MenuItem(id: 'biltong-pizza', name: 'Biltong & Feta', desc: 'Local favourite — shaved biltong, feta, caramelised onion.', price: 11.00, emoji: '🍕', category: 'Pizza'),
      MenuItem(id: 'garlic-bread', name: 'Garlic Focaccia', desc: 'Wood-fired flatbread brushed with garlic butter.', price: 3.50, emoji: '🥖', category: 'Sides'),
      MenuItem(id: 'tiramisu', name: 'Tiramisu', desc: 'Coffee-soaked layers, mascarpone, cocoa dust.', price: 4.00, emoji: '🍰', category: 'Dessert'),
    ],
  ),
  Restaurant(
    id: 'samora-shawarma',
    name: 'Samora Shawarma',
    emoji: '🌯',
    cuisine: 'Middle Eastern',
    rating: 4.7,
    reviews: 431,
    deliveryTime: '15–25 min',
    deliveryFee: 1.00,
    tags: const ['wraps', 'fast', 'late-night'],
    color: const Color(0xFF6B4226),
    menu: const [
      MenuItem(id: 'chicken-shawarma', name: 'Chicken Shawarma', desc: 'Spit-roasted chicken, garlic sauce, pickles in a warm wrap.', price: 5.00, emoji: '🌯', category: 'Mains', popular: true),
      MenuItem(id: 'beef-shawarma', name: 'Beef Shawarma', desc: 'Marinated beef strips, tahini, fresh salad.', price: 6.00, emoji: '🌯', category: 'Mains', popular: true),
      MenuItem(id: 'falafel-plate', name: 'Falafel Plate', desc: 'Six crispy falafels, hummus, flatbread and salad.', price: 5.50, emoji: '🧆', category: 'Mains'),
      MenuItem(id: 'loaded-fries', name: 'Shawarma Loaded Fries', desc: 'Chips buried under shawarma meat, garlic sauce and chilli.', price: 6.50, emoji: '🍟', category: 'Sides'),
    ],
  ),
  Restaurant(
    id: 'kombucha-corner',
    name: 'Greenside Bowls',
    emoji: '🥗',
    cuisine: 'Healthy & Vegan',
    rating: 4.4,
    reviews: 289,
    deliveryTime: '20–30 min',
    deliveryFee: 2.00,
    tags: const ['vegan', 'fresh', 'healthy'],
    color: const Color(0xFF3E7C59),
    menu: const [
      MenuItem(id: 'buddha-bowl', name: 'Harare Buddha Bowl', desc: 'Brown rice, roast butternut, chickpeas, avo, peanut dressing.', price: 7.00, emoji: '🥗', category: 'Mains', popular: true),
      MenuItem(id: 'smoothie', name: 'Mango Baobab Smoothie', desc: 'Mango, baobab powder, banana and coconut milk.', price: 4.00, emoji: '🥭', category: 'Drinks', popular: true),
      MenuItem(id: 'avo-toast', name: 'Avo Smash Toast', desc: 'Sourdough, smashed avo, chilli flakes, lime.', price: 4.50, emoji: '🥑', category: 'Mains'),
      MenuItem(id: 'granola-cup', name: 'Granola & Yoghurt Cup', desc: 'House granola, plain yoghurt, seasonal fruit.', price: 3.50, emoji: '🍓', category: 'Mains'),
    ],
  ),
  Restaurant(
    id: 'sweet-mbare',
    name: 'Sweet Mbare Bakery',
    emoji: '🍩',
    cuisine: 'Bakery & Desserts',
    rating: 4.9,
    reviews: 977,
    deliveryTime: '25–40 min',
    deliveryFee: 1.50,
    tags: const ['dessert', 'baked', 'popular'],
    color: const Color(0xFF8E4585),
    menu: const [
      MenuItem(id: 'fat-cooks', name: 'Fat Cooks (6pc)', desc: 'Golden fried dough balls dusted with sugar. Still warm.', price: 3.00, emoji: '🍩', category: 'Pastries', popular: true),
      MenuItem(id: 'scones', name: 'Buttermilk Scones (4pc)', desc: 'With strawberry jam and whipped cream.', price: 4.00, emoji: '🧁', category: 'Pastries', popular: true),
      MenuItem(id: 'choc-cake', name: 'Chocolate Fudge Slice', desc: 'Dense chocolate cake with a fudge glaze.', price: 3.50, emoji: '🍫', category: 'Cakes'),
      MenuItem(id: 'custard-tart', name: 'Custard Tart', desc: 'Silky custard in crisp shortcrust pastry.', price: 2.50, emoji: '🥧', category: 'Pastries'),
    ],
  ),

  // ---------- Supermarkets ----------
  // Same data shape as the restaurants above so they slot straight into
  // the existing cards / menu / cart / checkout UI — a "menu" here is
  // just a shelf of grocery items, grouped by aisle instead of course.
  Restaurant(
    id: 'pick-n-pay',
    name: 'Pick n Pay',
    emoji: '🛒',
    cuisine: 'Supermarket & Groceries',
    rating: 4.5,
    reviews: 640,
    deliveryTime: '40–60 min',
    deliveryFee: 3.00,
    tags: const ['supermarket', 'groceries', 'household'],
    color: const Color(0xFF004B87),
    menu: const [
      MenuItem(id: 'white-bread', name: 'White Bread Loaf', desc: 'Fresh sliced white bread, baked daily.', price: 1.20, emoji: '🍞', category: 'Bakery', popular: true),
      MenuItem(id: 'full-cream-milk', name: 'Full Cream Milk 2L', desc: 'Long-life full cream milk.', price: 2.50, emoji: '🥛', category: 'Dairy & Eggs', popular: true),
      MenuItem(id: 'dozen-eggs', name: 'Dozen Eggs', desc: 'Large free-range eggs, tray of 12.', price: 2.80, emoji: '🥚', category: 'Dairy & Eggs'),
      MenuItem(id: 'rice-2kg', name: 'Rice 2kg', desc: 'Long-grain white rice.', price: 3.50, emoji: '🍚', category: 'Pantry'),
      MenuItem(id: 'cooking-oil', name: 'Cooking Oil 2L', desc: 'Pure sunflower cooking oil.', price: 4.20, emoji: '🛢️', category: 'Pantry'),
      MenuItem(id: 'sugar-2kg', name: 'Sugar 2kg', desc: 'White refined sugar.', price: 2.90, emoji: '🍬', category: 'Pantry'),
      MenuItem(id: 'mazoe-2l', name: 'Mazoe Orange Crush 2L', desc: 'The Zimbabwean classic, concentrated.', price: 3.00, emoji: '🧃', category: 'Beverages'),
      MenuItem(id: 'toilet-paper', name: 'Toilet Paper (9 pack)', desc: 'Soft 2-ply toilet tissue.', price: 4.50, emoji: '🧻', category: 'Household'),
    ],
  ),
  Restaurant(
    id: 'food-lovers-market',
    name: 'Food Lovers Market',
    emoji: '🥦',
    cuisine: 'Fresh Produce & Groceries',
    rating: 4.6,
    reviews: 512,
    deliveryTime: '35–55 min',
    deliveryFee: 2.50,
    tags: const ['supermarket', 'fresh produce', 'groceries', 'fruit & veg'],
    color: const Color(0xFF8DC63F),
    menu: const [
      MenuItem(id: 'mixed-veg-box', name: 'Mixed Veg Box', desc: 'A hand-picked box of seasonal vegetables.', price: 5.00, emoji: '🥕', category: 'Fresh Produce', popular: true),
      MenuItem(id: 'bananas-1kg', name: 'Bananas (1kg)', desc: 'Sweet ripe bananas.', price: 1.50, emoji: '🍌', category: 'Fresh Produce', popular: true),
      MenuItem(id: 'tomatoes-1kg', name: 'Tomatoes (1kg)', desc: 'Fresh vine-ripened tomatoes.', price: 2.00, emoji: '🍅', category: 'Fresh Produce'),
      MenuItem(id: 'avocados-4pc', name: 'Avocados (4pc)', desc: 'Ready-to-eat avocados.', price: 2.50, emoji: '🥑', category: 'Fresh Produce'),
      MenuItem(id: 'butternut', name: 'Butternut (each)', desc: 'Locally grown butternut squash.', price: 1.20, emoji: '🎃', category: 'Fresh Produce'),
      MenuItem(id: 'herb-bunch', name: 'Fresh Herb Bunch', desc: 'Coriander, parsley or spring onion.', price: 1.00, emoji: '🌿', category: 'Fresh Produce'),
      MenuItem(id: 'mixed-nuts', name: 'Mixed Nuts 500g', desc: 'Roasted and salted mixed nuts.', price: 4.50, emoji: '🥜', category: 'Pantry'),
    ],
  ),
  Restaurant(
    id: 'spar-supermarket',
    name: 'Spar',
    emoji: '🏪',
    cuisine: 'Supermarket & Groceries',
    rating: 4.4,
    reviews: 398,
    deliveryTime: '30–50 min',
    deliveryFee: 2.80,
    tags: const ['supermarket', 'groceries', '24hr'],
    color: const Color(0xFF00723C),
    menu: const [
      MenuItem(id: 'spar-bread', name: 'White Bread Loaf', desc: 'Fresh sliced white bread, baked daily.', price: 1.15, emoji: '🍞', category: 'Bakery', popular: true),
      MenuItem(id: 'spar-milk', name: 'Fresh Milk 1L', desc: 'Pasteurised full cream milk.', price: 1.30, emoji: '🥛', category: 'Dairy & Eggs', popular: true),
      MenuItem(id: 'braai-pack', name: 'Chicken Braai Pack 1kg', desc: 'Mixed chicken pieces, ready for the grill.', price: 6.50, emoji: '🍗', category: 'Meat & Poultry'),
      MenuItem(id: 'instant-noodles', name: 'Instant Noodles (5 pack)', desc: 'Quick two-minute noodles, assorted flavours.', price: 2.00, emoji: '🍜', category: 'Pantry'),
      MenuItem(id: 'peanut-butter', name: 'Peanut Butter 400g', desc: 'Smooth peanut butter.', price: 2.60, emoji: '🥜', category: 'Pantry'),
      MenuItem(id: 'snack-chips', name: 'Snack Chips Multipack', desc: 'Assorted flavoured potato chips.', price: 3.20, emoji: '🍟', category: 'Snacks'),
      MenuItem(id: 'soft-drink-2l', name: '2L Soft Drink', desc: 'Assorted fizzy soft drinks.', price: 1.80, emoji: '🥤', category: 'Beverages'),
    ],
  ),
];

/// Category chips shown on the home page. "filter" matches against a
/// restaurant's cuisine or tags.
const List<FoodCategory> categories = [
  FoodCategory(label: 'All', filter: 'all', emoji: '🍽️'),
  FoodCategory(label: 'Traditional', filter: 'sadza', emoji: '🍲'),
  FoodCategory(label: 'Grill', filter: 'grill', emoji: '🔥'),
  FoodCategory(label: 'Pizza', filter: 'pizza', emoji: '🍕'),
  FoodCategory(label: 'Wraps', filter: 'wraps', emoji: '🌯'),
  FoodCategory(label: 'Healthy', filter: 'vegan', emoji: '🥗'),
  FoodCategory(label: 'Dessert', filter: 'dessert', emoji: '🍩'),
  FoodCategory(label: 'Supermarkets', filter: 'supermarket', emoji: '🛒'),
];

/// Demo promo codes applied at checkout: percentage-off or flat-amount-off,
/// with an optional minimum subtotal.
class PromoCode {
  final String code;
  final double percentOff;
  final double flatOff;
  final double minSubtotal;
  final String description;

  const PromoCode({
    required this.code,
    this.percentOff = 0,
    this.flatOff = 0,
    this.minSubtotal = 0,
    required this.description,
  });

  double discountFor(double subtotal) {
    if (subtotal < minSubtotal) return 0;
    final pct = subtotal * percentOff;
    return (pct + flatOff).clamp(0, subtotal);
  }
}

const List<PromoCode> promoCodes = [
  PromoCode(code: 'WELCOME10', percentOff: 0.10, description: '10% off your order'),
  PromoCode(code: 'ZIM5', flatOff: 5.00, minSubtotal: 15.00, description: '\$5 off orders over \$15'),
];

PromoCode? findPromoCode(String code) {
  final normalized = code.trim().toUpperCase();
  for (final p in promoCodes) {
    if (p.code == normalized) return p;
  }
  return null;
}

Restaurant restaurantById(String id) => restaurants.firstWhere(
      (r) => r.id == id,
      orElse: () => restaurants.first,
    );
