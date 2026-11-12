import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/app_models.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> uploadEatery(Eatery eatery, LatLng location) async {
    try {
      await _db.collection('eateries').doc(eatery.id).set({
        'id': eatery.id,
        'name': eatery.name,
        'cuisine': eatery.cuisine,
        'distance': eatery.distance,
        'rating': eatery.rating,
        'reviewsCount': eatery.reviewsCount,
        'ratingSum': eatery.ratingSum,
        'imageUrl': eatery.imageUrl,
        'description': eatery.description,
        'hasStudentDiscount': eatery.hasStudentDiscount,
        'lat': location.latitude,
        'lng': location.longitude,
        'vendorEmail': eatery.vendorEmail,
        'showOnMap': eatery.showOnMap,
        'deliveryFee': eatery.deliveryFee,
        'menu': eatery.menu.map((m) => {'name': m.name, 'price': m.price, 'imageUrl': m.imageUrl}).toList(),
      });
    } catch (e) {
      debugPrint('Firestore uploadEatery error: $e');
    }
  }

  static Future<List<Eatery>> getEateries() async {
    try {
      final snapshot = await _db.collection('eateries').get();
      List<Eatery> eateries = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lat = data['lat'] ?? 7.4578;
        final lng = data['lng'] ?? 125.7921;
        final showMap = data['showOnMap'] ?? false;
        final deliveryFee = data['deliveryFee'] ?? 'Free Delivery';
        final menuList = (data['menu'] as List<dynamic>? ?? []).map((m) => MenuItem(
          name: m['name'] ?? '',
          price: m['price'] ?? '',
          imageUrl: m['imageUrl'] ?? '',
        )).toList();

        eateries.add(Eatery(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          cuisine: data['cuisine'] ?? 'Filipino',
          distance: (data['distance'] ?? 0.1).toDouble(),
          rating: (data['rating'] ?? 0.0).toDouble(),
          reviewsCount: data['reviewsCount'] ?? 0,
          ratingSum: (data['ratingSum'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          hasStudentDiscount: data['hasStudentDiscount'] ?? true,
          location: LatLng(lat, lng),
          vendorEmail: data['vendorEmail'],
          showOnMap: showMap,
          deliveryFee: deliveryFee,
          menu: menuList,
        ));
      }
      return eateries;
    } catch (e) {
      debugPrint('Firestore getEateries error: $e');
      return [];
    }
  }

  static Future<void> deleteEatery(String id) async {
    try {
      await _db.collection('eateries').doc(id).delete();
    } catch (e) {
      debugPrint('Firestore deleteEatery error: $e');
    }
  }

  static Future<void> uploadOrder(FoodOrder order) async {
    try {
      await _db.collection('orders').doc(order.id).set({
        'id': order.id,
        'eateryName': order.eateryName,
        'itemName': order.itemName,
        'price': order.price,
        'fulfillmentType': order.fulfillmentType,
        'status': order.status,
        'timestamp': order.timestamp,
      });
    } catch (e) {
      debugPrint('Firestore uploadOrder error: $e');
    }
  }

  static Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _db.collection('orders').doc(id).update({'status': status});
    } catch (e) {
      debugPrint('Firestore updateOrderStatus error: $e');
    }
  }

  static Future<void> saveVendorProfile(String uid, String businessName, String handle, String logoUrl, LatLng location) async {
    try {
      await _db.collection('vendors').doc(uid).set({
        'businessName': businessName,
        'handle': handle,
        'logoUrl': logoUrl,
        'lat': location.latitude,
        'lng': location.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveVendorProfile error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getVendorProfile(String uid) async {
    try {
      final doc = await _db.collection('vendors').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore getVendorProfile error: $e');
    }
    return null;
  }

  static Future<void> saveUserProfile(String uid, String name, String handle, String avatarUrl) async {
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'handle': handle,
        'avatarUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore getUserProfile error: $e');
    }
    return null;
  }
}
