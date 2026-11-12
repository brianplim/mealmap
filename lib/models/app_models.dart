import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<List<Eatery>> eateryNotifier = ValueNotifier(mockEateries);
final ValueNotifier<String> businessNameNotifier = ValueNotifier('ACES Canteen Bites & Deals');
final ValueNotifier<int> vendorTabNotifier = ValueNotifier(0);
final ValueNotifier<bool> vendorNotifReadNotifier = ValueNotifier(false);
final ValueNotifier<bool> locationSharingNotifier = ValueNotifier(true);

class Eatery {
  final String id;
  final String name;
  final String cuisine;
  final double distance;
  double rating;
  int reviewsCount;
  double ratingSum;
  final String imageUrl;
  final String description;
  final bool hasStudentDiscount;
  final List<MenuItem> menu;
  final LatLng location;
  final String? vendorEmail;
  final bool showOnMap;
  final String deliveryFee;

  Eatery({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.distance,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.ratingSum = 0.0,
    required this.imageUrl,
    required this.description,
    required this.hasStudentDiscount,
    required this.menu,
    this.location = const LatLng(7.4578, 125.7921),
    this.vendorEmail,
    this.showOnMap = true,
    this.deliveryFee = 'Free Delivery',
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
  final String? vendorEmail;
  String prepTime;
  int? userRating;

  FoodOrder({
    required this.id,
    required this.eateryName,
    required this.itemName,
    required this.price,
    required this.fulfillmentType,
    required this.status,
    required this.timestamp,
    this.vendorEmail,
    this.prepTime = '15 mins',
    this.userRating,
  });
}

class CustomVendorPin {
  final String id;
  final String label;
  final LatLng location;
  final Eatery eatery;

  CustomVendorPin({
    required this.id,
    required this.label,
    required this.location,
    required this.eatery,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String detail;
  final String time;
  final Eatery eatery;

  const AppNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.time,
    required this.eatery,
  });
}

final List<AppNotification> globalNotifications = [];

final List<CustomVendorPin> globalVendorPins = [];

final List<FoodOrder> globalOrders = [];

final List<String> globalFavoriteIds = [];

final List<Eatery> mockEateries = [];

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

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? Colors.white : const Color(0xFF1E2D2A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: logoColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.55,
                height: size * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? const Color(0xFF121816) : Colors.white, width: 3),
                ),
              ),
              Icon(
                Icons.restaurant_menu,
                size: size * 0.45,
                color: isDark ? const Color(0xFF121816) : Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MealMap',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  Color confirmColor = const Color(0xFF0F7A5B),
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
