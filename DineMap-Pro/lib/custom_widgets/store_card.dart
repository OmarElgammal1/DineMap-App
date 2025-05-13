import 'package:flutter/material.dart';
import '../store_screen.dart';

class StoreCard extends StatelessWidget {
  final int id;
  final String storeName;
  final String imageUrl;
  final String district;

  const StoreCard({
    super.key,
    required this.id,
    required this.storeName,
    required this.imageUrl,
    required this.district,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreScreen(storeID: id)),
        );
      },
      child: Card(
        margin: EdgeInsets.all(4.0),
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 120,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Container(
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Text(
                          district,
                          overflow: TextOverflow.visible,
                          style: TextStyle(color: Colors.grey),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
