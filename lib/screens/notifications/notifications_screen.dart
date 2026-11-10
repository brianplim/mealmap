import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                    'Notifications',
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
              child: globalNotifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet.\nNew deals and discounts from vendors will appear here!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: globalNotifications.length,
                      itemBuilder: (context, index) {
                        final notif = globalNotifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/restaurant',
                              arguments: notif.eatery,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F7A5B).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.local_offer,
                                      color: Color(0xFF0F7A5B),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          notif.detail,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF566A64),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        notif.time,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF8E9D99),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF8E9D99)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
