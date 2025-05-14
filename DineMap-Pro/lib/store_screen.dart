import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/store/store_cubit.dart';
import 'cubits/store/store_state.dart';
import 'custom_widgets/product_card.dart';
import 'models/store.dart'; // Import the Store model
import 'models/product.dart'; // Import the Product model

class StoreScreen extends StatefulWidget {
  final int storeID;
  //final String? distance;

  const StoreScreen({super.key, required this.storeID});

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<StoreScreen> {
  // final List<LatLng> _routePoints = [];
  // final MapController _mapController = MapController();

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

        final storeCubit = context.read<StoreCubit>();
        final Store? store = storeCubit.getStoreById(widget.storeID); // Explicitly type as Store?
        final List<Product> productList = storeCubit.getStoreProducts(widget.storeID); // Explicitly type as List<Product>

        if (store == null) {
          return Scaffold(body: Center(child: Text('Store not found!')));
        }

        // Calculate distance using the cubit
        // final double storeLat = store.latitude; // Access using dot notation
        // final double storeLng = store.longitude; // Access using dot notation
        // final distance = storeCubit.calculateDistance(storeLat, storeLng);

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
                    store.imageUrl, // Access using dot notation
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
                        store.restaurantName, // Access using dot notation
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.address, // Access using dot notation
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        store.description, // Access using dot notation
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
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio:
                    0.7, // Adjusted for product cards which are usually taller
                  ),
                  delegate: SliverChildBuilderDelegate((
                      context,
                      index,
                      ) {
                    Product product = productList[index]; // Access as Product object

                    int productID = product.restaurantID; // Access using dot notation
                    String productName = product.productName; // Access using dot notation
                    String imageUrl = product.imageUrl; // Access using dot notation
                    double price = product.price; // Access using dot notation

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