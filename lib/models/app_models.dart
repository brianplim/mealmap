import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class Eatery {
  final String id;
  final String name;
  final String cuisine;
  final double distance;
  final double rating;
  final int reviewsCount;
  final String imageUrl;
  final String description;
  final bool hasStudentDiscount;
  final List<MenuItem> menu;

  const Eatery({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.distance,
    required this.rating,
    required this.reviewsCount,
    required this.imageUrl,
    required this.description,
    required this.hasStudentDiscount,
    required this.menu,
  });
}

class MenuItem {
  final String name;
  final String price;
  final String imageUrl;

  const MenuItem({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class FoodOrder {
  final String id;
  final String eateryName;
  final String itemName;
  final String price;
  final String fulfillmentType;
  String status;
  final String timestamp;

  FoodOrder({
    required this.id,
    required this.eateryName,
    required this.itemName,
    required this.price,
    required this.fulfillmentType,
    required this.status,
    required this.timestamp,
  });
}

final List<FoodOrder> globalOrders = [
  FoodOrder(
    id: 'ORD-001',
    eateryName: 'Taco Haven Tagum',
    itemName: 'Campus Tacos (2x)',
    price: '₱130',
    fulfillmentType: 'Delivery',
    status: 'Out for Delivery near ACES College',
    timestamp: '10 mins ago',
  ),
  FoodOrder(
    id: 'ORD-002',
    eateryName: 'ACES Canteen Bites',
    itemName: 'Pancit + Drink',
    price: '₱50',
    fulfillmentType: 'Pickup',
    status: 'Food Taken / Picked Up',
    timestamp: '1 hour ago',
  ),
];

final List<String> globalFavoriteIds = ['1', '2', '3', '4'];

final List<Eatery> mockEateries = [
  Eatery(
    id: '1',
    name: 'Taco Haven Tagum',
    cuisine: 'Mexican',
    distance: 0.3,
    rating: 4.5,
    reviewsCount: 120,
    imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=700&q=80',
    description: 'Popular Tex-Mex spot near ACES Tagum College. Fresh ingredients, bold flavors, and student-friendly prices!',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Campus Tacos', price: '₱65', imageUrl: 'https://images.unsplash.com/photo-1613514785940-daed07799d9b?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Mindanao Burrito', price: '₱95', imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Loaded Nachos', price: '₱75', imageUrl: 'https://images.unsplash.com/photo-1513456856091-30c4b8d6f60a?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '2',
    name: 'ACES Canteen Bites',
    cuisine: 'Filipino',
    distance: 0.1,
    rating: 4.3,
    reviewsCount: 95,
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
    description: 'Located right inside/near ACES Tagum College. Serving affordable homemade Filipino comfort food and student meals.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Pancit + Drink', price: '₱50', imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=300&q=80'),
      MenuItem(name: 'Chicken Adobo Meal', price: '₱75', imageUrl: 'https://images.unsplash.com/photo-1626503378942-8874a9cf2996?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '3',
    name: 'Tagum Inihaw Express',
    cuisine: 'Filipino',
    distance: 0.4,
    rating: 4.6,
    reviewsCount: 210,
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
    description: 'Best grilled pork barbecue and native chicken near ACES Tagum College.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Pork BBQ Skewers (3pcs)', price: '₱60', imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
  Eatery(
    id: '4',
    name: 'Mindanao Halal Grill & Cafe',
    cuisine: 'Asian',
    distance: 0.6,
    rating: 4.4,
    reviewsCount: 88,
    imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
    description: 'Authentic Halal dishes, flavorful satay, and refreshing fruit shakes near ACES Tagum College.',
    hasStudentDiscount: true,
    menu: [
      MenuItem(name: 'Beef Satay Rice', price: '₱90', imageUrl: 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=300&q=80'),
    ],
  ),
];

Widget statusBar({String time = '9:41', Color color = const Color(0xFF1E1E1E)}) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6),
    child: Row(
      children: [
        Text(
          time,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
        const Spacer(),
        Icon(Icons.signal_cellular_4_bar, size: 14, color: color),
        const SizedBox(width: 4),
        Icon(Icons.wifi, size: 14, color: color),
        const SizedBox(width: 4),
        Icon(Icons.battery_full, size: 14, color: color),
      ],
    ),
  );
}

Widget placeholderImage({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFD0D7D3),
    child: const Center(
      child: Icon(Icons.restaurant, color: Color(0xFF0F7A5B), size: 24),
    ),
  );
}

Future<void> launchAcesMap(BuildContext context) async {
  final Uri url = Uri.parse('https://maps.app.goo.gl/dNineAW6Vxaz2v7e7');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening ACES Tagum College Google Maps link')),
      );
    }
  }
}
