import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/app_models.dart';

class VendorCreateOrderTab extends StatefulWidget {
  const VendorCreateOrderTab({super.key});

  @override
  State<VendorCreateOrderTab> createState() => _VendorCreateOrderTabState();
}

class _VendorCreateOrderTabState extends State<VendorCreateOrderTab> {
  final _eateryNameController = TextEditingController(text: 'ACES Canteen Bites');
  final _menuNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  bool _hasDiscount = true;
  String _imageUrl = 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80';
  LatLng _selectedLatLng = const LatLng(7.4578, 125.7921);

  @override
  void dispose() {
    _eateryNameController.dispose();
    _menuNameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food photo selected from gallery!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image picker note: using preset photo (${e.toString()})')),
        );
      }
    }
  }

  void _showPresetImagePicker() {
    final presets = [
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Food Photo'),
          content: SizedBox(
            width: 300,
            height: 250,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final url = presets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _imageUrl = url);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              child: const Text('Upload from Gallery'),
            ),
          ],
        );
      },
    );
  }

  void _publishMenu() {
    if (_menuNameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter menu name and price')),
      );
      return;
    }

    final rawPrice = _priceController.text.trim().replaceAll('₱', '');
    final formattedPrice = '₱$rawPrice';

    final newEatery = Eatery(
      id: 'vendor-${DateTime.now().millisecondsSinceEpoch}',
      name: _eateryNameController.text.trim(),
      cuisine: 'Local Special',
      distance: 0.1,
      rating: 5.0,
      reviewsCount: 1,
      imageUrl: _imageUrl,
      description: _hasDiscount && _discountController.text.trim().isNotEmpty
          ? _discountController.text.trim()
          : 'Special daily offering near ACES Tagum College.',
      hasStudentDiscount: _hasDiscount,
      menu: [
        MenuItem(
          name: _menuNameController.text.trim(),
          price: formattedPrice,
          imageUrl: _imageUrl,
        ),
      ],
    );

    mockEateries.insert(0, newEatery);
    globalVendorPins.add(
      CustomVendorPin(
        id: newEatery.id,
        label: _menuNameController.text.trim(),
        location: _selectedLatLng,
        eatery: newEatery,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu item and map location published successfully!')),
    );
    _menuNameController.clear();
    _priceController.clear();
    _discountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Order / Post Menu',
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
                TextField(
                  controller: _eateryNameController,
                  decoration: InputDecoration(
                    labelText: 'Eatery / Business Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _menuNameController,
                  decoration: InputDecoration(
                    labelText: 'Menu Item Name',
                    hintText: 'e.g. Special Pork Adobo Meal',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    hintText: '75',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasDiscount,
                      activeColor: const Color(0xFF0F7A5B),
                      onChanged: (val) => setState(() => _hasDiscount = val ?? true),
                    ),
                    const Text('Include Student Discount Offer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                if (_hasDiscount) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _discountController,
                    decoration: InputDecoration(
                      labelText: 'Student Discount Description',
                      hintText: 'e.g. 20% OFF with valid student ID',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Pinpoint Location on Map', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Tap anywhere on the mini map below to set your business location:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedLatLng,
                        initialZoom: 17.0,
                        onTap: (tapPosition, latLng) {
                          setState(() {
                            _selectedLatLng = latLng;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location pinpointed on map!')),
                          );
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.mealmap',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLatLng,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Food Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showPresetImagePicker,
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF0F7A5B), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _imageUrl.startsWith('http')
                              ? Image.network(_imageUrl, fit: BoxFit.cover)
                              : Image.file(File(_imageUrl), fit: BoxFit.cover),
                          Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Tap to Choose Food Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _publishMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F7A5B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Publish Menu & Location to Student Map',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
