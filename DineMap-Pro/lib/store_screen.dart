import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_widgets/product_card.dart';
import 'providers/store_provider.dart';

class StoreScreen extends StatelessWidget {
  final int storeId;

  const StoreScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    // storeProvider.getStoreProducts(storeId) returns List<Map<String, Object>> as per the error.
    // We will cast it to List<Map<String, dynamic>> for easier handling.
    List<dynamic> rawProducts = storeProvider.getStoreProducts(storeId) as List;
    List<Map<String, dynamic>> productList =
        rawProducts
            .map((product) => Map<String, dynamic>.from(product as Map))
            .toList();

    var store = storeProvider.getStoreById(storeId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                store!['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['restaurantName'],
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
                  Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    store['description'],
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(15.0),
            sliver:
                productList.isEmpty
                    ? const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'No products available',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                    : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio:
                            0.7, // Adjusted for product cards which are usually taller
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // productList is now List<Map<String, dynamic>>
                        Map<String, dynamic> product = productList[index];

                        int productID = product['productID'] as int;
                        String productName = product['productName'] as String;
                        String imageUrl = product['imageUrl'] as String;
                        double price = product['price'];

                        return ProductCard(
                          id: productID,
                          productName: productName,
                          imageUrl: imageUrl,
                          price: price,
                        );
                      }, childCount: productList.length),
                    ),
          ),
        ],
      ),
    );
  }
}
