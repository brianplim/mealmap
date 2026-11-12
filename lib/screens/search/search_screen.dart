import 'package:flutter/material.dart';

import '../../models/app_models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Map<String, String>? _appliedFilters;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final result = await Navigator.pushNamed(context, '/filter');
    if (result != null && result is Map<String, String>) {
      setState(() {
        _appliedFilters = result;
      });
    }
  }

  bool get _hasActiveFilters {
    if (_appliedFilters == null) return false;
    return (_appliedFilters!['cuisine'] != 'All') ||
        (_appliedFilters!['price'] != 'All') ||
        (_appliedFilters!['distance'] != 'All');
  }

  @override
  Widget build(BuildContext context) {
    final results = eateryNotifier.value.where((e) {
      final q = _query.toLowerCase();
      final matchesName = e.name.toLowerCase().contains(q);
      final matchesCuisine = e.cuisine.toLowerCase().contains(q);
      final matchesMenu = e.menu.any((m) => m.name.toLowerCase().contains(q));
      final matchesQuery = matchesName || matchesCuisine || matchesMenu;

      if (!matchesQuery) return false;

      if (_appliedFilters != null) {
        final cuisineFilter = _appliedFilters!['cuisine'];
        if (cuisineFilter != null && cuisineFilter != 'All') {
          if (!e.cuisine.toLowerCase().contains(cuisineFilter.toLowerCase())) {
            return false;
          }
        }

        final distanceFilter = _appliedFilters!['distance'];
        if (distanceFilter != null && distanceFilter != 'All') {
          if (distanceFilter == 'Within 500m' && e.distance > 0.5) return false;
          if (distanceFilter == '1 km' && e.distance > 1.0) return false;
        }
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (val) => setState(() => _query = val),
                      decoration: InputDecoration(
                        hintText:
                            'Search Eateries,Fast Food,Desserts,Drinks...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF0F7A5B),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.tune,
                                color: _hasActiveFilters
                                    ? Colors.orange
                                    : const Color(0xFF0F7A5B),
                                size: 20,
                              ),
                              onPressed: _openFilters,
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_hasActiveFilters) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Active Filters: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_appliedFilters!['cuisine'] != 'All')
                              _filterTag('Cuisine: ${_appliedFilters!['cuisine']}', () {
                                setState(() => _appliedFilters!['cuisine'] = 'All');
                              }),
                            if (_appliedFilters!['price'] != 'All')
                              _filterTag('Price: ${_appliedFilters!['price']}', () {
                                setState(() => _appliedFilters!['price'] = 'All');
                              }),
                            if (_appliedFilters!['distance'] != 'All')
                              _filterTag('Distance: ${_appliedFilters!['distance']}', () {
                                setState(() => _appliedFilters!['distance'] = 'All');
                              }),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _appliedFilters = null),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No food spots found for "$_query"',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final eatery = results[index];
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
                                      eatery.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              placeholderImage(
                                                width: 60,
                                                height: 60,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eatery.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${eatery.cuisine} • ${eatery.distance} km near ACES',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6E7D79),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 12,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              eatery.rating.toString(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF8E9D99),
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
      ),
    );
  }

  Widget _filterTag(String label, VoidCallback onClear) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECF7EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0F7A5B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F7A5B),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 12, color: Color(0xFF0F7A5B)),
          ),
        ],
      ),
    );
  }
}
