import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/restaurants_data.dart';
import '../models/restaurant.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeFilter = 'all';
  String searchText = '';
  bool favoritesOnly = false;
  final _searchController = TextEditingController();

  bool _matches(Restaurant r) {
    final passesCategory = activeFilter == 'all' ||
        r.tags.contains(activeFilter) ||
        r.cuisine.toLowerCase().contains(activeFilter);

    final text = searchText.toLowerCase();
    final passesSearch = text.isEmpty ||
        r.name.toLowerCase().contains(text) ||
        r.cuisine.toLowerCase().contains(text) ||
        r.tags.any((t) => t.contains(text)) ||
        r.menu.any((m) => m.name.toLowerCase().contains(text));

    return passesCategory && passesSearch;
  }

  List<Restaurant> _sorted(List<Restaurant> list, SortMode mode) {
    final copy = [...list];
    switch (mode) {
      case SortMode.ratingDesc:
        copy.sort((a, b) => b.rating.compareTo(a.rating));
      case SortMode.feeAsc:
        copy.sort((a, b) => a.deliveryFee.compareTo(b.deliveryFee));
      case SortMode.fastest:
        copy.sort((a, b) => a.deliveryMinutes.compareTo(b.deliveryMinutes));
      case SortMode.relevance:
        break;
    }
    return copy;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    var results = restaurants.where(_matches).toList();
    if (favoritesOnly) results = results.where((r) => app.isFavorite(r.id)).toList();
    results = _sorted(results, app.sortMode);

    final title = (activeFilter == 'all' && searchText.isEmpty && !favoritesOnly)
        ? 'All restaurants'
        : '${results.length} kitchen${results.length == 1 ? '' : 's'} found';

    return AppShell(
      currentRoute: 'home',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(controller: _searchController, onSearch: (v) => setState(() => searchText = v))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _CategoryChips(
                    active: activeFilter,
                    onSelect: (f) => setState(() => activeFilter = f),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
                      ),
                      FilterChip(
                        label: const Text('❤️ Favourites'),
                        selected: favoritesOnly,
                        onSelected: (v) => setState(() => favoritesOnly = v),
                      ),
                      const SizedBox(width: 8),
                      _SortMenu(mode: app.sortMode, onChanged: app.setSortMode),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (results.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Text('No kitchens match that — try another search.', style: TextStyle(color: context.zim.inkSoft)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = (width / 300).floor().clamp(1, 4);
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.86,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => RestaurantCard(
                        restaurant: results[i],
                        onTap: () => context.go('/restaurant/${results[i].id}'),
                      ),
                      childCount: results.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  const _Hero({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 720;
    final zim = context.zim;

    final textBlock = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: zim.line),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text('📍 Delivering across Harare', style: TextStyle(color: AppColors.forest, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Hot plates,\n'),
              TextSpan(
                text: 'straight to your gate.',
                style: const TextStyle(color: AppColors.flame),
              ),
            ],
          ),
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: wide ? 44 : 34,
                height: 1.05,
                letterSpacing: -1,
              ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            "From Gogo's sadza to late-night shawarma — order from Harare's best kitchens and track your rider to the door.",
            textAlign: wide ? TextAlign.left : TextAlign.center,
            style: TextStyle(color: zim.inkSoft, fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(color: zim.line),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search restaurants or cravings…',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onSearch(controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.flame,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final art = _HeroArt();

    return Container(
      width: double.infinity,
      color: zim.mist,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: wide ? 56 : 32),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textBlock),
                const SizedBox(width: 32),
                Expanded(flex: 4, child: Center(child: art)),
              ],
            )
          : textBlock,
    );
  }
}

class _HeroArt extends StatefulWidget {
  @override
  State<_HeroArt> createState() => _HeroArtState();
}

class _HeroArtState extends State<_HeroArt> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(offset: Offset(0, -10 * t), child: child);
      },
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: AppColors.marigold, width: 10),
          boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 28, offset: Offset(0, 10))],
        ),
        alignment: Alignment.center,
        child: const Text('🍲', style: TextStyle(fontSize: 96)),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String active;
  final ValueChanged<String> onSelect;
  const _CategoryChips({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final selected = c.filter == active;
          return ChoiceChip(
            label: Text('${c.emoji} ${c.label}'),
            selected: selected,
            onSelected: (_) => onSelect(c.filter),
            selectedColor: context.zim.ink,
            labelStyle: TextStyle(
              color: selected ? Theme.of(context).scaffoldBackgroundColor : context.zim.ink,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: StadiumBorder(side: BorderSide(color: selected ? context.zim.ink : context.zim.line)),
          );
        },
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final SortMode mode;
  final ValueChanged<SortMode> onChanged;
  const _SortMenu({required this.mode, required this.onChanged});

  String _label(SortMode m) => switch (m) {
        SortMode.relevance => 'Sort',
        SortMode.ratingDesc => 'Top rated',
        SortMode.feeAsc => 'Cheapest delivery',
        SortMode.fastest => 'Fastest',
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortMode>(
      initialValue: mode,
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: SortMode.relevance, child: Text('Relevance')),
        PopupMenuItem(value: SortMode.ratingDesc, child: Text('Top rated')),
        PopupMenuItem(value: SortMode.feeAsc, child: Text('Cheapest delivery')),
        PopupMenuItem(value: SortMode.fastest, child: Text('Fastest')),
      ],
      child: Chip(
        avatar: const Icon(Icons.swap_vert_rounded, size: 18),
        label: Text(_label(mode)),
      ),
    );
  }
}
