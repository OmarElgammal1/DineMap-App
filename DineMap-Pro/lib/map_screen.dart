import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'models/store.dart';
import 'directions_screen.dart'; // Make sure this file exists and accepts start & end LatLng
import 'cubits/store/store_cubit.dart';

class MapScreen extends StatefulWidget {
  final List<Store> restaurants;
  final Position? userCurrentPosition;

  const MapScreen({
    super.key,
    required this.restaurants,
    this.userCurrentPosition,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  late final storeCubit = context.read<StoreCubit>();
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
      _initialCameraPosition = LatLng(
        widget.restaurants.first.latitude,
        widget.restaurants.first.longitude,
      );
    } else {
      _initialCameraPosition = const LatLng(0, 0);
    }
  }

  void _setMarkers() {
    _markers.clear();
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

    for (var restaurant in widget.restaurants) {
      double distance = storeCubit.calculateDistance(restaurant.latitude, restaurant.longitude);
      _markers.add(
        Marker(
          width: 80.0,
          height: 100.0,
          point: LatLng(restaurant.latitude, restaurant.longitude),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.restaurantName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$distance km',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text("Get Directions"),
                          onPressed: () {
                            Navigator.pop(context);
                            if (widget.userCurrentPosition == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Current location not available")),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DirectionsScreen(
                                  start: LatLng(
                                    widget.userCurrentPosition!.latitude,
                                    widget.userCurrentPosition!.longitude,
                                  ),
                                  end: LatLng(
                                    restaurant.latitude,
                                    restaurant.longitude,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    restaurant.restaurantName,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.redAccent,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _initialCameraPosition ?? const LatLng(0, 0);
    final double zoom =
    (widget.userCurrentPosition != null || widget.restaurants.isNotEmpty)
        ? 12.0
        : 2.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Locations'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.yourcompany.yourapp',
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}