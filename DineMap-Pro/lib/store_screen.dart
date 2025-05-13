import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';

class StoreScreen extends StatefulWidget {
  final int id;
  final String? distance;

  StoreScreen({required this.id, this.distance});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<StoreScreen> {
  final List<LatLng> _routePoints = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Update current position when screen loads using the cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreCubit>().updateCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        if (state is! StoresLoaded) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final storesLoaded = state as StoresLoaded;
        final storeCubit = context.read<StoreCubit>();
        final store = storeCubit.getStoreById(widget.id);

        if (store == null) {
          return Scaffold(body: Center(child: Text('Store not found!')));
        }

        final double storeLat = store['latitude'];
        final double storeLng = store['longitude'];

        // Calculate distance using the cubit
        final distance = storeCubit.calculateDistance(storeLat, storeLng);

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
      },
    );
  }
}