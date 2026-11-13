import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class FavoritesScreenContent extends StatefulWidget {
  const FavoritesScreenContent({super.key});

  @override
  State<FavoritesScreenContent> createState() => _FavoritesScreenContentState();
}

class _FavoritesScreenContentState extends State<FavoritesScreenContent> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final favoriteEateries = eateryNotifier.value.where((e) => globalFavoriteIds.contains(e.id)).toList();
    final favoriteDeals = eateryNotifier.value.where((e) => globalFavoriteDealIds.contains(e.id)).toList();
    final currentList = _tabIndex == 0 ? favoriteEateries : favoriteDeals;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tagum Favorites',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? const Color(0xFF0F7A5B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Eateries',
                            style: TextStyle(
                              color: _tabIndex == 0 ? Colors.white : const Color(0xFF6E7D79),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? const Color(0xFF0F7A5B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Deals',
                            style: TextStyle(
                              color: _tabIndex == 1 ? Colors.white : const Color(0xFF6E7D79),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: currentList.isEmpty
                ? Center(
                    child: Text(
                      _tabIndex == 0
                          ? 'No favorite eateries yet.\nTap the heart icon on any eatery to save it here!'
                          : 'No favorite deals yet.\nTap the heart icon on any deal to save it here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final eatery = currentList[index];
                      final firstMenuItem = eatery.menu.isNotEmpty ? eatery.menu.first.name : eatery.name;
                      final firstPrice = eatery.menu.isNotEmpty ? eatery.menu.first.price : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/restaurant', arguments: eatery);
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    eatery.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        placeholderImage(width: 60, height: 60),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tabIndex == 0 ? eatery.name : firstMenuItem,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _tabIndex == 0
                                            ? '${eatery.cuisine} • ${eatery.distance} km from ACES'
                                            : '${eatery.name} • $firstPrice • ${eatery.cuisine}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            eatery.rating.toString(),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
                                  tooltip: 'Unfavorite',
                                  onPressed: () {
                                    setState(() {
                                      if (_tabIndex == 0) {
                                        globalFavoriteIds.remove(eatery.id);
                                      } else {
                                        globalFavoriteDealIds.remove(eatery.id);
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _tabIndex == 0
                                              ? 'Removed ${eatery.name} from favorite eateries'
                                              : 'Removed ${eatery.name} from favorite deals',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
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
