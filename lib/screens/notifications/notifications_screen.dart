import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      NotificationItemData(
        title: 'New deal at ACES Canteen Bites!',
        detail: '₱50 Pancit + Drink student special available.',
        time: '2h ago',
        color: const Color(0xFF0F7A5B),
      ),
      NotificationItemData(
        title: 'Tagum Inihaw Express promo!',
        detail: 'Buy 2 BBQ Skewers Get 1 Free near ACES College.',
        time: '4h ago',
        color: const Color(0xFF0F7A5B),
      ),
      NotificationItemData(
        title: 'Price drop alert in Tagum City!',
        detail: 'Taco Haven Tagum now has 20% off with student ID.',
        time: '6h ago',
        color: Colors.deepOrange,
      ),
      NotificationItemData(
        title: 'Reminder',
        detail: 'Your saved discount at Mindanao Halal Grill ends tonight.',
        time: '1d ago',
        color: Colors.blue,
      ),
      NotificationItemData(
        title: 'Welcome to MealMap Tagum!',
        detail: 'Discover the best food spots around ACES Tagum College, Mindanao.',
        time: '1d ago',
        color: const Color(0xFF0F7A5B),
      ),
    ];

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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                            color: item.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            color: item.color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.detail,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF566A64),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8E9D99),
                          ),
                        ),
                      ],
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

class NotificationItemData {
  const NotificationItemData({
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
  });

  final String title;
  final String detail;
  final String time;
  final Color color;
}
