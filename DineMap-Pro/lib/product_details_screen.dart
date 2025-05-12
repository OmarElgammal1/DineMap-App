import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;
  final String? distance;  // Add this line

  ProductDetailScreen({required this.id, this.distance});  // Update constructor

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Use the provider to update current position when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).updateCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the store provider
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.getStoreById(widget.id);

    if (store == null) {
      return Scaffold(body: Center(child: Text('Store not found!')));
    }

    final double storeLat = store['latitude'];
    final double storeLng = store['longitude'];

    // Calculate distance using the provider
    final distance = storeProvider.calculateDistance(storeLat, storeLng);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Favorite button using provider
          IconButton(
            icon: Icon(
              storeProvider.isFavorite(widget.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: storeProvider.isFavorite(widget.id)
                  ? Colors.red
                  : Colors.grey,
            ),
            onPressed: () {
              storeProvider.toggleFavorite(widget.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Image.network(
                store['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            // Store map preview with route if available
            SizedBox(
              height: 200,
              width: double.infinity,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(storeLat, storeLng),
                  zoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Draw the route line if available
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Store marker
                      Marker(
                        point: LatLng(storeLat, storeLng),
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      // Current location marker
                      if (storeProvider.currentPosition != null)
                        Marker(
                          point: LatLng(
                            storeProvider.currentPosition!.latitude,
                            storeProvider.currentPosition!.longitude,
                          ),
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Store details
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['category'],
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    store['storeName'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store['address'],
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "Operating Hours: ${store['hours']}",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        store['phone'],
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    store['description'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Distance, travel time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Distance: ${distance} km away",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Estimated travel time: ${store['travelTime']} min',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}