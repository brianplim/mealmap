import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class DailyDealsScreenContent extends StatefulWidget {
  const DailyDealsScreenContent({super.key});

  @override
  State<DailyDealsScreenContent> createState() => _DailyDealsScreenContentState();
}

class _DailyDealsScreenContentState extends State<DailyDealsScreenContent> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tagum Daily Deals',
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
            child: Row(
              children: [
                DealChip(
                  label: 'All',
                  active: _filter == 'All',
                  onTap: () => setState(() => _filter = 'All'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'Discounts',
                  active: _filter == 'Discounts',
                  onTap: () => setState(() => _filter = 'Discounts'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'Specials',
                  active: _filter == 'Specials',
                  onTap: () => setState(() => _filter = 'Specials'),
                ),
                const SizedBox(width: 8),
                DealChip(
                  label: 'New',
                  active: _filter == 'New',
                  onTap: () => setState(() => _filter = 'New'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ValueListenableBuilder<List<Eatery>>(
              valueListenable: eateryNotifier,
              builder: (context, eateries, child) {
                final dealEateries = eateries.where((e) {
                  if (_filter == 'All') return true;
                  if (_filter == 'Discounts') return e.hasStudentDiscount || e.dealType == 'Discounts';
                  if (_filter == 'Specials') return e.dealType == 'Specials';
                  if (_filter == 'New') return true; // Shows all new posted orders
                  return true;
                }).toList();

                if (dealEateries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No $_filter deals posted yet.\nCheck back soon for new student offers!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dealEateries.length,
                  itemBuilder: (context, index) {
                    final eatery = dealEateries[index];
                    final firstMenuItem = eatery.menu.isNotEmpty ? eatery.menu.first.name : 'Special Meal';
                    final firstPrice = eatery.menu.isNotEmpty ? eatery.menu.first.price : '';

                    String badgeLabel = 'STUDENT DEAL';
                    if (_filter == 'New' || eatery.dealType == 'New') {
                      badgeLabel = 'NEW OFFER';
                    } else if (_filter == 'Specials' || eatery.dealType == 'Specials') {
                      badgeLabel = 'SPECIAL';
                    }

                    return DealItemCard(
                      title: eatery.name,
                      cuisine: '${eatery.cuisine} • ${eatery.distance} km near ACES',
                      dealText: '$firstMenuItem - $firstPrice (${eatery.description})',
                      badge: badgeLabel,
                      image: eatery.imageUrl,
                      onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: eatery),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DealChip extends StatelessWidget {
  const DealChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0F7A5B) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF0F7A5B) : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class DealItemCard extends StatelessWidget {
  const DealItemCard({
    super.key,
    required this.title,
    required this.cuisine,
    required this.dealText,
    required this.badge,
    this.badgeColor = const Color(0xFF0F7A5B),
    required this.image,
    required this.onTap,
  });

  final String title;
  final String cuisine;
  final String dealText;
  final String badge;
  final Color badgeColor;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      placeholderImage(width: 65, height: 65),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cuisine,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dealText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
