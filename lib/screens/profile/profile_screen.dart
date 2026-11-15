import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';

class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  String _name = globalStudentName;
  String _handle = 'student@gmail.com';
  String? _imagePath;
  bool _isNetworkImage = false;

  @override
  void initState() {
    super.initState();
    _name = globalStudentName;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final email = user.email ?? 'student@gmail.com';
      setState(() {
        _handle = email;
      });
      final data = await FirestoreService.getUserProfile(user.uid);
      if (data != null && data['name'] != null && mounted) {
        setState(() {
          _name = data['name'].toString();
          globalStudentName = _name;
          _imagePath = data['avatarUrl'] ?? _imagePath;
          if (_imagePath != null && _imagePath!.startsWith('http')) {
            _isNetworkImage = true;
          }
        });
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _name);
    final handleController = TextEditingController(text: _handle);
    String? tempImagePath = _imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Student Profile'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setDialogState(() {
                                tempImagePath = pickedFile.path;
                              });
                            }
                          } catch (e) {
                            // ignore
                          }
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF0F7A5B),
                          backgroundImage: tempImagePath != null
                              ? (tempImagePath!.startsWith('http')
                                  ? NetworkImage(tempImagePath!) as ImageProvider
                                  : FileImage(File(tempImagePath!)))
                              : null,
                          child: tempImagePath == null
                              ? const Icon(Icons.camera_alt, color: Colors.white, size: 28)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: handleController,
                        enabled: false,
                        decoration: const InputDecoration(labelText: 'Gmail Address (Fixed)'),
                      ),
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
                      _name = nameController.text.trim();
                      globalStudentName = _name;
                      _imagePath = tempImagePath;
                      if (_imagePath != null && _imagePath!.startsWith('http')) {
                        _isNetworkImage = true;
                      } else {
                        _isNetworkImage = false;
                      }
                    });
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirestoreService.saveUserProfile(
                        user.uid,
                        _name,
                        _handle,
                        _imagePath ?? '',
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!')),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
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
                      ProfileStat(count: '${globalFavoriteIds.length + globalFavoriteDealIds.length}', label: 'Favorites'),
                      ProfileStat(count: '${globalNotifications.length}', label: 'Notifications'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ProfileMenuItem(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    badge: globalNotifications.isNotEmpty ? '${globalNotifications.length}' : null,
                    onTap: () async {
                      await Navigator.pushNamed(context, '/notifications');
                      setState(() {});
                    },
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
                    onTap: () async {
                      final ok = await showConfirmDialog(
                        context: context,
                        title: 'Log Out',
                        message: 'Are you sure you want to log out?',
                        confirmText: 'Log Out',
                        confirmColor: Colors.red,
                      );
                      if (ok && context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
