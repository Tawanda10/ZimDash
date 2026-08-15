class MenuItem {
  final String id;
  final String name;
  final String desc;
  final double price;
  final String emoji;
  final String category;
  final bool popular;

  const MenuItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.emoji,
    required this.category,
    this.popular = false,
  });
}
