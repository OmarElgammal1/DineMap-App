import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/data.dart';

class StoreProvider extends ChangeNotifier {
  // Store current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Favorite stores
  final Map<int, bool> _favorites = {};

  // Get all stores
  Map<int, Map<String, dynamic>> get allStores => stores;

  // Get favorite stores
  Map<int, Map<String, dynamic>> get favoriteStores {
    final result = <int, Map<String, dynamic>>{};
    stores.forEach((key, value) {
      if (_favorites[key] == true || value['isFavorite'] == true) {
        result[key] = value;
      }
    });
    return result;
  }

  // Check if a store is favorite
  bool isFavorite(int id) {
    return _favorites[id] == true || (stores[id]?['isFavorite'] == true);
  }

  // Toggle favorite status
  void toggleFavorite(int id) {
    if (stores.containsKey(id)) {
      _favorites[id] = !(_favorites[id] ?? (stores[id]?['isFavorite'] ?? false));
      notifyListeners();
    }
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