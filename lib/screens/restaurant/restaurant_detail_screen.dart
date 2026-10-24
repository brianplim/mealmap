import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  void _showOrderDialog(BuildContext context, Eatery eatery, MenuItem item) {
    String fulfillment = 'Delivery';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Order ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eatery: ${eatery.name}'),
                  const SizedBox(height: 4),
                  Text('Price: ${item.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B))),
                  const SizedBox(height: 16),
                  const Text('Select Fulfillment:', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setStateDialog(() => fulfillment = 'Delivery'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: fulfillment == 'Delivery' ? const Color(0xFFECF7EF) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: fulfillment == 'Delivery' ? const Color(0xFF0F7A5B) : Colors.transparent,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.delivery_dining, color: Color(0xFF0F7A5B)),
                                SizedBox(height: 4),
                                Text('Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setStateDialog(() => fulfillment = 'Pickup'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: fulfillment == 'Pickup' ? const Color(0xFFECF7EF) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: fulfillment == 'Pickup' ? const Color(0xFF0F7A5B) : Colors.transparent,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.store, color: Color(0xFF0F7A5B)),
                                SizedBox(height: 4),
                                Text('Pickup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newOrder = FoodOrder(
                      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      eateryName: eatery.name,
                      itemName: item.name,
                      price: item.price,
                      fulfillmentType: fulfillment,
                      status: fulfillment == 'Delivery' ? 'Out for Delivery' : 'Ready for Pickup',
                      timestamp: 'Just now',
                    );
                    globalOrders.insert(0, newOrder);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order placed successfully! Check Deliveries/Orders status.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A5B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm Order'),
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
    final eatery = ModalRoute.of(context)?.settings.arguments as Eatery? ?? mockEateries[0];
    bool isFav = globalFavoriteIds.contains(eatery.id);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    eatery.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        placeholderImage(width: double.infinity, height: 260),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2D2A)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : const Color(0xFF1E2D2A),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isFav) {
                                  globalFavoriteIds.remove(eatery.id);
                                } else {
                                  globalFavoriteIds.add(eatery.id);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eatery.name,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECF7EF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${eatery.rating} (${eatery.reviewsCount} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F7A5B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF5A6A64)),
                        const SizedBox(width: 4),
                        Text(
                          '${eatery.distance} km from ACES Tagum College',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A64)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      eatery.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Menu & Delivery Tap to Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: eatery.menu.length,
                        itemBuilder: (context, index) {
                          final item = eatery.menu[index];
                          return GestureDetector(
                            onTap: () => _showOrderDialog(context, eatery, item),
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                    child: Image.network(
                                      item.imageUrl,
                                      height: 80,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          placeholderImage(width: double.infinity, height: 80),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              item.price,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F7A5B),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.add_shopping_cart, size: 14, color: Color(0xFF0F7A5B)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (eatery.hasStudentDiscount)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECF7EF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFB5E3C7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer, color: Color(0xFF0F7A5B)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Student Deal (Tagum)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xFF0F7A5B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '20% OFF on all delivery & pickup orders with valid student ID',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF3D554F)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => launchAcesMap(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F7A5B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Open ACES Tagum College in Google Maps',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
