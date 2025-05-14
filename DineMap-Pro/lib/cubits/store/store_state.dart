import '../../models/store.dart'; // Import your Store model
import 'package:geolocator/geolocator.dart'; // Assuming Position is used

abstract class StoreState {}

class StoreInitial extends StoreState {}
class StoreLoading extends StoreState {} // Added for better UI feedback

class StoresLoaded extends StoreState {
  final Map<int, Store> allStores; // Use Store model
  final Map<int, Store> favoriteStores; // Use Store model
  final Position? currentPosition; // Explicitly type currentPosition

  StoresLoaded({
    required this.allStores,
    required this.favoriteStores,
    this.currentPosition,
  });
}

class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}