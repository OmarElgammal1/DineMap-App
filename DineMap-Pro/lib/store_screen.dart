import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart'; // Keep if using flutter_map in this screen
// import 'package:latlong2/latlong.dart'; // Keep if using flutter_map in this screen
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
    // This ensures the distance is calculated correctly on this screen
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

        // StoreScreen needs access to the loaded data to find the specific store.
        // It should work with either StoresLoaded or StoreSearchResultsLoaded
        // because getStoreById now uses _allStores which holds all data.
        if (state is! StoresLoaded && state is! StoreSearchResultsLoaded && state is! StoreSearchEmpty) {
             // Show loading if data is not in a loaded state yet.
             // If it's loading or initial, show progress.
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final storeCubit = context.read<StoreCubit>();
        // getStoreById now works with the full list (_allStores) regardless of the state type
        final Store? store = storeCubit.getStoreById(widget.storeID);
        // getStoreProducts also uses getStoreById which uses _allStores
        final List<Product> productList = storeCubit.getStoreProducts(widget.storeID);

        if (store == null) {
          // This could happen if the storeID is invalid or _allStores is empty
          // This state should ideally not be reached if the navigation was based on existing store data
          return const Scaffold(body: Center(child: Text('Store not found!')));
        }

        // Calculate distance using the cubit
        final double storeLat = store.latitude; // Access using dot notation
        final double storeLng = store.longitude; // Access using dot notation
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
                  // When navigating back, no specific action needed in cubit
                  // as the state is already managed correctly.
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.address, // Access using dot notation
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                           Text(
                            '${distance.toStringAsFixed(1)} km', // Display calculated distance
                             style: const TextStyle(
                               color: Colors.grey,
                               fontSize: 16,
                             ),
                           ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                       // Assuming your Store model has a description field
                      Text(
                        store.description, // Access using dot notation
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
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

                    int productID = product.restaurantID; // Corrected to use product.id
                    String productName = product.productName; // Corrected to use product.name
                    String imageUrl = product.imageUrl; // Corrected to use product.image_url
                    double price = product.price; // Corrected to use product.price

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