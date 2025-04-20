import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/data.dart';
import '../product_details_screen.dart';

class ProductCard extends StatefulWidget {
  final int id;
  final String productName;
  final String imageUrl;
  final double price;
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
  Future<void> _openDirections() async {
    final store = stores[widget.id];
    if (store == null) return;

    double lat = store['latitude'];
    double lng = store['longitude'];

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Try to launch Google Maps first, then Apple Maps, then OSM
      final Uri googleUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=$lat,$lng&travelmode=driving'
      );
      final Uri appleUrl = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d&t=m');
      final Uri osmUrl = Uri.parse(
          'https://www.openstreetmap.org/directions?engine=graphhopper_car&route=${position.latitude}%2C${position.longitude}%3B$lat%2C$lng'
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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProductDetailScreen with the store id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(id: widget.id),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Store Image
                    Image.network(widget.imageUrl,
                        fit: BoxFit.cover, height: 120, width: double.infinity),

                    // Favorite Icon (Top-right corner)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: toggleFavorite,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                // Store Name and Distance
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.productName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text("${widget.price.toString()} km",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Delete button for Favorites screen
            if (widget.screenType == 'Favorites')
              Positioned(
                bottom: 0,
                right: 50,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (widget.onRemoveFromCart != null)
                      widget.onRemoveFromCart!();
                  },
                ),
              ),
            // Location icon (bottom-right corner)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _openDirections,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
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
        ),
      ),
    );
  }
}