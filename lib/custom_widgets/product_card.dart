import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../models/data.dart';
import '../product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String productName;
  final String imageUrl;
  final double price;
  final String district;
  final bool isFavorite;
  final String screenType;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;
  final String? size;
  final int? ind;

  ProductCard({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.district,
    this.isFavorite = false,
    required this.screenType,
    this.onAddToCart,
    this.onRemoveFromCart,
    this.size,
    this.ind,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    stores[widget.id]?['isFavorite'] = _isFavorite;
    print(stores[widget.id]?['isFavorite']);
  }

  // Launch maps with directions to store
  /* Future<void> _openDirections() async {
    final store = stores[widget.id];
    if (store == null) return;

    double lat = store['latitude'];
    double lng = store['longitude'];

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Try to launch Google Maps first, then Apple Maps, then OSM
      final Uri googleUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$lat,$lng&travelmode=driving',
      );
      final Uri appleUrl = Uri.parse(
        'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d&t=m',
      );
      final Uri osmUrl = Uri.parse(
        'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=${position.latitude}%2C${position.longitude}%3B$lat%2C$lng',
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
      print('Error opening directions: $e');
    }
  } */

  // Pre-calculate the distance to the store then navigate to ProductDetailScreen
  Future<void> navigateToProductDetail(
    BuildContext context,
    int storeId,
  ) async {
    final store = stores[storeId];
    if (store == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Store not found!')));
      return;
    }

    final double storeLat = store['latitude'];
    final double storeLng = store['longitude'];

    Position? currentPosition;
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled and request permission if not
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

      // Get the current user position
      currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting position: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accessing location: $e')));
    }

    // Calculate the distance between the current position and the store
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition.longitude,
        storeLat,
        storeLng,
      );
      final distance = (distanceInMeters / 1000).toStringAsFixed(2);
      // Navigate to ProductDetailScreen with the store id and the pre-calculated distance
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProductDetailScreen(id: storeId, distance: distance),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error calculating distance: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator on this specific card
    final loadingOverlay = OverlayEntry(
      builder:
          (context) => Positioned.fill(
            child: Material(
              color: Colors.black38,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Calculating distance...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    return GestureDetector(
      onTap: () {
        // Add the loading overlay to this card
        Overlay.of(context).insert(loadingOverlay);

        // Navigate with distance calculation
        navigateToProductDetail(context, widget.id)
            .then((_) {
              // Remove loading indicator when done
              loadingOverlay.remove();
            })
            .catchError((error) {
              // Make sure to remove loading on error too
              loadingOverlay.remove();
            });
      },
      child: Card(
        margin: EdgeInsets.all(4.0), // Adds margin around the card for spacing
        clipBehavior: Clip.antiAlias, // Clips the content to the card's shape
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
            // Store Name and Distance
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Container(
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Text(
                          widget.district,
                          overflow: TextOverflow.visible,
                          style: TextStyle(color: Colors.grey),
                          softWrap: true,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: toggleFavorite,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Row containing Favorite Icon and Location Icon (OLD)
                  /* Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Favorite Icon
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: toggleFavorite,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Location Icon
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _openDirections,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.directions,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
