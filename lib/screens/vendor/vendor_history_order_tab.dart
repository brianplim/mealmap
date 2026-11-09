import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class VendorHistoryOrderTab extends StatefulWidget {
  const VendorHistoryOrderTab({super.key});

  @override
  State<VendorHistoryOrderTab> createState() => _VendorHistoryOrderTabState();
}

class _VendorHistoryOrderTabState extends State<VendorHistoryOrderTab> {
  @override
  Widget build(BuildContext context) {
    final historyOrders = globalOrders.where((o) => o.status.contains('Taken') || o.status.contains('Delivered') || o.status.contains('Received')).toList();

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
                  'Order History & Analytics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF7EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${historyOrders.length} Sold',
                    style: const TextStyle(color: Color(0xFF0F7A5B), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: historyOrders.isEmpty
                ? Center(
                    child: Text(
                      'No completed/received orders yet.\nFinished orders will appear here automatically!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historyOrders.length,
                    itemBuilder: (context, index) {
                      final order = historyOrders[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF7EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.check_circle, color: Color(0xFF0F7A5B), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order.id,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F7A5B)),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Completed',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.itemName,
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${order.eateryName} • ${order.price} • ${order.fulfillmentType}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF6E7D79)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date & Time: Today, 9:41 AM (Sold: 1)',
                                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
