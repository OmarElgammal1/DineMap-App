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

  Map<int, Store> _allStores = {};
  List<Store> _searchResults = [];
  final Map<int, Store> _favoriteStores = {};
  Position? _currentPosition;

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

  void toggleFavorite(int id) {
    if (_favoriteStores.containsKey(id)) {
      _favoriteStores.remove(id);
    } else if (_allStores.containsKey(id)) {
      _favoriteStores[id] = _allStores[id]!;
    }
    if (state is StoresLoaded) {
       final currentState = state as StoresLoaded;
       emit(StoresLoaded(
           allStores: currentState.allStores,
           favoriteStores: Map<int, Store>.from(_favoriteStores),
           currentPosition: _currentPosition));
    } else if (state is StoreSearchResultsLoaded) {
       final currentState = state as StoreSearchResultsLoaded;
       emit(StoreSearchResultsLoaded(
           searchedRestaurants: currentState.searchedRestaurants,
           currentPosition: _currentPosition));
    } else if (state is StoreSearchEmpty) {
        final currentState = state as StoreSearchEmpty;
        emit(StoreSearchEmpty(
            currentPosition: _currentPosition,
        ));
    }
  }

  bool isFavorite(int id) => _favoriteStores.containsKey(id);

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