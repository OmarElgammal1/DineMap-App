import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/data.dart';

class StoreProvider extends ChangeNotifier {
  // Store current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Get all stores
  Map<int, Map<String, dynamic>> get allStores => stores;

  // Get store products
  List<Map<String, dynamic>> getStoreProducts(int storeId) {
    final store = stores[storeId];
    if (store != null && store['products'] != null) {
      // Ensure that 'products' is treated as a List
      // and that its elements are Map<String, dynamic>
      return List<Map<String, dynamic>>.from(store['products'] as List);
    }
    return []; // Return an empty list if no products or store found
  }

  // Get store by ID
  Map<String, dynamic>? getStoreById(int id) {
    return stores[id];
  }

  // Update current position
  Future<void> updateCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      print('Error getting position: $e');
    }
  }

  // Calculate distance to store
  double calculateDistance(double storeLat, double storeLng) {
    if (_currentPosition == null) return 0;

    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      storeLat,
      storeLng,
    );

    return (distanceInMeters / 1000); // Convert to km
  }
}