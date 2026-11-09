import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/app_models.dart';

class MapScreenContent extends StatelessWidget {
  const MapScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<List<Eatery>>(
              valueListenable: eateryNotifier,
              builder: (context, eateries, child) {
                return FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(7.4575, 125.7925),
                    initialZoom: 18.5,
                    minZoom: 5.0,
                    maxZoom: 20.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mealmap',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(7.4578, 125.7921),
                          width: 130,
                          height: 90,
                          child: GestureDetector(
                            onTap: () => launchAcesMap(context),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                                  ),
                                  child: const Text('Aces Tagum College', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1E2D2A))),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.school, color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...globalVendorPins.map((pin) => Marker(
                              point: pin.location,
                              width: 80,
                              height: 80,
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: pin.eatery),
                                child: _eateryMarkerContent(),
                              ),
                            )),
                        ...eateries.map((eatery) {
                          final coords = [
                            const LatLng(7.4568, 125.7925),
                            const LatLng(7.4575, 125.7915),
                            const LatLng(7.4582, 125.7928),
                            const LatLng(7.4565, 125.7938),
                            const LatLng(7.4572, 125.7930),
                            const LatLng(7.4585, 125.7920),
                          ];
                          final idx = eateries.indexOf(eatery) % coords.length;
                          return Marker(
                            point: coords[idx],
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: eatery),
                              child: _eateryMarkerContent(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).cardColor,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food Map',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Text(
                            'Pioneer Avenue • Aces Tagum College',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5A6A64),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface, size: 20),
                          onPressed: () => Navigator.pushNamed(context, '/filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/deals'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EFE3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ramen_dining, color: Color(0xFF0F7A5B), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cuisine & Student Deals',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Pioneer Avenue • Tagum City',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                'Explore food spots',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F7A5B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eateryMarkerContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}
