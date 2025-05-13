import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(StoreInitial()) {
    _loadStores();
    updateCurrentPosition();
  }

  // Store data
  final Map<int, Map<String, dynamic>> _allStores = {
    1: {
      'storeName': 'Grocery Store',
      'imageUrl': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58',
      'district': 'Downtown',
      'category': 'Grocery',
      'address': '123 Main St, Downtown',
      'description': 'A local grocery store with fresh produce and essentials.',
      'hours': '8am - 9pm',
      'phone': '(555) 123-4567',
      'travelTime': '15',
      'latitude': 37.7749,
      'longitude': -122.4194,
    },
    2: {
      'storeName': 'Fashion Boutique',
      'imageUrl': 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5',
      'district': 'Midtown',
      'category': 'Fashion',
      'address': '456 Oak St, Midtown',
      'description': 'Trendy fashion boutique offering the latest styles.',
      'hours': '10am - 8pm',
      'phone': '(555) 987-6543',
      'travelTime': '10',
      'latitude': 37.7833,
      'longitude': -122.4167,
    },
    // Add more sample stores as needed
  };

  // Favorite stores map
  final Map<int, Map<String, dynamic>> _favoriteStores = {};

  // Current position for distance calculation
  Position? _currentPosition;

  void _loadStores() {
    emit(StoresLoaded(
      allStores: _allStores,
      favoriteStores: _favoriteStores,
      currentPosition: _currentPosition,
    ));
  }

  // Toggle favorite status for a store
  void toggleFavorite(int id) {
    if (_favoriteStores.containsKey(id)) {
      _favoriteStores.remove(id);
    } else if (_allStores.containsKey(id)) {
      _favoriteStores[id] = _allStores[id]!;
    }

    emit(StoresLoaded(
      allStores: _allStores,
      favoriteStores: _favoriteStores,
      currentPosition: _currentPosition,
    ));
  }

  // Check if a store is in favorites
  bool isFavorite(int id) {
    return _favoriteStores.containsKey(id);
  }

  // Get a store by ID
  Map<String, dynamic>? getStoreById(int id) {
    return _allStores[id];
  }

  // Update current user position for distance calculations
  Future<void> updateCurrentPosition() async {
    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(StoreError("Location permissions are denied"));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(StoreError("Location permissions are permanently denied"));
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      _currentPosition = position;

      emit(StoresLoaded(
        allStores: _allStores,
        favoriteStores: _favoriteStores,
        currentPosition: _currentPosition,
      ));
    } catch (e) {
      emit(StoreError("Failed to get current location: $e"));
    }
  }

  // Calculate distance between current position and a store
  double calculateDistance(double storeLat, double storeLng) {
    if (_currentPosition == null) {
      return 0.0;
    }

    // Use Geolocator to calculate distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      storeLat,
      storeLng,
    );

    // Convert to kilometers and round to 1 decimal place
    return double.parse((distanceInMeters / 1000).toStringAsFixed(1));
  }
}