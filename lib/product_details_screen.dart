import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/data.dart';
import 'utils/openroute_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;

  ProductDetailScreen({required this.id});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  Map<String, String>? _directionsSummary;
  List<Map<String, dynamic>>? _directionsSteps;
  List<LatLng> _routePoints = [];
  bool _showDirections = false;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Get the user's current location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting position: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accessing location: $e')));
    }
  }

  // Get directions from current location to store
  Future<void> _getDirections(double storeLat, double storeLng) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Waiting for your location...')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await OpenRouteService.getDirections(
        start: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        end: LatLng(storeLat, storeLng),
      );

      setState(() {
        _directionsSummary = OpenRouteService.getDirectionsSummary(response);
        if (_currentPosition != null) {
          final distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            storeLat,
            storeLng,
          );
          _directionsSummary!['distance'] = (distanceInMeters / 1000)
              .toStringAsFixed(2);
        }
        _directionsSteps = OpenRouteService.getDirectionsSteps(response);
        _routePoints = OpenRouteService.decodePolyline(response);
        _showDirections = true;
        _isLoading = false;
      });

      // Center the map to fit the route
      if (_routePoints.isNotEmpty) {
        _mapController.fitBounds(
          LatLngBounds.fromPoints(_routePoints),
          options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting directions: $e')));
    }
  }

  // Open navigation in external maps app
  Future<void> _launchMapsUrl(double lat, double lng, String label) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Waiting for your location...')));
      return;
    }

    try {
      final Uri googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=$lat,$lng&travelmode=driving',
      );
      final Uri appleUrl = Uri.parse(
        'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d&t=m',
      );
      final Uri osmUrl = Uri.parse(
        'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}%3B$lat%2C$lng',
      );

      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl);
      } else if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl);
      } else if (await canLaunchUrl(osmUrl)) {
        await launchUrl(osmUrl);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching maps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = stores[widget.id];

    if (store == null) {
      return Scaffold(body: Center(child: Text('Store not found!')));
    }

    final double storeLat = store['latitude'];
    final double storeLng = store['longitude'];

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
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
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
            Container(
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
                      if (_currentPosition != null)
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        child: Text('View all', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=3',
                        ),
                        radius: 20,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['reviews'][0]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            store['reviews'][0]['date'],
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: List.generate(5, (starIndex) {
                          if (starIndex <
                              store['reviews'][0]['rating'].floor()) {
                            return Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else if (starIndex ==
                                  store['reviews'][0]['rating'].floor() &&
                              store['reviews'][0]['rating'] % 1 != 0) {
                            return Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else {
                            return Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }
                        }),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${store['reviews'][0]['rating']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    store['reviews'][0]['comment'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Display directions information if available
            if (_showDirections && _directionsSummary != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Distance',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "${_directionsSummary!['distance'] ?? ''} km",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    _directionsSummary!['duration'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  _launchMapsUrl(
                                    storeLat,
                                    storeLng,
                                    store['storeName'],
                                  );
                                },
                                child: Text(
                                  'Open in Maps',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),

                          // Show the step-by-step directions if available
                          if (_directionsSteps != null &&
                              _directionsSteps!.isNotEmpty)
                            ExpansionTile(
                              title: Text('Step-by-step directions'),
                              children:
                                  _directionsSteps!.map((step) {
                                    IconData iconData;
                                    switch (step['type']) {
                                      case 10: // Start
                                        iconData = Icons.trip_origin;
                                        break;
                                      case 11: // Finish
                                        iconData = Icons.place;
                                        break;
                                      case 1: // Right
                                        iconData = Icons.turn_right;
                                        break;
                                      case 2: // Left
                                        iconData = Icons.turn_left;
                                        break;
                                      case 5: // Roundabout
                                        iconData = Icons.roundabout_left;
                                        break;
                                      default:
                                        iconData = Icons.arrow_forward;
                                    }

                                    return ListTile(
                                      leading: Icon(iconData),
                                      title: Text(step['instruction']),
                                      subtitle: Text(
                                        '${step['distance']} · ${step['duration']}',
                                      ),
                                    );
                                  }).toList(),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${store['distance']} km away',
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
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _getDirections(storeLat, storeLng),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon:
                        _isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Icon(Icons.directions, color: Colors.white),
                    label: Text(
                      'Get Directions',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
