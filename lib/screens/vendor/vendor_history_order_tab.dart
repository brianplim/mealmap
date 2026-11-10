import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class VendorHistoryOrderTab extends StatefulWidget {
  const VendorHistoryOrderTab({super.key});

  @override
  State<VendorHistoryOrderTab> createState() => _VendorHistoryOrderTabState();
}

class _VendorHistoryOrderTabState extends State<VendorHistoryOrderTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyOrders = globalOrders
        .where((o) => o.status.contains('Taken') || o.status.contains('Delivered') || o.status.contains('Received'))
        .where((o) {
      final q = _query.toLowerCase();
      final matchesQuery = o.id.toLowerCase().contains(q) ||
          o.itemName.toLowerCase().contains(q) ||
          o.eateryName.toLowerCase().contains(q) ||
          o.timestamp.toLowerCase().contains(q);

      if (_selectedFilter == 'Today') {
        return matchesQuery && (o.timestamp.contains('Today') || o.timestamp.contains('min') || o.timestamp.contains('hour') || o.timestamp.contains('now') || o.timestamp.contains('Just'));
      } else if (_selectedFilter == 'Order Code') {
        return matchesQuery && o.id.toLowerCase().contains(q);
      }
      return matchesQuery;
    }).toList();

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
                Expanded(
                  child: Text(
                    'Order History & Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _query = val),
                    decoration: InputDecoration(
                      hintText: 'Search by order code (e.g. ORD-002) or date...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0F7A5B), size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F7A5B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                  onSelected: (val) => setState(() => _selectedFilter = val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'All', child: Text('All Orders')),
                    const PopupMenuItem(value: 'Today', child: Text('Today (Date)')),
                    const PopupMenuItem(value: 'Order Code', child: Text('Order Code (e.g. ORD-002)')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: historyOrders.isEmpty
                ? Center(
                    child: Text(
                      'No matching orders found for "$_query"',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    'Date & Time: ${order.timestamp} (Sold: 1)',
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
