import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadEateries();
  }

  Future<void> _loadEateries() async {
    final fetched = await FirestoreService.getEateries();
    if (fetched.isNotEmpty && mounted) {
      mockEateries.clear();
      mockEateries.addAll(fetched);
      eateryNotifier.value = List.from(mockEateries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: Color(0xFF0F7A5B), size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MealMap Tagum',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Text(
                      'Tagum City, Mindanao',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6E7D79),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delivery_dining, color: Color(0xFF0F7A5B)),
                  tooltip: 'Delivery & Orders',
                  onPressed: () => Navigator.pushNamed(context, '/orders'),
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0xFF7A8A85)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search food near ACES Tagum College...',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/deals'),
                  child: Container(
                    height: 110,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F7A5B), Color(0xFF12A66B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F7A5B).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tagum Student Deals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discounts near ACES Tagum College!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'View Deals',
                                  style: TextStyle(
                                    color: Color(0xFF0F7A5B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=200&q=80',
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                placeholderImage(width: 76, height: 76),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryItem(
                      icon: Icons.grid_view,
                      label: 'All',
                      active: _selectedCategory == 'All',
                      onTap: () => setState(() => _selectedCategory = 'All'),
                    ),
                    CategoryItem(
                      icon: Icons.rice_bowl,
                      label: 'Filipino',
                      active: _selectedCategory == 'Filipino',
                      onTap: () => setState(() => _selectedCategory = 'Filipino'),
                    ),
                    CategoryItem(
                      icon: Icons.fastfood,
                      label: 'Fast Food',
                      active: _selectedCategory == 'Fast Food',
                      onTap: () => setState(() => _selectedCategory = 'Fast Food'),
                    ),
                    CategoryItem(
                      icon: Icons.coffee,
                      label: 'Coffee',
                      active: _selectedCategory == 'Coffee',
                      onTap: () => setState(() => _selectedCategory = 'Coffee'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Eateries Near ACES Tagum College',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/map'),
                      child: const Text(
                        'View Map >',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F7A5B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<List<Eatery>>(
                  valueListenable: eateryNotifier,
                  builder: (context, eateries, child) {
                    final filteredEateries = eateries.where((e) {
                      if (_selectedCategory == 'All') return true;
                      if (e.cuisine.toLowerCase().trim() == _selectedCategory.toLowerCase().trim()) return true;
                      if (_selectedCategory == 'Fast Food' && (e.cuisine.toLowerCase().contains('fast') || e.cuisine.toLowerCase().contains('mexican'))) return true;
                      return false;
                    }).toList();
                    if (filteredEateries.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No eateries posted yet.\nNew food spots & vendor deals will appear here!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: filteredEateries
                          .map((eatery) {
                            final menuItemName = eatery.menu.isNotEmpty ? eatery.menu.first.name : eatery.name;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/restaurant',
                                  arguments: eatery,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          eatery.imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              placeholderImage(width: double.infinity, height: 140),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  menuItemName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${eatery.name} • ${eatery.distance} km from ACES • ${eatery.cuisine}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF6E7D79),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      eatery.rating.toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                        color: Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (eatery.hasStudentDiscount)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECF7EF),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: const Text(
                                                      'Student Discount',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF0F7A5B),
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'View More',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(0xFF0F7A5B),
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F7A5B) : Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: active ? Colors.white : const Color(0xFF0F7A5B),
        ),
      ),
    );
  }
}
