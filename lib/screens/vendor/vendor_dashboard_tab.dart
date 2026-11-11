import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class VendorDashboardTab extends StatefulWidget {
  const VendorDashboardTab({super.key});

  @override
  State<VendorDashboardTab> createState() => _VendorDashboardTabState();
}

class _VendorDashboardTabState extends State<VendorDashboardTab> {
  void _showEateryDetailDialog(BuildContext context, Eatery eatery) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(eatery.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    eatery.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => placeholderImage(width: double.infinity, height: 160),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cuisine Category: ${eatery.cuisine}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Description / Deal:\n${eatery.description}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                if (eatery.menu.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Menu Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ...eatery.menu.map((m) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text('• ${m.name}'),
                            const Spacer(),
                            Text(m.price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B))),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

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
                final vendorEateries = currentUserEmail != null
                    ? eateries.where((e) => e.vendorEmail == currentUserEmail).toList()
                    : <Eatery>[];

                final vendorOrders = currentUserEmail != null
                    ? globalOrders.where((o) => o.vendorEmail == currentUserEmail).toList()
                    : <FoodOrder>[];

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
                              _statBox('Active Posts', '${vendorEateries.length}'),
                              _statBox('Orders', '${vendorOrders.length}'),
                              _statBox('Sold Today', '${vendorOrders.where((o) => o.status.contains('Received') || o.status.contains('Taken')).length}'),
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
                    if (vendorEateries.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No active posts yet.\nUse "Create Order" tab to post your first menu item!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          ),
                        ),
                      )
                    else
                      ...vendorEateries.map((eatery) => InkWell(
                            onTap: () => _showEateryDetailDialog(context, eatery),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
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
                                      FirestoreService.deleteEatery(eatery.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Removed ${eatery.name} from student feed')),
                                      );
                                    },
                                  ),
                                ],
                              ),
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
