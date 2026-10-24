import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class DealsFilterScreen extends StatefulWidget {
  const DealsFilterScreen({super.key});

  @override
  State<DealsFilterScreen> createState() => _DealsFilterScreenState();
}

class _DealsFilterScreenState extends State<DealsFilterScreen> {
  String _priceFilter = 'All';
  String _cuisineFilter = 'All';
  String _distanceFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusBar(time: '9:41', color: Theme.of(context).colorScheme.onSurface),
              Row(
                children: [
                  Text(
                    'Filter Tagum Deals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Price Range',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', '₱0 - ₱50', '₱51 - ₱100', '₱101+'].map((price) {
                  return FilterChipWidget(
                    label: price,
                    selected: _priceFilter == price,
                    onSelected: () => setState(() => _priceFilter = price),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Cuisine',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Filipino', 'Fast Food', 'Asian', 'Western', 'Mexican', 'Desserts', 'Drinks'].map((cuisine) {
                  return FilterChipWidget(
                    label: cuisine,
                    selected: _cuisineFilter == cuisine,
                    onSelected: () => setState(() => _cuisineFilter = cuisine),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Distance from ACES College',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Within 500m', '1 km', '2+ km'].map((distance) {
                  return FilterChipWidget(
                    label: distance,
                    selected: _distanceFilter == distance,
                    onSelected: () => setState(() => _distanceFilter = distance),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tagum filters applied!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _priceFilter = 'All';
                    _cuisineFilter = 'All';
                    _distanceFilter = 'All';
                  }),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFF0F7A5B), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECF7EF) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0F7A5B) : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? const Color(0xFF0F7A5B) : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
