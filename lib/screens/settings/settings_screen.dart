import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  late bool _darkMode;
  bool _studentVerified = true;
  bool _locationSharing = true;

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;
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
                        const Divider(height: 1),
                        SwitchListTile(
                          title: Text('Location Sharing', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('Find food spots near ACES Tagum College', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _locationSharing,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() => _locationSharing = val),
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
                        SwitchListTile(
                          title: Text('ACES Student ID Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: Text(_studentVerified ? 'Verified Student (20% Off Active)' : 'Unverified', style: TextStyle(fontSize: 12, color: _studentVerified ? const Color(0xFF0F7A5B) : Colors.red)),
                          value: _studentVerified,
                          activeTrackColor: const Color(0xFF0F7A5B),
                          activeThumbColor: Colors.white,
                          onChanged: (val) => setState(() {
                            _studentVerified = val;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_studentVerified ? 'Student ID Verified successfully!' : 'Student ID verification revoked.')),
                            );
                          }),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Change Password'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    TextField(obscureText: true, decoration: InputDecoration(labelText: 'Current Password')),
                                    SizedBox(height: 8),
                                    TextField(obscureText: true, decoration: InputDecoration(labelText: 'New Password')),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F7A5B), foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                            );
                          },
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
                          title: Text('Contact Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                          subtitle: const Text('support@mealmaptagum.ph', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Icon(Icons.support_agent, color: Theme.of(context).colorScheme.onSurface),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Support ticket opened: support@mealmaptagum.ph')),
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
