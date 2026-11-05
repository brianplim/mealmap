import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class VendorPostDealScreen extends StatefulWidget {
  const VendorPostDealScreen({super.key});

  @override
  State<VendorPostDealScreen> createState() => _VendorPostDealScreenState();
}

class _VendorPostDealScreenState extends State<VendorPostDealScreen> {
  final _eateryNameController = TextEditingController();
  final _dealTitleController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
  );

  @override
  void dispose() {
    _eateryNameController.dispose();
    _dealTitleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _postDeal() {
    if (_eateryNameController.text.trim().isEmpty || _dealTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in eatery name and deal title')),
      );
      return;
    }

    final newEatery = Eatery(
      id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
      name: _eateryNameController.text.trim(),
      cuisine: 'Local Special',
      distance: 0.2,
      rating: 5.0,
      reviewsCount: 1,
      imageUrl: _imageUrlController.text.trim(),
      description: _discountController.text.trim().isNotEmpty
          ? _discountController.text.trim()
          : 'Special daily offering near ACES Tagum College.',
      hasStudentDiscount: true,
      menu: [
        MenuItem(
          name: _dealTitleController.text.trim(),
          price: _priceController.text.trim().isNotEmpty ? _priceController.text.trim() : '₱75',
          imageUrl: _imageUrlController.text.trim(),
        ),
      ],
    );

    mockEateries.insert(0, newEatery);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deal posted successfully! Now live on student feeds and map.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Eatery Vendor Portal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF7EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB5E3C7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: Color(0xFF0F7A5B), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Post Daily Special & Discount',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF0F7A5B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Your deal will instantly broadcast to all students near ACES Tagum College!',
                                style: TextStyle(fontSize: 12, color: Color(0xFF3D554F)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _eateryNameController,
                    decoration: InputDecoration(
                      labelText: 'Eatery / Business Name',
                      hintText: 'e.g. ACES Canteen Bites',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dealTitleController,
                    decoration: InputDecoration(
                      labelText: 'Daily Special / Menu Item',
                      hintText: 'e.g. Special Pork Adobo Meal',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g. ₱75',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Student Discount Promo description',
                      hintText: 'e.g. 20% OFF with valid student ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Food Photo URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _postDeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F7A5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Publish Deal to Student Feed',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
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
