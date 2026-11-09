import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';

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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _businessName);
    final handleController = TextEditingController(text: _handle);
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Business Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Or Logo Image URL',
                    hintText: 'https://example.com/logo.jpg',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _imagePath = pickedFile.path;
                          _isNetworkImage = false;
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Business logo updated from gallery!')),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gallery picker note: Use Image URL below (${e.toString()})')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Upload Logo from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _businessName = nameController.text.trim();
                  _handle = handleController.text.trim();
                  if (urlController.text.trim().isNotEmpty) {
                    _imagePath = urlController.text.trim();
                    _isNetworkImage = true;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Business profile updated successfully!')),
                );
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
                  icon: Icons.storefront,
                  label: 'Business Settings',
                  onTap: _showEditProfileDialog,
                ),
                _menuItem(
                  icon: Icons.notifications_none,
                  label: 'Vendor Notifications',
                  badge: '${globalOrders.length}',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All vendor notifications checked')),
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
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
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
