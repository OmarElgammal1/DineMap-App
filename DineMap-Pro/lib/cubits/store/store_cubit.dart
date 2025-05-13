import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(StoreInitial()) {
    _loadStores();
    updateCurrentPosition();
  }

  // Stores data
  final Map<int, Map<String, dynamic>> _allStores = {
    1: {
      "restaurantID": 1,
      "restaurantName": "El Dabbagh",
      "address":
          "Mohyee Al Din Abd Al Al Hamid, Al Manteqah Ath Thamenah, Nasr City, Cairo Governorate 4441506",
      "district": "Cairo, Nasr City",
      "latitude": 30.047983666181203,
      "longitude": 31.346979372173706,
      "imageUrl":
          "https://blogger.googleusercontent.com/img/a/AVvXsEjmBLPSq4_UCcHv-PFH7iLnIIkyUXr_MZXHXX76oLl1-feCytWcKeYAdEdV1jX5EEVq4w9fnb38kL5kbUpYAYZRFissDmenxUx5DL8qaMNMT9DoLoq77DqE3rVu3dgPPzMvK5jzrJoSDFzh67GfHHwRC2y9-qYXnZjrpL1fBAWblIyvzVHhv_j7dWfl=w640-h358-rw",
      "description":
          "A fabulous restaurant with a great location and a cozy atmosphere.",
      "products": [
        {
          "productID": 1,
          "productName": "Chicken Pane Rizo",
          "price": 100.0,
          "imageUrl": "https://i.imgur.com/W3Uv8Ec.jpeg",
          "restaurantID": 1,
        },
        {
          "productID": 2,
          "productName": "V7 Cola",
          "price": 15.0,
          "imageUrl":
              "https://m.media-amazon.com/images/I/61TEazg2PxL._AC_UF894,1000_QL80_.jpg",
          "restaurantID": 1,
        },
        {
          "productID": 3,
          "productName": "Franshesco Sandwich",
          "price": 140.0,
          "imageUrl": "https://i.imgur.com/dEaZHXD.jpeg",
          "restaurantID": 1,
        },
      ],
    },
    2: {
      "restaurantID": 2,
      "restaurantName": "Anas EL Demeshky",
      "address":
          "48 Abbas El-Akkad, Al Manteqah Al Oula, Nasr City, Cairo Governorate 4450320",
      "district": "Cairo, Nasr City",
      "latitude": 30.061353972137116,
      "longitude": 31.33786591041985,
      "imageUrl":
          "https://lh3.googleusercontent.com/p/AF1QipMuJCLIn-b12cYWMfEwYp4SwizgeraRoMtzTAN9=w408-h306-k-no",
      "description": "A cool syrian restaurant with great location.",
      "products": [
        {
          "productID": 1,
          "productName": "Chicken Shawerma Sandwich",
          "price": 85.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRD7PsF2RKOwwahp1G6C18W2gXhUX7ibxpVRQ&s",
          "restaurantID": 2,
        },
        {
          "productID": 2,
          "productName": "V7 Cola",
          "price": 25.0,
          "imageUrl":
              "https://m.media-amazon.com/images/I/61TEazg2PxL._AC_UF894,1000_QL80_.jpg",
          "restaurantID": 2,
        },
        {
          "productID": 3,
          "productName": "Fried Chicken Meal",
          "price": 245.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTUs9hKVxgGJ_3UF58lE4ABVxI_wWYSnnc8g&s",
          "restaurantID": 2,
        },
      ],
    },
    3: {
      "restaurantID": 3,
      "restaurantName": "Süss",
      "address":
          "Salah El Din Abdel Karim, New Cairo 1, Cairo Governorate 4740601",
      "district": "Cairo, 5th Settlement",
      "latitude": 30.04655314651884,
      "longitude": 31.485873335470842,
      "imageUrl":
          "https://lh3.googleusercontent.com/p/AF1QipMVMDK7ZIdMe94m5aDpoadnV7s26JLOiUEhbhFT=w408-h306-k-no",
      "description":
          "A cozy dessert shop offering tasty cookies, crepe, cheesecake, ice cream and more.",
      "products": [
        {
          "productID": 1,
          "productName": "Triple Chocolate Waffle",
          "price": 230.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSo7DZIHkhqdGyX0zGRBQt1aBMg26E5hcGtfayYZDT9nuS1cK8MtFkFYhip-Al39Nd3Xc4&usqp=CAU",
          "restaurantID": 3,
        },
        {
          "productID": 2,
          "productName": "Pistachio Cheesecake",
          "price": 320.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3bX4onzu_ZmHZswM6F7U6ClKv87XZhqDPew&s",
          "restaurantID": 3,
        },
        {
          "productID": 3,
          "productName": "Chocolate Pancake",
          "price": 220.0,
          "imageUrl":
              "https://s3-eu-west-1.amazonaws.com/elmenusv5-stg/Normal/20a2fc4b-108f-4ef8-8cd7-d4b212dfa021.jpg",
          "restaurantID": 3,
        },
      ],
    },
    4: {
      "restaurantID": 4,
      "restaurantName": "Al Refaei Hawawshi",
      "address":
          "87 El-Shaikh Rihan, As Saqayin, Abdeen, Cairo Governorate 4281023",
      "district": "Cairo, Downtown",
      "latitude": 30.041243377945,
      "longitude": 31.246889329519806,
      "imageUrl":
          "https://lh3.googleusercontent.com/p/AF1QipPsl-AsYIv4EplM3mhPRKAvjtquR6EzBc6rv50=w408-h306-k-no",
      "description":
          "An oriental downtown butcher offering tasty hawawshi made with high quality meat.",
      "products": [
        {
          "productID": 1,
          "productName": "Meat Hawawshi",
          "price": 75.0,
          "imageUrl":
              "https://s3-eu-west-1.amazonaws.com/elmenusv5-stg/Normal/13ff8b7a-b715-489d-a5d1-8eebd6287ee6.jpg",
          "restaurantID": 4,
        },
        {
          "productID": 2,
          "productName": "Chicken Hawawshi",
          "price": 80.0,
          "imageUrl":
              "https://tarasmulticulturaltable.com/wp-content/uploads/2021/09/Hawawshi-Egyptian-Meat-Stuffed-Bread-3-of-3.jpg",
          "restaurantID": 4,
        },
        {
          "productID": 3,
          "productName": "Sausage Hawawshi",
          "price": 90.0,
          "imageUrl":
              "https://images.deliveryhero.io/image/talabat/Menuitems/%D8%AD%D9%88%D8%A7%D9%88%D8%B4%D9%8A_%D8%B3%D8%A7%D8%AF%D8%A9638143113827523455.jpg",
          "restaurantID": 4,
        },
      ],
    },
    5: {
      "restaurantID": 5,
      "restaurantName": "Kazaz",
      "address":
          "7 Al Bostan Al Seidi, Bab Al Louq, Abdeen, Cairo Governorate 4280124",
      "district": "Cairo, Downtown",
      "latitude": 30.04706886978214,
      "longitude": 31.23924210230681,
      "imageUrl":
          "https://lh3.googleusercontent.com/p/AF1QipNKxAiQnRh201652s12mamdFZNUvNPZizHuAft2=w640-h240-k-no",
      "description":
          "An old egyptian restaurant serving different types of oriental food.",
      "products": [
        {
          "productID": 1,
          "productName": "Chicken Shawerma Sandwich",
          "price": 80.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSNASQamUwynjLo1WpSdIQeLzFEaJRpmhBDb7lt0OrUNEbUQ4eKInNA2_2YRaUPhaMcUbY&usqp=CAU",
          "restaurantID": 5,
        },
        {
          "productID": 2,
          "productName": "Fried Chicken Meal",
          "price": 195.0,
          "imageUrl":
              "https://www.theorganickitchen.org/wp-content/uploads/2015/03/Depositphotos_41631619_l-2015-500x467.jpg",
          "restaurantID": 5,
        },
        {
          "productID": 3,
          "productName": "Meat Hawawshi",
          "price": 75.0,
          "imageUrl":
              "https://www.curiouscuisiniere.com/wp-content/uploads/2022/10/Egyptian-hawawshi-horizontal-crop.jpg",
          "restaurantID": 5,
        },
      ],
    },
    6: {
      "restaurantID": 6,
      "restaurantName": "El Baraka Fried Chicken",
      "address":
          "14 Kafr Saqr, Camp Shizar, Bab Sharqi, Alexandria Governorate 5424071",
      "district": "Alex, Sea Kornish",
      "latitude": 31.214559540422705,
      "longitude": 29.92085285046518,
      "imageUrl":
          "https://lh3.googleusercontent.com/p/AF1QipNQgNN9yjL3XgTCPIbidqD8wAvbnTwvkLGBqWJT=w427-h240-k-no",
      "description":
          "A rising local restaurant serving high quality friend chicken.",
      "products": [
        {
          "productID": 1,
          "productName": "Chicken Fattah",
          "price": 135.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzpmQGdWgR3WAg2lIt3b5bxt1evrgajw9dww&s",
          "restaurantID": 6,
        },
        {
          "productID": 2,
          "productName": "V7 Cola",
          "price": 20.0,
          "imageUrl":
              "https://m.media-amazon.com/images/I/61TEazg2PxL._AC_UF894,1000_QL80_.jpg",
          "restaurantID": 6,
        },
        {
          "productID": 3,
          "productName": "Fried Chicken Meal",
          "price": 200.0,
          "imageUrl":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoLwKHls37DXN0GlUdx6WOQqXAbX9wAytXbw&s",
          "restaurantID": 6,
        },
      ],
    },
  };

  // Favorite stores map
  final Map<int, Map<String, dynamic>> _favoriteStores = {};

  // Current position for distance calculation
  Position? _currentPosition;

  void _loadStores() {
    emit(
      StoresLoaded(
        allStores: _allStores,
        favoriteStores: _favoriteStores,
        currentPosition: _currentPosition,
      ),
    );
  }

  // Toggle favorite status for a store
  void toggleFavorite(int id) {
    if (_favoriteStores.containsKey(id)) {
      _favoriteStores.remove(id);
    } else if (_allStores.containsKey(id)) {
      _favoriteStores[id] = _allStores[id]!;
    }

    emit(
      StoresLoaded(
        allStores: _allStores,
        favoriteStores: _favoriteStores,
        currentPosition: _currentPosition,
      ),
    );
  }

  // Check if a store is in favorites
  bool isFavorite(int id) {
    return _favoriteStores.containsKey(id);
  }

  // Get a store by ID
  Map<String, dynamic>? getStoreById(int id) {
    return _allStores[id];
  }

  // Get store products
  List<Map<String, dynamic>> getStoreProducts(int storeId) {
    final store = _allStores[storeId];
    if (store != null && store['products'] != null) {
      // Ensure that 'products' is treated as a List
      // and that its elements are Map<String, dynamic>
      return List<Map<String, dynamic>>.from(store['products'] as List);
    }
    return []; // Return an empty list if no products or store found
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
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;

      emit(
        StoresLoaded(
          allStores: _allStores,
          favoriteStores: _favoriteStores,
          currentPosition: _currentPosition,
        ),
      );
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
