import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
  }

  Future<void> _changePassword() async {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && passwordController.text.trim().isNotEmpty) {
                  await user.updatePassword(passwordController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid new password')));
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating password: ${e.toString()}')));
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final ok = await showConfirmDialog(
      context: context,
      title: 'Delete Account Permanently',
      message: 'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be erased.',
      confirmText: 'Delete Permanently',
      confirmColor: Colors.red,
    );

    if (!ok) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account permanently deleted.')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Get alerts on new student deals in Tagum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _pushNotifications,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() => _pushNotifications = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Use dark appearance mode', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _darkMode,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) {
                            setState(() {
                              _darkMode = val;
                              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_darkMode ? 'Dark mode enabled!' : 'Light mode enabled!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Account & Verification',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
                          onTap: _changePassword,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red)),
                          subtitle: const Text('Permanently remove your account and data', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: const Icon(Icons.delete_forever, color: Colors.red),
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About & Support',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('About MealMap Tagum', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Version 1.0.0 • ACES Tagum College Edition', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'MealMap Tagum',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 MealMap Team\nTagum City, Mindanao, Philippines',
                              children: [
                                const SizedBox(height: 10),
                                const Text('Designed specifically for ACES Tagum College students to discover food spots, student discounts, and navigate local eateries.'),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Contact Support (Gmail & Socials)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('support@mealmaptagum.ph • FB: facebook.com/mealmaptagum', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Contact Support & Socials'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('• Support Gmail: support@mealmaptagum.ph', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6),
                                    Text('• Facebook Page: facebook.com/mealmaptagum', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6),
                                    Text('• Messenger: m.me/mealmaptagum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
