import 'package:flutter/material.dart';
import 'vendor_dashboard_tab.dart';
import 'vendor_create_order_tab.dart';
import 'vendor_received_order_tab.dart';
import 'vendor_history_order_tab.dart';
import 'vendor_profile_tab.dart';
import '../../models/app_models.dart';

class VendorPortalShell extends StatefulWidget {
  const VendorPortalShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<VendorPortalShell> createState() => _VendorPortalShellState();
}

class _VendorPortalShellState extends State<VendorPortalShell> {
  @override
  void initState() {
    super.initState();
    vendorTabNotifier.value = widget.initialTab;
    vendorTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    vendorTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  final List<Widget> _tabs = const [
    VendorDashboardTab(),
    VendorCreateOrderTab(),
    VendorReceivedOrderTab(),
    VendorHistoryOrderTab(),
    VendorProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[vendorTabNotifier.value],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: vendorTabNotifier.value,
          onTap: (index) => vendorTabNotifier.value = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: const Color(0xFF0F7A5B),
          unselectedItemColor: const Color(0xFF8E9D99),
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Create Order'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Received Order'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
