import '../../models/store.dart';
import 'package:geolocator/geolocator.dart'; // Assuming Position is used

abstract class StoreState {}

class StoreInitial extends StoreState {}
class StoreLoading extends StoreState {}

// States for Product Search
class StoreSearchLoading extends StoreState {} // Specifically for when a search is in progress

class StoreSearchResultsLoaded extends StoreState {
  final List<Store> searchedRestaurants;
  final Position? currentPosition;

  StoreSearchResultsLoaded({
    required this.searchedRestaurants,
    this.currentPosition,
  });
}

class StoreSearchEmpty extends StoreState { // When search returns no results
  final Position? currentPosition;
  StoreSearchEmpty({this.currentPosition});
}

// States for All Stores

class StoresLoaded extends StoreState { // For when all stores are loaded (initial load)
  final Map<int, Store> allStores;
  final Map<int, Store> favoriteStores;
  final Position? currentPosition;

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