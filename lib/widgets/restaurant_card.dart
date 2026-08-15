import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../state/app_state.dart';
import '../theme.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({super.key, required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isFav = app.isFavorite(restaurant.id);
    final zim = context.zim;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Container(
                    color: restaurant.color,
                    alignment: Alignment.center,
                    child: Text(restaurant.emoji, style: const TextStyle(fontSize: 52)),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _FavButton(isFav: isFav, onTap: () => app.toggleFavorite(restaurant.id)),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${money(restaurant.deliveryFee)} delivery',
                        style: const TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('★ ${restaurant.rating}', style: const TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('(${restaurant.reviews})', style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                      Text('·', style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                      Text(restaurant.cuisine, style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                      Text('·', style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                      Text(restaurant.deliveryTime, style: TextStyle(color: zim.inkSoft, fontSize: 13)),
                    ],
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

class _FavButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;
  const _FavButton({required this.isFav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: AppColors.flame,
          ),
        ),
      ),
    );
  }
}
