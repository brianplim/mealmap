import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/app_models.dart';
import '../../services/firestore_service.dart';
import 'eatery_reviews_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  void _showOrderDialog(BuildContext context, Eatery eatery, MenuItem item) {
    String fulfillment = 'Delivery';
    int quantity = 1;

    final cleanPriceStr = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
    final unitPrice = double.tryParse(cleanPriceStr) ?? 75.0;

    final cleanFeeStr = eatery.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
    final numericDeliveryFee = eatery.deliveryFee.toLowerCase().contains('free') || cleanFeeStr.isEmpty
        ? 0.0
        : (double.tryParse(cleanFeeStr) ?? 0.0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final deliveryFee = fulfillment == 'Delivery' ? numericDeliveryFee : 0.0;
            final totalPrice = (unitPrice * quantity) + deliveryFee;
            final formattedTotal = '₱${totalPrice.toStringAsFixed(0)}';

            return AlertDialog(
              title: Text('Order ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eatery: ${eatery.name}'),
                  const SizedBox(height: 4),
                  Text('Unit Price: ${item.price}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('Delivery Fee: ${eatery.deliveryFee}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0F7A5B)),
                        onPressed: () {
                          if (quantity > 1) {
                            setStateDialog(() => quantity--);
                          }
                        },
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F7A5B)),
                        onPressed: () {
                          setStateDialog(() => quantity++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF7EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('Total Estimated Price:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F7A5B))),
                        const Spacer(),
                        Text(
                          formattedTotal,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F7A5B)),
                        ),
                      ],
                    ),
                  ),
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
                  onPressed: () async {
                    final ok = await _showReceiptDialog(
                      context,
                      item,
                      quantity,
                      eatery,
                      fulfillment,
                      eatery.deliveryFee,
                      formattedTotal,
                    );
                    if (ok == true && context.mounted) {
                      final newOrder = FoodOrder(
                        id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        eateryName: eatery.name,
                        itemName: '${item.name} (x$quantity)',
                        price: formattedTotal,
                        fulfillmentType: fulfillment,
                        status: fulfillment == 'Delivery' ? 'Out for Delivery' : 'Ready for Pickup',
                        timestamp: 'Just now',
                        vendorEmail: eatery.vendorEmail,
                      );
                      globalOrders.insert(0, newOrder);
                      vendorNotifReadNotifier.value = false;
                      FirestoreService.uploadOrder(newOrder);
                      Navigator.pop(context); // close order dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order placed successfully! Total: $formattedTotal')),
                      );
                    }
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

  Future<bool?> _showReceiptDialog(
    BuildContext context,
    MenuItem item,
    int quantity,
    Eatery eatery,
    String fulfillment,
    String deliveryFeeStr,
    String formattedTotal,
  ) async {
    final refNo = 'MM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final nowStr = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.receipt_long, color: Color(0xFF0F7A5B), size: 26),
              SizedBox(width: 10),
              Text('MealMap E-Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0F7A5B).withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'TRANSACTION SUMMARY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 1.2),
                  ),
                ),
                const Divider(height: 20),
                _receiptRow('Reference No.', refNo),
                const SizedBox(height: 8),
                _receiptRow('Date & Time', nowStr),
                const SizedBox(height: 8),
                _receiptRow('Eatery / Merchant', eatery.name),
                const SizedBox(height: 8),
                _receiptRow('Item & Qty', '${item.name} (x$quantity)'),
                const SizedBox(height: 8),
                _receiptRow('Fulfillment', fulfillment),
                const SizedBox(height: 8),
                _receiptRow('Delivery Fee', fulfillment == 'Delivery' ? deliveryFeeStr : 'Free'),
                const Divider(height: 20),
                Row(
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E2D2A))),
                    const Spacer(),
                    Text(formattedTotal, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F7A5B))),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF7EF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('✓ Verified Secure Order', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F7A5B))),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F7A5B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E2D2A))),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final eatery = ModalRoute.of(context)?.settings.arguments as Eatery? ?? (mockEateries.isNotEmpty ? mockEateries[0] : Eatery(id: '1', name: 'Eatery', cuisine: 'Filipino', distance: 0.1, rating: 5.0, reviewsCount: 1, imageUrl: '', description: '', hasStudentDiscount: true, menu: []));

    // Group all menu items from any post sharing the same eatery name
    final allRelatedEateries = eateryNotifier.value.where((e) => e.name.toLowerCase().trim() == eatery.name.toLowerCase().trim()).toList();
    final List<MenuItem> combinedMenu = [];
    for (var e in allRelatedEateries) {
      combinedMenu.addAll(e.menu);
    }
    final menuItems = combinedMenu.isNotEmpty ? combinedMenu : eatery.menu;

    bool isFav = globalFavoriteIds.contains(eatery.id);

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              displayEateryImage(
                eatery.imageUrl,
                height: 240,
                width: double.infinity,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2D2A)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : const Color(0xFF1E2D2A),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isFav) {
                                globalFavoriteIds.remove(eatery.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed ${eatery.name} from favorites')),
                                );
                              } else {
                                globalFavoriteIds.add(eatery.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added ${eatery.name} to favorites')),
                                );
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF0F7A5B),
                      backgroundImage: eatery.vendorLogoUrl != null && eatery.vendorLogoUrl!.isNotEmpty
                          ? (eatery.vendorLogoUrl!.startsWith('http')
                              ? NetworkImage(eatery.vendorLogoUrl!) as ImageProvider
                              : FileImage(File(eatery.vendorLogoUrl!)))
                          : null,
                      child: eatery.vendorLogoUrl == null || eatery.vendorLogoUrl!.isEmpty
                          ? const Icon(Icons.storefront, color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        eatery.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECF7EF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        eatery.cuisine,
                        style: const TextStyle(
                          color: Color(0xFF0F7A5B),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EateryReviewsScreen(eatery: eatery),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${eatery.rating} (${eatery.reviewsCount} reviews)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0F7A5B),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF0F7A5B)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF0F7A5B)),
                    const SizedBox(width: 2),
                    Text(
                      '${eatery.distance} km near ACES',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6E7D79)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  eatery.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Menu Items & Specials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (menuItems.isEmpty)
                  const Center(child: Text('No menu items posted yet.'))
                else
                  ...menuItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showOrderDialog(context, eatery, item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: displayEateryImage(
                                    item.imageUrl,
                                    width: 70,
                                    height: 70,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.price,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: Color(0xFF0F7A5B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F7A5B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
