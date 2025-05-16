import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'store_state.dart';
import '../../config/constants.dart';
import '../../models/store.dart';
import '../../models/product.dart';

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(StoreInitial()) {
    fetchStoresFromApi();
  }

  int? _userId;
  Map<int, Store> _allStores = {};
  List<Store> _searchResults = [];
  final Map<int, Store> _favoriteStores = {};
  Position? _currentPosition;

  Map<int, Store> get favoriteStores => Map.unmodifiable(_favoriteStores);
  Position? get currentPositionGetter => _currentPosition;

  void setUserId(int? userId) {
    _userId = userId;
    if (_userId != null) { // Only fetch if userId is set
      _fetchFavoritesFromApi();
    } else {
      // User logged out, clear favorites and potentially update state
      _favoriteStores.clear();
      if (state is StoresLoaded) {
        final s = state as StoresLoaded;
        emit(StoresLoaded(
            allStores: s.allStores,
            favoriteStores: {}, // Empty favorites
            currentPosition: s.currentPosition));
      } else if (state is StoreSearchResultsLoaded) {
        final s = state as StoreSearchResultsLoaded;
        emit(StoreSearchResultsLoaded(
            searchedRestaurants: s.searchedRestaurants,
            currentPosition: s.currentPosition));
        // isFavorite will now return false for all items
      }
      // Handle other states if necessary
    }
  }

  Future<void> _fetchFavoritesFromApi() async {
    if (_userId == null) return;

    // Consider emitting a loading state for favorites if it's a long operation
    // e.g., emit(FavoritesLoading());

    try {
      final resp = await http.get(
        Uri.parse('$API_BASE_URL/users/$_userId/favorites'),
      );
      if (resp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(resp.body);
        final Map<int, Store> newFavoriteStores = {};
        for (var e in list) {
          final s = Store.fromJson(e as Map<String, dynamic>);
          newFavoriteStores[s.restaurantID] = s;
        }
        _favoriteStores.clear();
        _favoriteStores.addAll(newFavoriteStores);

        // Emit a state that includes the new favorites
        // Try to preserve the current view (all stores vs search results)
        if (state is StoresLoaded || state is StoreInitial || state is StoreLoading || state is StoreError) {
          // If was showing all stores, or in an initial/loading/error state, emit StoresLoaded
          emit(StoresLoaded(
            allStores: Map.from(_allStores),
            favoriteStores: Map.from(_favoriteStores),
            currentPosition: _currentPosition,
          ));
        } else if (state is StoreSearchResultsLoaded) {
          final currentSearchState = state as StoreSearchResultsLoaded;
          emit(StoreSearchResultsLoaded(
            searchedRestaurants: currentSearchState.searchedRestaurants, // Keep current search results
            currentPosition: _currentPosition,
          ));
        } else if (state is StoreSearchEmpty) {
          emit(StoreSearchEmpty(currentPosition: _currentPosition));
        }
        // Add other states if necessary
      } else {
        // Handle API error for fetching favorites
        print("Failed to fetch favorites: ${resp.statusCode}");
        // Optionally emit an error state specific to favorites
      }
    } catch (e) {
      print("Error fetching favorites: $e");
      // Optionally emit an error state
    }
  }

  /// Toggle and sync favorite for dynamic userId
  Future<void> toggleFavorite(int storeId) async {
    if (_userId == null) {
      print("User ID is null. Cannot toggle favorite.");
      // Optionally emit an error or a state indicating user needs to log in
      return;
    }

    // Create a temporary mutable copy of current favorites to work with
    final Map<int, Store> tempFavoriteStores = Map.from(_favoriteStores);
    bool apiCallSuccessful = false;

    try {
      if (tempFavoriteStores.containsKey(storeId)) {
        // ---- ATTEMPT TO UNFAVORITE ----
        final response = await http.delete(
          Uri.parse('$API_BASE_URL/users/$_userId/favorites/$storeId'),
        );
        if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content is also success
          tempFavoriteStores.remove(storeId);
          apiCallSuccessful = true;
        } else {
          print('Failed to remove favorite: ${response.statusCode} ${response.body}');
          // Optionally emit a specific error state for UI feedback
        }
      } else {
        // ---- ATTEMPT TO FAVORITE ----
        // Ensure the store object is available. _allStores is the primary source.
        if (_allStores.containsKey(storeId)) {
          final response = await http.post(
            Uri.parse('$API_BASE_URL/users/$_userId/favorites'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'restaurant_id': storeId}),
          );
          // Assuming API returns 201 Created or 200 OK on success
          if (response.statusCode == 201 || response.statusCode == 200) {
            // Successfully added on backend, now update local state
            // If your API returns the full store object in the response body:
            // final storeData = jsonDecode(response.body);
            // final store = Store.fromJson(storeData as Map<String, dynamic>);
            // tempFavoriteStores[store.restaurantID] = store;

            // If API does NOT return store object, rely on _allStores:
            tempFavoriteStores[storeId] = _allStores[storeId]!;
            apiCallSuccessful = true;
          } else {
            print('Failed to add favorite: ${response.statusCode} ${response.body}');
            // Optionally emit a specific error state
          }
        } else {
          print('Store with ID $storeId not found in _allStores. Cannot add to local favorites cache reliably.');
          // This indicates a potential data inconsistency.
          // How to handle? Maybe try to fetch store details or show an error.
          // For now, we won't change the favorite state if the store object isn't available.
        }
      }

      if (apiCallSuccessful) {
        // If API call was successful, commit changes to the canonical _favoriteStores
        _favoriteStores.clear();
        _favoriteStores.addAll(tempFavoriteStores);

        // ***** THE CRUCIAL STEP: EMIT A NEW STATE *****
        final currentStateSnapshot = state; // Get current state type

        if (currentStateSnapshot is StoresLoaded) {
          emit(StoresLoaded(
            allStores: Map.from(_allStores),
            favoriteStores: Map.from(_favoriteStores), // Use the updated favorites
            currentPosition: _currentPosition,
          ));
        } else if (currentStateSnapshot is StoreSearchResultsLoaded) {
          emit(StoreSearchResultsLoaded(
            // Keep existing search results, favorite status will update via isFavorite()
            searchedRestaurants: List.from(currentStateSnapshot.searchedRestaurants),
            currentPosition: _currentPosition,
          ));
        } else if (currentStateSnapshot is StoreSearchEmpty) {
          // If user could favorite from an "empty" view (unlikely for a card)
          emit(StoreSearchEmpty(currentPosition: _currentPosition));
        }
        // Add other relevant states your StoreCard might appear in
        // else {
        //   // Fallback: if current state is initial, loading, or error,
        //   // emitting StoresLoaded might be a sensible default after a favorite toggle.
        //   emit(StoresLoaded(
        //     allStores: Map.from(_allStores),
        //     favoriteStores: Map.from(_favoriteStores),
        //     currentPosition: _currentPosition,
        //   ));
        // }
      }
      // If apiCallSuccessful is false, it means the backend operation failed or prerequisites weren't met.
      // _favoriteStores remains unchanged from its state before this method call.
      // No emit is needed here unless you want to show a specific error message for the failed toggle.

    } catch (e) {
      print('Exception in toggleFavorite: $e');
      emit(StoreError('Error toggling favorite: $e'));
    }
  }


  bool isFavorite(int id) => _favoriteStores.containsKey(id);

  Future<void> fetchStoresFromApi() async {
    if (state is! StoreSearchResultsLoaded && state is! StoreSearchEmpty) {
        emit(StoreLoading());
    }

    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/restaurants'));

      if (response.statusCode == 200) {
        List<dynamic> restaurantsJson = jsonDecode(response.body);
        _allStores = {};

        for (var restaurantDataJson in restaurantsJson) {
          Map<String, dynamic> restaurantMap = restaurantDataJson as Map<String, dynamic>;
          Store store = Store.fromJson(restaurantMap);
          _allStores[store.restaurantID] = store;
        }

        emit(StoresLoaded(
          allStores: _allStores,
          favoriteStores: _favoriteStores,
          currentPosition: _currentPosition,
        ));
         updateCurrentPosition();


      } else {
         if (state is! StoreSearchResultsLoaded && state is! StoreSearchEmpty) {
              emit(StoreError("Failed to load stores: ${response.statusCode}"));
         } else {
              print("Error fetching all stores while in search state: ${response.statusCode}");
         }

      }
    } catch (e) {
       if (state is! StoreSearchResultsLoaded && state is! StoreSearchEmpty) {
           emit(StoreError("Failed to load stores: $e. Response body: ${e is http.ClientException ? 'N/A (ClientException)' : (e as dynamic).response?.body ?? 'No response body available'}"));
       } else {
           print("Error fetching all stores while in search state: $e");
       }
    }
  }

  Future<void> searchRestaurantsByProduct(String productName) async {
    if (productName.trim().isEmpty) {
      _searchResults = [];
      emit(StoresLoaded(
         allStores: _allStores,
         favoriteStores: _favoriteStores,
         currentPosition: _currentPosition,
      ));
      return;
    }
    emit(StoreSearchLoading());
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/search/restaurants_by_product_name?q=${Uri.encodeComponent(productName.trim())}'));

      if (response.statusCode == 200) {
        List<dynamic> restaurantsJson = jsonDecode(response.body);
        if (restaurantsJson.isEmpty) {
           _searchResults = [];
           emit(StoreSearchEmpty(currentPosition: _currentPosition));
        } else {
          _searchResults = [];
          for (var restaurantDataJson in restaurantsJson) {
            Map<String, dynamic> restaurantMap = restaurantDataJson as Map<String, dynamic>;
            Store store = Store.fromJson(restaurantMap);
            _searchResults.add(store);
          }
          emit(StoreSearchResultsLoaded(
            searchedRestaurants: _searchResults,
            currentPosition: _currentPosition,
          ));
        }
      } else if (response.statusCode == 404) {
         _searchResults = [];
         emit(StoreSearchEmpty(currentPosition: _currentPosition));
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? "Failed to search restaurants";
         emit(StoreError("Search failed: $errorMessage (Status: ${response.statusCode})"));
      }
    } catch (e) {
       emit(StoreError("An error occurred during search: $e."));
    }
  }


  Store? getStoreById(int id) => _allStores[id];


  List<Product> getStoreProducts(int storeId) {
    final store = _allStores[storeId];
    if (store != null) {
      return store.products;
    }
    return [];
  }

  Future<void> updateCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
           print("Location permissions are denied");
           return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
         print("Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;

      if (state is StoresLoaded) {
        final currentState = state as StoresLoaded;
        emit(StoresLoaded(
          allStores: currentState.allStores,
          favoriteStores: currentState.favoriteStores,
          currentPosition: _currentPosition,
        ));
      } else if (state is StoreSearchResultsLoaded) {
        final currentState = state as StoreSearchResultsLoaded;
        emit(StoreSearchResultsLoaded(
          searchedRestaurants: currentState.searchedRestaurants,
          currentPosition: _currentPosition,
        ));
      } else if (state is StoreSearchEmpty) {
         final currentState = state as StoreSearchEmpty;
         emit(StoreSearchEmpty(
             currentPosition: _currentPosition,
         ));
      }

    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  double calculateDistance(double storeLat, double storeLng) {
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