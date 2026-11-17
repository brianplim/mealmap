import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class AdminPortalShell extends StatefulWidget {
  const AdminPortalShell({super.key});

  @override
  State<AdminPortalShell> createState() => _AdminPortalShellState();
}

class _AdminPortalShellState extends State<AdminPortalShell> {
  int _tabIndex = 0; // 0: Overview, 1: Pending Approvals, 2: Active Eateries, 3: System Orders
  static String? globalAdminImagePath;
  static bool globalAdminIsNetworkImage = false;

  @override
  void initState() {
    super.initState();
    _loadEateries();
  }

  Future<void> _loadEateries() async {
    final fetched = await FirestoreService.getEateries();
    if (fetched.isNotEmpty && mounted) {
      mockEateries.clear();
      mockEateries.addAll(fetched);
      eateryNotifier.value = List.from(mockEateries);
      setState(() {});
    }
  }

  void _showAdminProfileDialog(BuildContext context) {
    final pendingCount = mockEateries.where((e) => !e.isApproved).length;
    final activeCount = mockEateries.where((e) => e.isApproved).length;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.admin_panel_settings, color: Color(0xFF0F7A5B)),
                  SizedBox(width: 8),
                  Text('Admin Profile'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setDialogState(() {
                              globalAdminImagePath = pickedFile.path;
                              globalAdminIsNetworkImage = false;
                            });
                            setState(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Admin profile picture updated!')),
                              );
                            }
                          }
                        } catch (e) {
                          // ignore
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: const Color(0xFF0F7A5B),
                            backgroundImage: globalAdminImagePath != null
                                ? (globalAdminIsNetworkImage
                                    ? NetworkImage(globalAdminImagePath!) as ImageProvider
                                    : FileImage(File(globalAdminImagePath!)))
                                : null,
                            child: globalAdminImagePath == null
                                ? const Icon(Icons.security, size: 40, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF0F7A5B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'MealMap Super Administrator',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'admin@mealmap.com',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(height: 24),
                  Text('• Active Published Eateries: $activeCount', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('• Pending Vendor Approvals: $pendingCount', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('• System Orders Recorded: ${globalOrders.length}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                  GestureDetector(
                    onTap: () => _showAdminProfileDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'MealMap Administrator',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Log Out Admin',
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        context: context,
                        title: 'Log Out Administrator',
                        message: 'Are you sure you want to log out from MealMap Administrator?',
                        confirmText: 'Log Out',
                      );
                      if (ok && context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    },
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
                              'Pending (${mockEateries.where((e) => !e.isApproved && !e.isDeletionRequested).length})',
                              style: TextStyle(
                                color: _tabIndex == 1 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
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
                              'Deletion (${mockEateries.where((e) => e.isDeletionRequested).length})',
                              style: TextStyle(
                                color: _tabIndex == 2 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
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
                              'Active (${mockEateries.where((e) => e.isApproved && !e.isDeletionRequested).length})',
                              style: TextStyle(
                                color: _tabIndex == 3 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 4 ? const Color(0xFF0F7A5B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Orders (${globalOrders.length})',
                              style: TextStyle(
                                color: _tabIndex == 4 ? Colors.white : const Color(0xFF6E7D79),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
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
                  : (_tabIndex == 1
                      ? _buildPendingTab()
                      : (_tabIndex == 2
                          ? _buildDeletionRequestsTab()
                          : (_tabIndex == 3 ? _buildEateriesTab() : _buildOrdersTab()))),
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

  void _showPendingEateryDetailDialog(BuildContext context, Eatery eatery) {
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
                  child: displayEateryImage(eatery.imageUrl, width: double.infinity, height: 160),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cuisine: ${eatery.cuisine}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vendor Email: ${eatery.vendorEmail ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  'Description / Offer:\n${eatery.description}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E2D2A)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Delivery Fee: ${eatery.deliveryFee}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if (eatery.menu.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Submitted Menu Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  eatery.isApproved = true;
                });
                FirestoreService.uploadEatery(eatery, eatery.location);
                eateryNotifier.value = List.from(mockEateries);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved "${eatery.name}"! Now live on student feeds.')));
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingTab() {
    final pending = mockEateries.where((e) => !e.isApproved && !e.isDeletionRequested).toList();
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
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showPendingEateryDetailDialog(context, eatery),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: displayEateryImage(eatery.imageUrl, width: 60, height: 60),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(menuItemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${eatery.name} • ${eatery.cuisine}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        const Text('Tap to review details', style: TextStyle(fontSize: 10, color: Color(0xFF0F7A5B), fontStyle: FontStyle.italic)),
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
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        context: context,
                        title: 'Reject Pending Post',
                        message: 'Are you sure you want to reject and delete "${eatery.name}"?',
                        confirmText: 'Reject',
                      );
                      if (ok) {
                        mockEateries.removeWhere((e) => e.id == eatery.id);
                        eateryNotifier.value = List.from(mockEateries);
                        FirestoreService.deleteEatery(eatery.id);
                        setState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rejected "${eatery.name}"')));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeletionRequestsTab() {
    final deletionRequests = mockEateries.where((e) => e.isDeletionRequested).toList();
    if (deletionRequests.isEmpty) {
      return const Center(child: Text('No pending deletion requests from vendors.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deletionRequests.length,
      itemBuilder: (context, index) {
        final eatery = deletionRequests[index];
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
                  child: displayEateryImage(eatery.imageUrl, width: 60, height: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(menuItemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${eatery.name} • Vendor: ${eatery.vendorEmail ?? 'N/A'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      const Text('⏳ Requested Deletion', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10)),
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context: context,
                      title: 'Approve Deletion',
                      message: 'Are you sure you want to permanently delete "${eatery.name}" as requested by vendor?',
                      confirmText: 'Delete Permanently',
                    );
                    if (ok && context.mounted) {
                      mockEateries.removeWhere((e) => e.id == eatery.id);
                      globalVendorPins.removeWhere((pin) => pin.id == eatery.id);
                      eateryNotifier.value = List.from(mockEateries);
                      FirestoreService.deleteEatery(eatery.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permanently deleted "${eatery.name}"')));
                    }
                  },
                  child: const Text('Delete', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.grey),
                  tooltip: 'Cancel Request',
                  onPressed: () {
                    setState(() {
                      eatery.isDeletionRequested = false;
                    });
                    FirestoreService.uploadEatery(eatery, eatery.location);
                    eateryNotifier.value = List.from(mockEateries);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancelled deletion request for "${eatery.name}"')));
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
    final active = mockEateries.where((e) => e.isApproved && !e.isDeletionRequested).toList();
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
              child: displayEateryImage(eatery.imageUrl, width: 50, height: 50),
            ),
            title: Text(eatery.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${eatery.cuisine} • ${eatery.distance} km • Rating: ${eatery.rating}★'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context: context,
                  title: 'Delete Active Eatery',
                  message: 'Are you sure you want to delete "${eatery.name}" from the student feed and system?',
                  confirmText: 'Delete',
                );
                if (ok) {
                  mockEateries.removeWhere((e) => e.id == eatery.id);
                  eateryNotifier.value = List.from(mockEateries);
                  FirestoreService.deleteEatery(eatery.id);
                  setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${eatery.name} as Admin')));
                  }
                }
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
