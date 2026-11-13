import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class AdminPortalShell extends StatefulWidget {
  const AdminPortalShell({super.key});

  @override
  State<AdminPortalShell> createState() => _AdminPortalShellState();
}

class _AdminPortalShellState extends State<AdminPortalShell> {
  int _tabIndex = 0; // 0: Overview, 1: Pending Approvals, 2: Active Eateries, 3: System Orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: const Color(0xFF0F7A5B),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
                  const SizedBox(width: 10),
                  const Text(
                    'MealMap Administrator',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Log Out Admin',
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? const Color(0xFF0F7A5B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Overview',
                              style: TextStyle(
                                color: _tabIndex == 0 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? const Color(0xFF0F7A5B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Pending (${mockEateries.where((e) => !e.isApproved).length})',
                              style: TextStyle(
                                color: _tabIndex == 1 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 2 ? const Color(0xFF0F7A5B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Active (${mockEateries.where((e) => e.isApproved).length})',
                              style: TextStyle(
                                color: _tabIndex == 2 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 3 ? const Color(0xFF0F7A5B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Orders (${globalOrders.length})',
                              style: TextStyle(
                                color: _tabIndex == 3 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? _buildOverviewTab()
                  : (_tabIndex == 1 ? _buildPendingTab() : (_tabIndex == 2 ? _buildEateriesTab() : _buildOrdersTab())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final pendingCount = mockEateries.where((e) => !e.isApproved).length;
    final activeCount = mockEateries.where((e) => e.isApproved).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Statistics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F7A5B))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Pending', '$pendingCount'),
                  _statItem('Active Posts', '$activeCount'),
                  _statItem('Orders', '${globalOrders.length}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Admin Quick Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        ListTile(
          tileColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.pending_actions, color: Colors.orange),
          title: Text('Review Pending Vendor Posts ($pendingCount)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => _tabIndex = 1),
        ),
        const SizedBox(height: 10),
        ListTile(
          tileColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.restaurant, color: Color(0xFF0F7A5B)),
          title: const Text('Manage Active Published Eateries & Deals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => _tabIndex = 2),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    final pending = mockEateries.where((e) => !e.isApproved).toList();
    if (pending.isEmpty) {
      return const Center(child: Text('No pending vendor posts awaiting approval.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final eatery = pending[index];
        final menuItemName = eatery.menu.isNotEmpty ? eatery.menu.first.name : eatery.name;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(eatery.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholderImage(width: 60, height: 60)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(menuItemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${eatery.name} • ${eatery.cuisine}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                  onPressed: () {
                    setState(() {
                      eatery.isApproved = true;
                    });
                    FirestoreService.uploadEatery(eatery, eatery.location);
                    eateryNotifier.value = List.from(mockEateries);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved "${eatery.name}"! Now live on student feeds.')));
                  },
                  child: const Text('Approve', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    mockEateries.removeWhere((e) => e.id == eatery.id);
                    eateryNotifier.value = List.from(mockEateries);
                    FirestoreService.deleteEatery(eatery.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejected "${eatery.name}"')));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEateriesTab() {
    final active = mockEateries.where((e) => e.isApproved).toList();
    if (active.isEmpty) {
      return const Center(child: Text('No active eateries published.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: active.length,
      itemBuilder: (context, index) {
        final eatery = active[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(eatery.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholderImage(width: 50, height: 50)),
            ),
            title: Text(eatery.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${eatery.cuisine} • ${eatery.distance} km • Rating: ${eatery.rating}★'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                mockEateries.removeWhere((e) => e.id == eatery.id);
                eateryNotifier.value = List.from(mockEateries);
                FirestoreService.deleteEatery(eatery.id);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${eatery.name} as Admin')));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    if (globalOrders.isEmpty) {
      return const Center(child: Text('No orders recorded in the system yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: globalOrders.length,
      itemBuilder: (context, index) {
        final order = globalOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.receipt, color: Color(0xFF0F7A5B)),
            title: Text('${order.id} - ${order.itemName}'),
            subtitle: Text('${order.eateryName} • ${order.price} • ${order.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  globalOrders.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order removed by Admin')));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F7A5B))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
