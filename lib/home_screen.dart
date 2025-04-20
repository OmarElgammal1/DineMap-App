import 'package:flutter/material.dart';
import 'custom_widgets/product_card.dart';
import 'models/data.dart';

class HomeScreen extends StatelessWidget {
  final String screenType;

  HomeScreen({required this.screenType});

  @override
  Widget build(BuildContext context) {
    var storeList = stores.entries.toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: false,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[700]),
                  SizedBox(width: 10.0),
                  Text(
                    'Search Stores',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          expandedHeight: 80.0,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(13.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              var storeEntry = storeList[index];
              var store = storeEntry.value;

              return ProductCard(
                id: storeEntry.key,
                productName: store['storeName'],
                imageUrl: store['imageUrl'],
                price: store['distance'],
                isFavorite: store['isFavorite'],
                screenType: screenType,
                onAddToCart: () {
                  print('${store['storeName']} selected');
                },
                onRemoveFromCart: () {
                  print('${store['storeName']} removed from favorites');
                },
              );
            }, childCount: storeList.length),
          ),
        ),
      ],
    );
  }
}
