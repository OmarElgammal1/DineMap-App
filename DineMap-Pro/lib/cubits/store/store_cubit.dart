import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'store_state.dart';
import '../../config/constants.dart'; // Your API base URL
import '../../models/store.dart'; // Import your Store model
import '../../models/product.dart'; // Import your Product model

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(StoreInitial()) {
    fetchStoresFromApi();
    updateCurrentPosition();
  }

  // Use your defined Store model
  Map<int, Store> _allStoresFromApi = {};
  final Map<int, Store> _favoriteStores = {}; // Consider using Store model here too
  Position? _currentPosition;

  Future<void> fetchStoresFromApi() async {
    emit(StoreLoading()); // Indicate loading state
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/restaurants'));

      if (response.statusCode == 200) {
        List<dynamic> restaurantsJson = jsonDecode(response.body);
        _allStoresFromApi = {}; // Clear previous data

        for (var restaurantDataJson in restaurantsJson) {
          // Ensure restaurantDataJson is correctly cast to Map<String, dynamic>
          Map<String, dynamic> restaurantMap = restaurantDataJson as Map<String, dynamic>;

          // Use your Store.fromJson factory
          Store store = Store.fromJson(restaurantMap);
          _allStoresFromApi[store.restaurantID] = store; // Assuming Store model has restaurantID
          // If Store model uses 'id', adjust accordingly.
          // Based on your data.json and Store model, it seems you don't have a restaurantID directly in the Store model,
          // but it's used as a key in the map. The JSON from backend should have an 'id' field for the restaurant.
          // Let's assume your backend provides 'id' for the restaurant, and you map it.
          // If Store.fromJson expects 'restaurantID', ensure your backend sends it or adapt Store.fromJson.
          // For now, let's assume your backend sends an 'id' which corresponds to restaurantID.
          // And your Store model should ideally have an 'id' field.

          // If your Store model doesn't have an `id` or `restaurantID` field,
          // you might need to add one or adjust how you key the `_allStoresFromApi` map.
          // For consistency with `data.json` and `Product` model, let's assume `Store` has `restaurantID`.
          // Let's modify `Store` to include `restaurantID`.
        }

        emit(StoresLoaded(
          allStores: _allStoresFromApi,
          favoriteStores: _favoriteStores,
          currentPosition: _currentPosition,
        ));
      } else {
        emit(StoreError("Failed to load stores: ${response.statusCode}"));
      }
    } catch (e) {
      emit(StoreError("Failed to load stores: $e. Response body: ${e is http.ClientException ? 'N/A (ClientException)' : (e as dynamic).response?.body ?? 'No response body available'}"));
    }
  }

  // Method to search restaurants by product name
  Future<void> searchRestaurantsByProduct(String productName) async {
    if (productName.trim().isEmpty) {
      // If search query is empty, show all stores again
      fetchStoresFromApi();
      return;
    }
    emit(StoreSearchLoading());
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/search/restaurants_by_product_name?q=${Uri.encodeComponent(productName.trim())}'));

      if (response.statusCode == 200) {
        List<dynamic> restaurantsJson = jsonDecode(response.body);
        if (restaurantsJson.isEmpty) {
          emit(StoreSearchEmpty(currentPosition: _currentPosition));
        } else {
          List<Store> searchedStoresList = [];
          for (var restaurantDataJson in restaurantsJson) {
            Map<String, dynamic> restaurantMap = restaurantDataJson as Map<String, dynamic>;
            Store store = Store.fromJson(restaurantMap);
            searchedStoresList.add(store);
          }
          emit(StoreSearchResultsLoaded(
            searchedRestaurants: searchedStoresList,
            currentPosition: _currentPosition,
          ));
        }
      } else if (response.statusCode == 404) {
        // no restaurant found for the query
        emit(StoreSearchEmpty(currentPosition: _currentPosition));
      } else {
        // Handle other error codes
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? "Failed to search restaurants";
        emit(StoreError("Search failed: $errorMessage (Status: ${response.statusCode})"));
      }
    } catch (e) {
      emit(StoreError("An error occurred during search: $e."));
    }
  }
  void toggleFavorite(int id) {
    if (_favoriteStores.containsKey(id)) {
      _favoriteStores.remove(id);
    } else if (_allStoresFromApi.containsKey(id)) {
      _favoriteStores[id] = _allStoresFromApi[id]!;
    }
    // Ensure state is re-emitted with the correct types
    emit(StoresLoaded(
        allStores: Map<int, Store>.from(_allStoresFromApi), // Ensure correct type
        favoriteStores: Map<int, Store>.from(_favoriteStores), // Ensure correct type
        currentPosition: _currentPosition));
  }

  bool isFavorite(int id) => _favoriteStores.containsKey(id);

  Store? getStoreById(int id) => _allStoresFromApi[id];

  List<Product> getStoreProducts(int storeId) { // Return List<Product>
    final store = _allStoresFromApi[storeId];
    if (store != null) {
      return store.products; // Directly access the products list from the Store object
    }
    return [];
  }

  // updateCurrentPosition and calculateDistance remain the same
  Future<void> updateCurrentPosition() async { /* ... same as before ... */
    try {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;

      // Re-emit StoresLoaded with the updated position, using existing store data
      if (state is StoresLoaded) {
        final currentStoreState = state as StoresLoaded;
        emit(StoresLoaded(
          allStores: currentStoreState.allStores, // or _allStoresFromApi
          favoriteStores: currentStoreState.favoriteStores, // or _favoriteStores
          currentPosition: _currentPosition,
        ));
      } else {
        // If not already loaded, perhaps fetch or just update position for next load
        emit(StoresLoaded( // Or handle differently if stores not yet loaded
          allStores: _allStoresFromApi,
          favoriteStores: _favoriteStores,
          currentPosition: _currentPosition,
        ));
      }

    } catch (e) {
      emit(StoreError("Failed to get current location: $e"));
    }
  }

  double calculateDistance(double storeLat, double storeLng) { /* ... same as before ... */
    if (_currentPosition == null) {
      return 0.0;
    }
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      storeLat,
      storeLng,
    );
    return double.parse((distanceInMeters / 1000).toStringAsFixed(1));
  }
}