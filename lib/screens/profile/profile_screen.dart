import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';

class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  String _name = 'Tagum Student';
  String _handle = '@tagum_student23';
  String? _imagePath;
  bool _isNetworkImage = false;

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final handleController = TextEditingController(text: _handle);
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: handleController,
                  decoration: const InputDecoration(labelText: 'Username / Handle'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Or Profile Image URL',
                    hintText: 'https://example.com/photo.jpg',
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
                            const SnackBar(content: Text('Profile picture updated from gallery!')),
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
                  label: const Text('Upload from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Or choose a preset avatar:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _presetAvatarButton('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', '1'),
                    _presetAvatarButton('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', '2'),
                    _presetAvatarButton('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80', '3'),
                  ],
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
                  _name = nameController.text.trim();
                  _handle = handleController.text.trim();
                  if (urlController.text.trim().isNotEmpty) {
                    _imagePath = urlController.text.trim();
                    _isNetworkImage = true;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
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

  Widget _presetAvatarButton(String url, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _imagePath = url;
          _isNetworkImage = true;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preset avatar selected!')),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        ? const Icon(Icons.person, size: 36, color: Color(0xFF0F7A5B))
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _name,
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
                    ProfileStat(count: '${globalFavoriteIds.length}', label: 'Favorites'),
                    const ProfileStat(count: '6', label: 'Deals Viewed'),
                    const ProfileStat(count: '2', label: 'Notifications'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ProfileMenuItem(
                  icon: Icons.delivery_dining,
                  label: 'Delivery & Orders Status',
                  badge: '${globalOrders.where((o) => !o.status.contains('Taken') && !o.status.contains('Delivered')).length}',
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                ProfileMenuItem(
                  icon: Icons.favorite_border,
                  label: 'My Favorites',
                  badge: '${globalFavoriteIds.length}',
                  onTap: () async {
                    await Navigator.pushNamed(context, '/favorites');
                    setState(() {});
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.local_offer_outlined,
                  label: 'My Deals',
                  onTap: () => Navigator.pushNamed(context, '/deals'),
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  badge: '3',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                ProfileMenuItem(
                  icon: Icons.map_outlined,
                  label: 'ACES College Map',
                  onTap: () => launchAcesMap(context),
                ),
                ProfileMenuItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.count, required this.label});

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
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
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.textColor = const Color(0xFF1E2D2A),
    this.iconColor = const Color(0xFF0F7A5B),
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor == const Color(0xFF1E2D2A) ? Theme.of(context).colorScheme.onSurface : textColor,
                      ),
                    ),
                  ],
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
                    badge!,
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
