import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class VendorDashboardTab extends StatefulWidget {
  const VendorDashboardTab({super.key});

  @override
  State<VendorDashboardTab> createState() => _VendorDashboardTabState();
}

class _VendorDashboardTabState extends State<VendorDashboardTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Vendor Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Exit Portal',
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Eatery>>(
              valueListenable: eateryNotifier,
              builder: (context, eateries, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F7A5B), Color(0xFF12A66B)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront, color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ValueListenableBuilder<String>(
                                  valueListenable: businessNameNotifier,
                                  builder: (context, name, child) {
                                    return Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statBox('Active Posts', '${eateries.length}'),
                              _statBox('Orders', '${globalOrders.length}'),
                              _statBox('Sold Today', '24'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Posts & Active Specials',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E2D2A)),
                    ),
                    const SizedBox(height: 12),
                    ...eateries.map((eatery) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  eatery.imageUrl,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => placeholderImage(width: 55, height: 55),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eatery.name,
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      eatery.description,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECF7EF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        eatery.hasStudentDiscount ? 'Student Discount Active' : 'Regular',
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  mockEateries.removeWhere((item) => item.id == eatery.id);
                                  globalVendorPins.removeWhere((pin) => pin.id == eatery.id);
                                  eateryNotifier.value = List.from(mockEateries);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Removed ${eatery.name} from student feed')),
                                  );
                                },
                              ),
                            ],
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
