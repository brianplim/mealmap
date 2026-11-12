import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class VendorReceivedOrderTab extends StatefulWidget {
  const VendorReceivedOrderTab({super.key});

  @override
  State<VendorReceivedOrderTab> createState() => _VendorReceivedOrderTabState();
}

class _VendorReceivedOrderTabState extends State<VendorReceivedOrderTab> {
  void _showPrepTimeDialog(BuildContext context, FoodOrder order, {bool isDelivery = false}) {
    final times = ['5 mins', '10 mins', '15 mins', '20 mins', '30 mins', '45 mins'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isDelivery ? 'Set Delivery Arrival Time' : 'Set Preparation Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: times.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                setState(() {
                  order.prepTime = t;
                  if (isDelivery) {
                    order.status = 'Out for Delivery (Arriving in $t)';
                  } else {
                    order.status = 'Preparing (Ready in $t)';
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isDelivery ? 'Delivery time set to $t!' : 'Prep time set to $t!')),
                );
              },
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Received Orders (Incoming)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (globalOrders.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${globalOrders.length} Active',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: globalOrders.isEmpty
                ? Center(
                    child: Text(
                      'No student orders yet.\nNew orders placed by students will appear here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: globalOrders.length,
                    itemBuilder: (context, index) {
                      final order = globalOrders[index];
                      final isReceived = order.status.contains('Taken') || order.status.contains('Delivered') || order.status.contains('Received');
                      final isPreparing = order.status.contains('Preparing');
                      final isDelivering = order.status.contains('Delivery') || order.status.contains('Out');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F7A5B)),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: isReceived,
                                      onChanged: null,
                                      activeColor: Colors.green,
                                    ),
                                    Text(
                                      isReceived ? 'Received by Student' : 'Not Received Yet',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isReceived ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.itemName,
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order.eateryName} • ${order.price} • ${order.fulfillmentType}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6E7D79)),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF7EF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF0F7A5B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Prep / Arrival Time: ${order.prepTime}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${order.status}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isReceived ? Colors.green : Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: isReceived ? null : () => _showPrepTimeDialog(context, order, isDelivery: false),
                                  icon: Icon(Icons.kitchen, size: 16, color: isReceived ? Colors.grey : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey)),
                                  label: Text(isPreparing ? 'Preparing (${order.prepTime})' : 'Preparing (Set Time)', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isReceived ? Colors.grey : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey),
                                    side: BorderSide(color: isReceived ? Colors.grey[300]! : (isPreparing ? const Color(0xFF0F7A5B) : Colors.grey[300]!)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: isReceived ? null : () => _showPrepTimeDialog(context, order, isDelivery: true),
                                  icon: Icon(Icons.delivery_dining, size: 16, color: isReceived ? Colors.grey : (isDelivering ? Colors.blue : Colors.grey)),
                                  label: Text(isDelivering ? 'Delivering (${order.prepTime})' : 'Delivering (Set Time)', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isReceived ? Colors.grey : (isDelivering ? Colors.blue : Colors.grey),
                                    side: BorderSide(color: isReceived ? Colors.grey[300]! : (isDelivering ? Colors.blue : Colors.grey[300]!)),
                                  ),
                                ),
                              ],
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
