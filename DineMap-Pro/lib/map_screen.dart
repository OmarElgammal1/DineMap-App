import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // For Position type
import 'models/store.dart'; // Import your Store model

class MapScreen extends StatefulWidget {
  final List<Store> restaurants;
  final Position? userCurrentPosition;

  const MapScreen({
    Key? key,
    required this.restaurants,
    this.userCurrentPosition,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _setInitialCameraPosition();
  }

  void _setInitialCameraPosition() {
    if (widget.userCurrentPosition != null) {
      _initialCameraPosition = LatLng(
        widget.userCurrentPosition!.latitude,
        widget.userCurrentPosition!.longitude,
      );
    } else if (widget.restaurants.isNotEmpty) {
      // Center map on the first restaurant if user position is not available
      _initialCameraPosition = LatLng(
        widget.restaurants.first.latitude,
        widget.restaurants.first.longitude,
      );
    } else {
      // Default position if no user location and no restaurants
      _initialCameraPosition =
          const LatLng(0, 0); // World view or a default city
    }

    // You can use the MapController to move the camera after it's built if needed
    // _mapController.move(_initialCameraPosition!, 12.0); // Example
  }

  void _setMarkers() {
    _markers.clear();
    // Add marker for user's current location
    if (widget.userCurrentPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(
            widget.userCurrentPosition!.latitude,
            widget.userCurrentPosition!.longitude,
          ),
          child: const Icon(
            Icons.location_pin,
            color: Colors.blueAccent,
            size: 40.0,
          ),
        ),
      );
    }

    // Add markers for each restaurant
    for (var restaurant in widget.restaurants) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(restaurant.latitude, restaurant.longitude),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Optional: Display restaurant name or image above marker icon
              // Container(
              //   padding: EdgeInsets.all(4),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(5),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.2),
              //         blurRadius: 2,
              //         spreadRadius: 1,
              //       ),
              //     ],
              //   ),
              //   child: Text(restaurant.restaurantName, style: TextStyle(fontSize: 10)),
              // ),
              Icon(
                Icons.restaurant_menu,
                color: Colors.redAccent,
                size: 40.0,
              ),
            ],
          ),
          // You can add a onTap callback here for marker tap events
          // onTap: () {
          //   // Show restaurant details, etc.
          // },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the center of the map. If user location is available, use it.
    // Otherwise, try to center on the first restaurant, or a default location.
    final LatLng center = _initialCameraPosition ?? const LatLng(0, 0);
    final double zoom =
        (widget.userCurrentPosition != null || widget.restaurants.isNotEmpty)
            ? 12.0
            : 2.0; // Adjust zoom based on data availability

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Locations'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          // You can add interactive flags to control map gestures
          // interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        children: [
          // Tile Layer (e.g., OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.yourcompany.yourapp', // Replace with your package name
          ),
          // Add markers layer
          MarkerLayer(
            markers: _markers,
          ),
          // Optionally, add other layers like polygons, polylines, etc.
          // PolylineLayer(polylines: []),
          // PolygonLayer(polygons: []),
        ],
      ),
      // Optional: Add a FAB to recenter on the user's location
      // if (widget.userCurrentPosition != null)
      //   FloatingActionButton(
      //     onPressed: () {
      //       if (_mapController != null && widget.userCurrentPosition != null) {
      //         _mapController.move(
      //           LatLng(widget.userCurrentPosition!.latitude, widget.userCurrentPosition!.longitude),
      //           15.0, // Zoom level when recentering
      //         );
      //       }
      //     },
      //     child: const Icon(Icons.my_location),
      //   ),
    );
  }
}
