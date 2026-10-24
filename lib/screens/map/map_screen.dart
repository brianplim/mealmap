import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class MapScreenContent extends StatelessWidget {
  const MapScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFD9E7DC),
              child: Stack(
                children: [
                  Positioned(top: 50, left: 150, width: 150, height: 180, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 250, left: 230, width: 130, height: 160, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 520, left: 30, width: 140, height: 150, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),
                  Positioned(top: 660, left: 190, width: 160, height: 140, child: Container(decoration: BoxDecoration(color: const Color(0xFFCEE0D2), borderRadius: BorderRadius.circular(24)))),

                  Positioned(
                    top: 170,
                    left: -50,
                    right: -50,
                    height: 45,
                    child: Transform.rotate(
                      angle: -0.12,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 350,
                    left: -50,
                    right: -50,
                    height: 42,
                    child: Transform.rotate(
                      angle: 0.18,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 520,
                    left: -50,
                    right: -50,
                    height: 46,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 110,
                    width: 44,
                    child: Transform.rotate(
                      angle: 0.22,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 100,
                    width: 48,
                    child: Transform.rotate(
                      angle: -0.25,
                      child: Container(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  statusBar(time: '9:41', color: const Color(0xFF1E2D2A)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2D2A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Food Map',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E2D2A),
                            ),
                          ),
                          Text(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Color(0xFF1E2D2A), size: 20),
                          onPressed: () => Navigator.pushNamed(context, '/filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GreenFoodPin(
            label: 'BBQ & Inihaw',
            top: 230,
            left: 115,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[2]),
          ),
          GreenFoodPin(
            label: 'Lutong Bahay',
            top: 215,
            left: 210,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[1]),
          ),
          Positioned(
            top: 410,
            left: 185,
            child: GestureDetector(
              onTap: () => launchAcesMap(context),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -38,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                        ],
                      ),
                      child: const Text(
                        'NEAR ACES SCHOOL',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF1E2D2A)),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                          ],
                        ),
                        child: const Text(
                          'ACES School',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E2D2A)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GreenFoodPin(
            label: 'Sisig & Rice',
            top: 555,
            left: 110,
            onTap: () => Navigator.pushNamed(context, '/restaurant', arguments: mockEateries[0]),
          ),
          GreenFoodPin(
            label: 'Halo-Halo',
            top: 615,
            left: 225,
            onTap: () => launchAcesMap(context),
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
                  color: Colors.white,
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
                          const Text(
                            'Filipino Food Nearby',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1E2D2A),
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
                    const Icon(Icons.chevron_right, color: Color(0xFF1E2D2A), size: 22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GreenFoodPin extends StatelessWidget {
  const GreenFoodPin({
    super.key,
    required this.label,
    required this.top,
    required this.left,
    required this.onTap,
  });

  final String label;
  final double top;
  final double left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F7A5B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E2D2A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
