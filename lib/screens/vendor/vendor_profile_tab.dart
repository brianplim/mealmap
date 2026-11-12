import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class VendorProfileTab extends StatefulWidget {
  const VendorProfileTab({super.key});

  @override
  State<VendorProfileTab> createState() => _VendorProfileTabState();
}

class _VendorProfileTabState extends State<VendorProfileTab> {
  String _businessName = 'ACES Canteen Bites';
  String _handle = '@aces_canteen_tagum';
  String? _imagePath;
  bool _isNetworkImage = false;
  LatLng _businessLocation = const LatLng(7.4578, 125.7921);
  bool _showMapLocation = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await FirestoreService.getVendorProfile(user.uid);
      if (data != null && mounted) {
        setState(() {
          _businessName = data['businessName'] ?? _businessName;
          _handle = data['handle'] ?? _handle;
          _imagePath = data['logoUrl'] ?? _imagePath;
          if (data['lat'] != null && data['lng'] != null) {
            _businessLocation = LatLng(data['lat'], data['lng']);
          }
          if (_imagePath != null && _imagePath!.startsWith('http')) {
            _isNetworkImage = true;
          }
        });
        businessNameNotifier.value = '$_businessName & Deals';
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _businessName);
    final handleController = TextEditingController(text: _handle);
    LatLng tempLocation = _businessLocation;
    bool tempShowMap = _showMapLocation;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Business Profile & Location'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Business / Company Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: handleController,
                        decoration: const InputDecoration(labelText: 'Business Handle'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setDialogState(() {
                                _imagePath = pickedFile.path;
                                _isNetworkImage = false;
                              });
                            }
                          } catch (e) {
                            // ignore
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload Logo from Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F7A5B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: tempShowMap,
                            activeColor: const Color(0xFF0F7A5B),
                            onChanged: (val) => setDialogState(() => tempShowMap = val ?? true),
                          ),
                          const Text('Pinpoint Location on Map', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                      if (tempShowMap) ...[
                        const SizedBox(height: 4),
                        const Text('Tap anywhere on the map to set your business location:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: tempLocation,
                                initialZoom: 17.0,
                                onTap: (tapPosition, latLng) {
                                  setDialogState(() {
                                    tempLocation = latLng;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Business location pinpointed!')),
                                  );
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.mealmap',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: tempLocation,
                                      width: 40,
                                      height: 40,
                                      child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _businessName = nameController.text.trim();
                      _handle = handleController.text.trim();
                      _businessLocation = tempLocation;
                      _showMapLocation = tempShowMap;
                    });
                    businessNameNotifier.value = '$_businessName & Deals';
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirestoreService.saveVendorProfile(
                        user.uid,
                        _businessName,
                        _handle,
                        _imagePath ?? '',
                        _businessLocation,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Business profile & map location saved!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
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
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F7A5B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showEditProfileDialog,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: _imagePath != null
                        ? (_isNetworkImage
                            ? NetworkImage(_imagePath!) as ImageProvider
                            : FileImage(File(_imagePath!)))
                        : null,
                    child: _imagePath == null
                        ? const Icon(Icons.storefront, size: 36, color: Color(0xFF0F7A5B))
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _businessName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _handle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _vendorStat('Active Deals', '${mockEateries.length}'),
                    _vendorStat('Total Orders', '${globalOrders.length}'),
                    _vendorStat('Rating', '4.9 ★'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _menuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: _showEditProfileDialog,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: vendorNotifReadNotifier,
                  builder: (context, isRead, child) {
                    final unreadCount = isRead ? 0 : globalOrders.length;
                    return _menuItem(
                      icon: Icons.notifications_none,
                      label: 'Vendor Notifications',
                      badge: unreadCount > 0 ? '$unreadCount' : null,
                      onTap: () {
                        vendorNotifReadNotifier.value = true;
                        vendorTabNotifier.value = 2; // Navigate to Received Order tab
                      },
                    );
                  },
                ),
                _menuItem(
                  icon: Icons.map_outlined,
                  label: 'ACES College Map',
                  onTap: () => launchAcesMap(context),
                ),
                _menuItem(
                  icon: Icons.logout,
                  label: 'Log Out Vendor',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () async {
                    final ok = await showConfirmDialog(
                      context: context,
                      title: 'Log Out Vendor',
                      message: 'Are you sure you want to log out of your vendor account?',
                      confirmText: 'Log Out',
                      confirmColor: Colors.red,
                    );
                    if (ok && context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vendorStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    String? badge,
    Color textColor = const Color(0xFF1E2D2A),
    Color iconColor = const Color(0xFF0F7A5B),
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor == const Color(0xFF1E2D2A) ? Theme.of(context).colorScheme.onSurface : textColor,
                  ),
                ),
              ),
              if (badge != null && badge != '0') ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (textColor != Colors.red)
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF8E9D99)),
            ],
          ),
        ),
      ),
    );
  }
}
