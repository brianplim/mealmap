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
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(7.4478, 125.8090),
                initialZoom: 16.0,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mealmap',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(7.4478, 125.8090),
                      width: 110,
                      height: 85,
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
                              child: const Text('ACES SCHOOL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1E2D2A))),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                              child: const Icon(Icons.school, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Marker(
                      point: const LatLng(7.4490, 125.8105),
                      width: 110,
                      height: 85,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[0]),
                        child: _eateryMarkerContent('Sisig & Rice'),
                      ),
                    ),
                    Marker(
                      point: const LatLng(7.4465, 125.8075),
                      width: 110,
                      height: 85,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[1]),
                        child: _eateryMarkerContent('Lutong Bahay'),
                      ),
                    ),
                    Marker(
                      point: const LatLng(7.4455, 125.8115),
                      width: 110,
                      height: 85,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[2]),
                        child: _eateryMarkerContent('BBQ & Inihaw'),
                      ),
                    ),
                    Marker(
                      point: const LatLng(7.4440, 125.8060),
                      width: 110,
                      height: 85,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[4]),
                        child: _eateryMarkerContent('Halo-Halo'),
                      ),
                    ),
                    Marker(
                      point: const LatLng(7.4485, 125.8120),
                      width: 110,
                      height: 85,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[5]),
                        child: _eateryMarkerContent('Coffee Shop'),
                      ),
                    ),
                  ],
                ),
              ],
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
                            'Tagum City, Mindanao, Philippines',
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
                            'Filipino Food Nearby',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Near ACES School • Tagum City',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                'Sample food spots',
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

  Widget _eateryMarkerContent(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F7A5B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
            ],
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 2),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1E2D2A)),
          ),
        ),
      ],
    );
  }
}
